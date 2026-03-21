'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/hooks/useAuth';
import { Sidebar } from '@/components/Sidebar';
import { PushNotificationInit } from '@/components/PushNotificationInit';

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && !user) {
      router.replace('/login');
    }
  }, [user, loading, router]);

  if (loading) {
    return (
      <div className="min-h-screen bg-[#061006] flex items-center justify-center">
        <div className="w-8 h-8 border-2 border-[#2FFF00] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (!user) return null;

  return (
    <div className="min-h-screen bg-[#061006]">
      <PushNotificationInit user={user} />
      <Sidebar />
      <main className="md:ml-64 min-h-screen p-4 md:p-6 pt-16 md:pt-6">
        {children}
      </main>
    </div>
  );
}
