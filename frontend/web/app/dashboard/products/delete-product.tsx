"use client";
import React from "react";
import { productService } from "@/services/productService";
import { Modal, ModalBody, ModalContent, ModalFooter, ModalHeader } from "@heroui/modal";
import { Button } from "@heroui/button";


interface DeleteProductProps {
    productId: number | null;
    isOpen: boolean;
    onClose: () => void;
    onDeleted?: (id: number) => void;
}

export const DeleteProduct: React.FC<DeleteProductProps> = ({
    productId,
    isOpen,
    onClose,
    onDeleted,
}) => {
    const handleDelete = async () => {
        if (!productId) return;
        try {
            await productService.deleteProduct(productId);
            onDeleted?.(productId);
            alert("Produk berhasil dihapus ✅");
            onClose();
            window.location.reload();
        } catch (error) {
            console.error("Failed to delete product:", error);
        }
    };

    return (
        <Modal isOpen={isOpen} onClose={onClose} backdrop="blur">
            <ModalContent>
                {(onClose) => (
                    <>
                        <ModalHeader className="text-lg font-bold">
                            Konfirmasi Hapus
                        </ModalHeader>
                        <ModalBody>
                            <p>
                                Apakah Anda yakin ingin menghapus produk ini? Semua gambar terkait juga akan ikut dihapus.
                            </p>
                        </ModalBody>
                        <ModalFooter>
                            <Button variant="light" onPress={onClose}>
                                Batal
                            </Button>
                            <Button color="danger" onPress={handleDelete}>
                                Hapus
                            </Button>
                        </ModalFooter>
                    </>
                )}
            </ModalContent>
        </Modal>
    );
};
