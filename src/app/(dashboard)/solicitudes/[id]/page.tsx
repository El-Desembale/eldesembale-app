'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { doc, getDoc, query, collection, where, getDocs, Timestamp } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { updateLoanStatus, getPaymentsByLoanId, getBudgetConfig, getLoans } from '@/lib/firestore';
import { LoanRequest, Payment } from '@/lib/types';
import { isInMora, getDaysOverdue } from '@/lib/mora';
import { StatusBadge } from '@/components/StatusBadge';
import { LoanDocumentsDialog } from '@/components/LoanDocumentsDialog';
import { ReminderDialog } from '@/components/ReminderDialog';
import { PaymentCard } from '@/components/PaymentCard';

const ACTION_STATUSES: { label: string; value: LoanRequest['status']; color: string }[] = [
  { label: 'Pendiente', value: 'pending', color: 'bg-yellow-500/20 text-yellow-400 border-yellow-500/30' },
  { label: 'En proceso', value: 'in_process', color: 'bg-blue-500/20 text-blue-400 border-blue-500/30' },
  { label: 'En desembolso', value: 'in_disbursement_process', color: 'bg-purple-500/20 text-purple-400 border-purple-500/30' },
  { label: 'Aprobar', value: 'approved', color: 'bg-[#2FFF00]/20 text-[#2FFF00] border-[#2FFF00]/30' },
  { label: 'Rechazar', value: 'rejected', color: 'bg-red-500/20 text-red-400 border-red-500/30' },
];

function parseLoanFromFirestore(id: string, data: Record<string, unknown>): LoanRequest {
  const createdAt = data.created_at instanceof Timestamp ? data.created_at.toDate() : new Date();
  const raw = (data.loan_information as Record<string, unknown>) || {};
  return {
    id,
    amount: (data.amount as number) || 0,
    createdAt,
    installments: (data.installments as number) || 0,
    interest: (data.interest as number) || 0,
    paymentPeriod: (data.payment_period as string) || '',
    status: (data.status as LoanRequest['status']) || 'pending',
    installmentsPaid: (data.installments_paid as number) || 0,
    phone: (data.phone as string) || '',
    isSubscribed: (data.isSubscribed as boolean) || false,
    loanInformation: {
      firstReference: (raw.first_reference as { phone: string; relationship: string }) || { phone: '', relationship: '' },
      secondReference: (raw.second_reference as { phone: string; relationship: string }) || { phone: '', relationship: '' },
      ccBackPicture: (raw.cc_back_picture as string) || '',
      selfiePicture: (raw.selfie_picture as string) || '',
      empInvoiceFile: (raw.emp_invoice_file as string) || '',
      ccFrontalPicture: (raw.cc_frontal_picture as string) || '',
      bankInformation: (raw.bank_information as Record<string, string>) || {},
      direction: (raw.direction as string) || '',
    },
  };
}

