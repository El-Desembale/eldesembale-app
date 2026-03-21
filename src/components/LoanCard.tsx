import Link from 'next/link';
import { LoanRequest } from '@/lib/types';
import { StatusBadge } from './StatusBadge';

interface Props {
  loan: LoanRequest;
  userName?: string;
  inMora?: boolean;
}

export function LoanCard({ loan, userName, inMora }: Props) {
  const date = loan.createdAt.toLocaleDateString('es-CO', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });

  const amount = new Intl.NumberFormat('es-CO', {
    style: 'currency',
    currency: 'COP',
    maximumFractionDigits: 0,
  }).format(loan.amount);

  return (
    <Link href={`/solicitudes/${loan.id}`}>
      <div className={`bg-[#0d1f0d] rounded-xl p-4 transition-all cursor-pointer border ${
        inMora
          ? 'border-orange-500/50 hover:border-orange-500'
          : 'border-[#2FFF00]/20 hover:border-[#2FFF00]/60'
      }`}>
        {inMora && (
          <div className="flex items-center gap-1.5 text-orange-400 text-xs font-medium mb-2">
            <span>⚠</span><span>En mora</span>
          </div>
        )}
        <div className="flex justify-between items-start mb-3">
          <div>
            <p className="text-white font-semibold text-lg">{amount}</p>
            {userName && <p className="text-white text-sm font-medium">{userName}</p>}
            <p className="text-gray-400 text-sm">{loan.phone}</p>
          </div>
          <StatusBadge status={loan.status} />
        </div>
        <div className="flex gap-4 text-sm text-gray-400">
          <span>{loan.installments} cuotas</span>
          <span>{loan.interest}% interés</span>
          <span>{loan.paymentPeriod}</span>
        </div>
        <p className="text-gray-500 text-xs mt-2">{date}</p>
      </div>
    </Link>
  );
}
