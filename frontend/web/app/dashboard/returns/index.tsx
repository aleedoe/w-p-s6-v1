"use client";
import React from "react";
import { Input } from "@heroui/input";
import { TableReturn } from "@/components/table-return/table";

export const Returns = () => {
    return (
        <div className="my-10 px-4 lg:px-6 max-w-[95rem] mx-auto w-full flex flex-col gap-4">
            <h3 className="text-xl font-semibold">Semua Return</h3>
            <div className="flex justify-between flex-wrap gap-4 items-center">
                <div className="flex items-center gap-3 flex-wrap md:flex-nowrap">
                    {/* <Input
                        classNames={{
                            input: "w-full",
                            mainWrapper: "w-full",
                        }}
                        placeholder="Search return"
                    /> */}
                </div>
                <div className="flex flex-row flex-wrap">
                </div>
            </div>
            <div className="max-w-[95rem] mx-auto w-full">
                <TableReturn />
            </div>
        </div>
    );
};