import { Layout } from "@/components/layoutD/layoutD";

export default function DashboardLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    return (<Layout>{children}</Layout>);
}
