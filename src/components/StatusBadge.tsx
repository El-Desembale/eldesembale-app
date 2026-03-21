import { LoanRequest, STATUS_COLORS, STATUS_LABELS } from '@/lib/types';

interface Props {
  status: LoanRequest['status'];
}

export function StatusBadge({ status }: Props) {
  const color = STATUS_COLORS[status] || '#6b7280';
  const label = STATUS_LABELS[status] || status;

  return (
    <span
      className="px-2 py-1 rounded-full text-xs font-semibold"
      style={{ backgroundColor: `${color}22`, color, border: `1px solid ${color}` }}
    >
      {label}
    </span>
  );
}
