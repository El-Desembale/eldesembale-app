'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useAuth } from '@/hooks/useAuth';

const NAV = [
  { href: '/', label: 'Solicitudes', icon: '📋' },
  { href: '/usuarios', label: 'Usuarios', icon: '👥' },
  { href: '/pagos', label: 'Pagos', icon: '💰' },
];

export function Sidebar() {
  const pathname = usePathname();
  const { logout } = useAuth();
  const [mobileOpen, setMobileOpen] = useState(false);

  const NavLinks = () => (
    <nav className="flex flex-col gap-2 flex-1">
      {NAV.map(item => {
        const active = pathname === item.href || (item.href !== '/' && pathname.startsWith(item.href));
        return (
          <Link
            key={item.href}
            href={item.href}
            onClick={() => setMobileOpen(false)}
            className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all text-sm font-medium ${
              active
                ? 'bg-[#2FFF00] text-black'
                : 'text-gray-300 hover:bg-[#2FFF00]/10 hover:text-[#2FFF00]'
            }`}
          >
            <span>{item.icon}</span>
            <span>{item.label}</span>
          </Link>
        );
      })}
    </nav>
  );

  return (
    <>
      {/* Mobile hamburger */}
      <button
        className="md:hidden fixed top-4 left-4 z-50 bg-[#0a1a0a] border border-[#2FFF00]/30 p-2 rounded-lg text-[#2FFF00]"
        onClick={() => setMobileOpen(v => !v)}
      >
        {mobileOpen ? '✕' : '☰'}
      </button>

      {/* Mobile overlay */}
      {mobileOpen && (
        <div
          className="md:hidden fixed inset-0 bg-black/60 z-40"
          onClick={() => setMobileOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside
        className={`fixed top-0 left-0 h-full w-64 bg-[#061006] border-r border-[#2FFF00]/20 flex flex-col z-40 transition-transform duration-300
          ${mobileOpen ? 'translate-x-0' : '-translate-x-full'} md:translate-x-0`}
      >
        {/* Logo */}
        <div className="p-6 border-b border-[#2FFF00]/20">
          <h1 className="text-[#2FFF00] font-bold text-xl">El Desembale</h1>
          <p className="text-gray-500 text-xs mt-1">Admin Panel</p>
        </div>

        <div className="flex-1 p-4 flex flex-col">
          <NavLinks />

          <button
            onClick={logout}
            className="mt-4 flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium text-gray-400 hover:bg-red-900/20 hover:text-red-400 transition-all"
          >
            <span>🚪</span>
            <span>Cerrar sesión</span>
          </button>
        </div>
      </aside>
    </>
  );
}
