import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { prisma } from "@/lib/db";
import {
  formatDateTime,
  formatShortDate,
  formatTime,
  getServerNowMs,
  pairPunches,
} from "@/lib/timeclock";
import CheckinForm from "./CheckinForm";

export const dynamic = "force-dynamic";

export const metadata = {
  title: "Clock In / Out · Shifts",
  description: "Tap the NFC tag in store to clock in or out.",
};

const THIRTY_DAYS_MS = 30 * 24 * 3_600_000;

export default async function CheckinPage() {
  const user = await getCurrentUser();
  if (!user) redirect("/login?next=/checkin");

  const serverNow = getServerNowMs();
  const since = new Date(serverNow - THIRTY_DAYS_MS);

  const [last, recentPunches] = await Promise.all([
    prisma.timeClock.findFirst({
      where: { userId: user.id },
      orderBy: { punchedAt: "desc" },
    }),
    prisma.timeClock.findMany({
      where: {
        userId: user.id,
        shiftTime: { gte: since },
      },
      orderBy: { shiftTime: "asc" },
    }),
  ]);

  // Suggest the opposite of the last punch if it was within the last 16 hours.
  const recent = last && serverNow - last.punchedAt.getTime() < 16 * 3_600_000;
  const suggested: "IN" | "OUT" = recent && last.action === "IN" ? "OUT" : "IN";

  // Pair punches into work periods and reverse so most recent is at the top.
  const periods = pairPunches(recentPunches).reverse();
  const totalHours = periods.reduce((sum, p) => sum + (p.hours ?? 0), 0);

  return (
    <main className="page-center checkin-page">
      <div className="checkin-stack">
        <div className="checkin-card">
          <p className="checkin-eyebrow">Kongfu Cat · Time Clock</p>
          <h1>Hi, {user.name}</h1>
          {last ? (
            <p className="subtext">
              Last: {last.action === "IN" ? "Clock In" : "Clock Out"} ·{" "}
              {formatDateTime(last.shiftTime)}
            </p>
          ) : (
            <p className="subtext">No check-ins yet.</p>
          )}
          <CheckinForm serverNow={serverNow} suggested={suggested} />
        </div>

        <section className="checkin-history-card" aria-label="Last 30 days history">
          <div className="checkin-history-header">
            <div>
              <h2>History (Last 30 Days)</h2>
              <p className="subtext">Most recent at top</p>
            </div>
            <div className="checkin-history-total">
              {totalHours.toFixed(2)} h
            </div>
          </div>

          {periods.length === 0 ? (
            <p className="subtext">No hours recorded in the last 30 days.</p>
          ) : (
            <div className="checkin-history-list">
              {periods.map((p, idx) => {
                const anchor = p.in?.shiftTime ?? p.out?.shiftTime;
                const dateLabel = anchor ? formatShortDate(anchor) : "—";
                const inLabel = p.in ? formatTime(p.in.shiftTime) : "Missing";
                const outLabel = p.out ? formatTime(p.out.shiftTime) : "In progress";
                const isIncomplete = p.hours === null;
                return (
                  <div
                    key={p.in?.id ?? p.out?.id ?? idx}
                    className={`checkin-history-row${isIncomplete ? " is-incomplete" : ""}`}
                  >
                    <div className="checkin-history-date">{dateLabel}</div>
                    <div className="checkin-history-times">
                      <span className={p.in ? "" : "checkin-history-warn"}>{inLabel}</span>
                      <span className="checkin-history-arrow">→</span>
                      <span className={p.out ? "" : "checkin-history-warn"}>{outLabel}</span>
                    </div>
                    <div className="checkin-history-hours">
                      {p.hours === null ? "—" : `${p.hours.toFixed(2)} h`}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </section>
      </div>
    </main>
  );
}
