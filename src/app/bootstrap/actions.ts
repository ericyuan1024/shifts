"use server";

import { redirect } from "next/navigation";
import { prisma } from "@/lib/db";
import { hashPasscode, createSession } from "@/lib/auth";

export async function bootstrapAdminAction(
  _prevState: unknown,
  formData: FormData
) {
  const existing = await prisma.user.findFirst({ where: { role: "ADMIN" } });
  if (existing) redirect("/login");

  const name = String(formData.get("name") || "").trim();
  const passcode = String(formData.get("passcode") || "").trim();

  if (!name || !/^[0-9]{4}$/.test(passcode)) {
    return { ok: false, message: "Please enter a name and 4-digit passcode." };
  }

  const passcodeHash = hashPasscode(passcode);
  const admin = await prisma.user.create({
    data: {
      name,
      passcodeHash,
      role: "ADMIN",
    },
  });

  await createSession(admin.id);
  redirect("/home");
}
