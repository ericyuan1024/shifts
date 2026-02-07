import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { ensureNextThreeWeeks, ensureSlotsForWeek } from "@/lib/weeks";
import { prisma } from "@/lib/db";
import { addDays, formatDateInTimeZone } from "@/lib/date";
import { syncFromTemplateAction, updatePreferenceAction } from "./actions";
import TopBar from "@/components/TopBar";
import WeekSelector from "@/components/WeekSelector";

const choiceLabels: Record<string, string> = {
  WANT: "Want",
  CAN: "Can",
  CANT: "Can't",
};

type PreferencesPageProps = {
  searchParams?: Promise<{ week?: string }>;
};

export const dynamic = "force-dynamic";

export default async function PreferencesPage({ searchParams }: PreferencesPageProps) {
  const user = await getCurrentUser();
  if (!user) redirect("/login");

  if (!user.roleTypeId) {
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
              <h1>Availability</h1>
              <p className="subtext">Ask an admin to assign your role first.</p>
            </div>
          </header>
        </main>
      </>
    );
  }

  const isManager = user.roleType?.name === "Manager";

  const resolvedSearchParams = searchParams ? await searchParams : undefined;
  const selectedStart = resolvedSearchParams?.week;

  const weeksAll = await ensureNextThreeWeeks();
  const weeks = weeksAll.slice(1, 3);
  await Promise.all(weeks.map((w) => ensureSlotsForWeek(w.id)));

  const weekKey = (d: Date) => formatDateInTimeZone(d, "America/Vancouver");
  const week =
    weeks.find((w) => weekKey(w.startDate) === selectedStart) ?? weeks[0];

  const slots = await prisma.shiftSlot.findMany({
    where: {
      weekId: week.id,
      ...(isManager ? {} : { roleTypeId: user.roleTypeId }),
    },
    include: { week: { include: { schedule: true } }, roleType: true },
    orderBy: [{ date: "asc" }, { startAt: "asc" }],
  });

  const preferences = await prisma.preference.findMany({
    where: { userId: user.id, shiftSlotId: { in: slots.map((s) => s.id) } },
  });

  const prefMap = new Map(
    preferences.map((p) => [p.shiftSlotId, p.choice])
  );

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
            <h1>Availability</h1>
            <p className="subtext">Select next 2 weeks (current week hidden).</p>
          </div>
          <WeekSelector
            path="/employee/preferences"
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

      {slots.length === 0 ? (
        <section className="empty-state">
          <h2>No shifts yet</h2>
          <p>Once templates exist, shifts will appear here.</p>
        </section>
      ) : (
        <section className="week-grid">
          <div className="week-card">
            <div className="week-card-header">
              <h2>
                Week of {new Intl.DateTimeFormat("en-US", {
                  timeZone: "America/Vancouver",
                  month: "short",
                  day: "numeric",
                }).format(week.startDate)}
              </h2>
              <form action={syncFromTemplateAction}>
                <input type="hidden" name="weekId" value={week.id} />
                <button className="ghost-button" type="submit">
                  Sync from template
                </button>
              </form>
            </div>
            {slots.length === 0 ? (
              <p className="subtext">No shifts for this week.</p>
            ) : (
              <div className="week-table">
                <div className="week-header">
                  <div>Role</div>
                  <div>Time</div>
                  <div>Preference</div>
                  <div></div>
                </div>
                {[0, 1, 2, 3, 4, 5, 6].map((dayIndex) => {
                  const dayDate = addDays(week.startDate, dayIndex);
                  const label = `${new Intl.DateTimeFormat("en-US", {
                    timeZone: "America/Vancouver",
                    weekday: "short",
                  }).format(dayDate)} - ${new Intl.DateTimeFormat("en-US", {
                    timeZone: "America/Vancouver",
                    month: "short",
                    day: "numeric",
                  }).format(dayDate)}`;

                  const daySlots = slots.filter((slot) => {
                    const slotDay = new Date(slot.date).getDay();
                    const mondayIndex = (slotDay + 6) % 7;
                    return mondayIndex === dayIndex;
                  });

                  if (daySlots.length === 0) {
                    return (
                      <div key={`day-${dayIndex}`} className="day-section">
                        <div className="day-header">{label}</div>
                        <div className="day-empty">No shifts</div>
                      </div>
                    );
                  }

                  return (
                    <div key={`day-${dayIndex}`} className="day-section">
                      <div className="day-header">{label}</div>
                      {daySlots.map((slot) => {
                        const choice = prefMap.get(slot.id) ?? "CAN";
                        const locked = slot.week.schedule?.status === "FINALIZED";
                        const choiceClass = `choice-pill choice-${choice.toLowerCase()}`;

                        return (
                          <form
                            key={slot.id}
                            action={updatePreferenceAction}
                            className={`week-row row-${choice.toLowerCase()}`}
                          >
                            <input type="hidden" name="shiftSlotId" value={slot.id} />
                            <div>{slot.roleType.name}</div>
                            <div>
                              {slot.startAt.toTimeString().slice(0, 5)} -{" "}
                              {slot.endAt.toTimeString().slice(0, 5)}
                            </div>
                            <div>
                              <select
                                name="choice"
                                defaultValue={choice}
                                disabled={locked}
                                className={choiceClass}
                              >
                                {Object.entries(choiceLabels).map(([value, label]) => (
                                  <option key={value} value={value}>
                                    {label}
                                  </option>
                                ))}
                              </select>
                            </div>
                            <div>
                              <button type="submit" className="ghost-button" disabled={locked}>
                                {locked ? "Locked" : "Save"}
                              </button>
                            </div>
                          </form>
                        );
                      })}
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </section>
      )}
      </main>
    </>
  );
}
