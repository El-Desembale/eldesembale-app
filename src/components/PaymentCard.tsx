import { Payment, PAYMENT_TYPE_LABELS } from '@/lib/types';
import { PaymentStatusBadge } from './PaymentStatusBadge';

interface Props {
  payment: Payment;
}

export function PaymentCard({ payment }: Props) {
  const date = payment.createdAt.toLocaleDateString('es-CO', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });

  const amount = new Intl.NumberFormat('es-CO', {
    style: 'currency',
    currency: 'COP',
    maximumFractionDigits: 0,
  }).format(payment.amount);

  const typeLabel = PAYMENT_TYPE_LABELS[payment.type] || payment.type;

  return (
    <div className="bg-[#0d1f0d] border border-[#2FFF00]/20 rounded-xl p-4 hover:border-[#2FFF00]/60 transition-all">
      <div className="flex justify-between items-start mb-3">
        <div>
          <p className="text-white font-semibold text-lg">{amount}</p>
          <p className="text-gray-400 text-sm">{payment.userName || payment.userPhone}</p>
        </div>
        <div className="flex flex-col items-end gap-1.5">
          <PaymentStatusBadge status={payment.status} />
          <span className="text-xs bg-[#2FFF00]/10 text-[#2FFF00] px-2 py-0.5 rounded-full">
            {typeLabel}
          </span>
        </div>
      </div>
      <div className="flex gap-4 text-sm text-gray-400 flex-wrap">
        <span>{payment.userPhone}</span>
        {payment.installmentNumber && (
          <span>Cuota #{payment.installmentNumber}</span>
        )}
        <span>{payment.reference}</span>
      </div>
      <p className="text-gray-500 text-xs mt-2">{date}</p>
    </div>
  );
}
