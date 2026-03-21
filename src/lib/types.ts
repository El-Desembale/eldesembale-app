export interface Reference {
  phone: string;
  relationship: string;
}

export type BankInformation = Record<string, string>;

export interface LoanInformation {
  firstReference: Reference;
  secondReference: Reference;
  ccBackPicture: string;
  selfiePicture: string;
  empInvoiceFile: string;
  ccFrontalPicture: string;
  bankInformation: BankInformation;
  direction: string;
}

export interface LoanRequest {
  id: string;
  amount: number;
  createdAt: Date;
  installments: number;
  interest: number;
  paymentPeriod: string;
  status: 'pending' | 'approved' | 'rejected' | 'in_process' | 'in_disbursement_process';
  installmentsPaid: number;
  phone: string;
  isSubscribed: boolean;
  loanInformation: LoanInformation;
}

export interface User {
  id: string;
  email: string;
  phone: string;
  name: string;
  lastName: string;
  isSubscribed: boolean;
  admin: boolean;
  loanRequests?: LoanRequest[];
}

export type LoanStatus = LoanRequest['status'];

export const STATUS_LABELS: Record<LoanStatus, string> = {
  pending: 'Pendiente',
  in_process: 'En revisión',
  in_disbursement_process: 'En desembolso',
  approved: 'Aprobado',
  rejected: 'Rechazado',
};

export const STATUS_COLORS: Record<LoanStatus, string> = {
  pending: '#f59e0b',
  in_process: '#ffffff',
  in_disbursement_process: '#60a5fa',
  approved: '#2FFF00',
  rejected: '#f87171',
};

// Payment types
export type PaymentType = 'subscription' | 'installment';
export type PaymentStatus = 'APPROVED' | 'DECLINED' | 'ERROR';

export interface Payment {
  id: string;
  reference: string;
  type: PaymentType;
  status: PaymentStatus;
  amount: number;
  amountInCents: number;
  currency: string;
  userPhone: string;
  userEmail: string;
  userName: string;
  loanId: string | null;
  installmentNumber: number | null;
  createdAt: Date;
}

export const PAYMENT_STATUS_LABELS: Record<PaymentStatus, string> = {
  APPROVED: 'Aprobado',
  DECLINED: 'Rechazado',
  ERROR: 'Error',
};

export const PAYMENT_STATUS_COLORS: Record<PaymentStatus, string> = {
  APPROVED: '#2FFF00',
  DECLINED: '#f87171',
  ERROR: '#f59e0b',
};

export const PAYMENT_TYPE_LABELS: Record<PaymentType, string> = {
  subscription: 'Suscripción',
  installment: 'Cuota',
};
