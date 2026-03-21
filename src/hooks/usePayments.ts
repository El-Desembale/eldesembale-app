'use client';

import { useState, useEffect } from 'react';
import { getPayments } from '@/lib/firestore';
import { Payment } from '@/lib/types';

export function usePayments() {
  const [payments, setPayments] = useState<Payment[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchPayments = async () => {
    try {
      setLoading(true);
      const data = await getPayments();
      setPayments(data);
    } catch (e) {
      setError('Error cargando pagos');
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPayments();
  }, []);

  return { payments, loading, error, refetch: fetchPayments };
}
