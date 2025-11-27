// components/table-product/table.tsx
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
import { productService, Product } from "@/services/productService";

// Added expired date column in columns list
const columns = [
  { name: "NO", uid: "no" },
  { name: "NAME", uid: "name" },
  { name: "PRICE", uid: "price" },
  { name: "QUANTITY", uid: "quantity" },
  { name: "EXPIRED DATE", uid: "expired_date" },
  { name: "ACTIONS", uid: "actions" },
];

export const TableProduct = () => {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const data = await productService.getProducts();
        setProducts(data);
      } catch (err) {
        console.error("Failed to fetch products:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchProducts();
  }, []);

  return (
    <div className="w-full flex flex-col gap-4">
      <Table aria-label="Products table">
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
          // Ensure expired_date gets passed through even if it is null
          items={products.map((p, index) => ({
            ...p,
            no: index + 1,
            expired_date: p.expired_date || "-", // fallback for null values
          }))}
          isLoading={loading}
          loadingContent={<div className="p-4">Loading...</div>}
        >
          {(item) => (
            <TableRow key={item.id}>
              {(columnKey) => (
                <TableCell>
                  {/* handle expired_date display formatting here if needed */}
                  {columnKey === "expired_date"
                    ? (item.expired_date && item.expired_date !== "-"
                        ? item.expired_date
                        : "-")
                    : <RenderCell user={item as any} columnKey={columnKey} />
                  }
                </TableCell>
              )}
            </TableRow>
          )}
        </TableBody>
      </Table>
    </div>
  );
};
