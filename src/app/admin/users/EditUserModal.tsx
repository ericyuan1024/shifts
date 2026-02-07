"use client";

import { useState } from "react";
import { updateUserAction } from "./actions";

type RoleType = { id: string; name: string };

type UserRow = {
  id: string;
  name: string;
  role: "ADMIN" | "EMPLOYEE";
  roleTypeId: string | null;
  weight: number;
};

type Props = {
  user: UserRow;
  roleTypes: RoleType[];
};

export default function EditUserModal({ user, roleTypes }: Props) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <button className="ghost-button" type="button" onClick={() => setOpen(true)}>
        Edit
      </button>
      {open ? (
        <div className="modal-backdrop" onClick={() => setOpen(false)}>
          <div className="modal-card" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>Edit User</h3>
              <button className="ghost-button" type="button" onClick={() => setOpen(false)}>
                Close
              </button>
            </div>
            <form action={updateUserAction} className="modal-list">
              <input type="hidden" name="userId" value={user.id} />
              <label>
                Name
                <input name="name" defaultValue={user.name} />
              </label>
              <label>
                Role
                <select name="role" defaultValue={user.role}>
                  <option value="EMPLOYEE">Employee</option>
                  <option value="ADMIN">Admin</option>
                </select>
              </label>
              <label>
                Role Type
                <select name="roleTypeId" defaultValue={user.roleTypeId ?? ""}>
                  <option value="">None</option>
                  {roleTypes.map((role: RoleType) => (
                    <option key={role.id} value={role.id}>
                      {role.name}
                    </option>
                  ))}
                </select>
              </label>
              <label>
                Weight
                <input name="weight" defaultValue={String(user.weight)} />
              </label>
              <label>
                New 4-digit passcode (optional)
                <input name="passcode" placeholder="****" maxLength={4} />
              </label>
              <button type="submit" className="primary">
                Save
              </button>
            </form>
          </div>
        </div>
      ) : null}
    </>
  );
}
