import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { prisma } from "@/lib/db";
import TopBar from "@/components/TopBar";
import { upsertTemplateAction, deleteTemplateAction } from "./actions";

const choiceLabels: Record<string, string> = {
  WANT: "Want",
  CAN: "Can",
  CANT: "Can't",
};

const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

export const dynamic = "force-dynamic";

export default async function TemplatePage() {
  const user = await getCurrentUser();
  if (!user) redirect("/login");

  if (!user.roleTypeId) {
    return (
      <>
        <TopBar name={user.name} role={user.role} roleLabel={user.roleType?.name ?? "Employee"} />
        <main className="page-with-topbar">
          <section className="empty-state">
            <h2>Role required</h2>
            <p>Ask an admin to assign your role before editing the template.</p>
          </section>
        </main>
      </>
    );
  }

  const isManager = user.roleType?.name === "Manager";

  const shiftTemplates = await prisma.shiftTemplate.findMany({
    where: isManager ? {} : { roleTypeId: user.roleTypeId },
    include: { roleType: true },
    orderBy: [{ dayOfWeek: "asc" }, { startTime: "asc" }],
  });
  type ShiftTemplate = (typeof shiftTemplates)[number];

  const templates = await prisma.availabilityTemplate.findMany({
    where: { userId: user.id },
  });
  type Template = (typeof templates)[number];

  const templateMap = new Map(
    templates.map((t: Template) => [
      `${t.roleTypeId}-${t.dayOfWeek}-${t.startTime}-${t.endTime}`,
      t,
    ])
  );

  const validKeys = new Set(
    shiftTemplates.map(
      (t: ShiftTemplate) =>
        `${t.roleTypeId}-${t.dayOfWeek}-${t.startTime}-${t.endTime}`
    )
  );

  const obsoleteTemplates = templates.filter(
    (t: Template) =>
      !validKeys.has(`${t.roleTypeId}-${t.dayOfWeek}-${t.startTime}-${t.endTime}`)
  );

  return (
    <>
      <TopBar name={user.name} role={user.role} roleLabel={user.roleType?.name ?? "Employee"} />
      <main className="page-with-topbar">
        <header className="page-header">
          <div>
            <h1>Availability Template</h1>
            <p className="subtext">
              This template is used to sync each new week. If admin changes shift templates,
              you may need to update this.
            </p>
          </div>
        </header>

        {shiftTemplates.length === 0 ? (
          <section className="empty-state">
            <h2>No shift templates yet</h2>
            <p>Ask admin to configure shift templates first.</p>
          </section>
        ) : (
          <section className="schedule-list">
            {shiftTemplates.map((slot: ShiftTemplate) => {
              const key = `${slot.roleTypeId}-${slot.dayOfWeek}-${slot.startTime}-${slot.endTime}`;
              const existing = templateMap.get(key);
              const choice = existing?.choice ?? "CAN";

              return (
                <form
                  key={slot.id}
                  action={upsertTemplateAction}
                  className={`schedule-row row-${choice.toLowerCase()}`}
                >
                  <input type="hidden" name="roleTypeId" value={slot.roleTypeId} />
                  <input type="hidden" name="dayOfWeek" value={slot.dayOfWeek} />
                  <input type="hidden" name="startTime" value={slot.startTime} />
                  <input type="hidden" name="endTime" value={slot.endTime} />
                  <input type="hidden" name="hours" value={slot.hours} />

                  <div>
                    <strong>{slot.roleType.name}</strong>
                    <div className="subtext">
                      {days[slot.dayOfWeek]} | {slot.startTime} - {slot.endTime}
                    </div>
                  </div>
                  <div className="row-actions">
                    <select
                      key={`${slot.id}-${choice}`}
                      name="choice"
                      defaultValue={choice}
                      className={`choice-pill choice-${choice.toLowerCase()}`}
                    >
                      {Object.entries(choiceLabels).map(([value, label]) => (
                        <option key={value} value={value}>
                          {label}
                        </option>
                      ))}
                    </select>
                    <button type="submit" className="icon-button" aria-label="Save">
                      ✓
                    </button>
                  </div>
                </form>
              );
            })}
          </section>
        )}

        {obsoleteTemplates.length > 0 ? (
          <section className="card" style={{ marginTop: 20 }}>
            <h2>Obsolete Template Entries</h2>
            <p className="subtext">
              These entries no longer match current shift templates. You can delete them.
            </p>
            <div className="schedule-list">
              {obsoleteTemplates.map((t: Template) => (
                <form key={t.id} action={deleteTemplateAction} className="schedule-row">
                  <input type="hidden" name="id" value={t.id} />
                  <div>
                    <strong>{days[t.dayOfWeek]}</strong>
                    <div className="subtext">
                      {t.startTime} - {t.endTime}
                    </div>
                  </div>
                  <button type="submit" className="ghost-button">Delete</button>
                </form>
              ))}
            </div>
          </section>
        ) : null}
      </main>
    </>
  );
}
