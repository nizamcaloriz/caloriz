"use client";

import { useEffect, useState } from "react";
import { db } from "@/lib/firebase";
import { collection, getDocs, query, limit, orderBy, updateDoc, doc } from "firebase/firestore";

interface User {
    id: string;
    name?: string;
    email?: string;
    isPremium?: boolean;
    isBanned?: boolean;
    createdAt?: any;
}

export default function UsersPage() {
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        async function fetchUsers() {
            try {
                const q = query(collection(db, "users"), orderBy("createdAt", "desc"), limit(20));
                const querySnapshot = await getDocs(q);
                const usersList = querySnapshot.docs.map(doc => ({
                    id: doc.id,
                    ...doc.data()
                })) as User[];
                setUsers(usersList);
            } catch (e) {
                console.error("Error fetching users:", e);
            } finally {
                setLoading(false);
            }
        }
        fetchUsers();
    }, []);

    const handleBanToggle = async (userId: string, currentStatus: boolean | undefined) => {
        const action = currentStatus ? "Unban" : "Ban";
        console.log(`Attempting to ${action} user: ${userId}`);

        if (!confirm(`Are you sure you want to ${action} this user?`)) {
            console.log("Action cancelled by user");
            return;
        }

        try {
            console.log("Updating Firestore...");
            await updateDoc(doc(db, "users", userId), {
                isBanned: !currentStatus,
                bannedAt: !currentStatus ? new Date() : null
            });
            console.log("Firestore update successful");

            // Update local state to reflect change instantly
            setUsers(users.map(u =>
                u.id === userId ? { ...u, isBanned: !currentStatus } : u
            ));

            alert(`User has been ${action}ned.`);
        } catch (e: any) {
            console.error("Error updating user status:", e);
            alert(`Failed to update user status: ${e.message}`);
        }
    };

    if (loading) return <div className="p-8 text-center text-gray-500">Loading users...</div>;

    return (
        <div>
            <h1 className="text-2xl font-bold mb-6">User Directory</h1>

            <div className="bg-white rounded-lg shadow overflow-hidden">
                <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                        <tr>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Joined</th>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                        {users.map((user) => (
                            <tr key={user.id} className={user.isBanned ? "bg-red-50" : ""}>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <div className="text-sm font-medium text-gray-900">{user.name || "N/A"}</div>
                                    <div className="text-sm text-gray-500">ID: {user.id.substring(0, 8)}...</div>
                                    {user.isBanned && <span className="text-xs text-red-600 font-bold">BANNED</span>}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{user.email}</td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${user.isPremium ? "bg-green-100 text-green-800" : "bg-gray-100 text-gray-800"}`}>
                                        {user.isPremium ? "Premium" : "Free"}
                                    </span>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                    {user.createdAt?.toDate ? user.createdAt.toDate().toLocaleDateString() : 'N/A'}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                    {/* <button className="text-primary hover:text-secondary mr-4">Edit</button> */}
                                    <button
                                        onClick={() => handleBanToggle(user.id, user.isBanned)}
                                        className={`${user.isBanned ? "text-green-600 hover:text-green-900" : "text-red-600 hover:text-red-900"}`}
                                    >
                                        {user.isBanned ? "Unban" : "Ban"}
                                    </button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
