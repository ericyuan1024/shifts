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

  if (!name) return { ok: false, message: "Please enter a name." };
  if (!/^[0-9]{4}$/.test(passcode)) return { ok: false, message: "Passcode must be 4 digits." };
  if (!roleTypeId) return { ok: false, message: "Please select a role." };

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
    return { ok: false, message: "Passcode is already in use." };
  }

  revalidatePath("/admin/users");
  return { ok: true };
}

export async function createAdminAction(formData: FormData) {
  const admin = await getCurrentUser();
  if (!admin || admin.role !== "ADMIN") throw new Error("UNAUTHORIZED");

  const name = String(formData.get("name") || "").trim();
  const passcode = String(formData.get("passcode") || "").trim();

  if (!name) return { ok: false, message: "Please enter a name." };
  if (!/^[0-9]{4}$/.test(passcode)) return { ok: false, message: "Passcode must be 4 digits." };

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
    return { ok: false, message: "Passcode is already in use." };
  }

  revalidatePath("/admin/users");
  return { ok: true };
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

  if (!userId) return { ok: false, message: "Missing user." };
  if (!name) return { ok: false, message: "Please enter a name." };
  if (!["EMPLOYEE", "ADMIN"].includes(role)) {
    return { ok: false, message: "Invalid role." };
  }

  const weight = Number(weightRaw);
  if (!Number.isFinite(weight) || weight <= 0) {
    return { ok: false, message: "Weight must be a positive number." };
  }

  let passcodeHash: string | undefined;
  if (passcode) {
    if (!/^[0-9]{4}$/.test(passcode)) {
      return { ok: false, message: "Passcode must be 4 digits." };
    }
    passcodeHash = hashPasscode(passcode);
    const conflict = await prisma.user.findUnique({ where: { passcodeHash } });
    if (conflict && conflict.id !== userId) {
      return { ok: false, message: "Passcode is already in use." };
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
  return { ok: true };
}
