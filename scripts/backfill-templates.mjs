import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  const users = await prisma.user.findMany({
    where: { role: "EMPLOYEE", roleTypeId: { not: null } },
    include: { roleType: true },
  });

  const shiftTemplates = await prisma.shiftTemplate.findMany({
    where: { isActive: true },
  });

  const templates = await prisma.availabilityTemplate.findMany();
  const existing = new Set(
    templates.map(
      (t) =>
        `${t.userId}-${t.roleTypeId}-${t.dayOfWeek}-${t.startTime}-${t.endTime}`
    )
  );

  const rows = [];
  for (const user of users) {
    const isManager = user.roleType?.name === "Manager";
    for (const slot of shiftTemplates) {
      if (!isManager && user.roleTypeId !== slot.roleTypeId) continue;
      const key = `${user.id}-${slot.roleTypeId}-${slot.dayOfWeek}-${slot.startTime}-${slot.endTime}`;
      if (existing.has(key)) continue;
      rows.push({
        userId: user.id,
        roleTypeId: slot.roleTypeId,
        dayOfWeek: slot.dayOfWeek,
        startTime: slot.startTime,
        endTime: slot.endTime,
        hours: slot.hours,
        choice: "CAN",
      });
      existing.add(key);
    }
  }

  if (!rows.length) {
    console.log("No missing templates found.");
    return;
  }

  const result = await prisma.availabilityTemplate.createMany({ data: rows });
  console.log(`Inserted ${result.count} missing template entries.`);
}

main()
  .catch((err) => {
    console.error(err);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
