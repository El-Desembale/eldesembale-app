import { PaymentStatus, PAYMENT_STATUS_COLORS, PAYMENT_STATUS_LABELS } from '@/lib/types';

interface Props {
  status: PaymentStatus;
}

export function PaymentStatusBadge({ status }: Props) {
  const color = PAYMENT_STATUS_COLORS[status] || '#6b7280';
  const label = PAYMENT_STATUS_LABELS[status] || status;

  return (
    <span
      className="px-2 py-1 rounded-full text-xs font-semibold"
      style={{ backgroundColor: `${color}22`, color, border: `1px solid ${color}` }}
    >
      {label}
    </span>
  );
}
