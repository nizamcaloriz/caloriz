"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
    Users,
    LayoutDashboard,
    Banknote,
} from "lucide-react";

export default function Sidebar() {
    const pathname = usePathname();

    const links = [
        { name: "Dashboard", href: "/", icon: LayoutDashboard },
        { name: "Users", href: "/users", icon: Users },
        { name: "Affiliates", href: "/affiliates", icon: Banknote },
    ];

    return (
        <aside className="fixed top-0 left-0 h-screen w-64 bg-white border-r border-gray-200 z-50">
            <div className="flex h-16 items-center border-b px-6">
                <h1 className="text-xl font-bold text-primary">Caloriz<span className="text-secondary">Admin</span></h1>
            </div>

            <nav className="flex-1 space-y-1 px-4 py-6">
                {links.map((link) => {
                    const isActive = pathname === link.href;
                    return (
                        <Link
                            key={link.name}
                            href={link.href}
                            className={`flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium ${isActive
                                ? "bg-primary/10 text-primary"
                                : "text-gray-500 hover:bg-gray-100 hover:text-gray-900"
                                }`}
                        >
                            <link.icon className="h-5 w-5" />
                            {link.name}
                        </Link>
                    );
                })}
            </nav>

            <div className="border-t p-4">
                <div className="flex items-center gap-3">
                    <div className="h-8 w-8 rounded-full bg-gray-200" />
                    <div>
                        <p className="text-sm font-medium text-gray-700">Admin User</p>
                        <p className="text-xs text-gray-500">View Profile</p>
                    </div>
                </div>
            </div>
        </aside>
    );
}
