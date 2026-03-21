'use client';

import { useState, useMemo, useEffect, useCallback } from 'react';
import { usePayments } from '@/hooks/usePayments';
import { useLoans } from '@/hooks/useLoans';
import { useUsers } from '@/hooks/useUsers';
import { PaymentStatusBadge } from '@/components/PaymentStatusBadge';
import { Payment, LoanRequest } from '@/lib/types';
import { isInMora, getDaysOverdue } from '@/lib/mora';
import { getBudgetConfig, setBudgetConfig } from '@/lib/firestore';
import Link from 'next/link';

type Tab = 'overview' | 'loans' | 'subscriptions';

const formatCOP = (amount: number) =>
  new Intl.NumberFormat('es-CO', { style: 'currency', currency: 'COP', maximumFractionDigits: 0 }).format(amount);

const formatDate = (date: Date) =>
  date.toLocaleDateString('es-CO', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });

export default function PagosPage() {
  const { payments, loading: loadingPayments, error, refetch } = usePayments();
  const { loans, loading: loadingLoans } = useLoans();
  const { users } = useUsers();
  const [tab, setTab] = useState<Tab>('overview');
  const [search, setSearch] = useState('');
  const [totalCapital, setTotalCapital] = useState<number>(0);
  const [loadingBudget, setLoadingBudget] = useState(true);

  useEffect(() => {
    getBudgetConfig().then(config => {
      if (config) setTotalCapital(config.totalCapital);
      setLoadingBudget(false);
    });
  }, []);

  const handleSaveBudget = useCallback(async (value: number) => {
    setTotalCapital(value);
    await setBudgetConfig(value);
  }, []);

  const loading = loadingPayments || loadingLoans || loadingBudget;

  // User lookup by phone
  const usersByPhone = useMemo(() => {
    const map: Record<string, { name: string; email: string }> = {};
    for (const u of users) {
      if (u.phone) map[u.phone] = { name: [u.name, u.lastName].filter(Boolean).join(' '), email: u.email };
    }
    return map;
  }, [users]);

  // ─── Financial metrics ───
  const finance = useMemo(() => {
    const approvedLoans = loans.filter(l => l.status === 'approved');

    // Capital prestado (suma de montos de préstamos aprobados)
    const capitalLent = approvedLoans.reduce((sum, l) => sum + l.amount, 0);

    // Total a cobrar con intereses (capital × (1 + interest/100))
    const totalToCollect = approvedLoans.reduce((sum, l) => sum + l.amount * (1 + l.interest / 100), 0);

    // Intereses totales esperados
    const totalInterest = totalToCollect - capitalLent;

    // Cuotas: valor por cuota = totalConIntereses / numCuotas
    // Recaudado por cuotas = cuotasPagadas × valorCuota
    const installmentCollected = approvedLoans.reduce((sum, l) => {
      if (l.installments <= 0) return sum;
      const totalWithInterest = l.amount * (1 + l.interest / 100);
      const perInstallment = totalWithInterest / l.installments;
      return sum + l.installmentsPaid * perInstallment;
    }, 0);

    // Capital recuperado (parte del principal que ya se pagó)
    const capitalRecovered = approvedLoans.reduce((sum, l) => {
      if (l.installments <= 0) return sum;
      const perInstallment = l.amount / l.installments;
      return sum + l.installmentsPaid * perInstallment;
    }, 0);

    // Intereses ganados (parte de interés ya cobrada)
    const interestEarned = installmentCollected - capitalRecovered;

    // Pendiente por cobrar
    const pendingToCollect = totalToCollect - installmentCollected;

    // Suscripciones
    const subscribedCount = users.filter(u => u.isSubscribed).length;
    const subscriptionRevenue = subscribedCount * 22000;

    // Total recaudado (cuotas + suscripciones)
    const totalCollected = installmentCollected + subscriptionRevenue;

    // Ganancia neta = intereses ganados + suscripciones
    const netProfit = interestEarned + subscriptionRevenue;

    // Capital en riesgo (préstamos en mora)
    const moraLoans = approvedLoans.filter(isInMora);
    const moraCount = moraLoans.length;
    const capitalAtRisk = moraLoans.reduce((sum, l) => {
      if (l.installments <= 0) return sum;
      const remaining = l.installments - l.installmentsPaid;
      const totalWithInterest = l.amount * (1 + l.interest / 100);
      return sum + (remaining / l.installments) * totalWithInterest;
    }, 0);

    // Préstamos completados
    const completedLoans = approvedLoans.filter(l => l.installmentsPaid >= l.installments).length;

    return {
      capitalLent, totalToCollect, totalInterest,
      installmentCollected, capitalRecovered, interestEarned,
      pendingToCollect, subscribedCount, subscriptionRevenue,
      totalCollected, netProfit, moraCount, capitalAtRisk,
      approvedLoansCount: approvedLoans.length, completedLoans,
    };
  }, [loans, users]);

  // Subscribed users with payment info
  const subscribedUsers = useMemo(() => {
    const subPaymentsByPhone: Record<string, Payment> = {};
    for (const p of payments) {
      if (p.type === 'subscription' && p.status === 'APPROVED') {
        if (!subPaymentsByPhone[p.userPhone] || p.createdAt > subPaymentsByPhone[p.userPhone].createdAt) {
          subPaymentsByPhone[p.userPhone] = p;
        }
      }
    }

    const items = users
      .filter(u => u.isSubscribed)
      .map(u => {
        const payment = u.phone ? subPaymentsByPhone[u.phone] : undefined;
        return {
          user: u,
          name: [u.name, u.lastName].filter(Boolean).join(' ') || u.phone,
          amount: payment?.amount || 22000,
          date: payment?.createdAt || null,
          hasPaymentRecord: !!payment,
        };
      });

    if (!search) return items;
    const q = search.toLowerCase();
    return items.filter(item =>
      item.name.toLowerCase().includes(q) || item.user.phone.includes(q) || item.user.email.toLowerCase().includes(q),
    );
  }, [users, payments, search]);

  // Loans with payment data
  const loanTracking = useMemo(() => {
    const paymentsByLoan: Record<string, Payment[]> = {};
    for (const p of payments) {
      if (p.type === 'installment' && p.loanId) {
        if (!paymentsByLoan[p.loanId]) paymentsByLoan[p.loanId] = [];
        paymentsByLoan[p.loanId].push(p);
      }
    }

    const approvedLoans = loans.filter(l => l.status === 'approved');

    const items = approvedLoans.map(loan => {
      const loanPayments = paymentsByLoan[loan.id] || [];
      const approvedPayments = loanPayments.filter(p => p.status === 'APPROVED');
      const paidAmount = approvedPayments.reduce((sum, p) => sum + p.amount, 0);
      const userName = usersByPhone[loan.phone]?.name || loan.phone;
      const mora = isInMora(loan);
      const daysOverdue = getDaysOverdue(loan);
      const progress = loan.installments > 0 ? (loan.installmentsPaid / loan.installments) * 100 : 0;
      const completed = loan.installmentsPaid >= loan.installments;

      return { loan, loanPayments, approvedPayments, paidAmount, userName, mora, daysOverdue, progress, completed };
    });

    items.sort((a, b) => {
      if (a.mora && !b.mora) return -1;
      if (!a.mora && b.mora) return 1;
      if (a.completed && !b.completed) return 1;
      if (!a.completed && b.completed) return -1;
      return a.progress - b.progress;
    });

    if (!search) return items;
    const q = search.toLowerCase();
    return items.filter(item =>
      item.userName.toLowerCase().includes(q) || item.loan.phone.includes(q),
    );
  }, [loans, payments, usersByPhone, search]);

  return (
    <div>
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-white text-2xl font-bold">Finanzas y Pagos</h1>
          <p className="text-gray-400 text-sm mt-1">
            {finance.approvedLoansCount} préstamos activos · {finance.subscribedCount} suscritos
          </p>
        </div>
        <button
          onClick={refetch}
          className="text-[#2FFF00] border border-[#2FFF00]/30 px-3 py-1.5 rounded-lg text-sm hover:bg-[#2FFF00]/10 transition-colors"
        >
          Actualizar
        </button>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 mb-6">
        {([
          { key: 'overview' as const, label: 'Resumen Financiero' },
          { key: 'loans' as const, label: 'Seguimiento Préstamos' },
          { key: 'subscriptions' as const, label: 'Suscripciones' },
        ]).map(t => (
          <button
            key={t.key}
            onClick={() => setTab(t.key)}
            className={`px-4 py-2 rounded-xl text-sm font-medium transition-all ${
              tab === t.key ? 'bg-[#2FFF00] text-black' : 'bg-[#2FFF00]/10 text-[#2FFF00] hover:bg-[#2FFF00]/20'
            }`}
          >
            {t.label}
          </button>
        ))}
      </div>

      {loading ? (
        <div className="flex justify-center py-16">
          <div className="w-8 h-8 border-2 border-[#2FFF00] border-t-transparent rounded-full animate-spin" />
        </div>
      ) : error ? (
        <p className="text-red-400 text-center py-8">{error}</p>
      ) : tab === 'overview' ? (
        <FinancialOverview finance={finance} totalCapital={totalCapital} onSaveBudget={handleSaveBudget} />
      ) : tab === 'loans' ? (
        <>
          <input
            type="text"
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Buscar por nombre o teléfono..."
            className="w-full bg-[#0d1f0d] border border-[#2FFF00]/20 rounded-xl px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:border-[#2FFF00]/60 transition-colors mb-6"
          />
          <LoansTrackingView items={loanTracking} />
        </>
      ) : (
        <>
          <input
            type="text"
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Buscar por nombre o teléfono..."
            className="w-full bg-[#0d1f0d] border border-[#2FFF00]/20 rounded-xl px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:border-[#2FFF00]/60 transition-colors mb-6"
          />
          <SubscriptionsView items={subscribedUsers} />
        </>
      )}
    </div>
  );
}

