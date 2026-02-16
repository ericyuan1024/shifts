"use server";

import { prisma } from "@/lib/db";
import { createSession, hashPasscode } from "@/lib/auth";
import { redirect } from "next/navigation";

export async function loginAction(_prevState: unknown, formData: FormData) {
  const globalCode = process.env.GLOBAL_PASSCODE?.trim();
  const providedGlobal = String(formData.get("globalPasscode") || "").trim();
  if (globalCode && providedGlobal !== globalCode) {
    return { ok: false, message: "Team passcode is incorrect." };
  }

  const passcode = String(formData.get("passcode") || "").trim();
  if (!/^[0-9]{4}$/.test(passcode)) {
    return { ok: false, message: "Passcode must be 4 digits." };
  }

  const passcodeHash = hashPasscode(passcode);
  const user = await prisma.user.findUnique({
    where: { passcodeHash },
  });

  if (!user) {
    return { ok: false, message: "Incorrect passcode." };
  }

  await createSession(user.id);
  redirect("/home");
}
