"use client";

import { useActionState } from "react";
import { loginAction } from "./actions";

const initialState = { ok: true, message: "" };

export default function LoginForm() {
  const [state, action, pending] = useActionState(loginAction, initialState);

  return (
    <form action={action} className="login-card">
      <h1>Employee Sign In</h1>
      <p className="subtext">Enter your 4-digit passcode</p>
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
