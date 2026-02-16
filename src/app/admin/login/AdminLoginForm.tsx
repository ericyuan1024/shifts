"use client";

import { useActionState, useEffect, useState } from "react";
import { adminLoginAction } from "./actions";

const initialState = { ok: true, message: "" };

export default function AdminLoginForm() {
  const [state, action, pending] = useActionState(adminLoginAction, initialState);
  const [globalPasscode, setGlobalPasscode] = useState("");

  useEffect(() => {
    const saved = window.localStorage.getItem("globalPasscode");
    if (saved) setGlobalPasscode(saved);
  }, []);

  const handleGlobalChange = (value: string) => {
    setGlobalPasscode(value);
    window.localStorage.setItem("globalPasscode", value);
  };

  return (
    <form action={action} className="login-card">
      <h1>Admin Sign In</h1>
      <p className="subtext">Enter the team passcode and your admin code</p>
      <input
        name="globalPasscode"
        type="password"
        placeholder="Team passcode"
        value={globalPasscode}
        onChange={(event) => handleGlobalChange(event.target.value)}
      />
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
