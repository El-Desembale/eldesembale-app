import { NextRequest, NextResponse } from 'next/server';
import nodemailer from 'nodemailer';

interface NewLoanPayload {
  loanId: string;
  amount: number;
  phone: string;
  installments: number;
  paymentPeriod: string;
  clientName?: string;
}

export async function POST(req: NextRequest) {
  const body: NewLoanPayload = await req.json();
  const { loanId, amount, phone, installments, paymentPeriod, clientName } = body;

  const smtpUser = process.env.SMTP_USER;
  const smtpPass = process.env.SMTP_PASS;
  const smtpHost = process.env.SMTP_HOST || 'smtp.gmail.com';
  const smtpPort = parseInt(process.env.SMTP_PORT || '587', 10);
  const fromEmail = process.env.SMTP_FROM || smtpUser;
  const adminEmails = (process.env.ADMIN_EMAILS || '').split(',').map(e => e.trim()).filter(Boolean);

  if (!smtpUser || !smtpPass || adminEmails.length === 0) {
    return NextResponse.json(
      { success: false, error: 'Email no configurado. Agrega SMTP_USER, SMTP_PASS y ADMIN_EMAILS en .env.local' },
      { status: 500 }
    );
  }

  const amountFormatted = new Intl.NumberFormat('es-CO', {
    style: 'currency',
    currency: 'COP',
    maximumFractionDigits: 0,
  }).format(amount);

  const clientDisplay = clientName ? `${clientName} (${phone})` : phone;
  const loanUrl = `https://eldesembale-admin.vercel.app/solicitudes/${loanId}`;

  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; background: #0a1a0a; border-radius: 16px; padding: 32px; color: #ffffff;">
      <h2 style="color: #2FFF00; margin: 0 0 24px 0; font-size: 20px;">Nueva solicitud de préstamo</h2>
      <table style="width: 100%; border-collapse: collapse;">
        <tr>
          <td style="padding: 8px 0; color: #9ca3af; font-size: 14px;">Cliente</td>
          <td style="padding: 8px 0; color: #ffffff; font-size: 14px; text-align: right; font-weight: bold;">${clientDisplay}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: #9ca3af; font-size: 14px;">Monto</td>
          <td style="padding: 8px 0; color: #2FFF00; font-size: 18px; text-align: right; font-weight: bold;">${amountFormatted}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: #9ca3af; font-size: 14px;">Cuotas</td>
          <td style="padding: 8px 0; color: #ffffff; font-size: 14px; text-align: right;">${installments} cuotas</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: #9ca3af; font-size: 14px;">Período</td>
          <td style="padding: 8px 0; color: #ffffff; font-size: 14px; text-align: right;">${paymentPeriod}</td>
        </tr>
      </table>
      <div style="margin-top: 24px; text-align: center;">
        <a href="${loanUrl}" style="display: inline-block; background: #2FFF00; color: #000000; padding: 12px 32px; border-radius: 24px; text-decoration: none; font-weight: bold; font-size: 14px;">
          Ver solicitud
        </a>
      </div>
      <p style="margin-top: 24px; color: #6b7280; font-size: 11px; text-align: center;">El Desembale · Panel de administración</p>
    </div>
  `;

  try {
    const transporter = nodemailer.createTransport({
      host: smtpHost,
      port: smtpPort,
      secure: smtpPort === 465,
      auth: { user: smtpUser, pass: smtpPass },
    });

    await transporter.sendMail({
      from: `"El Desembale" <${fromEmail}>`,
      to: adminEmails.join(', '),
      subject: `Nueva solicitud · ${clientDisplay} · ${amountFormatted}`,
      html,
    });

    return NextResponse.json({ success: true });
  } catch (e: unknown) {
    return NextResponse.json({ success: false, error: (e as Error).message }, { status: 500 });
  }
}
