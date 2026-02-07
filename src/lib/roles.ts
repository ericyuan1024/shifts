import { prisma } from "@/lib/db";

const DEFAULT_ROLE_TYPES = ["Server", "Kitchen", "Manager"];

export async function ensureDefaultRoleTypes() {
  await prisma.roleType.createMany({
    data: DEFAULT_ROLE_TYPES.map((name) => ({ name })),
    skipDuplicates: true,
  });
}
