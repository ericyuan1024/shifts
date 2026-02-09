import { prisma } from "@/lib/db";
import { PreferenceChoice } from "@prisma/client";
import { mondayIndex } from "@/lib/date";

const BASE_SCORE: Record<PreferenceChoice, number> = {
  WANT: 3,
  CAN: 1,
  CANT: -1000,
};

function mulberry32(seed: number) {
  return function () {
    let t = (seed += 0x6d2b79f5);
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

type Candidate = {
  userId: string;
  weight: number;
  maxHoursWeek: number;
  preference: PreferenceChoice;
};

type SlotInput = {
  id: string;
  hours: number;
  roleTypeId: string;
  date: Date;
  startAt: Date;
  endAt: Date;
};

export async function generateScheduleAssignments(
  weekId: string,
  seed: number
) {
  const users = await prisma.user.findMany({
    where: { role: "EMPLOYEE" },
    select: {
      id: true,
      weight: true,
      maxHoursWeek: true,
      roleTypeId: true,
      roleType: { select: { name: true } },
    },
  });

  const [slots, preferences, templates] = await Promise.all([
    prisma.shiftSlot.findMany({
      where: { weekId },
      select: {
        id: true,
        hours: true,
        roleTypeId: true,
        date: true,
        startAt: true,
        endAt: true,
      },
    }),
    prisma.preference.findMany({
      where: { shiftSlot: { weekId } },
      select: { userId: true, shiftSlotId: true, choice: true },
    }),
    prisma.availabilityTemplate.findMany({
      where: { userId: { in: users.map((u) => u.id) } },
      select: {
        userId: true,
        roleTypeId: true,
        dayOfWeek: true,
        startTime: true,
        endTime: true,
        choice: true,
      },
    }),
  ]);

  const preferenceMap = new Map<string, PreferenceChoice>();
  for (const pref of preferences) {
    preferenceMap.set(`${pref.userId}-${pref.shiftSlotId}`, pref.choice);
  }
  const templateMap = new Map<string, PreferenceChoice>();
  for (const template of templates) {
    templateMap.set(
      `${template.userId}-${template.roleTypeId}-${template.dayOfWeek}-${template.startTime}-${template.endTime}`,
      template.choice
    );
  }

  const slotsInput: SlotInput[] = slots;
  const userMap = new Map(users.map((u) => [u.id, u]));

  const candidatesBySlot = new Map<string, Candidate[]>();
  for (const slot of slotsInput) {
    const candidates: Candidate[] = [];
    for (const user of users) {
      const isManager = user.roleType?.name === "Manager";
      if (!isManager && user.roleTypeId !== slot.roleTypeId) continue;
      const day = mondayIndex(slot.date);
      const start = slot.startAt.toTimeString().slice(0, 5);
      const end = slot.endAt.toTimeString().slice(0, 5);
      const pref =
        preferenceMap.get(`${user.id}-${slot.id}`) ??
        templateMap.get(
          `${user.id}-${slot.roleTypeId}-${day}-${start}-${end}`
        ) ??
        "CANT";
      if (pref === "CANT") continue;
      candidates.push({
        userId: user.id,
        weight: user.weight,
        maxHoursWeek: user.maxHoursWeek,
        preference: pref,
      });
    }
    candidatesBySlot.set(slot.id, candidates);
  }

  const sortedSlots = [...slotsInput].sort((a, b) => {
    const ac = candidatesBySlot.get(a.id)?.length ?? 0;
    const bc = candidatesBySlot.get(b.id)?.length ?? 0;
    return ac - bc;
  });

  const attempts = 20;
  const debugLog: string[] = [];
  debugLog.push(
    `[scheduler] week=${weekId} slots=${slotsInput.length} users=${users.length}`
  );
  let bestAssignments: { shiftSlotId: string; userId: string }[] = [];
  let bestCount = -1;
  for (let attempt = 0; attempt < attempts; attempt += 1) {
    const rand = mulberry32(seed + attempt * 101);
    const assignedHours = new Map<string, number>();
    const assignedDays = new Map<string, Set<string>>();
    const assignments: { shiftSlotId: string; userId: string }[] = [];

    for (const slot of sortedSlots) {
      const candidates = (candidatesBySlot.get(slot.id) || []).filter(
        (candidate) => {
          const user = userMap.get(candidate.userId);
          const isManager = user?.roleType?.name === "Manager";
          const currentHours = assignedHours.get(candidate.userId) || 0;
          if (!isManager && currentHours + slot.hours > candidate.maxHoursWeek) {
            return false;
          }
          if (isManager) return true;

          const dayKey = slot.date.toISOString().slice(0, 10);
          const days = assignedDays.get(candidate.userId);
          if (!days) return true;
          return !days.has(dayKey);
        }
      );

      if (!candidates.length) {
        const slotDay = slot.date.toISOString().slice(0, 10);
        debugLog.push(
          `[scheduler] attempt=${attempt} slot=${slot.id} role=${slot.roleTypeId} date=${slotDay} hours=${slot.hours} candidates=0`
        );
        continue;
      }

      candidates.sort((a, b) => {
        const aScore =
          BASE_SCORE[a.preference] + a.weight * 0.5 + rand() * 0.2;
        const bScore =
          BASE_SCORE[b.preference] + b.weight * 0.5 + rand() * 0.2;
        return bScore - aScore;
      });

      const choice = candidates[0];
      assignments.push({ shiftSlotId: slot.id, userId: choice.userId });
      const currentHours = assignedHours.get(choice.userId) || 0;
      assignedHours.set(choice.userId, currentHours + slot.hours);
      const dayKey = slot.date.toISOString().slice(0, 10);
      const days = assignedDays.get(choice.userId) ?? new Set<string>();
      days.add(dayKey);
      assignedDays.set(choice.userId, days);
    }

    if (assignments.length === slotsInput.length) {
      console.log(
        `[scheduler] success attempt=${attempt} assignments=${assignments.length}`
      );
      return assignments;
    }

    if (assignments.length > bestCount) {
      bestAssignments = assignments;
      bestCount = assignments.length;
    }
  }

  console.log(debugLog.join("\n"));
  console.log(
    `[scheduler] partial assignments=${bestCount} of ${slotsInput.length}`
  );
  return bestAssignments;
}
