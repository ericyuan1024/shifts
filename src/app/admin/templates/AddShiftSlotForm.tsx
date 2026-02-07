"use client";

import { useMemo, useState } from "react";
import { createTemplateAction } from "./actions";

type RoleType = { id: string; name: string };

type Props = {
  roleTypes: RoleType[];
  days: string[];
};

function toMinutes(value: string) {
  const [h, m] = value.split(":").map(Number);
  if (Number.isNaN(h) || Number.isNaN(m)) return null;
  return h * 60 + m;
}

export default function AddShiftSlotForm({ roleTypes, days }: Props) {
  const [startTime, setStartTime] = useState("09:00");
  const [endTime, setEndTime] = useState("17:00");

  const { hours, error } = useMemo(() => {
    const start = toMinutes(startTime);
    const end = toMinutes(endTime);
    if (start === null || end === null) return { hours: "", error: "" };
    if (end <= start) return { hours: "", error: "End time must be later." };
    const diff = (end - start) / 60;
    return { hours: diff.toFixed(2), error: "" };
  }, [startTime, endTime]);

  return (
    <form className="card" action={createTemplateAction}>
      <h2>Add Shift Slot</h2>
      <select name="roleTypeId" defaultValue="">
        <option value="" disabled>
          Select role
        </option>
        {roleTypes.map((role: RoleType) => (
          <option key={role.id} value={role.id}>
            {role.name}
          </option>
        ))}
      </select>
      <select name="dayOfWeek" defaultValue="0">
        {days.map((label, index) => (
          <option key={label} value={index}>
            {label}
          </option>
        ))}
      </select>
      <div className="row-actions">
        <input
          name="startTime"
          type="time"
          value={startTime}
          onChange={(e) => setStartTime(e.target.value)}
        />
        <input
          name="endTime"
          type="time"
          value={endTime}
          onChange={(e) => setEndTime(e.target.value)}
        />
      </div>
      <input name="hours" value={hours} readOnly placeholder="Hours" />
      {error ? <p className="error">{error}</p> : null}
      <button type="submit" className="primary" disabled={!hours}>
        Save Slot
      </button>
    </form>
  );
}
