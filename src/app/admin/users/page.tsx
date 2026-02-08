import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { prisma } from "@/lib/db";
import { createAdminAction, createUserAction } from "./actions";
import { ensureDefaultRoleTypes } from "@/lib/roles";
import TopBar from "@/components/TopBar";
import EditUserModal from "./EditUserModal";

export const dynamic = "force-dynamic";

export default async function UsersPage() {
  const user = await getCurrentUser();
  if (!user) redirect("/admin/login");
  if (user.role !== "ADMIN") redirect("/home");

  await ensureDefaultRoleTypes();
  const [roleTypes, users] = await Promise.all([
    prisma.roleType.findMany({ orderBy: { name: "asc" } }),
    prisma.user.findMany({
      include: { roleType: true },
      orderBy: { name: "asc" },
    }),
  ]);
  type RoleType = (typeof roleTypes)[number];
  type UserRow = (typeof users)[number];

  return (
    <>
      <TopBar name={user.name} role={user.role} roleLabel="Admin" />
      <main className="page-with-topbar">
        <header className="page-header">
          <div>
            <h1>People & Access</h1>
            <p className="subtext">
              Set 4-digit passcodes and roles (Server, Kitchen, Manager).
            </p>
          </div>
        </header>

        <section className="card-grid">
        <form className="card" action={createUserAction}>
          <h2>Add Employee</h2>
          <input name="name" placeholder="Name" />
          <input name="passcode" placeholder="4-digit passcode" />
          <select name="roleTypeId" defaultValue="">
            <option value="" disabled>
              Select role
            </option>
            {roleTypes.map((role: RoleType) => (
              <option key={role.id} value={role.id}>
                {role.name}
              </option>
            ))}
          </select>
          <input name="weight" placeholder="Weight (default 1)" />
          <button type="submit" className="primary">Save Employee</button>
        </form>

        <form className="card" action={createAdminAction}>
          <h2>Add Admin</h2>
          <input name="name" placeholder="Name" />
          <input name="passcode" placeholder="4-digit passcode" />
          <button type="submit" className="primary">Save Admin</button>
        </form>
        </section>

        <section className="card" style={{ marginTop: 20 }}>
        <h2>Current Users</h2>
        {users.length === 0 ? (
          <p className="subtext">No users yet.</p>
        ) : (
          <div className="schedule-list">
            {users.map((u: UserRow) => (
              <div className="schedule-row user-row" key={u.id}>
                <div className="user-row-header">
                  <strong>{u.name}</strong>
                  <EditUserModal
                    user={{
                      id: u.id,
                      name: u.name,
                      role: u.role,
                      roleTypeId: u.roleTypeId,
                      weight: u.weight,
                    }}
                    roleTypes={roleTypes}
                  />
                </div>
                <div className="subtext">
                  {u.role === "ADMIN" ? "Admin" : u.roleType?.name ?? "No role"}
                </div>
                <div>Weight: {u.weight}</div>
              </div>
            ))}
          </div>
        )}
      </section>
      </main>
    </>
  );
}
