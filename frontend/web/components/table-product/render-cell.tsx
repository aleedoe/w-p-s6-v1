"use client";
import React, { useState } from "react";
import { DeleteIcon } from "../icons/table/delete-icon";
import { EditIcon } from "../icons/table/edit-icon";
import { Tooltip } from "@heroui/tooltip";
import { useDisclosure } from "@heroui/modal";
import { EditProduct } from "@/app/dashboard/products/edit-product";
import { DeleteProduct } from "@/app/dashboard/products/delete-product";

interface Props {
  user: any;
  columnKey: string | React.Key;
}

export const RenderCell = ({ user, columnKey }: Props) => {
  // state modal edit
  const {
    isOpen: isEditOpen,
    onOpen: onEditOpen,
    onClose: onEditClose,
  } = useDisclosure();
  const [editId, setEditId] = useState<number | null>(null);

  // state modal delete
  const {
    isOpen: isDeleteOpen,
    onOpen: onDeleteOpen,
    onClose: onDeleteClose,
  } = useDisclosure();
  const [deleteId, setDeleteId] = useState<number | null>(null);

  // @ts-ignore
  const cellValue = user[columnKey];

  switch (columnKey) {
    case "price":
      return <span>Rp {Number(cellValue).toLocaleString("id-ID")}</span>;

    case "actions":
      return (
        <div className="flex items-center gap-4">
          {/* Tombol Edit */}
          <Tooltip content="Edit product" color="secondary">
            <button
              onClick={() => {
                setEditId(user.id);
                onEditOpen();
              }}
            >
              <EditIcon size={20} fill="#979797" />
            </button>
          </Tooltip>

          {/* Tombol Delete */}
          <Tooltip content="Delete product" color="danger">
            <button
              onClick={() => {
                setDeleteId(user.id);
                onDeleteOpen();
              }}
            >
              <DeleteIcon size={20} fill="#FF0080" />
            </button>
          </Tooltip>

          {/* Modal Edit */}
          {editId && (
            <EditProduct
              productId={editId}
              isOpen={isEditOpen}
              onClose={onEditClose}
            />
          )}

          {/* Modal Delete */}
          {deleteId && (
            <DeleteProduct
              productId={deleteId}
              isOpen={isDeleteOpen}
              onClose={onDeleteClose}
              onDeleted={(id) => {
                console.log("Product deleted:", id);
              }}
            />
          )}
        </div>
      );
    default:
      return <span>{cellValue}</span>;
  }
};
