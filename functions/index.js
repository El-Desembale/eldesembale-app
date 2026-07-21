const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const twilio = require("twilio");

admin.initializeApp();

const twilioAccountSid = process.env.TWILIO_ACCOUNT_SID || "";
const twilioAuthToken = process.env.TWILIO_AUTH_TOKEN || "";
const twilioVerifyServiceSid = process.env.TWILIO_VERIFY_SERVICE_SID || "";

const ADMIN_EMAILS = [
  "andres.londono.cano@gmail.com",
  "Stiven96inversionista@gmail.com",
];

function createTransporter() {
  const smtpEmail = process.env.SMTP_EMAIL || "";
  const smtpPassword = process.env.SMTP_PASSWORD || "";
  if (!smtpEmail || !smtpPassword) {
    throw new Error("SMTP_EMAIL y SMTP_PASSWORD son requeridos");
  }

  return nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: smtpEmail,
      pass: smtpPassword,
    },
  });
}

function getDaysPerPeriod(period) {
  const normalized = String(period || "").toLowerCase();
  if (normalized.includes("seman")) return 7;
  if (normalized.includes("quince")) return 15;
  return 30;
}

function addDays(date, days) {
  return new Date(date.getTime() + days * 24 * 60 * 60 * 1000);
}

function getNextInstallmentDate(loan) {
  const createdAt = loan.created_at?.toDate
    ? loan.created_at.toDate()
    : new Date(loan.created_at);
  const nextInstallmentIndex = Number(loan.installments_paid || 0) + 1;
  const daysPerPeriod = getDaysPerPeriod(loan.payment_period);
  return addDays(createdAt, daysPerPeriod * nextInstallmentIndex);
}

function diffInWholeDays(fromDate, toDate) {
  const start = new Date(fromDate.getFullYear(), fromDate.getMonth(), fromDate.getDate());
  const end = new Date(toDate.getFullYear(), toDate.getMonth(), toDate.getDate());
  return Math.round((end.getTime() - start.getTime()) / (24 * 60 * 60 * 1000));
}

function formatCurrency(value) {
  return new Intl.NumberFormat("es-CO", {
    style: "currency",
    currency: "COP",
    maximumFractionDigits: 0,
  }).format(Number(value || 0));
}

function formatDate(value) {
  return new Intl.DateTimeFormat("es-CO", {
    year: "numeric",
    month: "short",
    day: "numeric",
  }).format(value);
}

function getLoanCreatedAt(loan) {
  if (loan.created_at?.toDate) {
    return loan.created_at.toDate();
  }
  if (loan.created_at?._seconds) {
    return new Date(loan.created_at._seconds * 1000);
  }
  return new Date(loan.created_at || Date.now());
}

function getInstallmentAmount(loan) {
  const totalLoan = Number(loan.amount || 0);
  const installments = Number(loan.installments || 0);
  const interest = Number(loan.interest || 1);
  if (!totalLoan || !installments) return 0;
  const loanInterest = (totalLoan * interest) - totalLoan;
  const capital = totalLoan / installments;
  return loanInterest + capital;
}

function getTotalRepayableAmount(loan) {
  const installmentAmount = getInstallmentAmount(loan);
  const installments = Number(loan.installments || 0);
  return installmentAmount * installments;
}

function getNextInstallmentDateFromPaidCount(loan, paidInstallments) {
  const createdAt = getLoanCreatedAt(loan);
  const nextInstallmentIndex = Math.max(Number(paidInstallments || 0), 0);
  const firstPaymentDate = new Date(
    createdAt.getFullYear(),
    createdAt.getMonth() + 1,
    createdAt.getDate(),
  );

  if (String(loan.payment_period || "").toLowerCase().includes("mens")) {
    return new Date(
      firstPaymentDate.getFullYear(),
      firstPaymentDate.getMonth() + nextInstallmentIndex,
      firstPaymentDate.getDate(),
    );
  }

  return addDays(firstPaymentDate, 15 * nextInstallmentIndex);
}

async function findLoanById(loanId) {
  if (!loanId) return null;

  const querySnap = await admin.firestore()
    .collection("loan_request")
    .where("id", "==", loanId)
    .limit(1)
    .get();

  if (!querySnap.empty) {
    return {
      id: querySnap.docs[0].id,
      data: querySnap.docs[0].data(),
    };
  }

  const docSnap = await admin.firestore().collection("loan_request").doc(loanId).get();
  if (!docSnap.exists) return null;

  return {
    id: docSnap.id,
    data: docSnap.data(),
  };
}

