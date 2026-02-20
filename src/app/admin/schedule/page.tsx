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
import AutoSubmitSelect from "@/components/AutoSubmitSelect";
import Link from "next/link";

type AdminSchedulePageProps = {
  searchParams?: Promise<{ week?: string; notice?: string }>;
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
  type Week = (typeof weeks)[number];
  const selectedStart = resolvedSearchParams?.week;
  const notice = resolvedSearchParams?.notice;
  const weekKey = (d: Date) => formatDateInTimeZone(d, "America/Vancouver");
  const week =
    weeks.find((w: Week) => weekKey(w.startDate) === selectedStart) ??
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

  const [schedule, slots, employees, preferences] = await Promise.all([
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
    prisma.preference.findMany({
      where: { shiftSlot: { weekId: week.id } },
      select: { userId: true, shiftSlotId: true, choice: true },
    }),
  ]);

  type Slot = (typeof slots)[number];
  const roleTypeMap = new Map<string, Slot["roleType"]>();
  slots.forEach((slot: Slot) => {
    if (!roleTypeMap.has(slot.roleTypeId)) {
      roleTypeMap.set(slot.roleTypeId, slot.roleType);
    }
  });
  const roleTypes = Array.from(roleTypeMap.values());

  const hoursByEmployee = new Map<string, { id: string; name: string; hours: number }>();
  slots.forEach((slot: Slot) => {
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
  const preferenceMap = new Map(
    preferences.map((p) => [`${p.userId}-${p.shiftSlotId}`, p.choice])
  );
  const choiceDot = (choice: string) => (choice === "CANT" ? "🔴" : "🟢");
  const choiceLabel = (choice: string) =>
    choice === "WANT" ? "Want" : choice === "CANT" ? "Can't" : "Can";

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
        </header>

        <div className="toolbar">
          <AdminScheduleActions weekId={week.id} />
          <div className="toolbar-actions">
            <Link
              className="ghost-button"
              href={`/admin/schedule/visual?week=${weekKey(week.startDate)}`}
            >
              Visual
            </Link>
            {schedule?.generatedAt ? <PreviewHours items={hoursPreview} /> : null}
          </div>
        </div>
        {notice ? <p className="error">{notice}</p> : null}

        <section className="card">
          <h2>Current Schedule</h2>
          {slots.length === 0 ? (
            <p className="subtext">No templates or slots.</p>
          ) : (
            <div className="schedule-matrix">
              <div
                className="matrix-header"
                style={{
                  gridTemplateColumns: `60px repeat(${roleTypes.length}, minmax(135px, 1fr))`,
                }}
              >
                <div>Day</div>
                {roleTypes.map((role: Slot["roleType"]) => (
                  <div key={role.id}>{role.name}</div>
                ))}
              </div>
              {[0, 1, 2, 3, 4, 5, 6].map((dayIndex) => {
                const date = addDays(week.startDate, dayIndex);
                const weekDay = date.toLocaleDateString(undefined, {
                  weekday: "short",
                });
                const dateLabel = date.toLocaleDateString(undefined, {
                  month: "short",
                  day: "numeric",
                });
                const rowClass = dayIndex % 2 === 0 ? "matrix-alt-a" : "matrix-alt-b";

                return (
                  <div
                    key={`row-${dayIndex}`}
                    className={`matrix-row ${rowClass}`}
                    style={{
                      gridTemplateColumns: `60px repeat(${roleTypes.length}, minmax(135px, 1fr))`,
                    }}
                  >
                    <div className="matrix-day">
                      <span className="day-week">{weekDay}</span>
                      <span className="day-date">{dateLabel}</span>
                    </div>
                  {roleTypes.map((role: Slot["roleType"]) => {
                    const daySlots = slots.filter((slot: Slot) => {
                      const slotDay = new Date(slot.date).getDay();
                      const mondayIndex = (slotDay + 6) % 7;
                      return mondayIndex === dayIndex && slot.roleTypeId === role.id;
                    });

                      if (daySlots.length === 0) {
                        return <div key={role.id} className="matrix-cell empty">—</div>;
                      }

                      return (
                        <div key={role.id} className="matrix-cell">
                        {daySlots.map((slot: Slot) => {
                          type Employee = (typeof employees)[number];
                          const availableEmployees = employees.filter(
                            (e: Employee) =>
                              e.roleTypeId === slot.roleTypeId ||
                              e.roleType?.name === "Manager"
                          );

                            return (
                              <form
                                key={slot.id}
                                action={updateAssignmentAction}
                                className="matrix-slot"
                                id={`assign-${slot.id}`}
                              >
                                <input type="hidden" name="shiftSlotId" value={slot.id} />
                                <div className="matrix-time">
                                  {slot.startAt.toTimeString().slice(0, 5)} -{" "}
                                  {slot.endAt.toTimeString().slice(0, 5)}
                                </div>
                                <div className="row-actions">
                                  <AutoSubmitSelect
                                    key={`${slot.id}-${slot.assignment?.userId ?? ""}`}
                                    formId={`assign-${slot.id}`}
                                    name="userId"
                                    defaultValue={slot.assignment?.userId ?? ""}
                                    options={[
                                      { value: "", label: "Select employee" },
                                      ...availableEmployees.map((employee: Employee) => {
                                        const pref =
                                          preferenceMap.get(`${employee.id}-${slot.id}`) ??
                                          "CAN";
                                        const label = `${choiceDot(pref)} ${employee.name} (${choiceLabel(pref)})`;
                                        return { value: employee.id, label };
                                      }),
                                    ]}
                                  />
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
