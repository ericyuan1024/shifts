"use client";

import { useMemo, useState } from "react";
import { updateShiftTemplateAction } from "./actions";

type Template = {
  id: string;
  dayOfWeek: number;
  startTime: string;
  endTime: string;
  hours: number;
  roleName: string;
};

type Props = {
  template: Template;
};

const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

function toMinutes(value: string) {
  const [h, m] = value.split(":").map(Number);
  if (Number.isNaN(h) || Number.isNaN(m)) return null;
  return h * 60 + m;
}

export default function EditShiftTemplateModal({ template }: Props) {
  const [open, setOpen] = useState(false);
  const [dayOfWeek, setDayOfWeek] = useState(String(template.dayOfWeek));
  const [startTime, setStartTime] = useState(template.startTime);
  const [endTime, setEndTime] = useState(template.endTime);

  const { hours, error } = useMemo(() => {
    const start = toMinutes(startTime);
    const end = toMinutes(endTime);
    if (start === null || end === null) return { hours: "", error: "" };
    if (end <= start) return { hours: "", error: "End time must be later." };
    return { hours: ((end - start) / 60).toFixed(2), error: "" };
  }, [startTime, endTime]);

  return (
    <>
      <button className="ghost-button" type="button" onClick={() => setOpen(true)}>
        Edit
      </button>
      {open ? (
        <div className="modal-backdrop" onClick={() => setOpen(false)}>
          <div className="modal-card" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>Edit Shift Slot</h3>
              <button className="ghost-button" type="button" onClick={() => setOpen(false)}>
                Close
              </button>
            </div>
            <form action={updateShiftTemplateAction} className="modal-list">
              <input type="hidden" name="id" value={template.id} />
              <label>
                Role
                <input value={template.roleName} readOnly />
              </label>
              <label>
                Day
                <select
                  name="dayOfWeek"
                  value={dayOfWeek}
                  onChange={(e) => setDayOfWeek(e.target.value)}
                >
                  {days.map((label, index) => (
                    <option key={label} value={index}>
                      {label}
                    </option>
                  ))}
                </select>
              </label>
              <label>
                Start
                <input
                  name="startTime"
                  type="time"
                  value={startTime}
                  onChange={(e) => setStartTime(e.target.value)}
                />
              </label>
              <label>
                End
                <input
                  name="endTime"
                  type="time"
                  value={endTime}
                  onChange={(e) => setEndTime(e.target.value)}
                />
              </label>
              <label>
                Hours
                <input name="hours" value={hours} readOnly />
              </label>
              {error ? <p className="error">{error}</p> : null}
              <button type="submit" className="primary" disabled={!hours}>
                Save
              </button>
            </form>
          </div>
        </div>
      ) : null}
    </>
  );
}
