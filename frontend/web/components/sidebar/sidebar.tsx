"use client";

import React from "react";
import { Sidebar } from "./sidebar.styles";
import { HomeIcon } from "../icons/sidebar/home-icon";
import { ProductsIcon } from "../icons/sidebar/products-icon";
import { ChangeLogIcon } from "../icons/sidebar/changelog-icon";
import { ShoppingCartIcon } from "../icons/sidebar/shopping-cart-icon";
import { SidebarItem } from "./sidebar-item";
import { SidebarMenu } from "./sidebar-menu";
import { useSidebarContext } from "../layoutD/layout-context";
import { usePathname, useRouter } from "next/navigation";
import { Button } from "@heroui/button";
import { AcmeLogo } from "../icons/acmelogo";

export const SidebarWrapper = () => {
  const pathname = usePathname();
  const { collapsed, setCollapsed } = useSidebarContext();
  const router = useRouter();

  const handleLogout = () => {
    // hapus token & user
    localStorage.removeItem("token");
    localStorage.removeItem("user");

    // redirect ke login
    router.push("/login");
  };

  return (
    <aside className="h-screen z-[20] sticky top-0">
      {collapsed ? (
        <div className={Sidebar.Overlay()} onClick={setCollapsed} />
      ) : null}
      <div
        className={Sidebar({
          collapsed: collapsed,
        })}
      >
        <div className={Sidebar.Header()}>
          <div className="flex items-center gap-2">
            <AcmeLogo />
            <h3 className="text-xl font-medium m-0 text-default-900 whitespace-nowrap">
              {"Instagram"}
            </h3>
          </div>
        </div>
        <div className="flex flex-col justify-between h-full">
          <div className={Sidebar.Body()}>
            <SidebarItem
              title="Home"
              icon={<HomeIcon />}
              isActive={pathname === "/dashboard"}
              href="/dashboard"
            />
            <SidebarMenu title="Main Menu">
              <SidebarItem
                isActive={pathname === "/dashboard/products"}
                title="Products"
                icon={<ProductsIcon />}
                href="/dashboard/products"
              />
              <SidebarItem
                isActive={pathname === "/dashboard/orders"}
                title="Orders"
                icon={<ShoppingCartIcon />}
                href="/dashboard/orders"
              />
              <SidebarItem
                isActive={pathname === "/dashboard/returns"}
                title="Returns"
                icon={<ChangeLogIcon />}
                href="/dashboard/returns"
              />
            </SidebarMenu>
          </div>
          <div className={Sidebar.Footer()}>
            <Button 
              color="danger" 
              className="w-full" 
              onClick={handleLogout}
            >
              Log Out
            </Button>
          </div>
        </div>
      </div>
    </aside>
  );
};
