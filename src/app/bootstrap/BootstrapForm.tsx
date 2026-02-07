"use client";

import { useActionState } from "react";
import { bootstrapAdminAction } from "./actions";

const initialState = { ok: true, message: "" };

export default function BootstrapForm() {
  const [state, action, pending] = useActionState(
    bootstrapAdminAction,
    initialState
  );

  return (
    <form className="login-card" action={action}>
      <h1>Initialize Admin</h1>
      <p className="subtext">Create the first admin account</p>
      <input name="name" placeholder="Name" />
      <input name="passcode" placeholder="4-digit passcode" inputMode="numeric" />
      {state?.message ? <p className="error">{state.message}</p> : null}
      <button type="submit" disabled={pending}>
        {pending ? "Creating..." : "Create Admin"}
      </button>
    </form>
  );
}
