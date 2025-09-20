// components/table-product/render-cell.tsx
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
    case "price":
      return <span>Rp {Number(cellValue).toLocaleString("id-ID")}</span>;

    case "actions":
      return (
        <div className="flex items-center gap-4 ">
          <div>
            <Tooltip content="Edit product" color="secondary">
              <button onClick={() => console.log("Edit product", user.id)}>
                <EditIcon size={20} fill="#979797" />
              </button>
            </Tooltip>
          </div>
          <div>
            <Tooltip content="Delete product" color="danger">
              <button onClick={() => console.log("Delete product", user.id)}>
                <DeleteIcon size={20} fill="#FF0080" />
              </button>
            </Tooltip>
          </div>
        </div>
      );
    default:
      return <span>{cellValue}</span>;
  }
};