function buildReminderEmailHtml({ title, intro, accentColor }) {
  return `
    <div style="font-family: Arial, sans-serif; max-width: 520px; margin: 0 auto; background: #08150d; border-radius: 18px; padding: 32px; color: #f4f7f1;">
      <h2 style="color: ${accentColor}; margin: 0 0 18px 0; font-size: 22px;">${title}</h2>
      <div style="color: #d7e1d5; font-size: 15px; line-height: 1.65; white-space: pre-wrap;">${intro}</div>
      <p style="margin-top: 24px; color: #92a097; font-size: 12px;">El Desembale</p>
    </div>
  `;
}

function buildPaymentReceiptEmailHtml({
  userName,
  paymentDate,
  paymentAmount,
  totalCreditAmount,
  installmentAmount,
  paidInstallments,
  totalInstallments,
  installmentsCovered,
  remainingInstallments,
  remainingBalance,
  nextDueDate,
  paymentPeriod,
  reference,
}) {
  return `
    <div style="font-family: Arial, sans-serif; max-width: 560px; margin: 0 auto; background: #0d1712; border-radius: 22px; padding: 32px; color: #f4f7f1;">
      <div style="display: inline-block; padding: 8px 14px; border-radius: 999px; background: #1d3324; color: #a8d08d; font-size: 12px; font-weight: 700;">
        Comprobante de pago
      </div>
      <h2 style="margin: 18px 0 10px 0; font-size: 26px; color: #f4f7f1;">Pago recibido correctamente</h2>
      <p style="margin: 0 0 24px 0; color: #c7d0c8; font-size: 15px; line-height: 1.7;">
        Hola ${userName}, registramos tu pago del ${paymentDate}. Aquí tienes el resumen actualizado de tu crédito.
      </p>

      <div style="background: #15211a; border: 1px solid #243328; border-radius: 18px; padding: 20px; margin-bottom: 18px;">
        <div style="font-size: 13px; color: #9bb09f; margin-bottom: 8px;">Valor abonado</div>
        <div style="font-size: 32px; font-weight: 700; color: #f4f7f1;">${paymentAmount}</div>
        <div style="margin-top: 10px; font-size: 13px; color: #9bb09f;">
          Referencia: ${reference || "Pago de cuota"} · ${installmentsCovered} cuota${installmentsCovered === 1 ? "" : "s"} cubierta${installmentsCovered === 1 ? "" : "s"}
        </div>
      </div>

      <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px; margin-bottom: 18px;">
        <div style="background: #111c15; border: 1px solid #243328; border-radius: 16px; padding: 16px;">
          <div style="font-size: 12px; color: #90a391;">Cuotas pagadas</div>
          <div style="margin-top: 6px; font-size: 22px; font-weight: 700; color: #f4f7f1;">${paidInstallments}/${totalInstallments}</div>
        </div>
        <div style="background: #111c15; border: 1px solid #243328; border-radius: 16px; padding: 16px;">
          <div style="font-size: 12px; color: #90a391;">Te faltan</div>
          <div style="margin-top: 6px; font-size: 22px; font-weight: 700; color: #f4f7f1;">${remainingInstallments} cuota${remainingInstallments === 1 ? "" : "s"}</div>
        </div>
      </div>

      <div style="background: #111c15; border: 1px solid #243328; border-radius: 16px; padding: 18px; margin-bottom: 18px;">
        <div style="font-size: 13px; color: #9bb09f; margin-bottom: 12px;">Resumen del crédito</div>
        <table style="width: 100%; border-collapse: collapse; color: #f4f7f1; font-size: 14px;">
          <tr>
            <td style="padding: 8px 0; color: #9bb09f;">Periodo</td>
            <td style="padding: 8px 0; text-align: right;">${paymentPeriod}</td>
          </tr>
          <tr>
            <td style="padding: 8px 0; color: #9bb09f;">Valor por cuota</td>
            <td style="padding: 8px 0; text-align: right;">${installmentAmount}</td>
          </tr>
          <tr>
            <td style="padding: 8px 0; color: #9bb09f;">Total del crédito</td>
            <td style="padding: 8px 0; text-align: right;">${totalCreditAmount}</td>
          </tr>
          <tr>
            <td style="padding: 8px 0; color: #9bb09f;">Saldo pendiente</td>
            <td style="padding: 8px 0; text-align: right;">${remainingBalance}</td>
          </tr>
          <tr>
            <td style="padding: 8px 0; color: #9bb09f;">Próximo pago</td>
            <td style="padding: 8px 0; text-align: right;">${nextDueDate || "Crédito al día"}</td>
          </tr>
        </table>
      </div>

      <p style="margin: 0; color: #90a391; font-size: 12px; line-height: 1.6;">
        Este correo es informativo y resume el estado del crédito después de tu pago.
      </p>
    </div>
  `;
}

