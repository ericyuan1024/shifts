"use client";

import { useState } from "react";
import { deleteShiftTemplateAction } from "./actions";

type Props = {
  templateId: string;
};

export default function DeleteShiftTemplateModal({ templateId }: Props) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <button className="ghost-button" type="button" onClick={() => setOpen(true)}>
        Delete
      </button>
      {open ? (
        <div className="modal-backdrop" onClick={() => setOpen(false)}>
          <div className="modal-card" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>Delete Shift Slot</h3>
              <button className="ghost-button" type="button" onClick={() => setOpen(false)}>
                Close
              </button>
            </div>
            <p className="subtext">Are you sure you want to delete this slot?</p>
            <form action={deleteShiftTemplateAction} className="row-actions">
              <input type="hidden" name="id" value={templateId} />
              <button type="submit" className="primary">Yes, delete</button>
              <button className="ghost-button" type="button" onClick={() => setOpen(false)}>
                Cancel
              </button>
            </form>
          </div>
        </div>
      ) : null}
    </>
  );
}
