// src/services/returnService.ts
import api from "@/lib/axios";

export interface ReturnTransaction {
    id_return_transaction: number;
    id_reseller: number;
    reseller_name: string;
    status: string;
    total_items: number;
    total_price: number;
    return_date: string;
}

export interface ReturnProduct {
    id_product: number;
    price: number;
    product_name: string;
    quantity: number;
    subtotal: number;
    reason: string;
}

export interface ReturnTransactionDetail extends ReturnTransaction {
    id_transaction: number;
    products: ReturnProduct[];
}

export const returnService = {
    async getReturnTransactions(): Promise<ReturnTransaction[]> {
        const res = await api.get<ReturnTransaction[]>("/admin/return-transactions");
        return res.data;
    },

    async getReturnTransactionById(id: number): Promise<ReturnTransactionDetail> {
        const res = await api.get<ReturnTransactionDetail>(`/admin/return-transactions/${id}`);
        return res.data;
    },

    async acceptReturnTransaction(id: number): Promise<void> {
        await api.put(`/admin/return-transactions/${id}/accept`);
    },

    async rejectReturnTransaction(id: number): Promise<void> {
        await api.put(`/admin/return-transactions/${id}/reject`);
    },

    // Method lain bisa ditambahkan sesuai kebutuhan
};