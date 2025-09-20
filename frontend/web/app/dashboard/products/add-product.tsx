"use client";
import React, { useState, useMemo } from "react";
import { Button } from "@heroui/button";
import {
    Modal,
    ModalContent,
    ModalHeader,
    ModalBody,
    ModalFooter,
    useDisclosure,
} from "@heroui/modal";
import { productService } from "@/services/productService";
import { Input, Textarea } from "@heroui/input";
import { Dropdown, DropdownItem, DropdownMenu, DropdownTrigger } from "@heroui/dropdown";

export const AddProduct = () => {
    const { isOpen, onOpen, onOpenChange } = useDisclosure();

    const [form, setForm] = useState({
        name: "",
        price: "",
        quantity: "",
        description: "",
        id_category: "",
    });

    const [loading, setLoading] = useState(false);
    const [selectedKeys, setSelectedKeys] = useState<Set<string>>(new Set());

    // daftar kategori (sementara hardcoded, bisa dari API nanti)
    const categories = [
        { id: "1", name: "Pakaian" },
        { id: "2", name: "Elektronik" },
        { id: "3", name: "Makanan" },
    ];

    const selectedValue = useMemo(() => {
        const key = Array.from(selectedKeys)[0];
        const category = categories.find((c) => c.id === key);
        return category ? category.name : "";
    }, [selectedKeys]);


    const handleChange = (key: string, value: string) => {
        setForm((prev) => ({ ...prev, [key]: value }));
    };

    const handleSubmit = async (onClose: () => void) => {
        try {
            setLoading(true);
            await productService.createProduct({
                name: form.name,
                price: parseFloat(form.price),
                quantity: parseInt(form.quantity) || 0,
                description: form.description,
                id_category: parseInt(form.id_category),
            });

            alert("Produk berhasil ditambahkan ✅");
            onClose();
            setForm({
                name: "",
                price: "",
                quantity: "",
                description: "",
                id_category: "",
            });
            setSelectedKeys(new Set());
            window.location.reload(); // sementara refresh table
        } catch (err: any) {
            alert(err.response?.data?.msg || "Gagal menambahkan produk");
        } finally {
            setLoading(false);
        }
    };

    return (
        <div>
            <Button onPress={onOpen} color="primary">
                Tambah Produk
            </Button>

            <Modal isOpen={isOpen} onOpenChange={onOpenChange} placement="top-center">
                <ModalContent>
                    {(onClose) => (
                        <>
                            <ModalHeader className="flex flex-col gap-1">
                                Tambah Produk
                            </ModalHeader>
                            <ModalBody>
                                <Input
                                    label="Nama Produk"
                                    variant="bordered"
                                    value={form.name}
                                    onChange={(e) => handleChange("name", e.target.value)}
                                />
                                <Input
                                    label="Harga"
                                    type="number"
                                    variant="bordered"
                                    value={form.price}
                                    onChange={(e) => handleChange("price", e.target.value)}
                                />
                                <Input
                                    label="Stok"
                                    type="number"
                                    variant="bordered"
                                    value={form.quantity}
                                    onChange={(e) => handleChange("quantity", e.target.value)}
                                />

                                {/* Textarea untuk deskripsi */}
                                <Textarea
                                    label="Deskripsi"
                                    placeholder="Masukkan deskripsi produk"
                                    variant="bordered"
                                    value={form.description}
                                    onChange={(e) => handleChange("description", e.target.value)}
                                />

                                {/* Dropdown kategori */}
                                <Dropdown>
                                    <DropdownTrigger>
                                        <Button className="capitalize" variant="bordered">
                                            {selectedValue || "Pilih Kategori"}
                                        </Button>
                                    </DropdownTrigger>
                                    <DropdownMenu
                                        disallowEmptySelection
                                        aria-label="Pilih kategori produk"
                                        selectedKeys={selectedKeys}
                                        selectionMode="single"
                                        variant="flat"
                                        onSelectionChange={(keys) => {
                                            setSelectedKeys(keys as Set<string>);
                                            const key = Array.from(keys)[0];
                                            handleChange("id_category", key.toString());
                                        }}
                                    >
                                        {categories.map((cat) => (
                                            <DropdownItem key={cat.id}>{cat.name}</DropdownItem>
                                        ))}
                                    </DropdownMenu>
                                </Dropdown>
                            </ModalBody>
                            <ModalFooter>
                                <Button color="danger" variant="flat" onClick={onClose}>
                                    Batal
                                </Button>
                                <Button
                                    color="primary"
                                    isLoading={loading}
                                    onPress={() => handleSubmit(onClose)}
                                >
                                    Simpan
                                </Button>
                            </ModalFooter>
                        </>
                    )}
                </ModalContent>
            </Modal>
        </div>
    );
};
