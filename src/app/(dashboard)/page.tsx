'use client';

import { useState, useMemo } from 'react';
import { useLoans } from '@/hooks/useLoans';
import { useUsers } from '@/hooks/useUsers';
import { LoanCard } from '@/components/LoanCard';
import { LoanRequest } from '@/lib/types';
import { isInMora } from '@/lib/mora';

const STATUS_FILTERS: { label: string; value: LoanRequest['status'] | 'all' | 'mora' }[] = [
  { label: 'Todas', value: 'all' },
  { label: 'Pendientes', value: 'pending' },
  { label: 'En proceso', value: 'in_process' },
  { label: 'En desembolso', value: 'in_disbursement_process' },
  { label: 'Aprobadas', value: 'approved' },
  { label: 'Rechazadas', value: 'rejected' },
  { label: '⚠ En mora', value: 'mora' },
];

export default function HomePage() {
  const { loans, loading, error, refetch } = useLoans();
  const { users } = useUsers();
  const [filter, setFilter] = useState<LoanRequest['status'] | 'all' | 'mora'>('all');
  const [search, setSearch] = useState('');

  const usersByPhone = useMemo(() => {
    const map: Record<string, string> = {};
    for (const u of users) {
      if (u.phone) map[u.phone] = [u.name, u.lastName].filter(Boolean).join(' ');
    }
    return map;
  }, [users]);

  const moraCount = useMemo(() => loans.filter(isInMora).length, [loans]);

  const filtered = useMemo(() => {
    return loans.filter(loan => {
      const matchesStatus =
        filter === 'all' ? true :
        filter === 'mora' ? isInMora(loan) :
        loan.status === filter;
      const matchesSearch = !search || loan.phone.includes(search) ||
        (usersByPhone[loan.phone] || '').toLowerCase().includes(search.toLowerCase());
      return matchesStatus && matchesSearch;
    });
  }, [loans, filter, search, usersByPhone]);

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-white text-2xl font-bold">Solicitudes</h1>
          <p className="text-gray-400 text-sm mt-1">
            {loans.length} solicitudes en total
            {moraCount > 0 && (
              <span className="ml-2 text-orange-400 font-medium">· {moraCount} en mora</span>
            )}
          </p>
        </div>
        <button
          onClick={refetch}
          className="text-[#2FFF00] border border-[#2FFF00]/30 px-3 py-1.5 rounded-lg text-sm hover:bg-[#2FFF00]/10 transition-colors"
        >
          Actualizar
        </button>
      </div>

      <input
        type="text"
        value={search}
        onChange={e => setSearch(e.target.value)}
        placeholder="Buscar por teléfono o nombre..."
        className="w-full bg-[#0d1f0d] border border-[#2FFF00]/20 rounded-xl px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:border-[#2FFF00]/60 transition-colors mb-4"
      />

      <div className="flex gap-2 flex-wrap mb-6">
        {STATUS_FILTERS.map(f => {
          const isMora = f.value === 'mora';
          const isActive = filter === f.value;
          return (
            <button
              key={f.value}
              onClick={() => setFilter(f.value)}
              className={`px-3 py-1.5 rounded-full text-sm font-medium transition-all ${
                isActive
                  ? isMora ? 'bg-orange-500 text-white' : 'bg-[#2FFF00] text-black'
                  : isMora
                    ? 'bg-orange-500/15 text-orange-400 hover:bg-orange-500/25'
                    : 'bg-[#2FFF00]/10 text-[#2FFF00] hover:bg-[#2FFF00]/20'
              }`}
            >
              {f.label}
              {isMora && moraCount > 0 && (
                <span className={`ml-1.5 px-1.5 py-0.5 rounded-full text-xs font-bold ${isActive ? 'bg-white/20' : 'bg-orange-500/30'}`}>
                  {moraCount}
                </span>
              )}
            </button>
          );
        })}
      </div>

      {loading ? (
        <div className="flex justify-center py-16">
          <div className="w-8 h-8 border-2 border-[#2FFF00] border-t-transparent rounded-full animate-spin" />
        </div>
      ) : error ? (
        <p className="text-red-400 text-center py-8">{error}</p>
      ) : filtered.length === 0 ? (
        <p className="text-gray-500 text-center py-8">No hay solicitudes</p>
      ) : (
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {filtered.map(loan => (
            <LoanCard
              key={loan.id}
              loan={loan}
              userName={usersByPhone[loan.phone]}
              inMora={isInMora(loan)}
            />
          ))}
        </div>
      )}
    </div>
  );
}
