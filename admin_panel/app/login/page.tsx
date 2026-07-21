"use client";

import { useState } from "react";
import { signInWithEmailAndPassword } from "firebase/auth";
import { auth } from "@/lib/firebase";
import { useRouter } from "next/navigation";
import { Lock, Mail, LogIn } from "lucide-react";

export default function LoginPage() {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(false);
    const router = useRouter();

    const handleAuth = async (e: React.FormEvent) => {
        e.preventDefault();
        setError("");
        setLoading(true);

        try {
            await signInWithEmailAndPassword(auth, email, password);
            router.push("/");
        } catch (err: any) {
            console.error("Full Auth Error:", err);
            // alert(err.message); // Uncomment for quick debugging on screen
            let msg = "Authentication failed: " + err.message;
            if (err.code === "auth/invalid-credential") msg = "Invalid email or password.";
            if (err.code === "auth/configuration-not-found") msg = "Firebase Auth not enabled in console.";
            setError(msg);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="flex min-h-screen items-center justify-center bg-gray-100 p-4">
            <div className="w-full max-w-md overflow-hidden rounded-2xl bg-white shadow-xl">
                {/* Header */}
                <div className="bg-[#00E3CC] p-8 text-center">
                    <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-white/20 backdrop-blur-sm">
                        <Lock className="h-8 w-8 text-white" />
                    </div>
                    <h2 className="text-3xl font-bold text-white">Caloriz Admin</h2>
                    <p className="mt-2 text-white/80">
                        Welcome back! Please login.
                    </p>
                </div>

                {/* Form */}
                <div className="p-8">
                    <form onSubmit={handleAuth} className="space-y-6">
                        <div className="space-y-4">
                            <div>
                                <label className="mb-1 block text-sm font-medium text-gray-700">Email Address</label>
                                <div className="relative">
                                    <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
                                        <Mail className="h-5 w-5 text-gray-400" />
                                    </div>
                                    <input
                                        type="email"
                                        required
                                        className="block w-full rounded-lg border border-gray-300 bg-gray-50 p-2.5 pl-10 text-gray-900 focus:border-[#00E3CC] focus:ring-[#00E3CC]"
                                        placeholder="admin@caloriz.com"
                                        value={email}
                                        onChange={(e) => setEmail(e.target.value)}
                                    />
                                </div>
                            </div>

                            <div>
                                <label className="mb-1 block text-sm font-medium text-gray-700">Password</label>
                                <div className="relative">
                                    <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
                                        <Lock className="h-5 w-5 text-gray-400" />
                                    </div>
                                    <input
                                        type="password"
                                        required
                                        className="block w-full rounded-lg border border-gray-300 bg-gray-50 p-2.5 pl-10 text-gray-900 focus:border-[#00E3CC] focus:ring-[#00E3CC]"
                                        placeholder="••••••••"
                                        value={password}
                                        onChange={(e) => setPassword(e.target.value)}
                                    />
                                </div>
                            </div>
                        </div>

                        {error && (
                            <div className="rounded-lg bg-red-50 p-3 text-sm text-red-500 border border-red-100">
                                {error}
                            </div>
                        )}

                        <button
                            type="submit"
                            disabled={loading}
                            className="flex w-full items-center justify-center rounded-lg bg-[#00E3CC] px-5 py-3 text-center text-sm font-medium text-white hover:bg-[#00c4b0] focus:outline-none focus:ring-4 focus:ring-[#00E3CC]/30 disabled:opacity-50 transition-colors"
                        >
                            {loading ? (
                                "Processing..."
                            ) : (
                                <>
                                    <LogIn className="mr-2 h-4 w-4" />
                                    Sign In
                                </>
                            )}
                        </button>
                    </form>
                </div>
            </div>
        </div>
    );
}
