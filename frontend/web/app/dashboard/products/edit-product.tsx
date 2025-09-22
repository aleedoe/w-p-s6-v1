"use client";
import React, { useState, useMemo, useCallback, useEffect } from "react";
import { useDropzone } from "react-dropzone";
import { Button } from "@heroui/button";
import {
    Modal,
    ModalContent,
    ModalHeader,
    ModalBody,
    ModalFooter,
    useDisclosure,
} from "@heroui/modal";
import { Input, Textarea } from "@heroui/input";
import {
    Dropdown,
    DropdownItem,
    DropdownMenu,
    DropdownTrigger,
} from "@heroui/dropdown";
import { productService, Product } from "@/services/productService";

interface EditProductProps {
    productId: number | null; // null kalau belum ada yang dipilih
    isOpen: boolean;
    onClose: () => void;
}

export const EditProduct: React.FC<EditProductProps> = ({
    productId,
    isOpen,
    onClose,
}) => {
    const [form, setForm] = useState({
        name: "",
        price: "",
        quantity: "",
        description: "",
        id_category: "",
    });
    const [files, setFiles] = useState<File[]>([]);
    const [existingImages, setExistingImages] = useState<string[]>([]);
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

    // Dropzone setup
    const onDrop = useCallback((acceptedFiles: File[]) => {
        setFiles((prev) => [...prev, ...acceptedFiles]);
    }, []);
    const { getRootProps, getInputProps, isDragActive } = useDropzone({
        onDrop,
        accept: { "image/*": [] },
        multiple: true,
    });

    // Fetch detail produk saat modal terbuka
    useEffect(() => {
        if (isOpen && productId) {
            (async () => {
                try {
                    const data = await productService.getProductById(productId);
                    setForm({
                        name: data.name || "",
                        price: String(data.price || ""),
                        quantity: String(data.quantity || ""),
                        description: data.description || "",
                        id_category: String(data.id_category || ""),
                    });
                    setSelectedKeys(new Set([String(data.id_category)]));

                    // simpan gambar existing dari backend
                    setExistingImages(data.images || []);
                    setFiles([]); // reset file baru
                } catch (err) {
                    console.error("Gagal ambil detail produk", err);
                }
            })();
        }
    }, [isOpen, productId]);

    const handleSubmit = async () => {
        if (!productId) return;
        try {
            setLoading(true);
            await productService.updateProduct(productId, {
                name: form.name,
                price: Number(form.price),
                quantity: Number(form.quantity),
                description: form.description,
                id_category: Number(form.id_category),
                images: files, // hanya upload gambar baru
            });
            alert("Produk berhasil diperbarui ✅");
            onClose();
            window.location.reload();
        } catch (err: any) {
            alert(err.response?.data?.msg || "Gagal memperbarui produk");
        } finally {
            setLoading(false);
        }
    };

    return (
        <Modal
            isOpen={isOpen}
            onOpenChange={onClose}
            placement="top-center"
            size="lg"
        >
            <ModalContent>
                <>
                    <ModalHeader className="flex flex-col gap-1">
                        Edit Produk
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
                            onChange={(e) =>
                                handleChange("quantity", e.target.value)
                            }
                        />
                        <Textarea
                            label="Deskripsi"
                            placeholder="Masukkan deskripsi produk"
                            variant="bordered"
                            value={form.description}
                            onChange={(e) =>
                                handleChange("description", e.target.value)
                            }
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
                                    <DropdownItem key={cat.id}>
                                        {cat.name}
                                    </DropdownItem>
                                ))}
                            </DropdownMenu>
                        </Dropdown>

                        {/* Dropzone */}
                        <div
                            {...getRootProps()}
                            className={`mt-4 flex flex-col items-center justify-center rounded-2xl border-2 border-dashed p-6 cursor-pointer transition
                                ${isDragActive
                                    ? "border-blue-500 bg-blue-50"
                                    : "border-gray-300 bg-gray-50 hover:border-blue-400"
                                }`}
                        >
                            <input {...getInputProps()} />
                            <p className="text-gray-600">
                                {isDragActive
                                    ? "Lepaskan file di sini ..."
                                    : "Tarik & lepas gambar baru atau klik untuk memilih"}
                            </p>
                            <p className="text-xs text-gray-400 mt-1">
                                Hanya file gambar (jpg, png, jpeg) yang diperbolehkan
                            </p>
                        </div>

                        {/* Preview Existing Images */}
                        {existingImages.length > 0 && (
                            <div className="grid grid-cols-3 gap-3 mt-4">
                                {existingImages.map((img, i) => (
                                    <div
                                        key={i}
                                        className="relative group border rounded-xl overflow-hidden shadow-sm"
                                    >
                                        <img
                                            src={`http://127.0.0.1:5000/static/uploads/products/${img}`} // pastikan sesuai API static files
                                            alt={img}
                                            className="h-28 w-full object-cover"
                                        />
                                    </div>
                                ))}
                            </div>
                        )}

                        {/* Preview New Uploaded Images */}
                        {files.length > 0 && (
                            <div className="grid grid-cols-3 gap-3 mt-4">
                                {files.map((file, i) => (
                                    <div
                                        key={i}
                                        className="relative group border rounded-xl overflow-hidden shadow-sm"
                                    >
                                        <img
                                            src={URL.createObjectURL(file)}
                                            alt={file.name}
                                            className="h-28 w-full object-cover"
                                        />
                                        <button
                                            type="button"
                                            onClick={() =>
                                                setFiles((prev) =>
                                                    prev.filter((_, idx) => idx !== i)
                                                )
                                            }
                                            className="absolute top-1 right-1 bg-red-500 text-white rounded-full px-2 py-1 text-xs opacity-0 group-hover:opacity-100 transition"
                                        >
                                            ✕
                                        </button>
                                    </div>
                                ))}
                            </div>
                        )}
                    </ModalBody>
                    <ModalFooter>
                        <Button color="danger" variant="flat" onClick={onClose}>
                            Batal
                        </Button>
                        <Button
                            color="primary"
                            isLoading={loading}
                            onPress={handleSubmit}
                        >
                            Simpan Perubahan
                        </Button>
                    </ModalFooter>
                </>
            </ModalContent>
        </Modal>
    );
};
