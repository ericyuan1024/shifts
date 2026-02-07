import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import ChangePasscodeForm from "./ChangePasscodeForm";
import TopBar from "@/components/TopBar";

export default async function SettingsPage() {
  const user = await getCurrentUser();
  if (!user) redirect("/login");

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
            <h1>My Settings</h1>
            <p className="subtext">Change your 4-digit passcode.</p>
          </div>
        </header>
        <ChangePasscodeForm />
      </main>
    </>
  );
}
