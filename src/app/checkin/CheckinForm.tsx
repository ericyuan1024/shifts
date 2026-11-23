"use client";

import { useActionState, useEffect, useMemo, useState } from "react";
import { checkinAction, type CheckinState } from "./actions";
import { formatTime, roundUpToQuarter, shiftTimeOptions } from "@/lib/timeclock";

const initialState: CheckinState = { ok: false, message: "" };

type Props = { serverNow: number; suggested: "IN" | "OUT" };

export default function CheckinForm({ serverNow, suggested }: Props) {
  const [state, formAction, pending] = useActionState(checkinAction, initialState);
  const [action, setAction] = useState<"IN" | "OUT">(suggested);
  // Use server clock (offset-corrected) so a wrong phone clock can't skew defaults.
  const [offset] = useState(() => serverNow - Date.now());
  const [now, setNow] = useState(() => new Date(serverNow));
  const [selected, setSelected] = useState(() => roundUpToQuarter(new Date(serverNow)).toISOString());

  useEffect(() => {
    const id = setInterval(() => setNow(new Date(Date.now() + offset)), 30_000);
    return () => clearInterval(id);
  }, [offset]);

  const options = useMemo(() => shiftTimeOptions(now), [now]);
  const values = options.map((o) => o.toISOString());
  const value = values.includes(selected) ? selected : roundUpToQuarter(now).toISOString();

  if (state.ok) {
    return (
      <div className="checkin-success" role="status">
        <div className="checkin-check">✓</div>
        <h2>{state.action === "IN" ? "Clocked in" : "Clocked out"}</h2>
        <p className="checkin-time">{state.shiftLabel}</p>
        <p className="subtext">You can close this page.</p>
      </div>
    );
  }

  return (
    <form action={formAction} className="checkin-form">
      <input type="hidden" name="action" value={action} />
      <div className="checkin-toggle" role="radiogroup" aria-label="Action">
        {(["IN", "OUT"] as const).map((a) => (
          <button
            key={a}
            id={`checkin-action-${a.toLowerCase()}`}
            type="button"
            role="radio"
            aria-checked={action === a}
            className={action === a ? "is-active" : ""}
            onClick={() => setAction(a)}
          >
            {a === "IN" ? "Clock In" : "Clock Out"}
          </button>
        ))}
      </div>

      <label className="checkin-label" htmlFor="checkin-shift-time">
        Shift {action === "IN" ? "start" : "end"} time
      </label>
      <select
        id="checkin-shift-time"
        name="shiftTime"
        className="checkin-select"
        value={value}
        onChange={(e) => setSelected(e.target.value)}
      >
        {options.map((o) => (
          <option key={o.toISOString()} value={o.toISOString()}>
            {formatTime(o)}
          </option>
        ))}
      </select>

      {state.message ? <p className="error">{state.message}</p> : null}

      <button id="checkin-submit" type="submit" className="checkin-submit" disabled={pending}>
        {pending ? "Saving..." : action === "IN" ? "Confirm Clock In" : "Confirm Clock Out"}
      </button>
    </form>
  );
}
