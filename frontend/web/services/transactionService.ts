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

export const transactionService = {
    async getTransactions(): Promise<Transaction[]> {
        const res = await api.get<Transaction[]>("/admin/transactions");
        return res.data;
    },

    async getTransactionById(id: number): Promise<Transaction> {
        const res = await api.get<Transaction>(`/admin/transactions/${id}`);
        return res.data;
    },

    // sementara create/update/delete kalau ada, bisa ditambahkan seperti productService
};
