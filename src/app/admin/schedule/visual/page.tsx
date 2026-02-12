import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { ensureNextThreeWeeks, ensureSlotsForWeek } from "@/lib/weeks";
import { prisma } from "@/lib/db";
import { addDays, formatDateInTimeZone, mondayIndex } from "@/lib/date";
import TopBar from "@/components/TopBar";
import WeekSelector from "@/components/WeekSelector";
import Link from "next/link";

type VisualPageProps = {
  searchParams?: Promise<{ week?: string }>;
};

export const dynamic = "force-dynamic";

type PreferenceChoice = "WANT" | "CAN" | "CANT";

export default async function VisualSchedulePage({ searchParams }: VisualPageProps) {
  const resolvedSearchParams = searchParams ? await searchParams : undefined;
  const user = await getCurrentUser();
  if (!user) redirect("/admin/login");
  if (user.role !== "ADMIN") redirect("/home");

  const weeks = await ensureNextThreeWeeks();
  type Week = (typeof weeks)[number];
  const selectedStart = resolvedSearchParams?.week;
  const weekKey = (d: Date) => formatDateInTimeZone(d, "America/Vancouver");
  const week =
    weeks.find((w: Week) => weekKey(w.startDate) === selectedStart) ??
    weeks[0];
  if (!week) {
    return (
      <main className="page">
        <h1>Visual Schedule</h1>
        <p className="subtext">No schedulable week.</p>
      </main>
    );
  }

  await ensureSlotsForWeek(week.id);

  const employees = await prisma.user.findMany({
    where: { role: "EMPLOYEE" },
    include: { roleType: true },
    orderBy: { name: "asc" },
  });
  type Employee = (typeof employees)[number];

  const [slots, preferences, templates, roleTypes] = await Promise.all([
    prisma.shiftSlot.findMany({
      where: { weekId: week.id },
      include: { assignment: true, roleType: true },
      orderBy: [{ date: "asc" }, { startAt: "asc" }],
    }),
    prisma.preference.findMany({
      where: { shiftSlot: { weekId: week.id } },
      select: { userId: true, shiftSlotId: true, choice: true },
    }),
    prisma.availabilityTemplate.findMany({
      where: { userId: { in: employees.map((e) => e.id) } },
      select: {
        userId: true,
        roleTypeId: true,
        dayOfWeek: true,
        startTime: true,
        endTime: true,
        choice: true,
      },
    }),
    prisma.roleType.findMany({ orderBy: { name: "asc" } }),
  ]);

  type Slot = (typeof slots)[number];
  type RoleType = (typeof roleTypes)[number];

  const preferenceMap = new Map(
    preferences.map((p) => [`${p.userId}-${p.shiftSlotId}`, p.choice as PreferenceChoice])
  );
  const templateMap = new Map(
    templates.map((t) => [
      `${t.userId}-${t.roleTypeId}-${t.dayOfWeek}-${t.startTime}-${t.endTime}`,
      t.choice as PreferenceChoice,
    ])
  );

  const slotsByDay = new Map<number, Slot[]>();
  for (const slot of slots) {
    const day = mondayIndex(slot.date);
    const list = slotsByDay.get(day) ?? [];
    list.push(slot);
    slotsByDay.set(day, list);
  }

  const groupedEmployees: { role: RoleType | null; employees: Employee[] }[] = [];
  for (const role of roleTypes) {
    const list = employees.filter((e) => e.roleTypeId === role.id);
    if (list.length) groupedEmployees.push({ role, employees: list });
  }
  const noRole = employees.filter((e) => !e.roleTypeId);
  if (noRole.length) groupedEmployees.push({ role: null, employees: noRole });

  const getStatus = (slot: Slot, employee: Employee) => {
    if (slot.assignment?.userId === employee.id) return "assigned";
    const start = slot.startAt.toTimeString().slice(0, 5);
    const end = slot.endAt.toTimeString().slice(0, 5);
    const key = `${employee.id}-${slot.roleTypeId}-${mondayIndex(slot.date)}-${start}-${end}`;
    const pref =
      preferenceMap.get(`${employee.id}-${slot.id}`) ??
      templateMap.get(key);
    if (pref === "CANT") return "cant";
    if (pref === "WANT" || pref === "CAN") return "can";
    return "none";
  };

  const dayStartMinutes = 10 * 60;
  const dayEndMinutes = 24 * 60;
  const getBarStyle = (slot: Slot) => {
    let startMinutes = slot.startAt.getHours() * 60 + slot.startAt.getMinutes();
    let endMinutes = slot.endAt.getHours() * 60 + slot.endAt.getMinutes();
    if (endMinutes <= startMinutes) endMinutes = dayEndMinutes;

    const clippedStart = Math.max(startMinutes, dayStartMinutes);
    const clippedEnd = Math.min(endMinutes, dayEndMinutes);
    if (clippedEnd <= dayStartMinutes) return { left: "0%", width: "0%" };

    const range = dayEndMinutes - dayStartMinutes;
    const left = ((clippedStart - dayStartMinutes) / range) * 100;
    const width = Math.max(2, ((clippedEnd - clippedStart) / range) * 100);
    return { left: `${left}%`, width: `${width}%` };
  };

  return (
    <>
      <TopBar name={user.name} role={user.role} roleLabel="Admin" />
      <main className="page-with-topbar">
        <header className="page-header">
          <div>
            <h1>Visual Schedule</h1>
            <p className="subtext">
              Week of{" "}
              {new Intl.DateTimeFormat("en-US", {
                timeZone: "America/Vancouver",
                year: "numeric",
                month: "short",
                day: "numeric",
              }).format(week.startDate)}
            </p>
          </div>
          <div className="header-actions">
            <WeekSelector
              path="/admin/schedule/visual"
              value={weekKey(week.startDate)}
              options={weeks.map((w: Week) => {
                const start = w.startDate;
                const end = addDays(start, 6);
                const label = `${new Intl.DateTimeFormat("en-US", {
                  timeZone: "America/Vancouver",
                  month: "short",
                  day: "numeric",
                }).format(start)} - ${new Intl.DateTimeFormat("en-US", {
                  timeZone: "America/Vancouver",
                  month: "short",
                  day: "numeric",
                }).format(end)}`;
                return { value: weekKey(start), label };
              })}
            />
            <Link className="ghost-button" href={`/admin/schedule?week=${weekKey(week.startDate)}`}>
              Back to Scheduling
            </Link>
          </div>
        </header>

        <section className="card visual-card">
          <div
            className="visual-grid"
            style={{ gridTemplateColumns: `160px repeat(7, minmax(140px, 1fr))` }}
          >
            <div className="visual-header">Employee</div>
            {[0, 1, 2, 3, 4, 5, 6].map((dayIndex) => {
              const date = addDays(week.startDate, dayIndex);
              const weekDay = date.toLocaleDateString(undefined, {
                weekday: "short",
              });
              const dateLabel = date.toLocaleDateString(undefined, {
                month: "short",
                day: "numeric",
              });
              return (
                <div key={`day-${dayIndex}`} className="visual-header">
                  <span className="day-week">{weekDay}</span>
                  <span className="day-date">{dateLabel}</span>
                </div>
              );
            })}

            {groupedEmployees.map((group) => (
              <div key={group.role?.id ?? "no-role"} className="visual-group">
                <div className="visual-group-label">
                  {group.role?.name ?? "No Role"}
                </div>
                {group.employees.map((employee) => {
                  const isManager = employee.roleType?.name === "Manager";
                  return (
                    <div key={employee.id} className="visual-row">
                      <div className="visual-employee">
                        <div className="visual-name">{employee.name}</div>
                        <div className="subtext">
                          {employee.roleType?.name ?? "No role"}
                        </div>
                      </div>
                      {[0, 1, 2, 3, 4, 5, 6].map((dayIndex) => {
                        const daySlots = (slotsByDay.get(dayIndex) ?? []).filter(
                          (slot) =>
                            isManager || slot.roleTypeId === employee.roleTypeId
                        );
                        return (
                          <div key={`${employee.id}-${dayIndex}`} className="visual-cell">
                            {daySlots.length === 0 ? (
                              <div className="visual-empty">—</div>
                            ) : (
                              <div className="visual-bars">
                                {daySlots.map((slot) => {
                                  const status = getStatus(slot, employee);
                                  const style = getBarStyle(slot);
                                  const label = `${slot.startAt.toTimeString().slice(0, 5)}-${slot.endAt
                                    .toTimeString()
                                    .slice(0, 5)} ${slot.roleType.name}`;
                                  return (
                                    <div key={slot.id} className="visual-bar-track">
                                      <div
                                        className={`visual-bar visual-${status}`}
                                        style={style}
                                        title={label}
                                      />
                                    </div>
                                  );
                                })}
                              </div>
                            )}
                          </div>
                        );
                      })}
                    </div>
                  );
                })}
              </div>
            ))}
          </div>
        </section>
      </main>
    </>
  );
}
