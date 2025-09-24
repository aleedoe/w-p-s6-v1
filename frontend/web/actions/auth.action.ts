"use server";

import { cookies } from "next/headers";

export const createAuthCookie = async (token: string) => {
  const cookieStore = await cookies();
  cookieStore.set("userAuth", token, {
    httpOnly: true, // biar aman, tidak bisa diakses JS client
    secure: process.env.NODE_ENV === "production",
    path: "/",
    maxAge: 60 * 60 * 24, // 1 hari
  });
};
export const deleteAuthCookie = async () => {
  const cookieStore = await cookies();
  cookieStore.delete("userAuth");
};
