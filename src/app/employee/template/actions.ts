"use server";

import { revalidatePath } from "next/cache";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { PreferenceChoice } from "@prisma/client";

export async function upsertTemplateAction(formData: FormData) {
  const user = await getCurrentUser();
  if (!user) throw new Error("UNAUTHORIZED");

  const roleTypeId = String(formData.get("roleTypeId") || "");
  const dayOfWeek = Number(formData.get("dayOfWeek"));
  const startTime = String(formData.get("startTime") || "");
  const endTime = String(formData.get("endTime") || "");
  const hours = Number(formData.get("hours"));
  const choice = String(formData.get("choice") || "");

  if (!roleTypeId) return;
  if (!/^[0-6]$/.test(String(dayOfWeek))) return;
  if (!/^\d{2}:\d{2}$/.test(startTime) || !/^\d{2}:\d{2}$/.test(endTime)) {
    return;
  }
  if (!hours || hours <= 0) return;
  if (!["WANT", "CAN", "CANT"].includes(choice)) {
    return;
  }

  await prisma.availabilityTemplate.upsert({
    where: {
      userId_roleTypeId_dayOfWeek_startTime_endTime: {
        userId: user.id,
        roleTypeId,
        dayOfWeek,
        startTime,
        endTime,
      },
    },
    create: {
      userId: user.id,
      roleTypeId,
      dayOfWeek,
      startTime,
      endTime,
      hours,
      choice: choice as PreferenceChoice,
    },
    update: {
      hours,
      choice: choice as PreferenceChoice,
    },
  });

  revalidatePath("/employee/template");
  return;
}

export async function deleteTemplateAction(formData: FormData) {
  const user = await getCurrentUser();
  if (!user) throw new Error("UNAUTHORIZED");

  const id = String(formData.get("id") || "");
  if (!id) return;

  await prisma.availabilityTemplate.deleteMany({
    where: { id, userId: user.id },
  });

  revalidatePath("/employee/template");
  return;
}
