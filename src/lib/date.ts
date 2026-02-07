export function startOfWeek(date: Date) {
  const d = new Date(date);
  const day = d.getDay();
  const diff = (day + 6) % 7; // Monday=0
  d.setDate(d.getDate() - diff);
  d.setHours(0, 0, 0, 0);
  return d;
}

export function addDays(date: Date, days: number) {
  const d = new Date(date);
  d.setDate(d.getDate() + days);
  return d;
}

export function formatDate(date: Date) {
  return date.toISOString().slice(0, 10);
}

export function mondayIndex(date: Date) {
  return (date.getDay() + 6) % 7;
}

export function formatDateLocal(date: Date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

const WEEKDAY_INDEX: Record<string, number> = {
  Mon: 0,
  Tue: 1,
  Wed: 2,
  Thu: 3,
  Fri: 4,
  Sat: 5,
  Sun: 6,
};

export function formatDateInTimeZone(date: Date, timeZone: string) {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(date);
}

export function startOfWeekInTimeZone(date: Date, timeZone: string) {
  const weekday = new Intl.DateTimeFormat("en-US", {
    timeZone,
    weekday: "short",
  }).format(date);
  const dayIndex = WEEKDAY_INDEX[weekday] ?? 0;

  const dateParts = new Intl.DateTimeFormat("en-CA", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(date);

  const year = Number(dateParts.find((p) => p.type === "year")?.value);
  const month = Number(dateParts.find((p) => p.type === "month")?.value);
  const day = Number(dateParts.find((p) => p.type === "day")?.value);

  const base = new Date(Date.UTC(year, month - 1, day, 12, 0, 0));
  const monday = new Date(base);
  monday.setUTCDate(monday.getUTCDate() - dayIndex);
  return monday;
}
