// src/services/productService.ts
import api from "@/lib/axios";

export interface Product {
    id: number;
    name: string;
    category?: string;
    price: number;
    quantity: number;
    description?: string;
    id_category?: number;
    images?: string[]; // biar bisa nampilin gambar
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
        id_category: number;
        images?: File[]; // untuk upload gambar
    }) {
        // kalau backend butuh multipart:
        const formData = new FormData();
        formData.append("name", payload.name);
        formData.append("price", String(payload.price));
        formData.append("quantity", String(payload.quantity));
        if (payload.description) formData.append("description", payload.description);
        formData.append("id_category", String(payload.id_category));

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

    async updateProduct(id: number, payload: any, files: File[]) {
        const formData = new FormData();
        formData.append("name", payload.name);
        formData.append("price", String(payload.price));
        formData.append("quantity", String(payload.quantity));
        formData.append("description", payload.description || "");
        formData.append("id_category", String(payload.id_category));

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