// src/lib/axios.ts
import axios from "axios";

const api = axios.create({
    baseURL: "http://127.0.0.1:5000/api",
    headers: {
        "Content-Type": "application/json",
    },
    timeout: 10000, // 10s, biar gak ngegantung
});

// Tambahkan interceptor kalau perlu (contoh logging / auth)
api.interceptors.response.use(
    (response) => response,
    (error) => {
        console.error("API Error:", error.response || error.message);
        return Promise.reject(error);
    }
);

export default api;
