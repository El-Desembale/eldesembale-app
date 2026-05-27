'use client';

import Link from 'next/link';
import { useMemo, useState } from 'react';
import { useLoans } from '@/hooks/useLoans';
import { useUsers } from '@/hooks/useUsers';
import { isInMora } from '@/lib/mora';
import { LoanRequest, STATUS_LABELS } from '@/lib/types';

const STATUS_FILTERS: { label: string; value: LoanRequest['status'] | 'all' | 'mora' }[] = [
  { label: 'Todas', value: 'all' },
  { label: 'Pendientes', value: 'pending' },
  { label: 'En revisión', value: 'in_process' },
  { label: 'En desembolso', value: 'in_disbursement_process' },
  { label: 'Aprobadas', value: 'approved' },
  { label: 'Rechazadas', value: 'rejected' },
  { label: 'En mora', value: 'mora' },
];

type SortOption = 'recent' | 'oldest' | 'highest' | 'lowest';

function formatCurrency(value: number) {
  return new Intl.NumberFormat('es-CO', {
    style: 'currency',
    currency: 'COP',
    maximumFractionDigits: 0,
  }).format(value);
}

function formatDate(date: Date) {
  return date.toLocaleDateString('es-CO', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

function formatDateInput(date: Date) {
  return new Date(date.getTime() - date.getTimezoneOffset() * 60000)
    .toISOString()
    .slice(0, 10);
}

function getStatusTone(status: LoanRequest['status'] | 'mora') {
  switch (status) {
    case 'approved':
      return 'bg-emerald-500/14 text-emerald-300 ring-1 ring-emerald-500/25';
    case 'pending':
      return 'bg-amber-500/14 text-amber-300 ring-1 ring-amber-500/25';
    case 'in_process':
      return 'bg-slate-300/10 text-slate-200 ring-1 ring-white/10';
    case 'in_disbursement_process':
      return 'bg-sky-500/14 text-sky-300 ring-1 ring-sky-500/25';
    case 'rejected':
      return 'bg-rose-500/14 text-rose-300 ring-1 ring-rose-500/25';
    case 'mora':
      return 'bg-orange-500/14 text-orange-300 ring-1 ring-orange-500/25';
    default:
      return 'bg-white/8 text-white ring-1 ring-white/10';
  }
}

function StatusPill({
  status,
  inMora,
}: {
  status: LoanRequest['status'];
  inMora?: boolean;
}) {
  if (inMora) {
    return (
      <span
        className={`inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold ${getStatusTone(
          'mora',
        )}`}
      >
        En mora
      </span>
    );
  }

  return (
    <span
      className={`inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold ${getStatusTone(
        status,
      )}`}
    >
      {STATUS_LABELS[status]}
    </span>
  );
}

function SummaryCard({
  label,
  value,
  accent,
  helper,
}: {
  label: string;
  value: number;
  accent: string;
  helper: string;
}) {
  return (
    <div className="rounded-[28px] border border-[#23352a] bg-[#0d1712] px-5 py-5 shadow-[0_20px_60px_rgba(0,0,0,0.25)]">
      <div className={`mb-4 h-1.5 w-14 rounded-full ${accent}`} />
      <p className="text-xs font-semibold uppercase tracking-[0.22em] text-[#7f9485]">
        {label}
      </p>
      <div className="mt-3 flex items-end justify-between gap-4">
        <p className="text-4xl font-semibold tracking-[-0.04em] text-[#f6f5ef]">
          {value}
        </p>
        <p className="max-w-[9rem] text-right text-xs leading-5 text-[#7f9485]">
          {helper}
        </p>
      </div>
    </div>
  );
}

export default function HomePage() {
  const { loans, loading, error, refetch } = useLoans();
  const { users } = useUsers();
  const [filter, setFilter] = useState<LoanRequest['status'] | 'all' | 'mora'>(
    'all',
  );
  const [search, setSearch] = useState('');
  const [fromDate, setFromDate] = useState('');
  const [toDate, setToDate] = useState('');
  const [sortBy, setSortBy] = useState<SortOption>('recent');

  const usersByPhone = useMemo(() => {
    const map: Record<string, { name: string; email: string }> = {};

    for (const user of users) {
      if (!user.phone) continue;
      map[user.phone] = {
        name: [user.name, user.lastName].filter(Boolean).join(' ').trim(),
        email: user.email,
      };
    }

    return map;
  }, [users]);

  const summary = useMemo(() => {
    const pending = loans.filter((loan) => loan.status === 'pending').length;
    const inReview = loans.filter((loan) => loan.status === 'in_process').length;
    const approved = loans.filter((loan) => loan.status === 'approved').length;
    const overdue = loans.filter(isInMora).length;

    return {
      total: loans.length,
      pending,
      inReview,
      approved,
      overdue,
    };
  }, [loans]);

  const filtered = useMemo(() => {
    const normalizedSearch = search.trim().toLowerCase();
    const from = fromDate ? new Date(`${fromDate}T00:00:00`) : null;
    const to = toDate ? new Date(`${toDate}T23:59:59`) : null;

    const next = loans.filter((loan) => {
      const inOverdue = isInMora(loan);
      const userInfo = usersByPhone[loan.phone];
      const haystack = [
        loan.phone,
        loan.id,
        userInfo?.name || '',
        userInfo?.email || '',
      ]
        .join(' ')
        .toLowerCase();

      const matchesStatus =
        filter === 'all'
          ? true
          : filter === 'mora'
            ? inOverdue
            : loan.status === filter;

      const matchesSearch =
        !normalizedSearch || haystack.includes(normalizedSearch);

      const matchesFrom = !from || loan.createdAt >= from;
      const matchesTo = !to || loan.createdAt <= to;

      return matchesStatus && matchesSearch && matchesFrom && matchesTo;
    });

    next.sort((a, b) => {
      switch (sortBy) {
        case 'oldest':
          return a.createdAt.getTime() - b.createdAt.getTime();
        case 'highest':
          return b.amount - a.amount;
        case 'lowest':
          return a.amount - b.amount;
        case 'recent':
        default:
          return b.createdAt.getTime() - a.createdAt.getTime();
      }
    });

    return next;
  }, [filter, fromDate, loans, search, sortBy, toDate, usersByPhone]);

  return (
    <div className="space-y-6 text-[#f6f5ef]">
      <section className="rounded-[32px] border border-[#203027] bg-[linear-gradient(180deg,#121c16_0%,#0b120e_100%)] p-6 shadow-[0_30px_90px_rgba(0,0,0,0.35)]">
        <div className="flex flex-col gap-5 xl:flex-row xl:items-end xl:justify-between">
          <div className="max-w-2xl">
            <div className="mb-4 inline-flex items-center rounded-full border border-[#31453b] bg-[#121d17] px-3 py-1 text-[11px] font-semibold uppercase tracking-[0.24em] text-[#9db2a1]">
              Panel de solicitudes
            </div>
            <h1 className="text-3xl font-semibold tracking-[-0.04em] text-[#f6f5ef] md:text-4xl">
              Solicitudes de préstamo ordenadas para decidir más rápido
            </h1>
            <p className="mt-3 max-w-xl text-sm leading-6 text-[#8fa393]">
              Revisa el volumen total, filtra por estado o fecha y entra al
              detalle de cada solicitud desde una sola tabla operativa.
            </p>
          </div>

          <div className="flex flex-wrap items-center gap-3">
            <button
              onClick={refetch}
              className="inline-flex items-center rounded-2xl border border-[#33493d] bg-[#16231b] px-4 py-2.5 text-sm font-medium text-[#dfe7df] transition hover:border-[#4d6657] hover:bg-[#1a2a20]"
            >
              Actualizar
            </button>
            <div className="rounded-2xl border border-[#33493d] bg-[#111914] px-4 py-2.5 text-sm text-[#8fa393]">
              {filtered.length} de {loans.length} solicitudes
            </div>
          </div>
        </div>
      </section>

      <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-5">
        <SummaryCard
          label="Total"
          value={summary.total}
          accent="bg-[#b79d66]"
          helper="Todos los registros cargados en el panel"
        />
        <SummaryCard
          label="Pendientes"
          value={summary.pending}
          accent="bg-[#d2a45c]"
          helper="Esperando revisión inicial"
        />
        <SummaryCard
          label="En revisión"
          value={summary.inReview}
          accent="bg-[#7d8fa4]"
          helper="Casos con validación en curso"
        />
        <SummaryCard
          label="Aprobadas"
          value={summary.approved}
          accent="bg-[#6ea37d]"
          helper="Solicitudes listas o ya activadas"
        />
        <SummaryCard
          label="En mora"
          value={summary.overdue}
          accent="bg-[#d38e5a]"
          helper="Créditos activos con atraso detectado"
        />
      </section>

      <section className="rounded-[32px] border border-[#203027] bg-[#0d1511] p-5 shadow-[0_25px_80px_rgba(0,0,0,0.28)]">
        <div className="flex flex-col gap-4">
          <div className="flex flex-wrap gap-2">
            {STATUS_FILTERS.map((item) => {
              const active = filter === item.value;
              const isMora = item.value === 'mora';

              return (
                <button
                  key={item.value}
                  onClick={() => setFilter(item.value)}
                  className={`rounded-2xl px-4 py-2 text-sm font-medium transition ${
                    active
                      ? isMora
                        ? 'bg-orange-500 text-white'
                        : 'bg-[#f1ede2] text-[#171d18]'
                      : isMora
                        ? 'bg-orange-500/10 text-orange-300 hover:bg-orange-500/15'
                        : 'bg-[#141d18] text-[#93a895] hover:bg-[#1b2820] hover:text-[#f6f5ef]'
                  }`}
                >
                  {item.label}
                  {isMora && summary.overdue > 0 && (
                    <span
                      className={`ml-2 rounded-full px-2 py-0.5 text-[11px] ${
                        active ? 'bg-white/20' : 'bg-orange-500/20'
                      }`}
                    >
                      {summary.overdue}
                    </span>
                  )}
                </button>
              );
            })}
          </div>

          <div className="grid gap-3 xl:grid-cols-[minmax(0,1.25fr)_180px_180px_180px]">
            <div className="relative">
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Buscar por código, teléfono, nombre o correo..."
                className="w-full rounded-2xl border border-[#2b3c31] bg-[#121b16] px-4 py-3 text-sm text-[#f6f5ef] placeholder:text-[#728576] outline-none transition focus:border-[#496152]"
              />
            </div>

            <input
              type="date"
              value={fromDate}
              max={toDate || undefined}
              onChange={(e) => setFromDate(e.target.value)}
              className="rounded-2xl border border-[#2b3c31] bg-[#121b16] px-4 py-3 text-sm text-[#dfe7df] outline-none transition focus:border-[#496152]"
            />

            <input
              type="date"
              value={toDate}
              min={fromDate || undefined}
              onChange={(e) => setToDate(e.target.value)}
              className="rounded-2xl border border-[#2b3c31] bg-[#121b16] px-4 py-3 text-sm text-[#dfe7df] outline-none transition focus:border-[#496152]"
            />

            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value as SortOption)}
              className="rounded-2xl border border-[#2b3c31] bg-[#121b16] px-4 py-3 text-sm text-[#dfe7df] outline-none transition focus:border-[#496152]"
            >
              <option value="recent">Más reciente</option>
              <option value="oldest">Más antigua</option>
              <option value="highest">Monto más alto</option>
              <option value="lowest">Monto más bajo</option>
            </select>
          </div>
        </div>
      </section>

      <section className="overflow-hidden rounded-[32px] border border-[#203027] bg-[#0c130f] shadow-[0_30px_90px_rgba(0,0,0,0.3)]">
        {loading ? (
          <div className="flex justify-center py-20">
            <div className="h-10 w-10 animate-spin rounded-full border-2 border-[#d4dbc8] border-t-transparent" />
          </div>
        ) : error ? (
          <div className="px-6 py-16 text-center text-sm text-rose-300">
            {error}
          </div>
        ) : filtered.length === 0 ? (
          <div className="px-6 py-16 text-center text-sm text-[#7f9485]">
            No hay solicitudes para los filtros actuales.
          </div>
        ) : (
          <>
            <div className="hidden grid-cols-[1.2fr_1fr_1.1fr_0.8fr_0.9fr_0.8fr_0.7fr] gap-4 border-b border-[#1f2d24] bg-[#101914] px-6 py-4 text-xs font-semibold uppercase tracking-[0.18em] text-[#7e9383] lg:grid">
              <div>Solicitud</div>
              <div>Cliente</div>
              <div>Contacto y fecha</div>
              <div>Monto</div>
              <div>Cuotas</div>
              <div>Estado</div>
              <div className="text-right">Acción</div>
            </div>

            <div className="divide-y divide-[#1a2720]">
              {filtered.map((loan) => {
                const userInfo = usersByPhone[loan.phone];
                const fullName = userInfo?.name || 'Sin nombre';
                const email = userInfo?.email || 'Sin correo';
                const inMora = isInMora(loan);
                const paidRatio = `${loan.installmentsPaid}/${loan.installments}`;
                const progress =
                  loan.installments > 0
                    ? Math.min(100, (loan.installmentsPaid / loan.installments) * 100)
                    : 0;

                return (
                  <Link
                    key={loan.id}
                    href={`/solicitudes/${loan.id}`}
                    className="block transition hover:bg-[#111b16]"
                  >
                    <div className="px-5 py-5 lg:px-6">
                      <div className="grid gap-4 lg:grid-cols-[1.2fr_1fr_1.1fr_0.8fr_0.9fr_0.8fr_0.7fr] lg:items-center">
                        <div>
                          <p className="text-sm font-semibold tracking-[-0.01em] text-[#f3efe4]">
                            {loan.id}
                          </p>
                          <p className="mt-1 text-xs text-[#7f9485]">
                            {loan.paymentPeriod}
                          </p>
                        </div>

                        <div>
                          <p className="text-sm font-medium text-[#f6f5ef]">
                            {fullName}
                          </p>
                          <p className="mt-1 text-xs text-[#7f9485]">{email}</p>
                        </div>

                        <div>
                          <p className="text-sm text-[#dce3d9]">{loan.phone}</p>
                          <p className="mt-1 text-xs text-[#7f9485]">
                            {formatDate(loan.createdAt)}
                          </p>
                        </div>

                        <div>
                          <p className="text-sm font-semibold text-[#f6f5ef]">
                            {formatCurrency(loan.amount)}
                          </p>
                        </div>

                        <div>
                          <div className="flex items-center justify-between text-xs text-[#8ea191]">
                            <span>Pagadas {paidRatio}</span>
                            <span>{Math.round(progress)}%</span>
                          </div>
                          <div className="mt-2 h-2 overflow-hidden rounded-full bg-[#17211c]">
                            <div
                              className={`h-full rounded-full ${
                                inMora
                                  ? 'bg-orange-400'
                                  : loan.status === 'approved'
                                    ? 'bg-emerald-400'
                                    : 'bg-[#d7c28a]'
                              }`}
                              style={{ width: `${progress}%` }}
                            />
                          </div>
                        </div>

                        <div>
                          <StatusPill status={loan.status} inMora={inMora} />
                        </div>

                        <div className="flex justify-end">
                          <span className="inline-flex items-center rounded-2xl border border-[#2a3a31] bg-[#141d18] px-4 py-2 text-sm font-medium text-[#e8e3d6] transition hover:border-[#4a6254] hover:bg-[#18231d]">
                            Ver
                          </span>
                        </div>
                      </div>
                    </div>
                  </Link>
                );
              })}
            </div>
          </>
        )}
      </section>
    </div>
  );
}
