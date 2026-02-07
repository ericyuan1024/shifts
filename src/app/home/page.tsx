import Link from "next/link";
import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import TopBar from "@/components/TopBar";

export default async function HomePage() {
  const user = await getCurrentUser();
  if (!user) {
    redirect("/login");
  }

  return (
    <>
      <TopBar
        name={user.name}
        role={user.role}
        roleLabel={user.role === "ADMIN" ? "Admin" : user.roleType?.name ?? "Employee"}
      />
      <main className="page-with-topbar">
        <section className="card-grid">
        {user.role === "EMPLOYEE" ? (
          <>
            <Link href="/employee/preferences" className="card">
              <h2>Set Availability</h2>
              <p>Next 2 weeks, default is “Can”.</p>
            </Link>
            <Link href="/employee/template" className="card">
              <h2>Availability Template</h2>
              <p>Your default weekly availability.</p>
            </Link>
            <Link href="/employee/my-shifts" className="card">
              <h2>My Final Shifts</h2>
              <p>See finalized schedules.</p>
            </Link>
            <Link href="/employee/settings" className="card">
              <h2>My Settings</h2>
              <p>Change your 4-digit passcode.</p>
            </Link>
          </>
        ) : null}
        {user.role === "ADMIN" ? (
          <>
            <Link href="/admin/schedule" className="card">
              <h2>Admin Scheduling</h2>
              <p>Generate, adjust, finalize.</p>
            </Link>
            <Link href="/admin/templates" className="card">
              <h2>Shift Templates</h2>
              <p>Changes apply to unscheduled weeks only.</p>
            </Link>
            <Link href="/admin/users" className="card">
              <h2>People & Access</h2>
              <p>Passcodes, roles, weights.</p>
            </Link>
          </>
        ) : null}
        </section>
      </main>
    </>
  );
}