export default function LoanDetailPage() {
  const { id } = useParams<{ id: string }>();
  const router = useRouter();
  const [loan, setLoan] = useState<LoanRequest | null>(null);
  const [loading, setLoading] = useState(true);
  const [showDocs, setShowDocs] = useState(false);
  const [showReminder, setShowReminder] = useState(false);
  const [updating, setUpdating] = useState(false);
  const [clientInfo, setClientInfo] = useState<{ name: string; email?: string } | null>(null);
  const [payments, setPayments] = useState<Payment[]>([]);
  const [availableFunds, setAvailableFunds] = useState<number | null>(null);

  useEffect(() => {
    const fetchLoan = async () => {
      try {
        const loanDoc = await getDoc(doc(db, 'loan_request', id));
        if (!loanDoc.exists()) {
          router.replace('/');
          return;
        }
        const parsed = parseLoanFromFirestore(loanDoc.id, loanDoc.data() as Record<string, unknown>);
        setLoan(parsed);
        // Fetch payments for this loan
        const loanPayments = await getPaymentsByLoanId(id);
        setPayments(loanPayments);
        // Fetch client info by phone
        if (parsed.phone) {
          const q = query(collection(db, 'users'), where('phone', '==', parsed.phone));
          const snap = await getDocs(q);
          if (!snap.empty) {
            const u = snap.docs[0].data() as Record<string, unknown>;
            setClientInfo({
              name: [(u.name as string) || '', (u.lastName as string) || ''].filter(Boolean).join(' '),
              email: (u.email as string) || undefined,
            });
          }
        }
        // Calculate available funds for budget check
        const [budgetConfig, allLoans] = await Promise.all([getBudgetConfig(), getLoans()]);
        if (budgetConfig && budgetConfig.totalCapital > 0) {
          const approvedLoans = allLoans.filter(l => l.status === 'approved');
          const capitalLent = approvedLoans.reduce((sum, l) => sum + l.amount, 0);
          const capitalRecovered = approvedLoans.reduce((sum, l) => {
            if (l.installments <= 0) return sum;
            return sum + (l.installmentsPaid * (l.amount / l.installments));
          }, 0);
          setAvailableFunds(budgetConfig.totalCapital - capitalLent + capitalRecovered);
        }
      } catch (e) {
        console.error(e);
      } finally {
        setLoading(false);
      }
    };
    fetchLoan();
  }, [id, router]);

  const handleStatusChange = async (status: LoanRequest['status']) => {
    if (!loan || updating) return;
    setUpdating(true);
    try {
      await updateLoanStatus(loan.id, status);
      setLoan(prev => prev ? { ...prev, status } : prev);
    } catch (e) {
      console.error(e);
    } finally {
      setUpdating(false);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center py-16">
        <div className="w-8 h-8 border-2 border-[#2FFF00] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (!loan) return null;

  const amount = new Intl.NumberFormat('es-CO', {
    style: 'currency',
    currency: 'COP',
    maximumFractionDigits: 0,
  }).format(loan.amount);

  const date = loan.createdAt.toLocaleDateString('es-CO', {
    day: '2-digit',
    month: 'long',
    year: 'numeric',
  });

  const bank = loan.loanInformation.bankInformation;
  const mora = isInMora(loan);
  const daysOverdue = getDaysOverdue(loan);

  return (
    <div className="max-w-2xl">
      <div className="flex items-center justify-between mb-6">
        <Link href="/" className="text-gray-400 hover:text-[#2FFF00] transition-colors">
          ← Solicitudes
        </Link>
        {mora && (
          <button
            onClick={() => setShowReminder(true)}
            className="flex items-center gap-2 bg-orange-500/20 border border-orange-500/40 text-orange-300 px-4 py-2 rounded-xl text-sm font-medium hover:bg-orange-500/30 transition-colors"
          >
            <span>📩</span> Enviar recordatorio
          </button>
        )}
      </div>

      {/* Mora banner */}
      {mora && (
        <div className="bg-orange-500/10 border border-orange-500/30 rounded-xl px-4 py-3 mb-4 flex items-center justify-between">
          <div>
            <p className="text-orange-400 font-semibold text-sm">⚠ Préstamo en mora</p>
            <p className="text-orange-300/70 text-xs mt-0.5">{daysOverdue} días de atraso · {loan.installmentsPaid} de {loan.installments} cuotas pagadas</p>
          </div>
        </div>
      )}

      {/* Main info */}
      <div className="bg-[#0d1f0d] border border-[#2FFF00]/20 rounded-2xl p-6 mb-4">
        <div className="flex justify-between items-start mb-4">
          <div>
            {clientInfo?.name && (
              <p className="text-white font-semibold text-lg mb-1">{clientInfo.name}</p>
            )}
            <p className="text-[#2FFF00] text-3xl font-bold">{amount}</p>
            <p className="text-gray-400 text-sm mt-1">{loan.phone}</p>
          </div>
          <StatusBadge status={loan.status} />
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 text-sm">
          <div>
            <p className="text-gray-500 text-xs">Cuotas</p>
            <p className="text-white">{loan.installments}</p>
          </div>
          <div>
            <p className="text-gray-500 text-xs">Cuotas pagadas</p>
            <p className="text-white">{loan.installmentsPaid}</p>
          </div>
          <div>
            <p className="text-gray-500 text-xs">Interés</p>
            <p className="text-white">{loan.interest}%</p>
          </div>
          <div>
            <p className="text-gray-500 text-xs">Período</p>
            <p className="text-white">{loan.paymentPeriod}</p>
          </div>
          <div>
            <p className="text-gray-500 text-xs">Fecha</p>
            <p className="text-white">{date}</p>
          </div>
          <div>
            <p className="text-gray-500 text-xs">Suscrito</p>
            <p className="text-white">{loan.isSubscribed ? 'Sí' : 'No'}</p>
          </div>
        </div>
      </div>

      {/* Bank info */}
      {Object.keys(bank).length > 0 && (
        <div className="bg-[#0d1f0d] border border-[#2FFF00]/20 rounded-2xl p-5 mb-4">
          <h2 className="text-white font-semibold mb-3">Información bancaria</h2>
          <div className="grid grid-cols-2 gap-2 text-sm">
            {Object.entries(bank).map(([key, val]) => (
              <div key={key}>
                <p className="text-gray-500 text-xs capitalize">{key.replace(/_/g, ' ')}</p>
                <p className="text-white">{val}</p>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* References */}
      <div className="bg-[#0d1f0d] border border-[#2FFF00]/20 rounded-2xl p-5 mb-4">
        <h2 className="text-white font-semibold mb-3">Referencias</h2>
        <div className="grid sm:grid-cols-2 gap-4 text-sm">
          <div>
            <p className="text-gray-500 text-xs mb-1">Referencia 1</p>
            <p className="text-white">{loan.loanInformation.firstReference.phone || '—'}</p>
            <p className="text-gray-400">{loan.loanInformation.firstReference.relationship || '—'}</p>
          </div>
          <div>
            <p className="text-gray-500 text-xs mb-1">Referencia 2</p>
            <p className="text-white">{loan.loanInformation.secondReference.phone || '—'}</p>
            <p className="text-gray-400">{loan.loanInformation.secondReference.relationship || '—'}</p>
          </div>
        </div>
        {loan.loanInformation.direction && (
          <div className="mt-3">
            <p className="text-gray-500 text-xs">Dirección</p>
            <p className="text-white text-sm">{loan.loanInformation.direction}</p>
          </div>
        )}
      </div>

      {/* Documents */}
      <button
        onClick={() => setShowDocs(true)}
        className="w-full bg-[#0d1f0d] border border-[#2FFF00]/20 rounded-2xl p-4 text-left hover:border-[#2FFF00]/60 transition-colors mb-4 flex justify-between items-center"
      >
        <span className="text-white font-semibold">Ver documentos</span>
        <span className="text-[#2FFF00]">→</span>
      </button>

      {/* Payment history */}
      <div className="bg-[#0d1f0d] border border-[#2FFF00]/20 rounded-2xl p-5 mb-4">
        <h2 className="text-white font-semibold mb-3">Historial de pagos ({payments.length})</h2>
        {payments.length === 0 ? (
          <p className="text-gray-500 text-sm">Sin pagos registrados</p>
        ) : (
          <div className="grid gap-3">
            {payments.map(payment => (
              <PaymentCard key={payment.id} payment={payment} />
            ))}
          </div>
        )}
      </div>

      {/* Insufficient funds warning */}
      {availableFunds !== null && availableFunds < loan.amount && loan.status !== 'approved' && (
        <div className="bg-red-500/10 border border-red-500/30 rounded-xl px-4 py-3 mb-4">
          <p className="text-red-400 font-semibold text-sm">Fondos insuficientes</p>
          <p className="text-red-300/70 text-xs mt-0.5">
            Disponible: {new Intl.NumberFormat('es-CO', { style: 'currency', currency: 'COP', maximumFractionDigits: 0 }).format(availableFunds)} — Este préstamo requiere: {amount}
          </p>
        </div>
      )}

      {/* Status actions */}
      <div className="bg-[#0d1f0d] border border-[#2FFF00]/20 rounded-2xl p-5">
        <h2 className="text-white font-semibold mb-3">Cambiar estado</h2>
        <div className="flex flex-wrap gap-2">
          {ACTION_STATUSES.map(action => {
            const insufficientFunds = action.value === 'approved' && availableFunds !== null && availableFunds < loan.amount;
            return (
              <button
                key={action.value}
                onClick={() => handleStatusChange(action.value)}
                disabled={updating || loan.status === action.value || insufficientFunds}
                title={insufficientFunds ? 'Fondos insuficientes para aprobar este préstamo' : undefined}
                className={`px-3 py-1.5 rounded-full text-sm font-medium border transition-all disabled:opacity-40 ${action.color} ${
                  loan.status === action.value ? 'opacity-100 ring-2 ring-white/20' : 'hover:opacity-80'
                }`}
              >
                {loan.status === action.value && '✓ '}{action.label}
              </button>
            );
          })}
        </div>
      </div>

      {showDocs && (
        <LoanDocumentsDialog
          loanInfo={loan.loanInformation}
          onClose={() => setShowDocs(false)}
        />
      )}

      {showReminder && (
        <ReminderDialog
          email={clientInfo?.email || ''}
          userName={clientInfo?.name || loan.phone}
          daysOverdue={daysOverdue}
          onClose={() => setShowReminder(false)}
        />
      )}
    </div>
  );
}
