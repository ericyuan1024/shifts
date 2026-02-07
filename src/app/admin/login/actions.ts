"use server";

import { prisma } from "@/lib/db";
import { createSession, hashPasscode } from "@/lib/auth";
import { redirect } from "next/navigation";

export async function adminLoginAction(_prevState: unknown, formData: FormData) {
  const passcode = String(formData.get("passcode") || "").trim();
  if (!/^[0-9]{4}$/.test(passcode)) {
    return { ok: false, message: "Passcode must be 4 digits." };
  }

  const passcodeHash = hashPasscode(passcode);
  const user = await prisma.user.findUnique({
    where: { passcodeHash },
  });

  if (!user || user.role !== "ADMIN") {
    return { ok: false, message: "Admin passcode not found." };
  }

  await createSession(user.id);
  redirect("/admin/schedule");
}