async function sendInstallmentReceiptEmail({
  payment,
  loan,
  recipientEmail,
  recipientName,
}) {
  if (!recipientEmail || !loan) return null;

  const transporter = createTransporter();
  const totalInstallments = Number(loan.installments || 0);
  const previousPaidInstallments = Math.min(
    Number(loan.installments_paid || 0),
    totalInstallments,
  );
  const paidInstallments = Math.min(
    Number(payment.installment_number || previousPaidInstallments),
    totalInstallments,
  );
  const installmentsCovered = Math.max(paidInstallments - previousPaidInstallments, 1);
  const remainingInstallments = Math.max(totalInstallments - paidInstallments, 0);
  const installmentAmount = getInstallmentAmount(loan);
  const totalCreditAmount = getTotalRepayableAmount(loan);
  const remainingBalance = remainingInstallments * installmentAmount;
  const paymentDate = payment.created_at?.toDate
    ? payment.created_at.toDate()
    : new Date(payment.created_at || Date.now());
  const nextDueDate = remainingInstallments > 0
    ? formatDate(getNextInstallmentDateFromPaidCount(loan, paidInstallments))
    : null;
  const userName = recipientName || payment.user_name || "Cliente";

  await transporter.sendMail({
    from: `"El Desembale" <${process.env.SMTP_EMAIL}>`,
    to: recipientEmail,
    subject: `Comprobante de pago · ${paidInstallments}/${totalInstallments} cuotas`,
    html: buildPaymentReceiptEmailHtml({
      userName,
      paymentDate: formatDate(paymentDate),
      paymentAmount: formatCurrency(payment.amount || 0),
      totalCreditAmount: formatCurrency(totalCreditAmount),
      installmentAmount: formatCurrency(installmentAmount),
      paidInstallments,
      totalInstallments,
      installmentsCovered,
      remainingInstallments,
      remainingBalance: formatCurrency(remainingBalance),
      nextDueDate,
      paymentPeriod: loan.payment_period || "Cuotas",
      reference: payment.reference,
    }),
  });

  return {
    paidInstallments,
    totalInstallments,
    installmentsCovered,
    remainingInstallments,
  };
}

async function getAdminRecipients() {
  const usersSnap = await admin.firestore()
    .collection("users")
    .where("admin", "==", true)
    .get();

  return usersSnap.docs
    .map((doc) => doc.data())
    .filter((user) => user.email)
    .map((user) => ({
      email: user.email,
      name: `${user.name || ""} ${user.lastName || ""}`.trim() || "Admin",
    }));
}

async function processLoanReminders({ notifyClients = true } = {}) {
  const transporter = createTransporter();
  const now = new Date();

  const loansSnap = await admin.firestore()
    .collection("loan_request")
    .where("status", "==", "approved")
    .get();

  const reminders = [];

  for (const doc of loansSnap.docs) {
    const loan = doc.data();
    const installments = Number(loan.installments || 0);
    const installmentsPaid = Number(loan.installments_paid || 0);

    if (!installments || installmentsPaid >= installments) continue;

    const nextDueDate = getNextInstallmentDate(loan);
    const daysUntilDue = diffInWholeDays(now, nextDueDate);
    const isOverdue = daysUntilDue < 0;
    const isDueSoon = daysUntilDue === 3;

    if (!isOverdue && !isDueSoon) continue;

    const userSnap = await admin.firestore()
      .collection("users")
      .where("phone", "==", loan.phone)
      .limit(1)
      .get();

    if (userSnap.empty) continue;

    const user = userSnap.docs[0].data();
    const userName = `${user.name || ""} ${user.lastName || ""}`.trim() || "Cliente";
    const amount = formatCurrency(loan.amount);
    const dueDate = formatDate(nextDueDate);
    const reminderType = isOverdue ? "overdue" : "due_soon";
    const subject = isOverdue
      ? `Tienes una cuota en mora · ${amount}`
      : `Tu próxima cuota vence en 3 días · ${amount}`;
    const message = isOverdue
      ? `Hola ${userName},\n\nTienes una cuota en mora correspondiente a tu préstamo por ${amount}. La fecha estimada de pago era ${dueDate}. Te recomendamos ponerte al día lo antes posible para evitar novedades en tu crédito.`
      : `Hola ${userName},\n\nTe recordamos que tu próxima cuota del préstamo por ${amount} vence el ${dueDate}. Te sugerimos programar tu pago con anticipación para mantenerte al día.`;

    if (notifyClients && user.email) {
      await transporter.sendMail({
        from: `"El Desembale" <${process.env.SMTP_EMAIL}>`,
        to: user.email,
        subject,
        html: buildReminderEmailHtml({
          title: isOverdue ? "Recordatorio de mora" : "Próximo pago",
          intro: message,
          accentColor: isOverdue ? "#ff8d7a" : "#86d39a",
        }),
      });
    }

    reminders.push({
      type: reminderType,
      loanId: loan.id || doc.id,
      phone: loan.phone || "",
      userName,
      email: user.email || "",
      amount,
      dueDate,
      daysUntilDue,
    });
  }

  const admins = await getAdminRecipients();
  if (admins.length) {
    const overdueItems = reminders.filter((item) => item.type === "overdue");
    const dueSoonItems = reminders.filter((item) => item.type === "due_soon");

    const summaryLines = [
      `Resumen de recordatorios ejecutado el ${formatDate(now)}.`,
      "",
      `Clientes en mora: ${overdueItems.length}`,
      ...overdueItems.map((item) =>
        `- ${item.userName} · ${item.amount} · vencía ${item.dueDate} · ${item.phone}`),
      "",
      `Clientes con cuota próxima en 3 días: ${dueSoonItems.length}`,
      ...dueSoonItems.map((item) =>
        `- ${item.userName} · ${item.amount} · vence ${item.dueDate} · ${item.phone}`),
    ].join("\n");

    await transporter.sendMail({
      from: `"El Desembale" <${process.env.SMTP_EMAIL}>`,
      to: admins.map((adminUser) => adminUser.email).join(","),
      subject: `Resumen de mora y próximos pagos · ${reminders.length} recordatorios`,
      html: buildReminderEmailHtml({
        title: "Resumen para admins",
        intro: summaryLines,
        accentColor: "#86d39a",
      }),
    });
  }

  return {
    processed: reminders.length,
    overdue: reminders.filter((item) => item.type === "overdue").length,
    dueSoon: reminders.filter((item) => item.type === "due_soon").length,
    adminsNotified: admins.length,
  };
}

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

