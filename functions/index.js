const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const twilio = require("twilio");

admin.initializeApp();

const smtpEmail = process.env.SMTP_EMAIL || "";
const smtpPassword = process.env.SMTP_PASSWORD || "";
const twilioAccountSid = process.env.TWILIO_ACCOUNT_SID || "";
const twilioAuthToken = process.env.TWILIO_AUTH_TOKEN || "";
const twilioVerifyServiceSid = process.env.TWILIO_VERIFY_SERVICE_SID || "";

exports.sendOtpSms = functions.runWith({
  secrets: ["TWILIO_ACCOUNT_SID", "TWILIO_AUTH_TOKEN", "TWILIO_VERIFY_SERVICE_SID"],
}).https.onCall(async (data, context) => {
  const { phone } = data;
  if (!phone) {
    throw new functions.https.HttpsError("invalid-argument", "El teléfono es requerido.");
  }
  try {
    const client = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
    await client.verify.v2.services(process.env.TWILIO_VERIFY_SERVICE_SID)
      .verifications.create({ to: phone, channel: "sms" });
    return { success: true };
  } catch (error) {
    console.error("Error enviando SMS:", error);
    throw new functions.https.HttpsError("internal", "No se pudo enviar el SMS.");
  }
});

exports.verifyOtpSms = functions.runWith({
  secrets: ["TWILIO_ACCOUNT_SID", "TWILIO_AUTH_TOKEN", "TWILIO_VERIFY_SERVICE_SID"],
}).https.onCall(async (data, context) => {
  const { phone, code } = data;
  if (!phone || !code) {
    throw new functions.https.HttpsError("invalid-argument", "Teléfono y código son requeridos.");
  }
  try {
    const client = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
    const check = await client.verify.v2.services(process.env.TWILIO_VERIFY_SERVICE_SID)
      .verificationChecks.create({ to: phone, code });
    return { success: check.status === "approved" };
  } catch (error) {
    console.error("Error verificando SMS:", error);
    throw new functions.https.HttpsError("internal", "No se pudo verificar el código.");
  }
});

exports.sendPushNotification = functions.https.onCall(async (data, context) => {
  const { phone, title, body } = data;
  if (!phone || !title || !body) {
    throw new functions.https.HttpsError("invalid-argument", "phone, title y body son requeridos.");
  }
  try {
    const snap = await admin.firestore()
      .collection('users')
      .where('phone', '==', phone)
      .limit(1)
      .get();

    if (snap.empty) return { success: false, reason: 'user_not_found' };

    const token = snap.docs[0].data().fcmToken;
    if (!token) return { success: false, reason: 'no_token' };

    await admin.messaging().send({
      token,
      notification: { title, body },
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default' } } },
    });
    return { success: true };
  } catch (error) {
    console.error("Error enviando push:", error);
    throw new functions.https.HttpsError("internal", "No se pudo enviar la notificación.");
  }
});

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
