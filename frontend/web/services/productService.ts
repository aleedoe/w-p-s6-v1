// src/services/productService.ts
import api from "@/lib/axios";

export interface Product {
    id: number;
    name: string;
    item_code?: string | null;
    item_series?: string | null;
    price: number;
    quantity: number;
    description?: string;
    images?: string[]; // biar bisa nampilin gambar
    expired_date?: string | null; // tanggal kadaluarsa, nullable
}

export const productService = {
    async getProducts(): Promise<Product[]> {
        const res = await api.get<Product[]>("/admin/products");
        return res.data;
    },

    async getProductById(id: number): Promise<Product> {
        const res = await api.get<Product>(`/admin/products/${id}`);
        return res.data;
    },

    async createProduct(payload: {
        name: string;
        price: number;
        quantity: number;
        description?: string;
        item_code?: string | null;
        item_series?: string | null;
        images?: File[]; // untuk upload gambar
        expired_date?: string | null; // string (YYYY-MM-DD) atau null
    }) {
        // kalau backend butuh multipart:
        const formData = new FormData();
        formData.append("name", payload.name);
        formData.append("price", String(payload.price));
        formData.append("quantity", String(payload.quantity));
        if (payload.description) formData.append("description", payload.description);
        if (payload.item_code) formData.append("item_code", payload.item_code);
        if (payload.item_series) formData.append("item_series", payload.item_series);
        if (payload.expired_date)
            formData.append("expired_date", payload.expired_date);

        if (payload.images) {
            payload.images.forEach((file) => {
                formData.append("images", file);
            });
        }

        const res = await api.post("/admin/products", formData, {
            headers: { "Content-Type": "multipart/form-data" },
        });
        return res.data;
    },

    async updateProduct(
        id: number,
        payload: {
            name: string;
            price: number;
            quantity: number;
            description?: string;
            item_code?: string | null;
            item_series?: string | null;
            expired_date?: string | null;
            removedImages?: string[];
        },
        files: File[]
    ) {
        const formData = new FormData();
        formData.append("name", payload.name);
        formData.append("price", String(payload.price));
        formData.append("quantity", String(payload.quantity));
        formData.append("description", payload.description || "");
        formData.append("item_code", payload.item_code || "");
        formData.append("item_series", payload.item_series || "");
        if (payload.expired_date)
            formData.append("expired_date", payload.expired_date);

        // Kirim daftar gambar yang akan dihapus
        if (payload.removedImages && payload.removedImages.length > 0) {
            payload.removedImages.forEach((imageName: string) => {
                formData.append("removedImages[]", imageName);
            });
        }

        // tambahkan file baru
        files.forEach((file) => {
            formData.append("images", file);
        });

        const res = await api.put(`/admin/products/${id}`, formData, {
            headers: { "Content-Type": "multipart/form-data" },
        });
        return res.data;
    },

    async deleteProduct(id: number) {
        const res = await api.delete(`/admin/products/${id}`);
        return res.data;
    },
};