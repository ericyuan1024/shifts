"use client";

import { useRouter } from "next/navigation";

type WeekOption = {
  value: string;
  label: string;
};

type Props = {
  value: string;
  options: WeekOption[];
  path: string;
};

export default function WeekSelector({ value, options, path }: Props) {
  const router = useRouter();

  return (
    <select
      name="week"
      value={value}
      onChange={(e) => router.push(`${path}?week=${e.target.value}`)}
    >
      {options.map((option) => (
        <option key={option.value} value={option.value}>
          {option.label}
        </option>
      ))}
    </select>
  );
}
