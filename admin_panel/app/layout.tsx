import type { Metadata } from 'next'
import './globals.css'
import AuthProvider from '@/components/AuthProvider'
import SidebarWrapper from '@/components/SidebarWrapper'

export const metadata: Metadata = {
    title: 'Caloriz Admin Panel',
    description: 'Manage users, affiliates, and settings',
}

export default function RootLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return (
        <html lang="en">
            <body className="bg-gray-50 text-gray-900 min-h-screen">
                <AuthProvider>
                    <div className="flex">
                        {/* Determine if we should show sidebar based on path/auth */}
                        {/* For simplicity, we can conditionally render sidebar in AuthProvider or check path here */}
                        <SidebarWrapper>{children}</SidebarWrapper>
                    </div>
                </AuthProvider>
            </body>
        </html>
    )
}
