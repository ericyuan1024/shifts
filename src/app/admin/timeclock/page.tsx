import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { prisma } from "@/lib/db";
import TopBar from "@/components/TopBar";
import {
  formatDateTime,
  formatTime,
  localDateString,
  pairPunches,
  zonedMidnight,
  type WorkPeriod,
} from "@/lib/timeclock";

export const dynamic = "force-dynamic";

type Search = { from?: string; to?: string; user?: string };
const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;

function defaultRange() {
  const today = localDateString(new Date());
  const noon = new Date(`${today}T12:00:00Z`);
  const mondayOffset = (noon.getUTCDay() + 6) % 7;
  const monday = new Date(noon.getTime() - mondayOffset * 86_400_000);
  const sunday = new Date(monday.getTime() + 6 * 86_400_000);
  return { from: monday.toISOString().slice(0, 10), to: sunday.toISOString().slice(0, 10) };
}

function addOneDay(dateStr: string) {
  const d = new Date(`${dateStr}T12:00:00Z`);
  d.setUTCDate(d.getUTCDate() + 1);
  return d.toISOString().slice(0, 10);
}

function diffLabel(shiftTime: Date, punchedAt: Date) {
  const mins = Math.round((punchedAt.getTime() - shiftTime.getTime()) / 60_000);
  if (mins === 0) return "on time";
  return `${mins > 0 ? "+" : ""}${mins} min`;
}

export default async function TimeClockPage({ searchParams }: { searchParams: Promise<Search> }) {
  const user = await getCurrentUser();
  if (!user) redirect("/admin/login");
  if (user.role !== "ADMIN") redirect("/home");

  const sp = await searchParams;
  const def = defaultRange();
  const from = sp.from && DATE_RE.test(sp.from) ? sp.from : def.from;
  const to = sp.to && DATE_RE.test(sp.to) ? sp.to : def.to;
  const userFilter = sp.user || "";

  const [people, punches] = await Promise.all([
    prisma.user.findMany({ orderBy: { name: "asc" }, select: { id: true, name: true } }),
    prisma.timeClock.findMany({
      where: {
        shiftTime: { gte: zonedMidnight(from), lt: zonedMidnight(addOneDay(to)) },
        ...(userFilter ? { userId: userFilter } : {}),
      },
      include: { user: { select: { id: true, name: true } } },
      orderBy: { shiftTime: "asc" },
    }),
  ]);
  type PunchRow = (typeof punches)[number];

  const byUser = new Map<string, { name: string; rows: PunchRow[] }>();
  for (const p of punches) {
    const entry = byUser.get(p.userId) ?? { name: p.user.name, rows: [] };
    entry.rows.push(p);
    byUser.set(p.userId, entry);
  }
  const groups = [...byUser.values()]
    .sort((a, b) => a.name.localeCompare(b.name))
    .map((g) => {
      const periods = pairPunches(g.rows) as (WorkPeriod & { in: PunchRow | null; out: PunchRow | null })[];
      const total = periods.reduce((sum, p) => sum + (p.hours ?? 0), 0);
      const issues = periods.filter((p) => p.hours === null).length;
      return { ...g, periods, total, issues };
    });

  return (
    <>
      <TopBar name={user.name} role={user.role} roleLabel="Admin" />
      <main className="page-with-topbar">
        <header className="page-header">
          <div>
            <h1>Time Clock</h1>
            <p className="subtext">
              NFC check-ins. Hours use the employee-confirmed shift times.
            </p>
          </div>
        </header>

        <form className="card timeclock-filter" method="get">
          <label>
            From
            <input id="tc-from" type="date" name="from" defaultValue={from} />
          </label>
          <label>
            To
            <input id="tc-to" type="date" name="to" defaultValue={to} />
          </label>
          <label>
            Employee
            <select id="tc-user" name="user" defaultValue={userFilter}>
              <option value="">All</option>
              {people.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name}
                </option>
              ))}
            </select>
          </label>
          <button id="tc-apply" type="submit" className="primary">
            Apply
          </button>
        </form>

        {groups.length === 0 ? (
          <section className="card" style={{ marginTop: 20 }}>
            <p className="subtext">No check-ins in this range.</p>
          </section>
        ) : (
          groups.map((g) => (
            <section className="card timeclock-group" key={g.name}>
              <div className="timeclock-group-head">
                <h2>{g.name}</h2>
                <div className="timeclock-total">
                  {g.total.toFixed(2)} h
                  {g.issues > 0 ? (
                    <span className="badge timeclock-warn">{g.issues} unmatched</span>
                  ) : null}
                </div>
              </div>
              <div className="timeclock-table-wrap">
                <table className="timeclock-table">
                  <thead>
                    <tr>
                      <th>Clock In</th>
                      <th>Clock Out</th>
                      <th>Hours</th>
                    </tr>
                  </thead>
                  <tbody>
                    {g.periods.map((p, i) => (
                      <tr key={p.in?.id ?? p.out?.id ?? i} className={p.hours === null ? "is-warn" : ""}>
                        {[p.in, p.out].map((punch, j) => (
                          <td key={j}>
                            {punch ? (
                              <>
                                <div>{j === 0 ? formatDateTime(punch.shiftTime) : formatTime(punch.shiftTime)}</div>
                                <div className="timeclock-meta" title={`${punch.ip ?? ""} ${punch.userAgent ?? ""}`}>
                                  punched {formatTime(punch.punchedAt)} · {diffLabel(punch.shiftTime, punch.punchedAt)}
                                </div>
                              </>
                            ) : (
                              <span className="timeclock-missing">missing</span>
                            )}
                          </td>
                        ))}
                        <td>{p.hours === null ? "—" : p.hours.toFixed(2)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </section>
          ))
        )}
      </main>
    </>
  );
}
