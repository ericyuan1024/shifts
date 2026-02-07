"use client";

import { useActionState } from "react";
import { adminLoginAction } from "./actions";

const initialState = { ok: true, message: "" };

export default function AdminLoginForm() {
  const [state, action, pending] = useActionState(adminLoginAction, initialState);

  return (
    <form action={action} className="login-card">
      <h1>Admin Sign In</h1>
      <p className="subtext">Enter your 4-digit admin passcode</p>
      <input
        name="passcode"
        type="password"
        inputMode="numeric"
        pattern="[0-9]*"
        maxLength={4}
        placeholder="****"
        autoFocus
      />
      {state?.message ? <p className="error">{state.message}</p> : null}
      <button type="submit" disabled={pending}>
        {pending ? "Signing in..." : "Sign in"}
      </button>
    </form>
  );
}
