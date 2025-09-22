"use client";
import React, { useState } from "react";
import { DeleteIcon } from "../icons/table/delete-icon";
import { EditIcon } from "../icons/table/edit-icon";
import { Tooltip } from "@heroui/tooltip";
import { useDisclosure } from "@heroui/modal";
import { EditProduct } from "@/app/dashboard/products/edit-product";

interface Props {
  user: any;
  columnKey: string | React.Key;
}

export const RenderCell = ({ user, columnKey }: Props) => {
  // state untuk modal edit
  const { isOpen, onOpen, onClose } = useDisclosure();
  const [editId, setEditId] = useState<number | null>(null);

  // @ts-ignore
  const cellValue = user[columnKey];

  switch (columnKey) {
    case "price":
      return <span>Rp {Number(cellValue).toLocaleString("id-ID")}</span>;

    case "actions":
      return (
        <div className="flex items-center gap-4">
          {/* Tombol Edit */}
          <div>
            <Tooltip content="Edit product" color="secondary">
              <button
                onClick={() => {
                  setEditId(user.id);
                  onOpen();
                }}
              >
                <EditIcon size={20} fill="#979797" />
              </button>
            </Tooltip>
          </div>

          {/* Tombol Delete */}
          <div>
            <Tooltip content="Delete product" color="danger">
              <button onClick={() => console.log("Delete product", user.id)}>
                <DeleteIcon size={20} fill="#FF0080" />
              </button>
            </Tooltip>
          </div>

          {/* Modal Edit Product */}
          {editId && (
            <EditProduct
              productId={editId}
              isOpen={isOpen}
              onClose={onClose}
            />
          )}
        </div>
      );
    default:
      return <span>{cellValue}</span>;
  }
};
