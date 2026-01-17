const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// إعداد حساب الإيميل الذي سيرسل الرسائل (مثلاً Gmail)
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "payrassed@gmail.com", // ضع إيميل التطبيق هنا
    pass: "ldbq coan zidk njkt",    // ضع "كلمة مرور التطبيقات" من جوجل هنا
  },
});

exports.sendRecoveryCode = functions.https.onCall(async (data, context) => {
  const email = data.email;
  const code = data.code;

  const mailOptions = {
    from: "نظام رصيد الزمردي <your-email@gmail.com>",
    to: email,
    subject: "رمز استعادة كلمة المرور",
    html: `
      <div dir="rtl" style="font-family: Arial, sans-serif; text-align: center;">
        <h2>مرحباً بك في نظام رصيد</h2>
        <p>لقد طلبت رمز استعادة كلمة المرور الخاصة بك.</p>
        <h1 style="color: #00796b;">${code}</h1>
        <p>هذا الرمز صالح لفترة قصيرة، لا تشاركه مع أحد.</p>
      </div>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    console.error("Error sending email:", error);
    throw new functions.https.HttpsError("internal", "فشل إرسال الإيميل");
  }
});