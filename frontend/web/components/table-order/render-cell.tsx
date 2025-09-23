"use client";
import React, { useState } from "react";
import { Tooltip } from "@heroui/tooltip";
import { useDisclosure } from "@heroui/modal";
import { EyeIcon } from "../icons/table/eye-icon";
import { DetailOrder } from "@/app/dashboard/orders/detail-order";

interface Props {
  user: any;
  columnKey: string | React.Key;
}

export const RenderCell = ({ user, columnKey }: Props) => {
  // State untuk modal detail transaksi
  const {
    isOpen: isDetailOpen,
    onOpen: onDetailOpen,
    onClose: onDetailClose,
  } = useDisclosure();
  const [selectedTransactionId, setSelectedTransactionId] = useState<number | null>(null);

  // @ts-ignore
  const cellValue = user[columnKey];

  // Handler untuk aksi terima transaksi
  const handleAcceptTransaction = (transactionId: number) => {
    console.log("Transaksi diterima:", transactionId);
    alert(`Transaksi #${transactionId} berhasil diterima ✅`);
    // TODO: Implement actual API call to accept transaction
  };

  // Handler untuk aksi tolak transaksi
  const handleRejectTransaction = (transactionId: number) => {
    console.log("Transaksi ditolak:", transactionId);
    alert(`Transaksi #${transactionId} ditolak ❌`);
    // TODO: Implement actual API call to reject transaction
  };

  switch (columnKey) {
    case "total_price":
      return <span className="font-mono">Rp {Number(cellValue).toLocaleString("id-ID")}</span>;

    case "transaction_date":
      return (
        <span className="text-sm">
          {new Date(cellValue).toLocaleDateString("id-ID", {
            day: "2-digit",
            month: "short",
            year: "numeric",
            hour: "2-digit",
            minute: "2-digit"
          })}
        </span>
      );

    case "actions":
      return (
        <div className="flex items-center gap-4">
          {/* Tombol Detail */}
          <Tooltip content="Lihat Detail Transaksi" color="secondary">
            <button
              onClick={() => {
                setSelectedTransactionId(user.id_transaction);
                onDetailOpen();
              }}
              className="text-gray-500 hover:text-blue-600 transition-colors duration-200"
            >
              <EyeIcon size={20} fill="currentColor" />
            </button>
          </Tooltip>

          {/* Modal Detail Transaksi */}
          {selectedTransactionId && (
            <DetailOrder
              transactionId={selectedTransactionId}
              isOpen={isDetailOpen}
              onClose={() => {
                onDetailClose();
                setSelectedTransactionId(null);
              }}
              onAccept={handleAcceptTransaction}
              onReject={handleRejectTransaction}
            />
          )}
        </div>
      );

    default:
      return <span>{cellValue}</span>;
  }
};