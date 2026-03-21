import { NextRequest, NextResponse } from 'next/server';
import nodemailer from 'nodemailer';

interface ReminderPayload {
  email: string;
  userName: string;
  message: string;
}

export async function POST(req: NextRequest) {
  const body: ReminderPayload = await req.json();
  const { email, userName, message } = body;

  const smtpUser = process.env.SMTP_USER;
  const smtpPass = process.env.SMTP_PASS;
  const smtpHost = process.env.SMTP_HOST || 'smtp.gmail.com';
  const smtpPort = parseInt(process.env.SMTP_PORT || '587', 10);
  const fromEmail = process.env.SMTP_FROM || smtpUser;

  if (!smtpUser || !smtpPass) {
    return NextResponse.json(
      { success: false, error: 'Email no configurado. Agrega SMTP_USER y SMTP_PASS en .env.local' },
      { status: 500 }
    );
  }

  if (!email) {
    return NextResponse.json(
      { success: false, error: 'El cliente no tiene correo electrónico registrado' },
      { status: 400 }
    );
  }

  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; background: #0a1a0a; border-radius: 16px; padding: 32px; color: #ffffff;">
      <h2 style="color: #ff9800; margin: 0 0 24px 0; font-size: 20px;">Recordatorio de pago</h2>
      <p style="color: #ffffff; font-size: 15px; line-height: 1.6; white-space: pre-wrap;">${message}</p>
      <p style="margin-top: 24px; color: #6b7280; font-size: 11px; text-align: center;">El Desembale</p>
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
      to: email,
      subject: `Recordatorio de pago · ${userName || 'Cliente'}`,
      html,
    });

    return NextResponse.json({ success: true });
  } catch (e: unknown) {
    return NextResponse.json({ success: false, error: (e as Error).message }, { status: 500 });
  }
}
