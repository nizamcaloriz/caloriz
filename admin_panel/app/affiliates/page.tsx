"use client";

import { useEffect, useState } from 'react';
import { db } from '@/lib/firebase';
import { collection, getDocs, query, where, orderBy, doc, updateDoc, increment, getDoc, serverTimestamp } from 'firebase/firestore';

export default function AffiliatesPage() {
    const [stats, setStats] = useState({
        totalPartners: 0,
        totalEarnings: 0,
        pendingWithdrawalsCount: 0,
        pendingWithdrawalsAmount: 0,
    });
    const [partners, setPartners] = useState<any[]>([]);
    const [withdrawals, setWithdrawals] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchData();
    }, []);

    async function fetchData() {
        setLoading(true);
        try {
            // 1. Fetch Partners (Users with referralCount > 0)
            const partnersSnap = await getDocs(query(collection(db, "users"), where("referralCount", ">", 0), orderBy("referralCount", "desc")));
            const partnersList = partnersSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setPartners(partnersList);

            // 2. Fetch Pending Withdrawals
            const withdrawalsSnap = await getDocs(query(collection(db, "withdrawals"), where("status", "==", "pending")));
            const withdrawalsList = withdrawalsSnap.docs
                .map(doc => ({ id: doc.id, ...doc.data() }))
                .sort((a: any, b: any) => (b.requestedAt?.seconds || 0) - (a.requestedAt?.seconds || 0));
            setWithdrawals(withdrawalsList);

            // 3. Calculate Stats
            let earnings = 0;
            partnersList.forEach((p: any) => earnings += (p.totalEarned || 0));

            let pendingAmount = 0;
            withdrawalsList.forEach((w: any) => pendingAmount += (w.amount || 0));

            setStats({
                totalPartners: partnersList.length,
                totalEarnings: earnings,
                pendingWithdrawalsCount: withdrawalsList.length,
                pendingWithdrawalsAmount: pendingAmount,
            });

        } catch (e) {
            console.error("Error fetching affiliates data:", e);
        } finally {
            setLoading(false);
        }
    }

    async function handleApproveWithdrawal(withdrawal: any) {
        if (!confirm(`Approve payment of ${withdrawal.currencySymbol}${withdrawal.amount} to user?`)) return;

        try {
            // Update withdrawal status
            await updateDoc(doc(db, "withdrawals", withdrawal.id), {
                status: 'completed',
                completedAt: serverTimestamp(),
            });

            // Update user wallet (already deducted when requested, just logging/notifying)
            // But we might want to update 'totalWithdrawn' if we tracked it.
            // For now just mark complete.

            alert("Withdrawal approved!");
            fetchData(); // Refresh
        } catch (e) {
            console.error("Error approving withdrawal:", e);
            alert("Failed to approve.");
        }
    }

    async function handleRejectWithdrawal(withdrawal: any) {
        if (!confirm(`Reject withdrawal? The amount ${withdrawal.currencySymbol}${withdrawal.amount} will be refunded to user wallet.`)) return;

        try {
            // Update withdrawal status
            await updateDoc(doc(db, "withdrawals", withdrawal.id), {
                status: 'rejected',
                rejectedAt: serverTimestamp(),
            });

            // Refund amount to user wallet
            await updateDoc(doc(db, "users", withdrawal.userId), {
                walletBalance: increment(withdrawal.amount),
                pendingEarnings: 0, // Reset pending
            });

            alert("Withdrawal rejected and refunded.");
            fetchData(); // Refresh
        } catch (e) {
            console.error("Error rejecting withdrawal:", e);
            alert("Failed to reject.");
        }
    }

    if (loading) {
        return <div className="p-8 text-center">Loading Affiliates Data...</div>;
    }

    return (
        <div className="p-6">
            <h1 className="text-3xl font-bold mb-8">Affiliates Program</h1>

            {/* Stats Overview */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
                <StatCard title="Active Partners" value={stats.totalPartners} icon="🤝" color="bg-blue-100 text-blue-800" />
                <StatCard title="Total Earnings Paid" value={`₹${stats.totalEarnings.toFixed(2)}`} icon="💸" color="bg-green-100 text-green-800" />
                <StatCard title="Pending Requests" value={stats.pendingWithdrawalsCount} icon="⏳" color="bg-orange-100 text-orange-800" />
                <StatCard title="Pending Amount" value={`₹${stats.pendingWithdrawalsAmount.toFixed(2)}`} icon="🏦" color="bg-red-100 text-red-800" />
            </div>

            {/* Pending Withdrawals Section */}
            {withdrawals.length > 0 && (
                <div className="bg-white rounded-lg shadow mb-8 overflow-hidden">
                    <div className="px-6 py-4 border-b border-gray-200 bg-orange-50">
                        <h2 className="text-lg font-semibold text-orange-800">Pending Withdrawal Requests</h2>
                    </div>
                    <table className="min-w-full divide-y divide-gray-200">
                        <thead className="bg-gray-50">
                            <tr>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User ID</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Method</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Details</th>
                                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Amount</th>
                                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-200">
                            {withdrawals.map((w) => (
                                <tr key={w.id}>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{w.userId.substring(0, 8)}...</td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 capitalize">{w.paymentMethod}</td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{w.paymentDetails}</td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm font-bold text-gray-900 text-right">
                                        {w.currencySymbol}{w.amount.toFixed(2)}
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                        <button onClick={() => handleApproveWithdrawal(w)} className="text-green-600 hover:text-green-900 mr-4 font-semibold">Approve</button>
                                        <button onClick={() => handleRejectWithdrawal(w)} className="text-red-600 hover:text-red-900">Reject</button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            )}

            {/* Top Partners Table */}
            <div className="bg-white rounded-lg shadow overflow-hidden">
                <div className="px-6 py-4 border-b border-gray-200">
                    <h2 className="text-lg font-semibold text-gray-800">Top Performing Partners</h2>
                </div>
                <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                        <tr>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Partner</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Referrals</th>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Total Earned</th>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Wallet Bal</th>
                        </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                        {partners.map((p) => (
                            <tr key={p.id}>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <div className="flex items-center">
                                        <div className="h-8 w-8 rounded-full bg-teal-100 flex items-center justify-center text-teal-600 font-bold mr-3">
                                            {p.name?.[0]?.toUpperCase() || 'U'}
                                        </div>
                                        <div>
                                            <div className="text-sm font-medium text-gray-900">{p.name || 'Unknown'}</div>
                                            <div className="text-xs text-gray-500">{p.email}</div>
                                        </div>
                                    </div>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 font-medium">
                                    {p.referralCount || 0}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-green-600 font-bold text-right">
                                    ₹{(p.totalEarned || 0).toFixed(2)}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 text-right">
                                    ₹{(p.walletBalance || 0).toFixed(2)}
                                </td>
                            </tr>
                        ))}
                        {partners.length === 0 && (
                            <tr>
                                <td colSpan={4} className="px-6 py-8 text-center text-gray-500">
                                    No active partners found.
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
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
