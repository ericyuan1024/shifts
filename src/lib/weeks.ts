import { prisma } from "@/lib/db";
import { addDays, startOfWeekInTimeZone } from "@/lib/date";

const DEFAULT_TZ = "America/Vancouver";

export async function ensureNextTwoWeeks() {
  const today = new Date();
  const start = startOfWeekInTimeZone(today, DEFAULT_TZ);
  const starts = [start, addDays(start, 7)];

  const existing = await prisma.week.findMany({
    where: { startDate: { in: starts } },
  });

  const existingMap = new Set(existing.map((w) => w.startDate.toISOString()));
  const toCreate = starts.filter(
    (date) => !existingMap.has(date.toISOString())
  );

  if (toCreate.length) {
    await prisma.week.createMany({
      data: toCreate.map((d) => ({ startDate: d })),
    });
  }

  return prisma.week.findMany({
    where: { startDate: { in: starts } },
    orderBy: { startDate: "asc" },
    include: { schedule: true },
  });
}

export async function ensureNextThreeWeeks() {
  const today = new Date();
  const start = startOfWeekInTimeZone(today, DEFAULT_TZ);
  const starts = [start, addDays(start, 7), addDays(start, 14)];

  const existing = await prisma.week.findMany({
    where: { startDate: { in: starts } },
  });

  const existingMap = new Set(existing.map((w) => w.startDate.toISOString()));
  const toCreate = starts.filter(
    (date) => !existingMap.has(date.toISOString())
  );

  if (toCreate.length) {
    await prisma.week.createMany({
      data: toCreate.map((d) => ({ startDate: d })),
    });
  }

  return prisma.week.findMany({
    where: { startDate: { in: starts } },
    orderBy: { startDate: "asc" },
    include: { schedule: true },
  });
}

export async function ensureSlotsForWeek(weekId: string) {
  const templates = await prisma.shiftTemplate.findMany({
    where: { isActive: true },
  });

  if (!templates.length) return;

  const week = await prisma.week.findUnique({ where: { id: weekId } });
  if (!week) return;

  const existing = await prisma.shiftSlot.findMany({
    where: { weekId },
    select: { roleTypeId: true, date: true, startAt: true, endAt: true },
  });

  const existingKey = new Set(
    existing.map(
      (slot) =>
        `${slot.roleTypeId}-${slot.date.toISOString()}-${slot.startAt.toISOString()}-${slot.endAt.toISOString()}`
    )
  );

  const slotsToCreate = templates
    .map((template) => {
      const date = addDays(week.startDate, template.dayOfWeek);
      const [startHour, startMinute] = template.startTime
        .split(":")
        .map(Number);
      const [endHour, endMinute] = template.endTime.split(":").map(Number);

      const startAt = new Date(date);
      startAt.setHours(startHour, startMinute, 0, 0);

      const endAt = new Date(date);
      endAt.setHours(endHour, endMinute, 0, 0);

      const key = `${template.roleTypeId}-${date.toISOString()}-${startAt.toISOString()}-${endAt.toISOString()}`;
      if (existingKey.has(key)) return null;

      return {
        weekId,
        roleTypeId: template.roleTypeId,
        date,
        startAt,
        endAt,
        hours: template.hours,
      };
    })
    .filter((slot) => slot !== null);

  if (slotsToCreate.length) {
    await prisma.shiftSlot.createMany({
      data: slotsToCreate,
    });
  }
}
