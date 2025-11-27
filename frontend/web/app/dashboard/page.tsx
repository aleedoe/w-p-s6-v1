"use client"

import { useEffect, useState } from "react"

export default function DashboardPage() {
    const [name, setName] = useState<string>("")

    useEffect(() => {
        // Retrieve user from localStorage
        if (typeof window !== "undefined") {
            const userStr = localStorage.getItem("user")
            if (userStr) {
                try {
                    const user = JSON.parse(userStr)
                    setName(user.name || "")
                } catch (e) {
                    setName("")
                }
            }
        }
    }, [])

    return (
        <div className="flex flex-col items-center justify-center min-h-[70vh] w-full">
            <span className="text-4xl font-bold text-center">
                {name ? `Selamat Datang, ${name}!` : "Welcome!"}
            </span>
        </div>
    )
}