import React from "react";
import { Sidebar } from "./sidebar.styles";
import { CompaniesDropdown } from "./companies-dropdown";
import { HomeIcon } from "../icons/sidebar/home-icon";
import { PaymentsIcon } from "../icons/sidebar/payments-icon";
import { BalanceIcon } from "../icons/sidebar/balance-icon";
import { AccountsIcon } from "../icons/sidebar/accounts-icon";
import { CustomersIcon } from "../icons/sidebar/customers-icon";
import { ProductsIcon } from "../icons/sidebar/products-icon";
import { ReportsIcon } from "../icons/sidebar/reports-icon";
import { DevIcon } from "../icons/sidebar/dev-icon";
import { ViewIcon } from "../icons/sidebar/view-icon";
import { SettingsIcon } from "../icons/sidebar/settings-icon";
import { CollapseItems } from "./collapse-items";
import { SidebarItem } from "./sidebar-item";
import { SidebarMenu } from "./sidebar-menu";
import { FilterIcon } from "../icons/sidebar/filter-icon";
import { useSidebarContext } from "../layoutD/layout-context";
import { ChangeLogIcon } from "../icons/sidebar/changelog-icon";
import { usePathname } from "next/navigation";
import { Tooltip } from "@heroui/tooltip";
import { Avatar } from "@heroui/avatar";
import { BottomIcon } from "../icons/sidebar/bottom-icon";
import { AcmeLogo } from "../icons/acmelogo";
import { ShoppingCartIcon } from "../icons/sidebar/shopping-cart-icon";
import { Button } from "@heroui/button";

export const SidebarWrapper = () => {
  const pathname = usePathname();
  const { collapsed, setCollapsed } = useSidebarContext();

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
              <Button color="danger" className="w-full">Log Out</Button>
          </div>
        </div>
      </div>
    </aside>
  );
};
