"use client";

import { useActionState } from "react";
import { changePasscodeAction } from "./actions";

const initialState = { ok: true, message: "" };

export default function ChangePasscodeForm() {
  const [state, action, pending] = useActionState(
    changePasscodeAction,
    initialState
  );

  return (
    <form className="card" action={action}>
      <h2>Change Passcode</h2>
      <input name="current" placeholder="Current 4-digit passcode" />
      <input name="next" placeholder="New 4-digit passcode" />
      {state?.message ? <p className="subtext">{state.message}</p> : null}
      <button className="primary" type="submit" disabled={pending}>
        {pending ? "Saving..." : "Save"}
      </button>
    </form>
  );
}
