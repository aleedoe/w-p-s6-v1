"use client";
import React from "react";
import { DeleteIcon } from "../icons/table/delete-icon";
import { EditIcon } from "../icons/table/edit-icon";
import { Tooltip } from "@heroui/tooltip";

interface Props {
  user: any;
  columnKey: string | React.Key;
}

export const RenderCell = ({ user, columnKey }: Props) => {
  // @ts-ignore
  const cellValue = user[columnKey];

  switch (columnKey) {
    case "total_price":
      return <span>Rp {Number(cellValue).toLocaleString("id-ID")}</span>;

    case "transaction_date":
      return <span>{new Date(cellValue).toLocaleString("id-ID")}</span>;

    case "actions":
      return (
        <div className="flex items-center gap-4">
          {/* Tombol Edit */}
          <Tooltip content="Edit transaction" color="secondary">
            <button
              onClick={() =>
                alert(`Edit transaction ID: ${user.id_transaction}`)
              }
            >
              <EditIcon size={20} fill="#979797" />
            </button>
          </Tooltip>

          {/* Tombol Delete */}
          <Tooltip content="Delete transaction" color="danger">
            <button
              onClick={() =>
                alert(`Delete transaction ID: ${user.id_transaction}`)
              }
            >
              <DeleteIcon size={20} fill="#FF0080" />
            </button>
          </Tooltip>
        </div>
      );

    default:
      return <span>{cellValue}</span>;
  }
};
