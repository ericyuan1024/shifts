// BC adopted permanent PDT (UTC-7). Using "Etc/GMT+7" (or "America/Dawson")
// ensures both the client browser and the server container (even if its ICU
// tzdata still has America/Vancouver at UTC-8 in winter) format identical
// UTC-7 wall-clock times.
export const TIME_ZONE = "Etc/GMT+7";
export const QUARTER_MS = 15 * 60 * 1000;
export const EDIT_WINDOW_MS = 60 * 60 * 1000;

/** Server clock timestamp in milliseconds (helper for Server Components). */
export function getServerNowMs() {
  return Date.now();
}

/** UTC instant of local midnight for a YYYY-MM-DD date in TIME_ZONE. */
export function zonedMidnight(dateStr: string) {
  const [y, m, d] = dateStr.split("-").map(Number);
  const guess = Date.UTC(y, m - 1, d);
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone: TIME_ZONE,
    hourCycle: "h23",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  }).formatToParts(new Date(guess));
  const get = (t: string) => Number(parts.find((p) => p.type === t)?.value);
  const asLocal = Date.UTC(get("year"), get("month") - 1, get("day"), get("hour"), get("minute"));
  return new Date(guess - (asLocal - guess));
}

/** YYYY-MM-DD in TIME_ZONE. */
export function localDateString(date: Date) {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: TIME_ZONE,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(date);
}

/**
 * Round up to the next 15-minute mark (exact quarters stay as-is).
 * Vancouver's UTC offset is a whole number of hours, so rounding on the
 * epoch is equivalent to rounding on local wall-clock time.
 */
export function roundUpToQuarter(date: Date) {
  return new Date(Math.ceil(date.getTime() / QUARTER_MS) * QUARTER_MS);
}

/** All quarter marks within ±1 hour of `now`. */
export function shiftTimeOptions(now: Date) {
  const start = Math.ceil((now.getTime() - EDIT_WINDOW_MS) / QUARTER_MS) * QUARTER_MS;
  const end = now.getTime() + EDIT_WINDOW_MS;
  const options: Date[] = [];
  for (let t = start; t <= end; t += QUARTER_MS) options.push(new Date(t));
  return options;
}

export function isValidShiftTime(shiftTime: Date, now: Date) {
  const t = shiftTime.getTime();
  if (Number.isNaN(t) || t % QUARTER_MS !== 0) return false;
  return Math.abs(t - now.getTime()) <= EDIT_WINDOW_MS;
}

export function formatTime(date: Date) {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: TIME_ZONE,
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  }).format(date);
}

export function formatDateTime(date: Date) {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: TIME_ZONE,
    month: "short",
    day: "numeric",
    weekday: "short",
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  }).format(date);
}

export function formatShortDate(date: Date) {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: TIME_ZONE,
    month: "short",
    day: "numeric",
    weekday: "short",
  }).format(date);
}

type Punch = { id: string; action: "IN" | "OUT"; shiftTime: Date };

export type WorkPeriod = {
  in: Punch | null;
  out: Punch | null;
  hours: number | null;
};

/**
 * Pair a single user's punches (any order) into work periods by shiftTime.
 * Unmatched IN/OUT produce a period with hours = null so they can be flagged.
 * Basis for the future hours report.
 */
export function pairPunches<T extends Punch>(punches: T[]): WorkPeriod[] {
  const sorted = [...punches].sort((a, b) => a.shiftTime.getTime() - b.shiftTime.getTime());
  const periods: WorkPeriod[] = [];
  let open: T | null = null;
  for (const p of sorted) {
    if (p.action === "IN") {
      if (open) periods.push({ in: open, out: null, hours: null });
      open = p;
    } else if (open) {
      const hours = (p.shiftTime.getTime() - open.shiftTime.getTime()) / 3_600_000;
      periods.push({ in: open, out: p, hours });
      open = null;
    } else {
      periods.push({ in: null, out: p, hours: null });
    }
  }
  if (open) periods.push({ in: open, out: null, hours: null });
  return periods;
}
