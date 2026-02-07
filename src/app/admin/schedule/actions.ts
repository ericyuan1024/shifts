"use server";

import { revalidatePath } from "next/cache";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { ensureNextTwoWeeks, ensureSlotsForWeek } from "@/lib/weeks";
import { generateScheduleAssignments } from "@/lib/scheduler";

export async function generateScheduleAction(
  _prevState: unknown,
  formData: FormData
) {
  const user = await getCurrentUser();
  if (!user || user.role !== "ADMIN") {
    throw new Error("UNAUTHORIZED");
  }

  const weekId = String(formData.get("weekId") || "");
  const week = weekId
    ? await prisma.week.findUnique({ where: { id: weekId } })
    : null;
  if (!week) throw new Error("No schedulable week found.");
  await ensureSlotsForWeek(week.id);

  let schedule = await prisma.schedule.findUnique({
    where: { weekId: week.id },
  });

  if (!schedule) {
    schedule = await prisma.schedule.create({
      data: { weekId: week.id },
    });
  } else if (schedule.status === "FINALIZED") {
    return { ok: false, message: "Finalized schedules cannot be regenerated." };
  } else {
    await prisma.assignment.deleteMany({
      where: { scheduleId: schedule.id },
    });
    schedule = await prisma.schedule.update({
      where: { id: schedule.id },
      data: { version: schedule.version + 1 },
    });
  }

  try {
    const assignments = await generateScheduleAssignments(
      week.id,
      schedule.version
    );

    await prisma.assignment.createMany({
      data: assignments.map((a) => ({
        ...a,
        scheduleId: schedule!.id,
        source: "AUTO",
      })),
    });

    await prisma.schedule.update({
      where: { id: schedule.id },
      data: { generatedAt: new Date() },
    });
  } catch (error) {
    return { ok: false, message: "No feasible schedule. Check templates or availability." };
  }

  revalidatePath("/admin/schedule");
  revalidatePath("/employee/my-shifts");

  return { ok: true };
}

export async function finalizeScheduleAction(
  _prevState: unknown,
  formData: FormData
) {
  const user = await getCurrentUser();
  if (!user || user.role !== "ADMIN") {
    throw new Error("UNAUTHORIZED");
  }

  const weekId = String(formData.get("weekId") || "");
  const week = weekId
    ? await prisma.week.findUnique({ where: { id: weekId } })
    : null;
  if (!week) throw new Error("No schedulable week found.");

  const schedule = await prisma.schedule.findUnique({
    where: { weekId: week.id },
  });

  if (!schedule) {
    return { ok: false, message: "Please generate a schedule first." };
  }

  if (schedule.status === "FINALIZED") {
    return { ok: false, message: "Schedule is already finalized." };
  }

  await prisma.schedule.update({
    where: { id: schedule.id },
    data: { status: "FINALIZED", finalizedAt: new Date() },
  });

  revalidatePath("/admin/schedule");
  revalidatePath("/employee/my-shifts");

  return { ok: true };
}

export async function reopenScheduleAction(
  _prevState: unknown,
  formData: FormData
) {
  const user = await getCurrentUser();
  if (!user || user.role !== "ADMIN") {
    throw new Error("UNAUTHORIZED");
  }

  const weekId = String(formData.get("weekId") || "");
  const week = weekId
    ? await prisma.week.findUnique({ where: { id: weekId } })
    : null;
  if (!week) throw new Error("No schedulable week found.");

  const schedule = await prisma.schedule.findUnique({
    where: { weekId: week.id },
  });

  if (!schedule) {
    return { ok: false, message: "No schedule to reopen." };
  }

  if (schedule.status !== "FINALIZED") {
    return { ok: false, message: "Schedule is not finalized." };
  }

  await prisma.schedule.update({
    where: { id: schedule.id },
    data: { status: "DRAFT", finalizedAt: null },
  });

  revalidatePath("/admin/schedule");
  revalidatePath("/employee/my-shifts");

  return { ok: true };
}

export async function updateAssignmentAction(formData: FormData) {
  const user = await getCurrentUser();
  if (!user || user.role !== "ADMIN") {
    throw new Error("UNAUTHORIZED");
  }

  const shiftSlotId = String(formData.get("shiftSlotId") || "");
  const userId = String(formData.get("userId") || "");

  if (!shiftSlotId || !userId) return { ok: false, message: "缺少参数" };

  const slot = await prisma.shiftSlot.findUnique({
    where: { id: shiftSlotId },
    include: { week: { include: { schedule: true } } },
  });
  if (!slot) return { ok: false, message: "Shift slot not found." };

  let schedule = slot.week.schedule;
  if (!schedule) {
    schedule = await prisma.schedule.create({
      data: { weekId: slot.weekId, generatedAt: new Date() },
    });
  }

  if (schedule.status === "FINALIZED") {
    return { ok: false, message: "Finalized schedules cannot be edited." };
  }

  await prisma.assignment.upsert({
    where: { shiftSlotId },
    create: {
      shiftSlotId,
      userId,
      scheduleId: schedule.id,
      source: "MANUAL",
    },
    update: { userId, source: "MANUAL" },
  });

  revalidatePath("/admin/schedule");
  revalidatePath("/employee/my-shifts");
  return { ok: true };
}
