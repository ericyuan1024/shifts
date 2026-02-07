"use server";

import { revalidatePath } from "next/cache";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { ensureNextTwoWeeks } from "@/lib/weeks";
import { mondayIndex } from "@/lib/date";
import { PreferenceChoice } from "@prisma/client";

export async function updatePreferenceAction(formData: FormData) {
  const user = await getCurrentUser();
  if (!user) throw new Error("UNAUTHORIZED");

  const shiftSlotId = String(formData.get("shiftSlotId") || "");
  const choice = String(formData.get("choice") || "");

  if (!shiftSlotId) return { ok: false, message: "Missing shift slot." };
  if (!["WANT", "CAN", "CANT"].includes(choice)) {
    return { ok: false, message: "Invalid choice." };
  }

  const slot = await prisma.shiftSlot.findUnique({
    where: { id: shiftSlotId },
    include: { week: { include: { schedule: true } } },
  });
  if (!slot) return { ok: false, message: "Shift slot not found." };

  if (slot.week.schedule?.status === "FINALIZED") {
    return { ok: false, message: "Schedule finalized. Availability is locked." };
  }

  const castChoice = choice as PreferenceChoice;
  await prisma.preference.upsert({
    where: { userId_shiftSlotId: { userId: user.id, shiftSlotId } },
    create: { userId: user.id, shiftSlotId, choice: castChoice },
    update: { choice: castChoice },
  });

  revalidatePath("/employee/preferences");
  return { ok: true };
}

export async function syncFromTemplateAction(formData: FormData) {
  const user = await getCurrentUser();
  if (!user) throw new Error("UNAUTHORIZED");

  if (!user.roleTypeId) {
    return { ok: false, message: "Ask an admin to assign your role first." };
  }

  const weekId = String(formData.get("weekId") || "");
  if (!weekId) return { ok: false, message: "Missing week." };

  const week = await prisma.week.findUnique({
    where: { id: weekId },
    include: { schedule: true },
  });

  if (!week) return { ok: false, message: "Week not found." };
  if (week.schedule?.status === "FINALIZED") {
    return { ok: false, message: "Week is finalized." };
  }

  const isManager = user.roleType?.name === "Manager";

  const slots = await prisma.shiftSlot.findMany({
    where: {
      weekId,
      ...(isManager ? {} : { roleTypeId: user.roleTypeId }),
    },
  });

  const templates = await prisma.availabilityTemplate.findMany({
    where: { userId: user.id },
  });

  const templateMap = new Map(
    templates.map((t) => [
      `${t.roleTypeId}-${t.dayOfWeek}-${t.startTime}-${t.endTime}`,
      t.choice,
    ])
  );

  await prisma.preference.deleteMany({
    where: { userId: user.id, shiftSlotId: { in: slots.map((s) => s.id) } },
  });

  const payload = slots.map((slot) => {
    const day = mondayIndex(slot.date);
    const start = slot.startAt.toTimeString().slice(0, 5);
    const end = slot.endAt.toTimeString().slice(0, 5);
    const key = `${slot.roleTypeId}-${day}-${start}-${end}`;
    const choice = templateMap.get(key) ?? "CAN";
    return { userId: user.id, shiftSlotId: slot.id, choice: choice as PreferenceChoice };
  });

  if (payload.length) {
    await prisma.preference.createMany({ data: payload });
  }

  revalidatePath("/employee/preferences");
  return { ok: true };
}
