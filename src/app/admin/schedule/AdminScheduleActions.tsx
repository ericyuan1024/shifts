"use client";

import { useActionState } from "react";
import { finalizeScheduleAction, generateScheduleAction, reopenScheduleAction } from "./actions";

const initialState = { ok: true, message: "" };

type Props = {
  weekId: string;
};

export default function AdminScheduleActions({ weekId }: Props) {
  const [genState, genAction, genPending] = useActionState(
    generateScheduleAction,
    initialState
  );
  const [finState, finAction, finPending] = useActionState(
    finalizeScheduleAction,
    initialState
  );
  const [reopenState, reopenAction, reopenPending] = useActionState(
    reopenScheduleAction,
    initialState
  );

  return (
    <>
      <form action={genAction}>
        <input type="hidden" name="weekId" value={weekId} />
        <button className="primary" type="submit" disabled={genPending}>
          {genPending ? "Generating..." : "Generate / Regenerate"}
        </button>
      </form>
      <form action={finAction}>
        <input type="hidden" name="weekId" value={weekId} />
        <button className="ghost-button" type="submit" disabled={finPending}>
          {finPending ? "Finalizing..." : "Finalize"}
        </button>
      </form>
      <form action={reopenAction}>
        <input type="hidden" name="weekId" value={weekId} />
        <button className="ghost-button" type="submit" disabled={reopenPending}>
          {reopenPending ? "Reopening..." : "Reopen"}
        </button>
      </form>
      {genState?.message ? <p className="error">{genState.message}</p> : null}
      {finState?.message ? <p className="error">{finState.message}</p> : null}
      {reopenState?.message ? <p className="error">{reopenState.message}</p> : null}
    </>
  );
}
