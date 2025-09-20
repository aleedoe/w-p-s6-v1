// src/services/productService.ts
import api from "@/lib/axios";

export interface Product {
    id: number;
    name: string;
    category: string;
    price: number;
    quantity: number;
}

export const productService = {
    async getProducts(): Promise<Product[]> {
        const res = await api.get<Product[]>("/admin/products");
        return res.data;
    },
    // bisa ditambah method lain misalnya create, update, delete
};
