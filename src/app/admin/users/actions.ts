"use server";

import { revalidatePath } from "next/cache";
import { prisma } from "@/lib/db";
import { getCurrentUser, hashPasscode } from "@/lib/auth";

export async function createUserAction(formData: FormData) {
  const admin = await getCurrentUser();
  if (!admin || admin.role !== "ADMIN") throw new Error("UNAUTHORIZED");

  const name = String(formData.get("name") || "").trim();
  const passcode = String(formData.get("passcode") || "").trim();
  const roleTypeId = String(formData.get("roleTypeId") || "");
  const weight = Number(formData.get("weight") || 1);

  if (!name) return;
  if (!/^[0-9]{4}$/.test(passcode)) return;
  if (!roleTypeId) return;

  const passcodeHash = hashPasscode(passcode);

  try {
    await prisma.user.create({
      data: {
        name,
        passcodeHash,
        roleTypeId,
        weight: Number.isFinite(weight) ? weight : 1,
      },
    });
  } catch (error) {
    return;
  }

  revalidatePath("/admin/users");
  return;
}

export async function createAdminAction(formData: FormData) {
  const admin = await getCurrentUser();
  if (!admin || admin.role !== "ADMIN") throw new Error("UNAUTHORIZED");

  const name = String(formData.get("name") || "").trim();
  const passcode = String(formData.get("passcode") || "").trim();

  if (!name) return;
  if (!/^[0-9]{4}$/.test(passcode)) return;

  const passcodeHash = hashPasscode(passcode);

  try {
    await prisma.user.create({
      data: {
        name,
        passcodeHash,
        role: "ADMIN",
      },
    });
  } catch (error) {
    return;
  }

  revalidatePath("/admin/users");
  return;
}

export async function updateUserAction(formData: FormData) {
  const admin = await getCurrentUser();
  if (!admin || admin.role !== "ADMIN") throw new Error("UNAUTHORIZED");

  const userId = String(formData.get("userId") || "");
  const name = String(formData.get("name") || "").trim();
  const role = String(formData.get("role") || "");
  const roleTypeId = String(formData.get("roleTypeId") || "");
  const weightRaw = String(formData.get("weight") || "").trim();
  const passcode = String(formData.get("passcode") || "").trim();

  if (!userId) return;
  if (!name) return;
  if (!["EMPLOYEE", "ADMIN"].includes(role)) {
    return;
  }

  const weight = Number(weightRaw);
  if (!Number.isFinite(weight) || weight <= 0) {
    return;
  }

  let passcodeHash: string | undefined;
  if (passcode) {
    if (!/^[0-9]{4}$/.test(passcode)) {
      return;
    }
    passcodeHash = hashPasscode(passcode);
    const conflict = await prisma.user.findUnique({ where: { passcodeHash } });
    if (conflict && conflict.id !== userId) {
      return;
    }
  }

  await prisma.user.update({
    where: { id: userId },
    data: {
      name,
      role: role as "EMPLOYEE" | "ADMIN",
      roleTypeId: roleTypeId || null,
      weight,
      ...(passcodeHash ? { passcodeHash } : {}),
    },
  });

  revalidatePath("/admin/users");
  return;
}
