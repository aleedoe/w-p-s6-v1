"use client";
import React, { useState } from "react";
import { Tooltip } from "@heroui/tooltip";
import { Chip } from "@heroui/chip";
import { useDisclosure } from "@heroui/modal";
import { EyeIcon } from "../icons/table/eye-icon";
import { DetailOrder } from "@/app/dashboard/orders/detail-order";
import { transactionService } from "@/services/transactionService";

interface Props {
  order: any;
  columnKey: string | React.Key;
}

export const RenderCell = ({ order, columnKey }: Props) => {
  // State untuk modal detail transaksi
  const {
    isOpen: isDetailOpen,
    onOpen: onDetailOpen,
    onClose: onDetailClose,
  } = useDisclosure();
  const [selectedTransactionId, setSelectedTransactionId] = useState<number | null>(null);

  // @ts-ignore
  const cellValue = order[columnKey];

  // Handler untuk aksi terima transaksi
  const handleAcceptTransaction = async (transactionId: number) => {
    try {
      await transactionService.acceptTransaction(transactionId);
      alert(`Transaksi #${transactionId} berhasil diterima ✅`);
      onDetailClose(); // Tutup modal setelah aksi
      setSelectedTransactionId(null); // Reset ID
      window.location.reload();
    } catch (error) {
      console.error("Gagal menerima transaksi:", error);
      alert("Gagal menerima transaksi. Silakan coba lagi.");
    }
  };

  // Handler untuk aksi tolak transaksi
  const handleRejectTransaction = async (transactionId: number) => {
    try {
      await transactionService.rejectTransaction(transactionId);
      alert(`Transaksi #${transactionId} berhasil ditolak ❌`);
      onDetailClose();
      setSelectedTransactionId(null);
      window.location.reload();
    } catch (error) {
      console.error("Gagal menolak transaksi:", error);
      alert("Gagal menolak transaksi. Silakan coba lagi.");
    }
  };

  // Function untuk mendapatkan warna status
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'success';
      case 'cancelled':
        return 'danger';
      case 'pending':
      default:
        return 'warning';
    }
  };

  // Function untuk mendapatkan label status
  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'completed':
        return 'Diterima';
      case 'cancelled':
        return 'Ditolak';
      case 'pending':
      default:
        return 'Menunggu';
    }
  };

  switch (columnKey) {
    case "status":
      return (
        <Chip 
          color={getStatusColor(cellValue || 'pending')}
          variant="flat"
          size="sm"
        >
          {getStatusLabel(cellValue || 'pending')}
        </Chip>
      );

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
                setSelectedTransactionId(order.id_transaction);
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