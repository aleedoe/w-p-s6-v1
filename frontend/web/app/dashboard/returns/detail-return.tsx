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
import { returnService } from "@/services/returnService";

interface ReturnProduct {
    id_product: number;
    price: number;
    product_name: string;
    quantity: number;
    subtotal: number;
    reason: string;
}

interface ReturnTransactionDetail {
    id_return_transaction: number;
    id_transaction: number;
    id_reseller: number;
    reseller_name: string;
    status: string;
    return_date: string;
    products: ReturnProduct[];
    total_items: number;
    total_price: number;
}

interface ReturnTransactionDetailModalProps {
    returnTransactionId: number | null;
    isOpen: boolean;
    onClose: () => void;
    onAccept?: (id: number) => void;
    onReject?: (id: number) => void;
}

export const DetailReturn: React.FC<ReturnTransactionDetailModalProps> = ({
    returnTransactionId,
    isOpen,
    onClose,
    onAccept,
    onReject,
}) => {
    const [returnTransactionDetail, setReturnTransactionDetail] =
        useState<ReturnTransactionDetail | null>(null);
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        const fetchReturnTransactionDetail = async () => {
            if (!returnTransactionId || !isOpen) return;

            setLoading(true);
            try {
                const detail = await returnService.getReturnTransactionById(
                    returnTransactionId
                );
                setReturnTransactionDetail(detail as any);
            } catch (error) {
                console.error("Failed to fetch return transaction detail:", error);
                alert("Gagal memuat detail return transaksi");
            } finally {
                setLoading(false);
            }
        };

        fetchReturnTransactionDetail();
    }, [returnTransactionId, isOpen]);

    const handleAccept = () => {
        if (returnTransactionId && onAccept) {
            onAccept(returnTransactionId);
            onClose();
        }
    };

    const handleReject = () => {
        if (returnTransactionId && onReject) {
            onReject(returnTransactionId);
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
            size="5xl"
            scrollBehavior="inside"
        >
            <ModalContent>
                {(onClose) => (
                    <>
                        <ModalHeader className="flex flex-col gap-1 border-b border-gray-700">
                            <h2 className="text-2xl font-bold ">
                                Detail Return Transaksi
                            </h2>
                            {returnTransactionDetail && (
                                <div className="flex items-center gap-2">
                                    <p className="text-sm text-gray-400">
                                        ID Return: #{returnTransactionDetail.id_return_transaction}
                                    </p>
                                    <p className="text-sm text-gray-400">
                                        ID Transaksi Asal: #{returnTransactionDetail.id_transaction}
                                    </p>
                                    <Chip
                                        color={getStatusColor(returnTransactionDetail.status)}
                                        variant="flat"
                                        size="sm"
                                    >
                                        {getStatusLabel(returnTransactionDetail.status)}
                                    </Chip>
                                </div>
                            )}
                        </ModalHeader>

                        <ModalBody className="py-6">
                            {loading ? (
                                <div className="flex justify-center items-center py-8">
                                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-400"></div>
                                </div>
                            ) : returnTransactionDetail ? (
                                <div className="space-y-6">
                                    {/* Return Transaction Info */}
                                    <Card className="bg-gray-800 border border-gray-700">
                                        <CardBody className="p-6">
                                            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                                <div>
                                                    <h3 className="text-sm font-medium text-gray-400 mb-1">
                                                        Nama Reseller
                                                    </h3>
                                                    <p className="text-lg font-semibold text-gray-100">
                                                        {returnTransactionDetail.reseller_name}
                                                    </p>
                                                </div>
                                                <div>
                                                    <h3 className="text-sm font-medium text-gray-400 mb-1">
                                                        Tanggal Return
                                                    </h3>
                                                    <p className="text-lg font-semibold text-gray-100">
                                                        {new Date(
                                                            returnTransactionDetail.return_date
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
                                                        color={getStatusColor(returnTransactionDetail.status)}
                                                        variant="flat"
                                                    >
                                                        {getStatusLabel(returnTransactionDetail.status)}
                                                    </Chip>
                                                </div>
                                            </div>

                                            <Divider className="my-4 bg-gray-700" />

                                            <div className="flex justify-between items-center">
                                                <div className="flex items-center gap-4">
                                                    <Chip color="primary" variant="flat">
                                                        {returnTransactionDetail.total_items} Items
                                                    </Chip>
                                                    <Chip className="bg-gray-700">
                                                        Total: Rp{" "}
                                                        {Number(returnTransactionDetail.total_price).toLocaleString(
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
                                            Daftar Produk yang Direturn
                                        </h3>
                                        <Table
                                            aria-label="Return transaction products table"
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
                                                <TableColumn className="bg-gray-800 text-gray-300">
                                                    ALASAN RETURN
                                                </TableColumn>
                                            </TableHeader>
                                            <TableBody>
                                                {returnTransactionDetail.products.map((product) => (
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
                                                        <TableCell>
                                                            <div className="max-w-xs">
                                                                <p className="text-sm text-gray-300 break-words">
                                                                    {product.reason || "Tidak ada alasan"}
                                                                </p>
                                                            </div>
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
                                                    Total Return:
                                                </span>
                                                <span className="text-2xl font-bold font-mono">
                                                    Rp{" "}
                                                    {Number(returnTransactionDetail.total_price).toLocaleString(
                                                        "id-ID"
                                                    )}
                                                </span>
                                            </div>
                                        </CardBody>
                                    </Card>
                                </div>
                            ) : (
                                <div className="text-center py-8">
                                    <p className="text-gray-500">Tidak ada data return transaksi</p>
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
                            {returnTransactionDetail?.status === 'pending' && (
                                <>
                                    <Button
                                        color="danger"
                                        variant="flat"
                                        onPress={handleReject}
                                        className="font-medium"
                                    >
                                        Tolak Return
                                    </Button>
                                    <Button
                                        className="bg-blue-600 hover:bg-blue-500 text-white font-medium"
                                        onPress={handleAccept}
                                    >
                                        Terima Return
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