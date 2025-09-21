import api from "@/lib/axios";

export interface Product {
    id: number;
    name: string;
    category: string;
    price: number;
    quantity: number;
    description?: string;
    id_category?: number;
}

export const productService = {
    async getProducts(): Promise<Product[]> {
        const res = await api.get<Product[]>("/admin/products");
        return res.data;
    },

    async createProduct(payload: {
        name: string;
        price: number;
        quantity: number;
        description?: string;
        id_category: number;
        images?: File[]; // tambahkan file upload
    }) {
        const formData = new FormData();
        formData.append("name", payload.name);
        formData.append("price", payload.price.toString());
        formData.append("quantity", payload.quantity.toString());
        if (payload.description) {
            formData.append("description", payload.description);
        }
        formData.append("id_category", payload.id_category.toString());

        // handle multiple images
        if (payload.images && payload.images.length > 0) {
            payload.images.forEach((file) => {
                formData.append("images", file);
            });
        }

        const res = await api.post("/admin/products", formData, {
            headers: {
                "Content-Type": "multipart/form-data",
            },
        });
        console.log(res.data.product);
        return res.data;
    },
};
