"use client";
import React, { useState, useEffect } from "react";
import {
    Modal,
    ModalBody,
    ModalContent,
    ModalFooter,
    ModalHeader,
} from "@heroui/modal";
import { Button } from "@heroui/button";
import {
    Table,
    TableHeader,
    TableColumn,
    TableBody,
    TableRow,
    TableCell,
} from "@heroui/table";
import { Divider } from "@heroui/divider";
import { Card, CardBody } from "@heroui/card";
import { Chip } from "@heroui/chip";
import { transactionService } from "@/services/transactionService";

interface Product {
    id_product: number;
    price: number;
    product_name: string;
    quantity: number;
    subtotal: number;
}

interface TransactionDetail {
    id_reseller: number;
    id_transaction: number;
    products: Product[];
    reseller_name: string;
    total_items: number;
    total_price: number;
    transaction_date: string;
    status?: string; // Tambahkan field status
}

interface TransactionDetailModalProps {
    transactionId: number | null;
    isOpen: boolean;
    onClose: () => void;
    onAccept?: (id: number) => void;
    onReject?: (id: number) => void;
}

export const DetailOrder: React.FC<TransactionDetailModalProps> = ({
    transactionId,
    isOpen,
    onClose,
    onAccept,
    onReject,
}) => {
    const [transactionDetail, setTransactionDetail] =
        useState<TransactionDetail | null>(null);
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        const fetchTransactionDetail = async () => {
            if (!transactionId || !isOpen) return;

            setLoading(true);
            try {
                const detail = await transactionService.getTransactionById(
                    transactionId
                );
                setTransactionDetail(detail as any);
            } catch (error) {
                console.error("Failed to fetch transaction detail:", error);
                alert("Gagal memuat detail transaksi");
            } finally {
                setLoading(false);
            }
        };

        fetchTransactionDetail();
    }, [transactionId, isOpen]);

    const handleAccept = () => {
        if (transactionId && onAccept) {
            onAccept(transactionId);
            onClose();
        }
    };

    const handleReject = () => {
        if (transactionId && onReject) {
            onReject(transactionId);
            onClose();
        }
    };

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

    return (
        <Modal
            isOpen={isOpen}
            onClose={onClose}
            backdrop="blur"
            size="4xl"
            scrollBehavior="inside"
        >
            <ModalContent>
                {(onClose) => (
                    <>
                        <ModalHeader className="flex flex-col gap-1 border-b border-gray-700">
                            <h2 className="text-2xl font-bold ">
                                Detail Transaksi
                            </h2>
                            {transactionDetail && (
                                <div className="flex items-center gap-2">
                                    <p className="text-sm text-gray-400">
                                        ID Transaksi: #{transactionDetail.id_transaction}
                                    </p>
                                    <Chip
                                        color={getStatusColor(transactionDetail.status || 'pending')}
                                        variant="flat"
                                        size="sm"
                                    >
                                        {getStatusLabel(transactionDetail.status || 'pending')}
                                    </Chip>
                                </div>
                            )}
                        </ModalHeader>

                        <ModalBody className="py-6">
                            {loading ? (
                                <div className="flex justify-center items-center py-8">
                                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-400"></div>
                                </div>
                            ) : transactionDetail ? (
                                <div className="space-y-6">
                                    {/* Transaction Info */}
                                    <Card className="bg-gray-800 border border-gray-700">
                                        <CardBody className="p-6">
                                            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                                <div>
                                                    <h3 className="text-sm font-medium text-gray-400 mb-1">
                                                        Nama Reseller
                                                    </h3>
                                                    <p className="text-lg font-semibold text-gray-100">
                                                        {transactionDetail.reseller_name}
                                                    </p>
                                                </div>
                                                <div>
                                                    <h3 className="text-sm font-medium text-gray-400 mb-1">
                                                        Tanggal Transaksi
                                                    </h3>
                                                    <p className="text-lg font-semibold text-gray-100">
                                                        {new Date(
                                                            transactionDetail.transaction_date
                                                        ).toLocaleDateString("id-ID", {
                                                            weekday: "long",
                                                            year: "numeric",
                                                            month: "long",
                                                            day: "numeric",
                                                            hour: "2-digit",
                                                            minute: "2-digit",
                                                        })}
                                                    </p>
                                                </div>
                                                <div>
                                                    <h3 className="text-sm font-medium text-gray-400 mb-1">
                                                        Status
                                                    </h3>
                                                    <Chip
                                                        color={getStatusColor(transactionDetail.status || 'pending')}
                                                        variant="flat"
                                                    >
                                                        {getStatusLabel(transactionDetail.status || 'pending')}
                                                    </Chip>
                                                </div>
                                            </div>

                                            <Divider className="my-4 bg-gray-700" />

                                            <div className="flex justify-between items-center">
                                                <div className="flex items-center gap-4">
                                                    <Chip color="primary" variant="flat">
                                                        {transactionDetail.total_items} Items
                                                    </Chip>
                                                    <Chip className="bg-gray-700">
                                                        Total: Rp{" "}
                                                        {Number(transactionDetail.total_price).toLocaleString(
                                                            "id-ID"
                                                        )}
                                                    </Chip>
                                                </div>
                                            </div>
                                        </CardBody>
                                    </Card>

                                    {/* Products Table */}
                                    <div>
                                        <h3 className="text-lg font-semibold mb-4 text-gray-100">
                                            Daftar Produk
                                        </h3>
                                        <Table
                                            aria-label="Transaction products table"
                                            className="min-w-full"
                                            removeWrapper
                                        >
                                            <TableHeader>
                                                <TableColumn className="bg-gray-800 text-gray-300">
                                                    NAMA PRODUK
                                                </TableColumn>
                                                <TableColumn className="bg-gray-800 text-gray-300">
                                                    HARGA SATUAN
                                                </TableColumn>
                                                <TableColumn className="bg-gray-800 text-gray-300">
                                                    QUANTITY
                                                </TableColumn>
                                                <TableColumn className="bg-gray-800 text-gray-300">
                                                    SUBTOTAL
                                                </TableColumn>
                                            </TableHeader>
                                            <TableBody>
                                                {transactionDetail.products.map((product) => (
                                                    <TableRow
                                                        key={product.id_product}
                                                        className="hover:bg-gray-800/60"
                                                    >
                                                        <TableCell>
                                                            <div className="flex flex-col">
                                                                <p className="font-medium text-gray-100">
                                                                    {product.product_name}
                                                                </p>
                                                                <p className="text-xs text-gray-500">
                                                                    ID: {product.id_product}
                                                                </p>
                                                            </div>
                                                        </TableCell>
                                                        <TableCell>
                                                            <span className="font-mono text-sm text-blue-400">
                                                                Rp{" "}
                                                                {Number(product.price).toLocaleString("id-ID")}
                                                            </span>
                                                        </TableCell>
                                                        <TableCell>
                                                            <Chip
                                                                size="sm"
                                                                className="bg-gray-700 text-gray-200"
                                                            >
                                                                {product.quantity}x
                                                            </Chip>
                                                        </TableCell>
                                                        <TableCell>
                                                            <span className="font-semibold font-mono">
                                                                Rp{" "}
                                                                {Number(product.subtotal).toLocaleString(
                                                                    "id-ID"
                                                                )}
                                                            </span>
                                                        </TableCell>
                                                    </TableRow>
                                                ))}
                                            </TableBody>
                                        </Table>
                                    </div>

                                    {/* Summary */}
                                    <Card className="bg-gray-800 border border-gray-700">
                                        <CardBody className="p-4">
                                            <div className="flex justify-between items-center">
                                                <span className="text-lg font-medium text-gray-300">
                                                    Total Keseluruhan:
                                                </span>
                                                <span className="text-2xl font-bold font-mono">
                                                    Rp{" "}
                                                    {Number(transactionDetail.total_price).toLocaleString(
                                                        "id-ID"
                                                    )}
                                                </span>
                                            </div>
                                        </CardBody>
                                    </Card>
                                </div>
                            ) : (
                                <div className="text-center py-8">
                                    <p className="text-gray-500">Tidak ada data transaksi</p>
                                </div>
                            )}
                        </ModalBody>

                        <ModalFooter className="flex gap-2 border-t border-gray-700">
                            <Button
                                variant="light"
                                onPress={onClose}
                                className="text-gray-300"
                            >
                                Tutup
                            </Button>
                            {/* Tombol Accept/Reject hanya muncul jika status pending atau undefined */}
                            {(!transactionDetail?.status ||
                                transactionDetail?.status === 'pending' ||
                                transactionDetail?.status === null ||
                                transactionDetail?.status === '') && (
                                    <>
                                        <Button
                                            color="danger"
                                            variant="flat"
                                            onPress={handleReject}
                                            className="font-medium"
                                        >
                                            Tolak
                                        </Button>
                                        <Button
                                            className="bg-blue-600 hover:bg-blue-500 text-white font-medium"
                                            onPress={handleAccept}
                                        >
                                            Terima
                                        </Button>
                                    </>
                                )}
                        </ModalFooter>
                    </>
                )}
            </ModalContent>
        </Modal>
    );
};