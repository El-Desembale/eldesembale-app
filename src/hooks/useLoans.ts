'use client';

import { useState, useEffect } from 'react';
import { getLoans, updateLoanStatus } from '@/lib/firestore';
import { LoanRequest } from '@/lib/types';

export function useLoans() {
  const [loans, setLoans] = useState<LoanRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchLoans = async () => {
    try {
      setLoading(true);
      const data = await getLoans();
      setLoans(data);
    } catch (e) {
      setError('Error cargando solicitudes');
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchLoans();
  }, []);

  const changeStatus = async (loanId: string, status: LoanRequest['status']) => {
    await updateLoanStatus(loanId, status);
    setLoans(prev => prev.map(l => l.id === loanId ? { ...l, status } : l));
  };

  return { loans, loading, error, refetch: fetchLoans, changeStatus };
}