exports.sendOtpEmail = functions.runWith({
  secrets: ["SMTP_EMAIL", "SMTP_PASSWORD"],
}).https.onCall(async (data, context) => {
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

  const transporter = createTransporter();

  const mailOptions = {
    from: `"El Desembale" <${process.env.SMTP_EMAIL}>`,
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

exports.sendLoanReminderEmails = functions.runWith({
  secrets: ["SMTP_EMAIL", "SMTP_PASSWORD"],
}).pubsub
  .schedule("0 8 * * *")
  .timeZone("America/Bogota")
  .onRun(async () => {
    const result = await processLoanReminders({ notifyClients: true });
    console.log("Loan reminders completed:", result);
    return null;
  });

exports.sendAdminRemindersTest = functions.runWith({
  secrets: ["SMTP_EMAIL", "SMTP_PASSWORD"],
}).https.onCall(async () => {
  try {
    const result = await processLoanReminders({ notifyClients: false });
    return { success: true, ...result };
  } catch (error) {
    console.error("Error sending admin reminders test:", error);
    throw new functions.https.HttpsError(
      "internal",
      "No se pudo enviar la prueba de recordatorios a admins."
    );
  }
});

exports.sendInstallmentReceiptOnPayment = functions.runWith({
  secrets: ["SMTP_EMAIL", "SMTP_PASSWORD"],
}).firestore.document("payments/{paymentId}").onCreate(async (snap) => {
  const payment = snap.data();

  if (!payment) return null;
  if (payment.status !== "APPROVED") return null;
  if (payment.type !== "installment") return null;
  if (!payment.loan_id || !payment.user_email) return null;

  try {
    const loanRecord = await findLoanById(payment.loan_id);
    if (!loanRecord) return null;

    const result = await sendInstallmentReceiptEmail({
      payment,
      loan: loanRecord.data,
      recipientEmail: payment.user_email,
      recipientName: payment.user_name,
    });

    console.log("Installment receipt email sent:", {
      paymentId: snap.id,
      loanId: payment.loan_id,
      userEmail: payment.user_email,
      result,
    });
  } catch (error) {
    console.error("Error sending installment receipt:", error);
  }

  return null;
});

exports.sendInstallmentReceiptTest = functions.runWith({
  secrets: ["SMTP_EMAIL", "SMTP_PASSWORD"],
}).https.onCall(async (data) => {
  const { email, loanId, paymentId, userName } = data || {};

  if (!email) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "El email es requerido."
    );
  }

  try {
    let payment = null;

    if (paymentId) {
      const paymentSnap = await admin.firestore().collection("payments").doc(paymentId).get();
      if (paymentSnap.exists) {
        payment = paymentSnap.data();
      }
    }

    if (!payment) {
      let paymentsQuery = admin.firestore()
        .collection("payments")
        .where("status", "==", "APPROVED")
        .where("type", "==", "installment")
        .orderBy("created_at", "desc")
        .limit(10);

      if (loanId) {
        paymentsQuery = admin.firestore()
          .collection("payments")
          .where("status", "==", "APPROVED")
          .where("type", "==", "installment")
          .where("loan_id", "==", loanId)
          .orderBy("created_at", "desc")
          .limit(10);
      }

      const paymentsSnap = await paymentsQuery.get();
      if (paymentsSnap.empty) {
        throw new functions.https.HttpsError(
          "not-found",
          "No se encontró un pago aprobado para generar la prueba."
        );
      }

      payment = paymentsSnap.docs[0].data();
    }

    const effectiveLoanId = loanId || payment.loan_id;
    const loanRecord = await findLoanById(effectiveLoanId);

    if (!loanRecord) {
      throw new functions.https.HttpsError(
        "not-found",
        "No se encontró el crédito asociado al pago."
      );
    }

    const result = await sendInstallmentReceiptEmail({
      payment,
      loan: loanRecord.data,
      recipientEmail: email,
      recipientName: userName || payment.user_name,
    });

    return {
      success: true,
      email,
      loanId: effectiveLoanId,
      result,
    };
  } catch (error) {
    console.error("Error sending installment receipt test:", error);
    throw new functions.https.HttpsError(
      "internal",
      "No se pudo enviar la prueba del comprobante de pago."
    );
  }
});

exports.notifyAdminsOnPayment = functions.runWith({
  secrets: ["SMTP_EMAIL", "SMTP_PASSWORD"],
}).firestore.document("payments/{paymentId}").onCreate(async (snap) => {
  const payment = snap.data();
  if (!payment || payment.status !== "APPROVED") return null;

  const isSubscription = payment.type === "subscription";
  const isInstallment = payment.type === "installment";
  if (!isSubscription && !isInstallment) return null;

  try {
    const transporter = createTransporter();
    const fromEmail = process.env.SMTP_EMAIL;
    const amount = formatCurrency(payment.amount || 0);
    const userName = payment.user_name || "Usuario";
    const userPhone = payment.user_phone || "";
    const userEmail = payment.user_email || "";
    const paymentDate = payment.created_at?.toDate
      ? formatDate(payment.created_at.toDate())
      : formatDate(new Date());

    let subject, bodyHtml;

    if (isSubscription) {
      subject = `💳 Nueva suscripción · ${userName} · ${amount}`;
      bodyHtml = `
        <div style="font-family:Arial,sans-serif;max-width:520px;margin:0 auto;background:#08150d;border-radius:18px;padding:32px;color:#f4f7f1;">
          <div style="display:inline-block;padding:6px 14px;border-radius:999px;background:#1d3324;color:#a8d08d;font-size:12px;font-weight:700;margin-bottom:18px;">
            Pago de suscripción
          </div>
          <h2 style="color:#a8d08d;margin:0 0 18px 0;font-size:22px;">Nueva suscripción pagada</h2>
          <table style="width:100%;border-collapse:collapse;font-size:15px;color:#d7e1d5;">
            <tr><td style="padding:8px 0;color:#92a097;">Usuario</td><td style="padding:8px 0;text-align:right;font-weight:600;">${userName}</td></tr>
            <tr><td style="padding:8px 0;color:#92a097;">Teléfono</td><td style="padding:8px 0;text-align:right;">${userPhone}</td></tr>
            <tr><td style="padding:8px 0;color:#92a097;">Correo</td><td style="padding:8px 0;text-align:right;">${userEmail}</td></tr>
            <tr><td style="padding:8px 0;color:#92a097;">Valor pagado</td><td style="padding:8px 0;text-align:right;font-size:20px;font-weight:700;color:#a8d08d;">${amount}</td></tr>
            <tr><td style="padding:8px 0;color:#92a097;">Fecha</td><td style="padding:8px 0;text-align:right;">${paymentDate}</td></tr>
          </table>
          <p style="margin-top:24px;color:#92a097;font-size:12px;">El Desembale · Panel de administración</p>
        </div>
      `;
    } else {
      // installment
      let loanInfo = "";
      if (payment.loan_id) {
        const loanRecord = await findLoanById(payment.loan_id);
        if (loanRecord) {
          const loan = loanRecord.data;
          const installmentNum = payment.installment_number || "?";
          const totalInstallments = loan.installments || "?";
          loanInfo = `<tr><td style="padding:8px 0;color:#92a097;">Crédito</td><td style="padding:8px 0;text-align:right;">${formatCurrency(loan.amount || 0)}</td></tr>
            <tr><td style="padding:8px 0;color:#92a097;">Cuota</td><td style="padding:8px 0;text-align:right;">${installmentNum} / ${totalInstallments}</td></tr>`;
        }
      }
      subject = `💰 Cuota pagada · ${userName} · ${amount}`;
      bodyHtml = `
        <div style="font-family:Arial,sans-serif;max-width:520px;margin:0 auto;background:#08150d;border-radius:18px;padding:32px;color:#f4f7f1;">
          <div style="display:inline-block;padding:6px 14px;border-radius:999px;background:#1d3324;color:#a8d08d;font-size:12px;font-weight:700;margin-bottom:18px;">
            Pago de cuota
          </div>
          <h2 style="color:#a8d08d;margin:0 0 18px 0;font-size:22px;">Cuota recibida</h2>
          <table style="width:100%;border-collapse:collapse;font-size:15px;color:#d7e1d5;">
            <tr><td style="padding:8px 0;color:#92a097;">Usuario</td><td style="padding:8px 0;text-align:right;font-weight:600;">${userName}</td></tr>
            <tr><td style="padding:8px 0;color:#92a097;">Teléfono</td><td style="padding:8px 0;text-align:right;">${userPhone}</td></tr>
            ${loanInfo}
            <tr><td style="padding:8px 0;color:#92a097;">Valor pagado</td><td style="padding:8px 0;text-align:right;font-size:20px;font-weight:700;color:#a8d08d;">${amount}</td></tr>
            <tr><td style="padding:8px 0;color:#92a097;">Fecha</td><td style="padding:8px 0;text-align:right;">${paymentDate}</td></tr>
          </table>
          <p style="margin-top:24px;color:#92a097;font-size:12px;">El Desembale · Panel de administración</p>
        </div>
      `;
    }

    await transporter.sendMail({
      from: `"El Desembale Admin" <${fromEmail}>`,
      to: ADMIN_EMAILS.join(", "),
      subject,
      html: bodyHtml,
    });

    console.log("Admin payment notification sent:", { type: payment.type, userPhone, amount: payment.amount });
  } catch (error) {
    console.error("Error sending admin payment notification:", error);
  }

  return null;
});

// ════════════════════════════════════════════════════════════════
//  PERFIL DE RIESGO Y CUPO (centralizado)
//  Recalcula y persiste en el documento del usuario cuando cambian
//  préstamos o pagos. Otros clientes solo leen los campos resultantes.
// ════════════════════════════════════════════════════════════════

const NEW_MAX_AMOUNT = 100000;     // cupo del primer préstamo
const CUPO_INCREMENT = 50000;      // aumento por préstamo pagado sin mora
const MAX_CUPO = 1000000;          // tope máximo

function getExpectedInstallments(loan) {
  const daysPerPeriod = getDaysPerPeriod(loan.payment_period);
  const createdAt = loan.created_at?.toDate
    ? loan.created_at.toDate()
    : new Date(loan.created_at || Date.now());
  const daysSince = Math.floor((Date.now() - createdAt.getTime()) / (1000 * 60 * 60 * 24));
  const installments = Number(loan.installments || 0);
  return Math.min(Math.floor(daysSince / daysPerPeriod), installments);
}

function loanIsInMora(loan) {
  if (loan.status !== "disbursed") return false;
  const paid = Number(loan.installments_paid || 0);
  const installments = Number(loan.installments || 0);
  if (paid >= installments) return false;
  return getExpectedInstallments(loan) > paid;
}

function computeUserRisk(loans, previousMax) {
  const paid = loans.filter((l) => Number(l.installments || 0) > 0 &&
    Number(l.installments_paid || 0) >= Number(l.installments || 0));
  const active = loans.filter((l) => l.status === "disbursed" &&
    Number(l.installments_paid || 0) < Number(l.installments || 0));
  const inMora = loans.filter(loanIsInMora);

  const hadMoraEver = inMora.length > 0 || loans.some((l) => l.hadMora === true);
  const currentLate = inMora.reduce(
    (s, l) => s + Math.max(getExpectedInstallments(l) - Number(l.installments_paid || 0), 0), 0);
  const severeMora = currentLate > 1 || inMora.length > 1 ||
    loans.some((l) => Number(l.maxLateInstallments || 0) > 1);
  const paidWithoutMoraCount = paid.filter((l) => l.hadMora !== true).length;

  let profile; let maxLoanAmount; let blocked = false;
  if (severeMora) {
    profile = "BLOCKED"; maxLoanAmount = 0; blocked = true;
  } else if (hadMoraEver) {
    profile = "MEDIUM_RISK";
    maxLoanAmount = Math.min(Math.max(previousMax || NEW_MAX_AMOUNT, NEW_MAX_AMOUNT), MAX_CUPO);
  } else if (paidWithoutMoraCount > 0) {
    profile = "GOOD_PAYER";
    // Cupo progresivo: $100.000 base + $50.000 por cada préstamo pagado sin mora
    maxLoanAmount = Math.min(NEW_MAX_AMOUNT + CUPO_INCREMENT * paidWithoutMoraCount, MAX_CUPO);
  } else {
    profile = "NEW"; maxLoanAmount = NEW_MAX_AMOUNT;
  }

  return {
    riskProfile: profile,
    maxLoanAmount,
    isBlockedForNewLoans: blocked,
    hasHadLatePayments: hadMoraEver,
    hasSevereLatePayments: severeMora,
    totalLoans: loans.length,
    paidLoans: paid.length,
    activeLoans: active.length,
    currentLateInstallments: currentLate,
  };
}

async function recalcRiskForPhone(phone) {
  if (!phone) return;
  const db = admin.firestore();
  const [loansSnap, userSnap] = await Promise.all([
    db.collection("loan_request").where("phone", "==", phone).get(),
    db.collection("users").where("phone", "==", phone).limit(1).get(),
  ]);
  if (userSnap.empty) return;
  const loans = loansSnap.docs.map((d) => d.data());
  const userDoc = userSnap.docs[0];
  const previousMax = userDoc.data().maxLoanAmount;
  const risk = computeUserRisk(loans, previousMax);
  await userDoc.ref.update({
    ...risk,
    riskUpdatedAt: admin.firestore.Timestamp.now(),
  });
  console.log("Risk recalculated for", phone, risk.riskProfile, risk.maxLoanAmount);
}

exports.recalcRiskOnLoanChange = functions.firestore
  .document("loan_request/{loanId}")
  .onWrite(async (change) => {
    const after = change.after.exists ? change.after.data() : null;
    const before = change.before.exists ? change.before.data() : null;
    const phone = after?.phone || before?.phone;
    try {
      await recalcRiskForPhone(phone);
    } catch (e) {
      console.error("recalcRiskOnLoanChange error", e);
    }
    return null;
  });

exports.recalcRiskOnPaymentChange = functions.firestore
  .document("payments/{paymentId}")
  .onWrite(async (change) => {
    const after = change.after.exists ? change.after.data() : null;
    const before = change.before.exists ? change.before.data() : null;
    const phone = after?.user_phone || before?.user_phone;
    try {
      await recalcRiskForPhone(phone);
    } catch (e) {
      console.error("recalcRiskOnPaymentChange error", e);
    }
    return null;
  });

// La confirmación visual del cliente no puede ser la responsable de aplicar una
// cuota: puede cerrar la app después de que Wompi apruebe. Este trigger enlaza el
// documento APPROVED con el préstamo de forma idempotente.
exports.applyApprovedInstallmentPayment = functions.firestore
  .document("payments/{paymentId}")
  .onWrite(async (change) => {
    if (!change.after.exists) return null;
    const payment = change.after.data();
    if (payment.status !== "APPROVED" || payment.type !== "installment" ||
        !payment.loan_id || payment.accounting_applied === true) return null;

    const db = admin.firestore();
    const paymentRef = change.after.ref;
    const loanRef = db.collection("loan_request").doc(payment.loan_id);
    await db.runTransaction(async (transaction) => {
      const freshPaymentSnap = await transaction.get(paymentRef);
      const loanSnap = await transaction.get(loanRef);
      if (!freshPaymentSnap.exists || !loanSnap.exists) return;
      const freshPayment = freshPaymentSnap.data();
      if (freshPayment.accounting_applied === true) return;

      const loan = loanSnap.data();
      const current = Number(loan.installments_paid || 0);
      const total = Number(loan.installments || current);
      const absoluteInstallment = Number(freshPayment.installment_number || 0);
      const quantity = Math.max(Number(freshPayment.installments_to_pay || 1), 1);
      const next = Math.min(
        absoluteInstallment > 0 ? Math.max(current, absoluteInstallment) : current + quantity,
        total,
      );
      if (next > current) {
        transaction.update(loanRef, {
          installments_paid: next,
          updated_at: admin.firestore.Timestamp.now(),
        });
      }
      transaction.update(paymentRef, {
        accounting_applied: true,
        accounting_applied_at: admin.firestore.Timestamp.now(),
      });
    });
    return null;
  });

// Callable para recalcular manualmente (usado por el admin o scripts)
exports.recalculateUserRisk = functions.https.onCall(async (data) => {
  const phone = data?.phone;
  if (!phone) {
    throw new functions.https.HttpsError("invalid-argument", "phone es requerido");
  }
  await recalcRiskForPhone(phone);
  return { success: true };
});

// ════════════════════════════════════════════════════════════════
//  OTP para la web (envío a correo + celular, verifica cualquiera)
// ════════════════════════════════════════════════════════════════

const OTP_CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

function normalizePhone(phone, countryCode) {
  let p = String(phone || "").trim();
  if (p.startsWith("+")) return p;
  const cc = String(countryCode || "+57").replace(/[^0-9+]/g, "");
  return `${cc.startsWith("+") ? cc : "+" + cc}${p}`;
}

// Envía el código por correo (código propio en otp_codes) y por SMS (Twilio Verify)
exports.sendRecoveryOtp = functions.runWith({
  secrets: ["SMTP_EMAIL", "SMTP_PASSWORD", "TWILIO_ACCOUNT_SID", "TWILIO_AUTH_TOKEN", "TWILIO_VERIFY_SERVICE_SID"],
}).https.onRequest(async (req, res) => {
  Object.entries(OTP_CORS).forEach(([k, v]) => res.set(k, v));
  if (req.method === "OPTIONS") { res.status(204).send(""); return; }

  const { phone, countryCode } = req.body || {};
  if (!phone) { res.status(400).json({ success: false, error: "phone requerido" }); return; }

  try {
    // Buscar usuario por teléfono
    const snap = await admin.firestore().collection("users")
      .where("phone", "==", String(phone).trim()).limit(1).get();
    if (snap.empty) { res.status(404).json({ success: false, error: "Cuenta no encontrada" }); return; }
    const user = snap.docs[0].data();
    const email = user.email;
    const fullPhone = normalizePhone(phone, countryCode || user.countryCode);

    let emailSent = false; let smsSent = false;

    // 1. Correo con código propio guardado en otp_codes
    if (email) {
      const code = Math.floor(100000 + Math.random() * 900000).toString();
      const now = admin.firestore.Timestamp.now();
      const expiresAt = admin.firestore.Timestamp.fromMillis(now.toMillis() + 10 * 60 * 1000);
      await admin.firestore().collection("otp_codes").add({
        email: email.toLowerCase().trim(), phone: String(phone).trim(),
        code, createdAt: now, expiresAt, used: false,
      });
      try {
        const transporter = createTransporter();
        await transporter.sendMail({
          from: `"El Desembale" <${process.env.SMTP_EMAIL}>`,
          to: email,
          subject: "Código de verificación - El Desembale",
          html: `<div style="font-family:Arial,sans-serif;max-width:480px;margin:0 auto;padding:32px;background:#0d1712;border-radius:12px;color:#f4f7f1;">
            <h2 style="color:#a8d08d;text-align:center;margin-bottom:8px;">El Desembale</h2>
            <p style="color:#c7d0c8;text-align:center;">Tu código de verificación es:</p>
            <div style="text-align:center;margin:24px 0;"><span style="font-size:34px;font-weight:bold;letter-spacing:8px;color:#0d1712;background:#a8d08d;padding:14px 28px;border-radius:8px;display:inline-block;">${code}</span></div>
            <p style="color:#92a097;text-align:center;font-size:13px;">Expira en 10 minutos. No lo compartas con nadie.</p>
          </div>`,
        });
        emailSent = true;
      } catch (e) { console.error("OTP email error", e); }
    }

    // 2. SMS vía Twilio Verify (código propio de Twilio)
    try {
      const client = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
      await client.verify.v2.services(process.env.TWILIO_VERIFY_SERVICE_SID)
        .verifications.create({ to: fullPhone, channel: "sms" });
      smsSent = true;
    } catch (e) { console.error("OTP sms error", e?.message || e); }

    res.json({ success: emailSent || smsSent, emailSent, smsSent, email });
  } catch (e) {
    console.error("sendRecoveryOtp error", e);
    res.status(500).json({ success: false, error: "Error enviando el código" });
  }
});

// Verifica el código contra el correo (otp_codes) o el SMS (Twilio Verify)
exports.verifyRecoveryOtp = functions.runWith({
  secrets: ["TWILIO_ACCOUNT_SID", "TWILIO_AUTH_TOKEN", "TWILIO_VERIFY_SERVICE_SID"],
}).https.onRequest(async (req, res) => {
  Object.entries(OTP_CORS).forEach(([k, v]) => res.set(k, v));
  if (req.method === "OPTIONS") { res.status(204).send(""); return; }

  const { phone, email, code, countryCode } = req.body || {};
  if (!code || (!phone && !email)) {
    res.status(400).json({ success: false, error: "code y (phone o email) requeridos" });
    return;
  }

  // 1. Verificar contra el código de correo en otp_codes
  if (email) {
    try {
      const now = admin.firestore.Timestamp.now();
      const snap = await admin.firestore().collection("otp_codes")
        .where("email", "==", email.toLowerCase().trim())
        .where("code", "==", String(code).trim())
        .where("used", "==", false).get();
      const valid = snap.docs.find((d) => d.data().expiresAt.toMillis() > now.toMillis());
      if (valid) {
        await valid.ref.update({ used: true });
        res.json({ success: true, channel: "email" });
        return;
      }
    } catch (e) { console.error("verify email error", e); }
  }

  // 2. Verificar contra Twilio Verify (SMS)
  if (phone) {
    try {
      const client = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
      const check = await client.verify.v2.services(process.env.TWILIO_VERIFY_SERVICE_SID)
        .verificationChecks.create({ to: normalizePhone(phone, countryCode), code: String(code).trim() });
      if (check.status === "approved") {
        res.json({ success: true, channel: "sms" });
        return;
      }
    } catch (e) { console.error("verify sms error", e?.message || e); }
  }

  res.json({ success: false, error: "Código inválido o expirado" });
});
