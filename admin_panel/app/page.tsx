"use client";

import { useEffect, useState } from 'react';
import { db } from '@/lib/firebase';
import { collection, getDocs, query, where, getCountFromServer, doc, getDoc, limit } from 'firebase/firestore';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

export default function Home() {
    const [stats, setStats] = useState({
        totalUsers: 0,
        premiumUsers: 0,
        activePartners: 0,
        pendingWithdrawals: 0,
        totalScans: 0,
        monthlyRevenue: 0,
    });

    const [loading, setLoading] = useState(true);
    const [chartData, setChartData] = useState<any[]>([]);

    useEffect(() => {
        async function fetchStats() {
            try {
                // Users
                const usersSnap = await getCountFromServer(collection(db, "users"));
                const premiumSnap = await getCountFromServer(query(collection(db, "users"), where("isPremium", "==", true)));

                const withdrawalsSnap = await getCountFromServer(query(collection(db, "withdrawals"), where("status", "==", "pending")));

                // Scan Count & Revenue
                let scanCount = 0;
                let totalRevenue = 0;
                try {
                    const globalStatsDoc = await getDoc(doc(db, "settings", "global_stats"));
                    if (globalStatsDoc.exists()) {
                        scanCount = globalStatsDoc.data().totalScans || 0;
                        totalRevenue = globalStatsDoc.data().totalRevenue || 0;
                    }
                } catch (err) {
                    console.log("Global stats error:", err);
                }

                // Active Partners
                let activePartners = 0;
                try {
                    const referralsSnap = await getDocs(query(collection(db, "referrals"), limit(500)));
                    const uniqueReferrers = new Set(referralsSnap.docs.map(d => d.data().referrerId));
                    activePartners = uniqueReferrers.size;
                } catch (e) {
                    console.log("Error fetching active partners", e);
                }

                // Chart Data
                const chartPoints: any[] = [];
                try {
                    const today = new Date();
                    const sevenDaysAgo = new Date();
                    sevenDaysAgo.setDate(today.getDate() - 7);

                    const recentUsers = await getDocs(query(collection(db, "users"), where("createdAt", ">", sevenDaysAgo)));

                    const daysMap = new Map<string, number>();
                    // Initialize
                    for (let i = 6; i >= 0; i--) {
                        const d = new Date();
                        d.setDate(today.getDate() - i);
                        const dayName = d.toLocaleDateString('en-US', { weekday: 'short' });
                        daysMap.set(dayName, 0);
                    }

                    recentUsers.forEach((doc) => {
                        const data = doc.data();
                        if (data.createdAt) {
                            const date = data.createdAt.toDate ? data.createdAt.toDate() : new Date(data.createdAt);
                            const dayName = date.toLocaleDateString('en-US', { weekday: 'short' });
                            if (daysMap.has(dayName)) {
                                daysMap.set(dayName, (daysMap.get(dayName) || 0) + 1);
                            }
                        }
                    });

                    // Convert to array
                    for (let i = 6; i >= 0; i--) {
                        const d = new Date();
                        d.setDate(today.getDate() - i);
                        const dayName = d.toLocaleDateString('en-US', { weekday: 'short' });
                        chartPoints.push({ name: dayName, users: daysMap.get(dayName) || 0 });
                    }

                } catch (e) {
                    console.error("Chart data error", e);
                }

                setStats({
                    totalUsers: usersSnap.data().count,
                    premiumUsers: premiumSnap.data().count,
                    activePartners: activePartners,
                    pendingWithdrawals: withdrawalsSnap.data().count,
                    totalScans: scanCount,
                    // Use real tracked revenue if available (>0), else use estimate ($10 * count)
                    monthlyRevenue: totalRevenue > 0 ? totalRevenue : (premiumSnap.data().count * 10),
                });
                setChartData(chartPoints);

            } catch (e) {
                console.error("Error fetching stats:", e);
            } finally {
                setLoading(false);
            }
        }

        fetchStats();
    }, []);

    return (
        <div>
            <h1 className="text-3xl font-bold mb-8">Dashboard Overview</h1>

            {/* Cards */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <StatCard title="Total Users" value={stats.totalUsers} icon="👥" color="bg-blue-100 text-blue-800" />
                <StatCard title="Premium Subscribers" value={stats.premiumUsers} icon="⭐" color="bg-yellow-100 text-yellow-800" />
                <StatCard title="Total Revenue" value={`$${stats.monthlyRevenue.toFixed(2)}`} icon="💰" color="bg-green-100 text-green-800" />
                <StatCard title="Pending Withdrawals" value={stats.pendingWithdrawals} icon="🏦" color="bg-orange-100 text-orange-800" />
                <StatCard title="Total Scans" value={stats.totalScans} icon="📷" color="bg-purple-100 text-purple-800" />
            </div>

            {/* Chart */}
            <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100">
                <h2 className="text-xl font-semibold mb-4">New Users (Last 7 Days)</h2>
                <div className="h-64 w-full">
                    <ResponsiveContainer width="100%" height="100%">
                        <AreaChart
                            data={chartData}
                            margin={{ top: 10, right: 30, left: 0, bottom: 0 }}
                        >
                            <CartesianGrid strokeDasharray="3 3" />
                            <XAxis dataKey="name" />
                            <YAxis />
                            <Tooltip />
                            <Area type="monotone" dataKey="users" stroke="#00A89E" fill="#00E3CC" />
                        </AreaChart>
                    </ResponsiveContainer>
                </div>
            </div>
        </div>
    );
}

function StatCard({ title, value, icon, color }: { title: string, value: string | number, icon: string, color: string }) {
    return (
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-100 flex items-center justify-between">
            <div>
                <p className="text-sm text-gray-500 font-medium">{title}</p>
                <p className="text-2xl font-bold mt-1 text-gray-900">{value}</p>
            </div>
            <div className={`p-4 rounded-full ${color}`}>
                <span className="text-xl">{icon}</span>
            </div>
        </div>
    );
}
