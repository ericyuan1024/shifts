import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

function formatDateInTimeZone(date, timeZone) {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(date);
}

async function main() {
  const target = "2026-02-02";
  const tz = "America/Vancouver";

  const weeks = await prisma.week.findMany();
  const week = weeks.find((w) => formatDateInTimeZone(w.startDate, tz) === target);

  if (!week) {
    console.log(`No week found for ${target} in ${tz}.`);
    return;
  }

  const slots = await prisma.shiftSlot.findMany({
    where: { weekId: week.id },
    orderBy: { createdAt: "asc" },
  });

  const keep = new Map();
  const toDelete = [];

  for (const slot of slots) {
    const key = `${slot.weekId}-${slot.roleTypeId}-${slot.startAt.toISOString()}-${slot.endAt.toISOString()}`;
    if (!keep.has(key)) {
      keep.set(key, slot.id);
    } else {
      toDelete.push(slot.id);
    }
  }

  if (toDelete.length === 0) {
    console.log("No duplicates found for Feb 2 week.");
    return;
  }

  const result = await prisma.shiftSlot.deleteMany({
    where: { id: { in: toDelete } },
  });

  console.log(`Removed ${result.count} duplicate slots for Feb 2 week.`);
}

main()
  .catch((err) => {
    console.error(err);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
