import crypto from "crypto";
import { cookies } from "next/headers";
import { prisma } from "@/lib/db";

const SESSION_COOKIE = "sid";

export function hashPasscode(passcode: string) {
  return crypto.createHash("sha256").update(passcode).digest("hex");
}

export function getSessionDurationMs() {
  const days = Number(process.env.SESSION_DAYS || 30);
  return days * 24 * 60 * 60 * 1000;
}

export async function createSession(userId: string) {
  const expiresAt = new Date(Date.now() + getSessionDurationMs());
  const session = await prisma.session.create({
    data: { userId, expiresAt },
  });

  const cookieStore = await cookies();
  cookieStore.set(SESSION_COOKIE, session.id, {
    httpOnly: true,
    sameSite: "lax",
    expires: expiresAt,
    path: "/",
  });

  return session;
}

export async function deleteSession() {
  const cookieStore = await cookies();
  const sessionId = cookieStore.get(SESSION_COOKIE)?.value;
  if (sessionId) {
    await prisma.session.deleteMany({ where: { id: sessionId } });
  }
  cookieStore.delete(SESSION_COOKIE);
}

export async function getCurrentUser() {
  const cookieStore = await cookies();
  const sessionId = cookieStore.get(SESSION_COOKIE)?.value;
  if (!sessionId) return null;

  const session = await prisma.session.findUnique({
    where: { id: sessionId },
    include: { user: { include: { roleType: true } } },
  });

  if (!session) return null;
  if (session.expiresAt < new Date()) {
    await prisma.session.delete({ where: { id: session.id } });
    return null;
  }

  return session.user;
}

export async function requireUser() {
  const user = await getCurrentUser();
  if (!user) {
    throw new Error("UNAUTHORIZED");
  }
  return user;
}
