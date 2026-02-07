"use server";

import { revalidatePath } from "next/cache";
import { prisma } from "@/lib/db";
import { getCurrentUser, hashPasscode } from "@/lib/auth";

export async function changePasscodeAction(
  _prevState: unknown,
  formData: FormData
) {
  const user = await getCurrentUser();
  if (!user) throw new Error("UNAUTHORIZED");

  const current = String(formData.get("current") || "").trim();
  const next = String(formData.get("next") || "").trim();

  if (!/^[0-9]{4}$/.test(current) || !/^[0-9]{4}$/.test(next)) {
    return { ok: false, message: "Passcode must be 4 digits." };
  }

  const currentHash = hashPasscode(current);
  if (currentHash !== user.passcodeHash) {
    return { ok: false, message: "Current passcode is incorrect." };
  }

  const nextHash = hashPasscode(next);
  const conflict = await prisma.user.findUnique({
    where: { passcodeHash: nextHash },
  });
  if (conflict && conflict.id !== user.id) {
    return { ok: false, message: "Passcode is already in use." };
  }

  await prisma.user.update({
    where: { id: user.id },
    data: { passcodeHash: nextHash },
  });

  revalidatePath("/employee/settings");
  return { ok: true, message: "Passcode updated." };
}
