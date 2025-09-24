// components/table-return/table.tsx
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
    returnService,
    ReturnTransaction,
} from "@/services/returnService";

const columns = [
    { name: "NO", uid: "no" },
    { name: "RESELLER NAME", uid: "reseller_name" },
    { name: "STATUS", uid: "status" },
    { name: "TOTAL ITEMS", uid: "total_items" },
    { name: "TOTAL PRICE", uid: "total_price" },
    { name: "RETURN DATE", uid: "return_date" },
    { name: "ACTIONS", uid: "actions" },
];

export const TableReturn = () => {
    const [returnTransactions, setReturnTransactions] = useState<ReturnTransaction[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchReturnTransactions = async () => {
            try {
                const data = await returnService.getReturnTransactions();
                setReturnTransactions(data);
            } catch (err) {
                console.error("Failed to fetch return transactions:", err);
            } finally {
                setLoading(false);
            }
        };

        fetchReturnTransactions();
    }, []);

    return (
        <div className="w-full flex flex-col gap-4">
            <Table aria-label="Return transactions table">
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
                    items={returnTransactions.map((rt, index) => ({ ...rt, no: index + 1 }))}
                    isLoading={loading}
                    loadingContent={<div className="p-4">Loading...</div>}
                >
                    {(item) => (
                        <TableRow key={item.id_return_transaction}>
                            {(columnKey) => (
                                <TableCell>
                                    <RenderCell returnTransaction={item as any} columnKey={columnKey} />
                                </TableCell>
                            )}
                        </TableRow>
                    )}
                </TableBody>
            </Table>
        </div>
    );
};