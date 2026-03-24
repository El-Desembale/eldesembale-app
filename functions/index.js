const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

const smtpEmail = process.env.SMTP_EMAIL || "";
const smtpPassword = process.env.SMTP_PASSWORD || "";

exports.sendOtpEmail = functions.https.onCall(async (data, context) => {
  const { email } = data;

  if (!email) {
    throw new functions.https.HttpsError("invalid-argument", "El email es requerido.");
  }

  const code = Math.floor(100000 + Math.random() * 900000).toString();

  const now = admin.firestore.Timestamp.now();
  const expiresAt = admin.firestore.Timestamp.fromMillis(
    now.toMillis() + 10 * 60 * 1000
  );

  await admin.firestore().collection("otp_codes").add({
    email: email.toLowerCase().trim(),
    code,
    createdAt: now,
    expiresAt,
    used: false,
  });

  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: smtpEmail,
      pass: smtpPassword,
    },
  });

  const mailOptions = {
    from: `"El Desembale" <${smtpEmail}>`,
    to: email,
    subject: "Código de verificación - El Desembale",
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 32px; background: #f9f9f9; border-radius: 12px;">
        <h2 style="color: #1a1a1a; text-align: center; margin-bottom: 8px;">El Desembale</h2>
        <p style="color: #555; text-align: center;">Tu código de verificación es:</p>
        <div style="text-align: center; margin: 24px 0;">
          <span style="font-size: 36px; font-weight: bold; letter-spacing: 8px; color: #2fff00; background: #1a1a1a; padding: 16px 32px; border-radius: 8px; display: inline-block;">${code}</span>
        </div>
        <p style="color: #888; text-align: center; font-size: 13px;">Este código expira en 10 minutos. No compartas este código con nadie.</p>
      </div>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    console.error("Error enviando email:", error);
    throw new functions.https.HttpsError("internal", "No se pudo enviar el correo.");
  }
});
