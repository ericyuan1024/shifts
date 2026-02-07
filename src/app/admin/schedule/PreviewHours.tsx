"use client";

import { useMemo, useState } from "react";

type EmployeeHours = {
  id: string;
  name: string;
  hours: number;
};

type Props = {
  items: EmployeeHours[];
};

export default function PreviewHours({ items }: Props) {
  const [open, setOpen] = useState(false);

  const totalHours = useMemo(
    () => items.reduce((sum, item) => sum + item.hours, 0),
    [items]
  );

  return (
    <>
      <button className="ghost-button" onClick={() => setOpen(true)}>
        Stat
      </button>
      {open ? (
        <div className="modal-backdrop" onClick={() => setOpen(false)}>
          <div className="modal-card" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>Hours Stats</h3>
              <button className="ghost-button" onClick={() => setOpen(false)}>
                Close
              </button>
            </div>
            {items.length === 0 ? (
              <p className="subtext">No assignments yet.</p>
            ) : (
              <div className="modal-list">
                {items.map((item) => (
                  <div key={item.id} className="modal-row">
                    <strong>{item.name}</strong>
                    <span>{item.hours.toFixed(2)} hrs</span>
                  </div>
                ))}
                <div className="modal-row total">
                  <strong>Total</strong>
                  <span>{totalHours.toFixed(2)} hrs</span>
                </div>
              </div>
            )}
          </div>
        </div>
      ) : null}
    </>
  );
}
