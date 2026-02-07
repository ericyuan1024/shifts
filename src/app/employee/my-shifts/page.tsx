import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { prisma } from "@/lib/db";
import { addDays, formatDateInTimeZone } from "@/lib/date";
import { ensureNextThreeWeeks } from "@/lib/weeks";
import TopBar from "@/components/TopBar";
import WeekSelector from "@/components/WeekSelector";

type MyShiftsPageProps = {
  searchParams?: Promise<{ week?: string }>;
};

export const dynamic = "force-dynamic";

export default async function MyShiftsPage({ searchParams }: MyShiftsPageProps) {
  const user = await getCurrentUser();
  if (!user) redirect("/login");

  const resolvedSearchParams = searchParams ? await searchParams : undefined;
  const selectedStart = resolvedSearchParams?.week;

  const weeks = await ensureNextThreeWeeks();
  type Week = (typeof weeks)[number];
  const weekKey = (d: Date) => formatDateInTimeZone(d, "America/Vancouver");
  const week =
    weeks.find((w: Week) => weekKey(w.startDate) === selectedStart) ?? weeks[0];

  if (!week) {
    return (
      <>
        <TopBar
          name={user.name}
          role={user.role}
          roleLabel={user.roleType?.name ?? "Employee"}
        />
        <main className="page-with-topbar">
          <section className="empty-state">
            <h2>No weeks available</h2>
            <p>Please check back later.</p>
          </section>
        </main>
      </>
    );
  }

  const slots = await prisma.shiftSlot.findMany({
    where: { weekId: week.id },
    include: {
      roleType: true,
      assignment: { include: { user: true } },
      week: { include: { schedule: true } },
    },
    orderBy: [{ date: "asc" }, { startAt: "asc" }],
  });

  type Slot = (typeof slots)[number];
  const roleTypeMap = new Map<string, Slot["roleType"]>();
  slots.forEach((slot: Slot) => {
    if (!roleTypeMap.has(slot.roleTypeId)) {
      roleTypeMap.set(slot.roleTypeId, slot.roleType);
    }
  });
  const roleTypes = Array.from(roleTypeMap.values());

  const isFinalized = week.schedule?.status === "FINALIZED";

  return (
    <>
      <TopBar
        name={user.name}
        role={user.role}
        roleLabel={user.roleType?.name ?? "Employee"}
      />
      <main className="page-with-topbar">
        <header className="page-header">
          <div>
            <h1>My Final Shifts</h1>
            <p className="subtext">
              {isFinalized
                ? "Finalized schedule for the selected week."
                : "This week is not finalized yet."}
            </p>
          </div>
          <WeekSelector
            path="/employee/my-shifts"
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

        {slots.length === 0 ? (
          <section className="empty-state">
            <h2>No shifts for this week</h2>
            <p>Ask your admin to configure templates.</p>
          </section>
        ) : (
          <section className="schedule-matrix">
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
              const weekDay = new Intl.DateTimeFormat("en-US", {
                timeZone: "America/Vancouver",
                weekday: "short",
              }).format(date);
              const dateLabel = new Intl.DateTimeFormat("en-US", {
                timeZone: "America/Vancouver",
                month: "short",
                day: "numeric",
              }).format(date);

              return (
                <div
                  key={`row-${dayIndex}`}
                  className="matrix-row"
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
                      return (
                        <div key={role.id} className="matrix-cell empty">
                          —
                        </div>
                      );
                    }

                    return (
                      <div key={role.id} className="matrix-cell">
                        {daySlots.map((slot: Slot) => {
                          const assignedUser = slot.assignment?.user;
                          const isSelf = assignedUser?.id === user.id;
                          return (
                            <div
                              key={slot.id}
                              className={`matrix-slot${isSelf ? " self" : ""}`}
                            >
                              <div className="matrix-time">
                                {slot.startAt.toTimeString().slice(0, 5)} -{" "}
                                {slot.endAt.toTimeString().slice(0, 5)}
                              </div>
                              <div className="badge">
                                {assignedUser?.name ?? "Unassigned"}
                              </div>
                            </div>
                          );
                        })}
                      </div>
                    );
                  })}
                </div>
              );
            })}
          </section>
        )}
      </main>
    </>
  );
}