// ─── Resumen Financiero ───

interface FinanceData {
  capitalLent: number;
  totalToCollect: number;
  totalInterest: number;
  installmentCollected: number;
  capitalRecovered: number;
  interestEarned: number;
  pendingToCollect: number;
  subscribedCount: number;
  subscriptionRevenue: number;
  totalCollected: number;
  netProfit: number;
  moraCount: number;
  capitalAtRisk: number;
  approvedLoansCount: number;
  completedLoans: number;
}

function FinancialOverview({ finance, totalCapital, onSaveBudget }: { finance: FinanceData; totalCapital: number; onSaveBudget: (v: number) => Promise<void> }) {
  const [editingBudget, setEditingBudget] = useState(false);
  const [budgetInput, setBudgetInput] = useState('');
  const [savingBudget, setSavingBudget] = useState(false);

  const availableFunds = totalCapital - finance.capitalLent + finance.capitalRecovered;

  const handleBudgetSave = async () => {
    const val = parseInt(budgetInput.replace(/\D/g, ''), 10);
    if (!val || val <= 0) return;
    setSavingBudget(true);
    await onSaveBudget(val);
    setEditingBudget(false);
    setSavingBudget(false);
  };

  const collectProgress = finance.totalToCollect > 0
    ? (finance.installmentCollected / finance.totalToCollect) * 100 : 0;

  return (
    <div className="flex flex-col gap-6">
      {/* Presupuesto disponible */}
      <div className={`border rounded-2xl p-6 ${availableFunds <= 0 && totalCapital > 0 ? 'bg-red-500/5 border-red-500/30' : 'bg-gradient-to-r from-[#0d1f0d] to-[#0d2a0d] border-[#2FFF00]/30'}`}>
        <div className="flex items-start justify-between">
          <div>
            <p className="text-gray-400 text-sm mb-1">Fondos disponibles para prestar</p>
            <p className={`font-bold text-4xl ${availableFunds <= 0 && totalCapital > 0 ? 'text-red-400' : 'text-[#2FFF00]'}`}>
              {totalCapital > 0 ? formatCOP(availableFunds) : 'Sin configurar'}
            </p>
            <p className="text-gray-500 text-xs mt-2">
              Capital total: {formatCOP(totalCapital)} − Prestado: {formatCOP(finance.capitalLent)} + Recuperado: {formatCOP(finance.capitalRecovered)}
            </p>
          </div>
          {!editingBudget && (
            <button
              onClick={() => { setEditingBudget(true); setBudgetInput(totalCapital > 0 ? String(totalCapital) : ''); }}
              className="text-[#2FFF00] text-sm hover:underline whitespace-nowrap"
            >
              {totalCapital > 0 ? 'Editar capital' : 'Configurar'}
            </button>
          )}
        </div>
        {editingBudget && (
          <div className="mt-4 pt-4 border-t border-white/10">
            <p className="text-gray-500 text-xs mb-2">Capital total disponible para préstamos</p>
            <div className="flex gap-2">
              <input
                type="text"
                value={budgetInput}
                onChange={e => setBudgetInput(e.target.value.replace(/[^0-9]/g, ''))}
                placeholder="Ej: 5000000"
                className="flex-1 bg-[#061006] border border-[#2FFF00]/20 rounded-lg px-3 py-2 text-white text-sm placeholder-gray-600 focus:outline-none focus:border-[#2FFF00]/60"
              />
              <button
                onClick={handleBudgetSave}
                disabled={savingBudget}
                className="bg-[#2FFF00] text-black px-4 py-2 rounded-lg text-sm font-medium hover:bg-[#2FFF00]/90 disabled:opacity-50"
              >
                {savingBudget ? '...' : 'Guardar'}
              </button>
              <button
                onClick={() => setEditingBudget(false)}
                className="text-gray-400 px-3 py-2 text-sm hover:text-white"
              >
                Cancelar
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Ganancia neta */}
      <div className="bg-gradient-to-r from-[#0d1f0d] to-[#0d2a0d] border border-[#2FFF00]/30 rounded-2xl p-6">
        <p className="text-gray-400 text-sm mb-1">Ganancia neta</p>
        <p className="text-[#2FFF00] font-bold text-4xl">{formatCOP(finance.netProfit)}</p>
        <p className="text-gray-500 text-xs mt-2">Intereses cobrados + ingresos por suscripciones</p>
      </div>

      {/* Préstamos - Capital */}
      <div>
        <h3 className="text-white font-semibold mb-3 text-sm uppercase tracking-wider">Capital</h3>
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <MetricCard label="Capital prestado" value={formatCOP(finance.capitalLent)} sublabel={`${finance.approvedLoansCount} préstamos`} color="text-white" />
          <MetricCard label="Capital recuperado" value={formatCOP(finance.capitalRecovered)} color="text-[#2FFF00]" />
          <MetricCard label="Capital pendiente" value={formatCOP(finance.capitalLent - finance.capitalRecovered)} color="text-yellow-400" />
          <MetricCard label="Capital en riesgo" value={formatCOP(finance.capitalAtRisk)} sublabel={`${finance.moraCount} en mora`} color={finance.moraCount > 0 ? 'text-orange-400' : 'text-white'} />
        </div>
      </div>

      {/* Recaudación */}
      <div>
        <h3 className="text-white font-semibold mb-3 text-sm uppercase tracking-wider">Recaudación</h3>
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
          <MetricCard label="Total a cobrar" value={formatCOP(finance.totalToCollect)} sublabel="Capital + intereses" color="text-white" />
          <MetricCard label="Total recaudado" value={formatCOP(finance.installmentCollected)} color="text-[#2FFF00]" />
          <MetricCard label="Pendiente por cobrar" value={formatCOP(finance.pendingToCollect)} color="text-yellow-400" />
          <MetricCard label="Préstamos completados" value={`${finance.completedLoans} / ${finance.approvedLoansCount}`} color="text-white" />
        </div>

        {/* Progress bar recaudación */}
        <div className="bg-[#0d1f0d] border border-[#2FFF00]/20 rounded-xl p-4 mt-3">
          <div className="flex justify-between text-xs text-gray-400 mb-2">
            <span>Progreso de recaudación</span>
            <span>{collectProgress.toFixed(1)}%</span>
          </div>
          <div className="w-full bg-white/10 rounded-full h-3 overflow-hidden">
            <div
              className="h-full rounded-full bg-[#2FFF00] transition-all"
              style={{ width: `${Math.min(collectProgress, 100)}%` }}
            />
          </div>
          <div className="flex justify-between text-xs mt-2">
            <span className="text-[#2FFF00]">{formatCOP(finance.installmentCollected)}</span>
            <span className="text-gray-500">{formatCOP(finance.totalToCollect)}</span>
          </div>
        </div>
      </div>

      {/* Intereses */}
      <div>
        <h3 className="text-white font-semibold mb-3 text-sm uppercase tracking-wider">Intereses</h3>
        <div className="grid grid-cols-2 lg:grid-cols-3 gap-3">
          <MetricCard label="Intereses esperados" value={formatCOP(finance.totalInterest)} sublabel="Total por cobrar" color="text-white" />
          <MetricCard label="Intereses ganados" value={formatCOP(finance.interestEarned)} sublabel="Ya cobrados" color="text-[#2FFF00]" />
          <MetricCard label="Intereses pendientes" value={formatCOP(finance.totalInterest - finance.interestEarned)} color="text-yellow-400" />
        </div>
      </div>

      {/* Suscripciones */}
      <div>
        <h3 className="text-white font-semibold mb-3 text-sm uppercase tracking-wider">Suscripciones</h3>
        <div className="grid grid-cols-2 lg:grid-cols-3 gap-3">
          <MetricCard label="Usuarios suscritos" value={String(finance.subscribedCount)} color="text-[#2FFF00]" />
          <MetricCard label="Ingreso por suscripciones" value={formatCOP(finance.subscriptionRevenue)} sublabel="$22,000 c/u" color="text-[#2FFF00]" />
          <MetricCard label="Ingreso total" value={formatCOP(finance.totalCollected)} sublabel="Cuotas + suscripciones" color="text-white" />
        </div>
      </div>

      {/* Resumen P&L */}
      <div className="bg-[#0d1f0d] border border-[#2FFF00]/20 rounded-2xl p-5">
        <h3 className="text-white font-semibold mb-4">Estado de resultados</h3>
        <div className="flex flex-col gap-2 text-sm">
          <PnlRow label="Ingresos por cuotas (cobradas)" value={finance.installmentCollected} />
          <PnlRow label="Ingresos por suscripciones" value={finance.subscriptionRevenue} />
          <div className="border-t border-white/10 my-1" />
          <PnlRow label="Total ingresos" value={finance.totalCollected} bold />
          <div className="border-t border-white/10 my-1" />
          <PnlRow label="Capital prestado (desembolsado)" value={-finance.capitalLent} />
          <PnlRow label="Capital recuperado" value={finance.capitalRecovered} />
          <div className="border-t border-white/10 my-1" />
          <PnlRow label="Flujo neto (ingresos - capital + recuperado)" value={finance.totalCollected - finance.capitalLent + finance.capitalRecovered} bold highlight />
          <div className="border-t border-white/10 my-1" />
          <PnlRow label="Ganancia neta (intereses + suscripciones)" value={finance.netProfit} bold highlight />
        </div>
      </div>
    </div>
  );
}

function MetricCard({ label, value, sublabel, color = 'text-white' }: { label: string; value: string; sublabel?: string; color?: string }) {
  return (
    <div className="bg-[#0d1f0d] border border-[#2FFF00]/20 rounded-xl p-4">
      <p className="text-gray-500 text-xs">{label}</p>
      <p className={`${color} font-bold text-lg`}>{value}</p>
      {sublabel && <p className="text-gray-600 text-xs mt-0.5">{sublabel}</p>}
    </div>
  );
}

function PnlRow({ label, value, bold, highlight }: { label: string; value: number; bold?: boolean; highlight?: boolean }) {
  const color = highlight
    ? value >= 0 ? 'text-[#2FFF00]' : 'text-red-400'
    : value >= 0 ? 'text-white' : 'text-red-400';
  return (
    <div className="flex justify-between items-center">
      <span className={`text-gray-400 ${bold ? 'font-semibold text-white' : ''}`}>{label}</span>
      <span className={`${color} ${bold ? 'font-bold' : 'font-medium'}`}>{formatCOP(value)}</span>
    </div>
  );
}

// ─── Seguimiento de Préstamos ───

interface LoanTrackingItem {
  loan: LoanRequest;
  loanPayments: Payment[];
  approvedPayments: Payment[];
  paidAmount: number;
  userName: string;
  mora: boolean;
  daysOverdue: number;
  progress: number;
  completed: boolean;
}

function LoansTrackingView({ items }: { items: LoanTrackingItem[] }) {
  const [expandedId, setExpandedId] = useState<string | null>(null);

  if (items.length === 0) {
    return <p className="text-gray-500 text-center py-8">No hay préstamos aprobados</p>;
  }

  return (
    <div className="flex flex-col gap-3">
      {items.map(item => {
        const expanded = expandedId === item.loan.id;
        return (
          <div
            key={item.loan.id}
            className={`bg-[#0d1f0d] rounded-xl border transition-all ${
              item.mora
                ? 'border-orange-500/50'
                : item.completed
                  ? 'border-[#2FFF00]/40'
                  : 'border-[#2FFF00]/20'
            }`}
          >
            <button
              onClick={() => setExpandedId(expanded ? null : item.loan.id)}
              className="w-full p-4 text-left"
            >
              <div className="flex items-start justify-between mb-3">
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 flex-wrap">
                    <p className="text-white font-semibold">{item.userName}</p>
                    {item.mora && (
                      <span className="text-xs bg-orange-500/20 text-orange-400 px-2 py-0.5 rounded-full font-medium">
                        {item.daysOverdue}d en mora
                      </span>
                    )}
                    {item.completed && (
                      <span className="text-xs bg-[#2FFF00]/20 text-[#2FFF00] px-2 py-0.5 rounded-full font-medium">
                        Completado
                      </span>
                    )}
                  </div>
                  <p className="text-gray-400 text-sm">{item.loan.phone}</p>
                </div>
                <div className="text-right ml-3">
                  <p className="text-white font-bold">{formatCOP(item.loan.amount)}</p>
                  <p className="text-gray-500 text-xs">{item.loan.paymentPeriod}</p>
                </div>
              </div>

              <div className="flex items-center gap-3">
                <div className="flex-1 bg-white/10 rounded-full h-2.5 overflow-hidden">
                  <div
                    className={`h-full rounded-full transition-all ${
                      item.mora ? 'bg-orange-500' : item.completed ? 'bg-[#2FFF00]' : 'bg-[#2FFF00]/70'
                    }`}
                    style={{ width: `${Math.min(item.progress, 100)}%` }}
                  />
                </div>
                <span className="text-sm text-gray-300 whitespace-nowrap">
                  {item.loan.installmentsPaid}/{item.loan.installments} cuotas
                </span>
                <span className="text-gray-600 text-sm">{expanded ? '▲' : '▼'}</span>
              </div>

              <div className="flex gap-4 mt-2 text-xs text-gray-500">
                <span>Pagado: {formatCOP(item.paidAmount)}</span>
                <span>{item.loan.interest}% interés</span>
                <span>{item.approvedPayments.length} pagos registrados</span>
              </div>
            </button>

            {expanded && (
              <div className="border-t border-white/10 px-4 pb-4">
                <div className="flex items-center justify-between mt-3 mb-2">
                  <p className="text-gray-400 text-xs font-medium">Historial de pagos</p>
                  <Link
                    href={`/solicitudes/${item.loan.id}`}
                    className="text-[#2FFF00] text-xs hover:underline"
                  >
                    Ver préstamo →
                  </Link>
                </div>
                {item.loanPayments.length === 0 ? (
                  <p className="text-gray-600 text-sm py-2">Sin pagos registrados</p>
                ) : (
                  <div className="flex flex-col gap-2">
                    {item.loanPayments.map(payment => (
                      <div
                        key={payment.id}
                        className="flex items-center justify-between bg-[#061006] rounded-lg px-3 py-2"
                      >
                        <div className="flex items-center gap-3">
                          <PaymentStatusBadge status={payment.status} />
                          <div>
                            <p className="text-white text-sm">
                              Cuota #{payment.installmentNumber || '—'}
                            </p>
                            <p className="text-gray-600 text-xs">{formatDate(payment.createdAt)}</p>
                          </div>
                        </div>
                        <p className="text-white text-sm font-medium">{formatCOP(payment.amount)}</p>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}

// ─── Suscripciones ───

interface SubscribedItem {
  user: { id: string; name: string; lastName: string; phone: string; email: string };
  name: string;
  amount: number;
  date: Date | null;
  hasPaymentRecord: boolean;
}

function SubscriptionsView({ items }: { items: SubscribedItem[] }) {
  if (items.length === 0) {
    return <p className="text-gray-500 text-center py-8">No hay usuarios suscritos</p>;
  }

  return (
    <div className="flex flex-col gap-2">
      {items.map(item => (
        <Link key={item.user.id} href={`/usuarios/${item.user.id}`}>
          <div className="bg-[#0d1f0d] border border-[#2FFF00]/20 rounded-xl p-4 flex items-center justify-between hover:border-[#2FFF00]/60 transition-all">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-[#2FFF00]/15 flex items-center justify-center text-[#2FFF00] font-bold text-sm">
                {(item.name?.[0] || '?').toUpperCase()}
              </div>
              <div>
                <p className="text-white font-medium">{item.name}</p>
                <p className="text-gray-500 text-xs">{item.user.phone} · {item.user.email}</p>
              </div>
            </div>
            <div className="text-right">
              <p className="text-[#2FFF00] font-semibold">{formatCOP(item.amount)}</p>
              {item.date ? (
                <p className="text-gray-600 text-xs">{formatDate(item.date)}</p>
              ) : (
                <p className="text-gray-600 text-xs">Sin registro de pago</p>
              )}
            </div>
          </div>
        </Link>
      ))}
    </div>
  );
}
