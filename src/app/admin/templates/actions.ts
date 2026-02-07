"use server";

import { revalidatePath } from "next/cache";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";

export async function createRoleTypeAction(formData: FormData) {
  const user = await getCurrentUser();
  if (!user || user.role !== "ADMIN") throw new Error("UNAUTHORIZED");

  const name = String(formData.get("name") || "").trim();
  if (!name) return;

  await prisma.roleType.create({ data: { name } });
  revalidatePath("/admin/templates");
  return { ok: true };
}

export async function createTemplateAction(formData: FormData) {
  const user = await getCurrentUser();
  if (!user || user.role !== "ADMIN") throw new Error("UNAUTHORIZED");

  const roleTypeId = String(formData.get("roleTypeId") || "");
  const dayOfWeek = Number(formData.get("dayOfWeek"));
  const startTime = String(formData.get("startTime") || "");
  const endTime = String(formData.get("endTime") || "");
  const hours = Number(formData.get("hours"));

  if (!roleTypeId) return;
  if (!/^[0-6]$/.test(String(dayOfWeek))) return;
  if (!/^\d{2}:\d{2}$/.test(startTime) || !/^\d{2}:\d{2}$/.test(endTime)) {
    return;
  }
  if (!hours || hours <= 0) return;

  await prisma.shiftTemplate.create({
    data: { roleTypeId, dayOfWeek, startTime, endTime, hours },
  });

  revalidatePath("/admin/templates");
  return;
}

export async function updateShiftTemplateAction(formData: FormData) {
  const user = await getCurrentUser();
  if (!user || user.role !== "ADMIN") throw new Error("UNAUTHORIZED");

  const id = String(formData.get("id") || "");
  const dayOfWeek = Number(formData.get("dayOfWeek"));
  const startTime = String(formData.get("startTime") || "");
  const endTime = String(formData.get("endTime") || "");
  const hours = Number(formData.get("hours"));

  if (!id) return;
  if (!/^[0-6]$/.test(String(dayOfWeek))) return;
  if (!/^\d{2}:\d{2}$/.test(startTime) || !/^\d{2}:\d{2}$/.test(endTime)) {
    return;
  }
  if (!hours || hours <= 0) return;

  await prisma.shiftTemplate.update({
    where: { id },
    data: { dayOfWeek, startTime, endTime, hours },
  });

  revalidatePath("/admin/templates");
  return;
}

export async function deleteShiftTemplateAction(formData: FormData) {
  const user = await getCurrentUser();
  if (!user || user.role !== "ADMIN") throw new Error("UNAUTHORIZED");

  const id = String(formData.get("id") || "");
  if (!id) return;

  await prisma.shiftTemplate.delete({ where: { id } });

  revalidatePath("/admin/templates");
  return;
}
