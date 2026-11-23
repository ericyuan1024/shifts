import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { prisma } from "@/lib/db";
import { formatDateTime, getServerNowMs } from "@/lib/timeclock";
import CheckinForm from "./CheckinForm";

export const dynamic = "force-dynamic";

export const metadata = {
  title: "Clock In / Out · Shifts",
  description: "Tap the NFC tag in store to clock in or out.",
};

export default async function CheckinPage() {
  const user = await getCurrentUser();
  if (!user) redirect("/login?next=/checkin");

  const last = await prisma.timeClock.findFirst({
    where: { userId: user.id },
    orderBy: { punchedAt: "desc" },
  });

  const serverNow = getServerNowMs();
  // Suggest the opposite of the last punch if it was within the last 16 hours.
  const recent = last && serverNow - last.punchedAt.getTime() < 16 * 3_600_000;
  const suggested: "IN" | "OUT" = recent && last.action === "IN" ? "OUT" : "IN";

  return (
    <main className="page-center checkin-page">
      <div className="checkin-card">
        <p className="checkin-eyebrow">Kongfu Cat · Time Clock</p>
        <h1>Hi, {user.name}</h1>
        {last ? (
          <p className="subtext">
            Last: {last.action === "IN" ? "Clock In" : "Clock Out"} ·{" "}
            {formatDateTime(last.shiftTime)}
          </p>
        ) : (
          <p className="subtext">No check-ins yet.</p>
        )}
        <CheckinForm serverNow={serverNow} suggested={suggested} />
      </div>
    </main>
  );
}
