import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { prisma } from "@/lib/db";
import AddShiftSlotForm from "./AddShiftSlotForm";
import { ensureDefaultRoleTypes } from "@/lib/roles";
import TopBar from "@/components/TopBar";
import EditShiftTemplateModal from "./EditShiftTemplateModal";
import DeleteShiftTemplateModal from "./DeleteShiftTemplateModal";

const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

export default async function TemplatesPage() {
  const user = await getCurrentUser();
  if (!user) redirect("/admin/login");
  if (user.role !== "ADMIN") redirect("/home");

  await ensureDefaultRoleTypes();
  const roleTypes = await prisma.roleType.findMany({ orderBy: { name: "asc" } });
  const templates = await prisma.shiftTemplate.findMany({
    include: { roleType: true },
    orderBy: [{ dayOfWeek: "asc" }, { startTime: "asc" }],
  });

  return (
    <>
      <TopBar name={user.name} role={user.role} roleLabel="Admin" />
      <main className="page-with-topbar">
        <header className="page-header">
          <div>
            <h1>Shift Templates</h1>
            <p className="subtext">
              Template changes only affect unscheduled weeks.
            </p>
          </div>
        </header>

        <section className="card-grid">
        <div className="card">
          <h2>Role Types</h2>
          <p className="subtext">Fixed roles for this MVP.</p>
          <div className="schedule-list">
            <div className="schedule-row">
              <strong>Server</strong>
              <span className="badge">Default</span>
            </div>
            <div className="schedule-row">
              <strong>Kitchen</strong>
              <span className="badge">Default</span>
            </div>
            <div className="schedule-row">
              <strong>Manager</strong>
              <span className="badge">Flexible</span>
            </div>
          </div>
        </div>

        <AddShiftSlotForm roleTypes={roleTypes} days={days} />
        </section>

        <section className="card" style={{ marginTop: 20 }}>
        <h2>Configured Templates</h2>
        {templates.length === 0 ? (
          <p className="subtext">No templates yet.</p>
        ) : (
          <div className="schedule-list">
            {templates.map((template) => (
              <div className="schedule-row" key={template.id}>
                <div>
                  <strong>{template.roleType.name}</strong>
                  <div className="subtext">
                    {days[template.dayOfWeek]} | {template.startTime} -
                    {template.endTime} | {template.hours} hours
                  </div>
                </div>
                <div className="row-actions">
                  <EditShiftTemplateModal
                    template={{
                      id: template.id,
                      dayOfWeek: template.dayOfWeek,
                      startTime: template.startTime,
                      endTime: template.endTime,
                      hours: template.hours,
                      roleName: template.roleType.name,
                    }}
                  />
                  <DeleteShiftTemplateModal templateId={template.id} />
                </div>
              </div>
            ))}
          </div>
        )}
        </section>
      </main>
    </>
  );
}
