// src/services/transactionService.ts
import api from "@/lib/axios";

export interface Transaction {
    id_reseller: number;
    id_transaction: number;
    reseller_name: string;
    total_items: number;
    total_price: number;
    transaction_date: string;
}

export interface Product {
    id_product: number;
    price: number;
    product_name: string;
    quantity: number;
    subtotal: number;
}

export interface TransactionDetail extends Transaction {
    products: Product[];
}

export const transactionService = {
    async getTransactions(): Promise<Transaction[]> {
        const res = await api.get<Transaction[]>("/admin/transactions");
        return res.data;
    },

    async getTransactionById(id: number): Promise<TransactionDetail> {
        const res = await api.get<TransactionDetail>(`/admin/transactions/${id}`);
        return res.data;
    },

    async acceptTransaction(id: number): Promise<void> {
        await api.put(`/admin/transactions/${id}/accept`);
    },

    async rejectTransaction(id: number): Promise<void> {
        await api.put(`/admin/transactions/${id}/reject`);
    },

    // Method lain bisa ditambahkan sesuai kebutuhan
};