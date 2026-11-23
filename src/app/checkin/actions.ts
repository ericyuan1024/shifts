"use server";

import { headers } from "next/headers";
import { revalidatePath } from "next/cache";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { formatTime, isValidShiftTime } from "@/lib/timeclock";

export type CheckinState = {
  ok: boolean;
  message: string;
  action?: "IN" | "OUT";
  shiftLabel?: string;
};

export async function checkinAction(
  _prev: CheckinState,
  formData: FormData,
): Promise<CheckinState> {
  const user = await getCurrentUser();
  if (!user) return { ok: false, message: "Session expired. Please sign in again." };

  const action = String(formData.get("action") || "");
  if (action !== "IN" && action !== "OUT") {
    return { ok: false, message: "Choose Clock In or Clock Out." };
  }

  const now = new Date(); // server time — the only trusted punch time
  const shiftTime = new Date(String(formData.get("shiftTime") || ""));
  if (!isValidShiftTime(shiftTime, now)) {
    return {
      ok: false,
      message: "Shift time must be within 1 hour of now. Please pick again.",
    };
  }

  const h = await headers();
  const ip = h.get("x-forwarded-for")?.split(",")[0].trim() || h.get("x-real-ip") || null;
  const userAgent = h.get("user-agent")?.slice(0, 300) || null;

  await prisma.timeClock.create({
    data: { userId: user.id, action, shiftTime, punchedAt: now, ip, userAgent },
  });

  revalidatePath("/checkin");
  revalidatePath("/admin/timeclock");
  return { ok: true, message: "", action, shiftLabel: formatTime(shiftTime) };
}
