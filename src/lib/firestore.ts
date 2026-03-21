import {
  collection,
  getDocs,
  doc,
  updateDoc,
  query,
  orderBy,
  where,
  Timestamp,
} from 'firebase/firestore';
import { db } from './firebase';
import { LoanRequest, User, Payment } from './types';

function parseLoanInformation(raw: Record<string, unknown>) {
  return {
    firstReference: (raw?.first_reference as { phone: string; relationship: string }) || { phone: '', relationship: '' },
    secondReference: (raw?.second_reference as { phone: string; relationship: string }) || { phone: '', relationship: '' },
    ccBackPicture: (raw?.cc_back_picture as string) || '',
    selfiePicture: (raw?.selfie_picture as string) || '',
    empInvoiceFile: (raw?.emp_invoice_file as string) || '',
    ccFrontalPicture: (raw?.cc_frontal_picture as string) || '',
    bankInformation: (raw?.bank_information as Record<string, string>) || {},
    direction: (raw?.direction as string) || '',
  };
}

function parseLoan(docId: string, data: Record<string, unknown>): LoanRequest {
  const createdAt = data.created_at instanceof Timestamp
    ? data.created_at.toDate()
    : new Date();

  return {
    id: docId,
    amount: (data.amount as number) || 0,
    createdAt,
    installments: (data.installments as number) || 0,
    interest: (data.interest as number) || 0,
    paymentPeriod: (data.payment_period as string) || '',
    status: (data.status as LoanRequest['status']) || 'pending',
    installmentsPaid: (data.installments_paid as number) || 0,
    phone: (data.phone as string) || '',
    isSubscribed: (data.isSubscribed as boolean) || false,
    loanInformation: parseLoanInformation((data.loan_information as Record<string, unknown>) || {}),
  };
}

export async function getLoans(): Promise<LoanRequest[]> {
  const q = query(collection(db, 'loan_request'), orderBy('created_at', 'desc'));
  const snapshot = await getDocs(q);
  return snapshot.docs.map(d => parseLoan(d.id, d.data() as Record<string, unknown>));
}

export async function getUserLoans(phone: string): Promise<LoanRequest[]> {
  const q = query(collection(db, 'loan_request'), where('phone', '==', phone));
  const snapshot = await getDocs(q);
  return snapshot.docs.map(d => parseLoan(d.id, d.data() as Record<string, unknown>));
}

export async function updateLoanStatus(loanId: string, status: LoanRequest['status']): Promise<void> {
  await updateDoc(doc(db, 'loan_request', loanId), { status });
}

export async function getUsers(): Promise<User[]> {
  const q = query(collection(db, 'users'), orderBy('createdAt', 'desc'));
  const snapshot = await getDocs(q);
  return snapshot.docs.map(d => {
    const data = d.data() as Record<string, unknown>;
    return {
      id: d.id,
      email: (data.email as string) || '',
      phone: (data.phone as string) || '',
      name: (data.name as string) || '',
      lastName: (data.lastName as string) || '',
      isSubscribed: (data.isSubscribed as boolean) || false,
      admin: (data.admin as boolean) || false,
    };
  });
}

export async function getUserPassword(userId: string): Promise<string | null> {
  const { getDoc } = await import('firebase/firestore');
  const snap = await getDoc(doc(db, 'users', userId));
  if (!snap.exists()) return null;
  const data = snap.data() as Record<string, unknown>;
  return (data.password as string) || null;
}

export async function updateUserPassword(userId: string, newPassword: string): Promise<void> {
  await updateDoc(doc(db, 'users', userId), { password: newPassword });
}

// Payments

function parsePayment(docId: string, data: Record<string, unknown>): Payment {
  const createdAt = data.created_at instanceof Timestamp
    ? data.created_at.toDate()
    : new Date();

  return {
    id: docId,
    reference: (data.reference as string) || '',
    type: (data.type as Payment['type']) || 'subscription',
    status: (data.status as Payment['status']) || 'ERROR',
    amount: (data.amount_in_cents as number) ? (data.amount_in_cents as number) / 100 : 0,
    amountInCents: (data.amount_in_cents as number) || 0,
    currency: (data.currency as string) || 'COP',
    userPhone: (data.user_phone as string) || '',
    userEmail: (data.user_email as string) || '',
    userName: (data.user_name as string) || '',
    loanId: (data.loan_id as string) || null,
    installmentNumber: (data.installment_number as number) || null,
    createdAt,
  };
}

export async function getPayments(): Promise<Payment[]> {
  const q = query(collection(db, 'payments'), orderBy('created_at', 'desc'));
  const snapshot = await getDocs(q);
  return snapshot.docs.map(d => parsePayment(d.id, d.data() as Record<string, unknown>));
}

export async function getPaymentsByPhone(phone: string): Promise<Payment[]> {
  const q = query(collection(db, 'payments'), where('user_phone', '==', phone), orderBy('created_at', 'desc'));
  const snapshot = await getDocs(q);
  return snapshot.docs.map(d => parsePayment(d.id, d.data() as Record<string, unknown>));
}

export async function getPaymentsByLoanId(loanId: string): Promise<Payment[]> {
  const q = query(collection(db, 'payments'), where('loan_id', '==', loanId), orderBy('created_at', 'desc'));
  const snapshot = await getDocs(q);
  return snapshot.docs.map(d => parsePayment(d.id, d.data() as Record<string, unknown>));
}

// Budget

export async function getBudgetConfig(): Promise<{ totalCapital: number } | null> {
  const { getDoc } = await import('firebase/firestore');
  const snap = await getDoc(doc(db, 'settings', 'budget'));
  if (!snap.exists()) return null;
  const data = snap.data() as Record<string, unknown>;
  return { totalCapital: (data.total_capital as number) || 0 };
}

export async function setBudgetConfig(totalCapital: number): Promise<void> {
  const { setDoc } = await import('firebase/firestore');
  await setDoc(doc(db, 'settings', 'budget'), {
    total_capital: totalCapital,
    updated_at: new Date(),
  });
}

export async function saveFcmToken(uid: string, token: string): Promise<void> {
  await updateDoc(doc(db, 'admins', uid), { fcmToken: token, updatedAt: new Date() })
    .catch(async () => {
      const { setDoc } = await import('firebase/firestore');
      await setDoc(doc(db, 'admins', uid), { fcmToken: token, updatedAt: new Date() });
    });
}
