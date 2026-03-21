import { LoanRequest } from './types';

function getDaysPerPeriod(period: string): number {
  const p = period.toLowerCase();
  if (p.includes('seman') || p === 'weekly') return 7;
  if (p.includes('quince') || p === 'biweekly') return 15;
  return 30; // mensual / monthly por defecto
}

export function getExpectedInstallments(loan: LoanRequest): number {
  const daysPerPeriod = getDaysPerPeriod(loan.paymentPeriod);
  const daysSince = Math.floor(
    (Date.now() - loan.createdAt.getTime()) / (1000 * 60 * 60 * 24)
  );
  return Math.min(Math.floor(daysSince / daysPerPeriod), loan.installments);
}

export function isInMora(loan: LoanRequest): boolean {
  if (loan.status !== 'approved') return false;
  if (loan.installmentsPaid >= loan.installments) return false;
  return getExpectedInstallments(loan) > loan.installmentsPaid;
}

export function getDaysOverdue(loan: LoanRequest): number {
  if (!isInMora(loan)) return 0;
  const daysPerPeriod = getDaysPerPeriod(loan.paymentPeriod);
  const overduePeriods = getExpectedInstallments(loan) - loan.installmentsPaid;
  return overduePeriods * daysPerPeriod;
}
