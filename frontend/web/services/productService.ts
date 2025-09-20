// src/services/productService.ts
import api from "@/lib/axios";

export interface Product {
    id: number;
    name: string;
    category: string;
    price: number;
    quantity: number;
    description?: string;
    id_category?: number;
}

export const productService = {
    async getProducts(): Promise<Product[]> {
        const res = await api.get<Product[]>("/admin/products");
        return res.data;
    },

    async createProduct(payload: {
        name: string;
        price: number;
        quantity: number;
        description?: string;
        id_category: number;
    }) {
        const res = await api.post("/admin/products", payload);
        return res.data;
    },
};
