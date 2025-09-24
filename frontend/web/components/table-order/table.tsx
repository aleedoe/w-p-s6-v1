// components/table-transaction/table.tsx
"use client";
import React, { useEffect, useState } from "react";
import { RenderCell } from "./render-cell";
import {
  Table,
  TableHeader,
  TableBody,
  TableColumn,
  TableRow,
  TableCell,
} from "@heroui/table";
import {
  transactionService,
  Transaction,
} from "@/services/transactionService";

const columns = [
  { name: "NO", uid: "no" },
  { name: "RESELLER NAME", uid: "reseller_name" },
  { name: "STATUS", uid: "status" }, // Tambahkan kolom STATUS
  { name: "TOTAL ITEMS", uid: "total_items" },
  { name: "TOTAL PRICE", uid: "total_price" },
  { name: "TRANSACTION DATE", uid: "transaction_date" },
  { name: "ACTIONS", uid: "actions" },
];

export const TableTransaction = () => {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchTransactions = async () => {
      try {
        const data = await transactionService.getTransactions();
        setTransactions(data);
      } catch (err) {
        console.error("Failed to fetch transactions:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchTransactions();
  }, []);

  return (
    <div className="w-full flex flex-col gap-4">
      <Table aria-label="Transactions table">
        <TableHeader columns={columns}>
          {(column) => (
            <TableColumn
              key={column.uid}
              hideHeader={column.uid === "actions"}
              align={column.uid === "actions" ? "center" : "start"}
            >
              {column.name}
            </TableColumn>
          )}
        </TableHeader>
        <TableBody
          items={transactions.map((t, index) => ({ ...t, no: index + 1 }))}
          isLoading={loading}
          loadingContent={<div className="p-4">Loading...</div>}
        >
          {(item) => (
            <TableRow key={item.id_transaction}>
              {(columnKey) => (
                <TableCell>
                  <RenderCell order={item as any} columnKey={columnKey} />
                </TableCell>
              )}
            </TableRow>
          )}
        </TableBody>
      </Table>
    </div>
  );
};