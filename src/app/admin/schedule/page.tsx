import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { ensureNextThreeWeeks, ensureSlotsForWeek } from "@/lib/weeks";
import { prisma } from "@/lib/db";
import { addDays, formatDateInTimeZone } from "@/lib/date";
import AdminScheduleActions from "./AdminScheduleActions";
import { updateAssignmentAction } from "./actions";
import TopBar from "@/components/TopBar";
import PreviewHours from "./PreviewHours";
import WeekSelector from "@/components/WeekSelector";

type AdminSchedulePageProps = {
  searchParams?: Promise<{ week?: string }>;
};

export const dynamic = "force-dynamic";

export default async function AdminSchedulePage({
  searchParams,
}: AdminSchedulePageProps) {
  const resolvedSearchParams = searchParams ? await searchParams : undefined;
  const user = await getCurrentUser();
  if (!user) redirect("/admin/login");
  if (user.role !== "ADMIN") redirect("/home");

  const weeks = await ensureNextThreeWeeks();
  const selectedStart = resolvedSearchParams?.week;
  const weekKey = (d: Date) => formatDateInTimeZone(d, "America/Vancouver");
  const week =
    weeks.find((w: (typeof weeks)[number]) => weekKey(w.startDate) === selectedStart) ??
    weeks[0];
  if (!week) {
    return (
      <main className="page">
        <h1>Admin Scheduling</h1>
        <p className="subtext">No schedulable week.</p>
      </main>
    );
  }

  await ensureSlotsForWeek(week.id);

  const [schedule, slots, employees] = await Promise.all([
    prisma.schedule.findUnique({ where: { weekId: week.id } }),
    prisma.shiftSlot.findMany({
      where: { weekId: week.id },
      include: {
        roleType: true,
        assignment: { include: { user: true } },
      },
      orderBy: [{ date: "asc" }, { startAt: "asc" }],
    }),
    prisma.user.findMany({
      where: { role: "EMPLOYEE" },
      include: { roleType: true },
      orderBy: { name: "asc" },
    }),
  ]);

  const roleTypes = Array.from(
    new Map(slots.map((slot) => [slot.roleTypeId, slot.roleType])).values()
  );

  const hoursByEmployee = new Map<string, { id: string; name: string; hours: number }>();
  slots.forEach((slot) => {
    if (!slot.assignment?.user) return;
    const existing = hoursByEmployee.get(slot.assignment.user.id) ?? {
      id: slot.assignment.user.id,
      name: slot.assignment.user.name,
      hours: 0,
    };
    existing.hours += slot.hours;
    hoursByEmployee.set(existing.id, existing);
  });
  const hoursPreview = Array.from(hoursByEmployee.values()).sort(
    (a, b) => b.hours - a.hours
  );

  return (
    <>
      <TopBar name={user.name} role={user.role} roleLabel="Admin" />
      <main className="page-with-topbar">
        <header className="page-header">
          <div>
            <h1>Admin Scheduling</h1>
            <p className="subtext">
              Week of{" "}
              {new Intl.DateTimeFormat("en-US", {
                timeZone: "America/Vancouver",
                year: "numeric",
                month: "short",
                day: "numeric",
              }).format(week.startDate)}{" "}
              | Status:{" "}
              {schedule?.status ?? "Not generated"}
            </p>
          </div>
          <WeekSelector
            path="/admin/schedule"
            value={weekKey(week.startDate)}
            options={weeks.map((w) => {
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
        </header>

        <div className="toolbar">
          <AdminScheduleActions weekId={week.id} />
          {schedule?.generatedAt ? <PreviewHours items={hoursPreview} /> : null}
        </div>

        <section className="card">
          <h2>Current Schedule</h2>
          {slots.length === 0 ? (
            <p className="subtext">No templates or slots.</p>
          ) : (
            <div className="schedule-matrix">
              <div
                className="matrix-header"
                style={{
                  gridTemplateColumns: `160px repeat(${roleTypes.length}, minmax(220px, 1fr))`,
                }}
              >
                <div>Day</div>
                {roleTypes.map((role) => (
                  <div key={role.id}>{role.name}</div>
                ))}
              </div>
              {[0, 1, 2, 3, 4, 5, 6].map((dayIndex) => {
                const date = addDays(week.startDate, dayIndex);
                const label = `${date.toLocaleDateString(undefined, {
                  weekday: "short",
                })} - ${date.toLocaleDateString(undefined, {
                  month: "short",
                  day: "numeric",
                })}`;

                return (
                  <div
                    key={`row-${dayIndex}`}
                    className="matrix-row"
                    style={{
                      gridTemplateColumns: `160px repeat(${roleTypes.length}, minmax(220px, 1fr))`,
                    }}
                  >
                    <div className="matrix-day">{label}</div>
                    {roleTypes.map((role) => {
                      const daySlots = slots.filter((slot) => {
                        const slotDay = new Date(slot.date).getDay();
                        const mondayIndex = (slotDay + 6) % 7;
                        return mondayIndex === dayIndex && slot.roleTypeId === role.id;
                      });

                      if (daySlots.length === 0) {
                        return <div key={role.id} className="matrix-cell empty">—</div>;
                      }

                      return (
                        <div key={role.id} className="matrix-cell">
                          {daySlots.map((slot) => {
                            const availableEmployees = employees.filter(
                              (e) =>
                                e.roleTypeId === slot.roleTypeId ||
                                e.roleType?.name === "Manager"
                            );

                            return (
                              <form
                                key={slot.id}
                                action={updateAssignmentAction}
                                className="matrix-slot"
                              >
                                <input type="hidden" name="shiftSlotId" value={slot.id} />
                                <div className="matrix-time">
                                  {slot.startAt.toTimeString().slice(0, 5)} -{" "}
                                  {slot.endAt.toTimeString().slice(0, 5)}
                                </div>
                                <div className="row-actions">
                                  <select
                                    name="userId"
                                    defaultValue={slot.assignment?.userId ?? ""}
                                  >
                                    <option value="" disabled>
                                      Select employee
                                    </option>
                                    {availableEmployees.map((employee) => (
                                      <option key={employee.id} value={employee.id}>
                                        {employee.name}
                                      </option>
                                    ))}
                                  </select>
                                  <button type="submit" className="ghost-button">
                                    Save
                                  </button>
                                </div>
                                <div className="badge">
                                  {slot.assignment?.user.name ?? "Unassigned"}
                                </div>
                              </form>
                            );
                          })}
                        </div>
                      );
                    })}
                  </div>
                );
              })}
            </div>
          )}
        </section>
      </main>
    </>
  );
}
