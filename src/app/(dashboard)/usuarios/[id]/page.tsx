'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { doc, getDoc } from 'firebase/firestore';
import { db } from '@/lib/firebase';
import { getUserLoans, getPaymentsByPhone, getUserPassword, updateUserPassword } from '@/lib/firestore';
import { User, LoanRequest, Payment } from '@/lib/types';
import { LoanCard } from '@/components/LoanCard';
import { PaymentCard } from '@/components/PaymentCard';

export default function UserDetailPage() {
  const { id } = useParams<{ id: string }>();
  const router = useRouter();
  const [user, setUser] = useState<User | null>(null);
  const [loans, setLoans] = useState<LoanRequest[]>([]);
  const [payments, setPayments] = useState<Payment[]>([]);
  const [loading, setLoading] = useState(true);
  const [currentPassword, setCurrentPassword] = useState<string | null>(null);
  const [showPassword, setShowPassword] = useState(false);
  const [newPassword, setNewPassword] = useState('');
  const [editingPassword, setEditingPassword] = useState(false);
  const [savingPassword, setSavingPassword] = useState(false);
  const [passwordMsg, setPasswordMsg] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const userDoc = await getDoc(doc(db, 'users', id));
        if (!userDoc.exists()) {
          router.replace('/usuarios');
          return;
        }
        const data = userDoc.data() as Record<string, unknown>;
        const userData: User = {
          id: userDoc.id,
          email: (data.email as string) || '',
          phone: (data.phone as string) || '',
          name: (data.name as string) || '',
          lastName: (data.lastName as string) || '',
          isSubscribed: (data.isSubscribed as boolean) || false,
          admin: (data.admin as boolean) || false,
        };
        setUser(userData);

        // Fetch password
        const pwd = await getUserPassword(id);
        setCurrentPassword(pwd);

        if (userData.phone) {
          const [userLoans, userPayments] = await Promise.all([
            getUserLoans(userData.phone),
            getPaymentsByPhone(userData.phone),
          ]);
          setLoans(userLoans);
          setPayments(userPayments);
        }
      } catch (e) {
        console.error(e);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [id, router]);

  if (loading) {
    return (
      <div className="flex justify-center py-16">
        <div className="w-8 h-8 border-2 border-[#2FFF00] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  const handleSavePassword = async () => {
    if (!newPassword || newPassword.length < 4) {
      setPasswordMsg({ type: 'error', text: 'La contraseña debe tener al menos 4 caracteres' });
      return;
    }
    setSavingPassword(true);
    setPasswordMsg(null);
    try {
      await updateUserPassword(id, newPassword);
      setCurrentPassword(newPassword);
      setNewPassword('');
      setEditingPassword(false);
      setPasswordMsg({ type: 'success', text: 'Contraseña actualizada' });
      setTimeout(() => setPasswordMsg(null), 3000);
    } catch {
      setPasswordMsg({ type: 'error', text: 'Error al actualizar la contraseña' });
    } finally {
      setSavingPassword(false);
    }
  };

  if (!user) return null;

  return (
    <div>
      <div className="flex items-center gap-3 mb-6">
        <Link href="/usuarios" className="text-gray-400 hover:text-[#2FFF00] transition-colors">
          ← Usuarios
        </Link>
      </div>

      {/* User info */}
      <div className="bg-[#0d1f0d] border border-[#2FFF00]/20 rounded-2xl p-6 mb-6">
        <div className="flex items-center gap-4 mb-4">
          <div className="w-16 h-16 rounded-full bg-[#2FFF00]/20 flex items-center justify-center text-[#2FFF00] font-bold text-2xl">
            {(user.name?.[0] || user.email?.[0] || '?').toUpperCase()}
          </div>
          <div>
            <h1 className="text-white text-xl font-bold">{user.name} {user.lastName}</h1>
            <div className="flex gap-2 mt-1">
              {user.isSubscribed && (
                <span className="text-xs bg-[#2FFF00]/20 text-[#2FFF00] px-2 py-0.5 rounded-full">Suscrito</span>
              )}
              {user.admin && (
                <span className="text-xs bg-blue-500/20 text-blue-400 px-2 py-0.5 rounded-full">Admin</span>
              )}
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          {user.email && (
            <div>
              <p className="text-gray-500 text-xs">Email</p>
              <p className="text-white text-sm">{user.email}</p>
            </div>
          )}
          {user.phone && (
            <div>
              <p className="text-gray-500 text-xs">Teléfono</p>
              <p className="text-white text-sm">{user.phone}</p>
            </div>
          )}
        </div>
      </div>

      {/* Password section */}
      <div className="bg-[#0d1f0d] border border-[#2FFF00]/20 rounded-2xl p-5 mb-6">
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-white font-semibold">Contraseña</h2>
          {!editingPassword && (
            <button
              onClick={() => { setEditingPassword(true); setNewPassword(''); setPasswordMsg(null); }}
              className="text-[#2FFF00] text-sm hover:underline"
            >
              Cambiar
            </button>
          )}
        </div>

        {/* Current password */}
        <div className="flex items-center gap-3 mb-2">
          <div className="flex-1">
            <p className="text-gray-500 text-xs">Contraseña actual</p>
            <div className="flex items-center gap-2 mt-1">
              <p className="text-white text-sm font-mono">
                {currentPassword
                  ? showPassword ? currentPassword : '••••••••'
                  : 'Sin contraseña'}
              </p>
              {currentPassword && (
                <button
                  onClick={() => setShowPassword(!showPassword)}
                  className="text-gray-500 hover:text-[#2FFF00] text-xs transition-colors"
                >
                  {showPassword ? 'Ocultar' : 'Ver'}
                </button>
              )}
            </div>
          </div>
        </div>

        {/* Edit password */}
        {editingPassword && (
          <div className="mt-3 pt-3 border-t border-white/10">
            <p className="text-gray-500 text-xs mb-2">Nueva contraseña</p>
            <div className="flex gap-2">
              <input
                type="text"
                value={newPassword}
                onChange={e => setNewPassword(e.target.value)}
                placeholder="Nueva contraseña..."
                className="flex-1 bg-[#061006] border border-[#2FFF00]/20 rounded-lg px-3 py-2 text-white text-sm placeholder-gray-600 focus:outline-none focus:border-[#2FFF00]/60"
              />
              <button
                onClick={handleSavePassword}
                disabled={savingPassword}
                className="bg-[#2FFF00] text-black px-4 py-2 rounded-lg text-sm font-medium hover:bg-[#2FFF00]/90 disabled:opacity-50 transition-colors"
              >
                {savingPassword ? '...' : 'Guardar'}
              </button>
              <button
                onClick={() => { setEditingPassword(false); setNewPassword(''); setPasswordMsg(null); }}
                className="text-gray-400 px-3 py-2 text-sm hover:text-white transition-colors"
              >
                Cancelar
              </button>
            </div>
          </div>
        )}

        {/* Feedback message */}
        {passwordMsg && (
          <p className={`text-xs mt-2 ${passwordMsg.type === 'success' ? 'text-[#2FFF00]' : 'text-red-400'}`}>
            {passwordMsg.text}
          </p>
        )}
      </div>

      {/* User loans */}
      <h2 className="text-white font-bold text-lg mb-3">
        Solicitudes ({loans.length})
      </h2>
      {loans.length === 0 ? (
        <p className="text-gray-500">Sin solicitudes</p>
      ) : (
        <div className="grid gap-3 sm:grid-cols-2">
          {loans.map(loan => (
            <LoanCard key={loan.id} loan={loan} userName={[user.name, user.lastName].filter(Boolean).join(' ') || undefined} />
          ))}
        </div>
      )}
      {/* User payments */}
      <h2 className="text-white font-bold text-lg mb-3 mt-6">
        Pagos ({payments.length})
      </h2>
      {payments.length === 0 ? (
        <p className="text-gray-500">Sin pagos registrados</p>
      ) : (
        <div className="grid gap-3 sm:grid-cols-2">
          {payments.map(payment => (
            <PaymentCard key={payment.id} payment={payment} />
          ))}
        </div>
      )}
    </div>
  );
}
