import Link from "next/link";
import { logoutAction } from "@/app/actions/auth";

type Props = {
  name: string;
  role: "ADMIN" | "EMPLOYEE";
  roleLabel: string;
};

export default function TopBar({ name, role, roleLabel }: Props) {
  return (
    <header className="topbar">
      <div>
        <Link href="/home" className="topbar-title-link">Home</Link>
        <div className="topbar-sub">
          Signed in as {name} · {roleLabel}
        </div>
      </div>
      <div className="topbar-actions">
        {role === "ADMIN" ? (
          <nav className="topbar-links">
            <Link href="/admin/schedule">Schedule</Link>
            <Link href="/admin/templates">Templates</Link>
            <Link href="/admin/users">People</Link>
          </nav>
        ) : (
          <nav className="topbar-links">
            <Link href="/employee/preferences">Availability</Link>
            <Link href="/employee/template">Template</Link>
            <Link href="/employee/my-shifts">My Shifts</Link>
            <Link href="/employee/settings">Settings</Link>
          </nav>
        )}
        <form action={logoutAction}>
          <button type="submit" className="ghost-button">
            Sign out
          </button>
        </form>
      </div>
    </header>
  );
}
