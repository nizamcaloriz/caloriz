"use client";

import { usePathname } from 'next/navigation';
import Sidebar from '@/components/Sidebar';

export default function SidebarWrapper({ children }: { children: React.ReactNode }) {
    const pathname = usePathname();
    // Hide sidebar on login page
    const showSidebar = pathname !== '/login';

    return (
        <>
            {showSidebar && <Sidebar />}
            <main className={`flex-1 p-8 ${showSidebar ? 'ml-64' : ''} transition-all duration-300`}>
                {children}
            </main>
        </>
    );
}
