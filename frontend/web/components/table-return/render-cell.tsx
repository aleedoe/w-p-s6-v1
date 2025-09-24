"use client";
import React, { useState } from "react";
import { Tooltip } from "@heroui/tooltip";
import { Chip } from "@heroui/chip";
import { useDisclosure } from "@heroui/modal";
import { EyeIcon } from "../icons/table/eye-icon";
import { DetailReturn } from "@/app/dashboard/returns/detail-return";
import { returnService } from "@/services/returnService";

interface Props {
    returnTransaction: any;
    columnKey: string | React.Key;
}

export const RenderCell = ({ returnTransaction, columnKey }: Props) => {
    // State untuk modal detail return transaksi
    const {
        isOpen: isDetailOpen,
        onOpen: onDetailOpen,
        onClose: onDetailClose,
    } = useDisclosure();
    const [selectedReturnTransactionId, setSelectedReturnTransactionId] = useState<number | null>(null);

    // @ts-ignore
    const cellValue = returnTransaction[columnKey];

    // Handler untuk aksi terima return transaksi
    const handleAcceptReturnTransaction = async (returnTransactionId: number) => {
        try {
            await returnService.acceptReturnTransaction(returnTransactionId);
            alert(`Return Transaksi #${returnTransactionId} berhasil diterima ✅`);
            onDetailClose(); // Tutup modal setelah aksi
            setSelectedReturnTransactionId(null); // Reset ID
            window.location.reload();
        } catch (error) {
            console.error("Gagal menerima return transaksi:", error);
            alert("Gagal menerima return transaksi. Silakan coba lagi.");
        }
    };

    // Handler untuk aksi tolak return transaksi
    const handleRejectReturnTransaction = async (returnTransactionId: number) => {
        try {
            await returnService.rejectReturnTransaction(returnTransactionId);
            alert(`Return Transaksi #${returnTransactionId} berhasil ditolak ❌`);
            onDetailClose();
            setSelectedReturnTransactionId(null);
            window.location.reload();
        } catch (error) {
            console.error("Gagal menolak return transaksi:", error);
            alert("Gagal menolak return transaksi. Silakan coba lagi.");
        }
    };

    // Function untuk mendapatkan warna status
    const getStatusColor = (status: string) => {
        switch (status) {
            case 'accepted':
                return 'success';
            case 'rejected':
                return 'danger';
            case 'pending':
            default:
                return 'warning';
        }
    };

    // Function untuk mendapatkan label status
    const getStatusLabel = (status: string) => {
        switch (status) {
            case 'accepted':
                return 'Diterima';
            case 'rejected':
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
                    color={getStatusColor(cellValue)}
                    variant="flat"
                    size="sm"
                >
                    {getStatusLabel(cellValue)}
                </Chip>
            );

        case "total_price":
            return <span className="font-mono">Rp {Number(cellValue).toLocaleString("id-ID")}</span>;

        case "return_date":
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
                    <Tooltip content="Lihat Detail Return Transaksi" color="secondary">
                        <button
                            onClick={() => {
                                setSelectedReturnTransactionId(returnTransaction.id_return_transaction);
                                onDetailOpen();
                            }}
                            className="text-gray-500 hover:text-blue-600 transition-colors duration-200"
                        >
                            <EyeIcon size={20} fill="currentColor" />
                        </button>
                    </Tooltip>

                    {/* Modal Detail Return Transaksi */}
                    {selectedReturnTransactionId && (
                        <DetailReturn
                            returnTransactionId={selectedReturnTransactionId}
                            isOpen={isDetailOpen}
                            onClose={() => {
                                onDetailClose();
                                setSelectedReturnTransactionId(null);
                            }}
                            onAccept={handleAcceptReturnTransaction}
                            onReject={handleRejectReturnTransaction}
                        />
                    )}
                </div>
            );

        default:
            return <span>{cellValue}</span>;
    }
};