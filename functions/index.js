const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

// إعداد الناقل مع Gmail
const transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 465,
    secure: true, // استخدام SSL
    auth: {
        user: 'payrassed@gmail.com', // بريدك الإلكتروني
        pass: 'ldbq coan zidk njkt'  // كود الـ App Password المكون من 16 حرفاً
    },
    tls: {
        rejectUnauthorized: false // لتجنب مشاكل الشهادات في البيئة السحابية
    }
});

exports.sendRecoveryCode = functions.https.onCall(async (data, context) => {
    const email = data.email;
    const code = data.code;

    const mailOptions = {
        from: '"رصيد الزمردي" <YOUR_EMAIL@gmail.com>',
        to: email,
        subject: 'رمز استعادة كلمة المرور',
        text: `رمز التحقق الخاص بك هو: ${code}`,
        html: `<b>رمز التحقق الخاص بك هو: ${code}</b>`
    };

    try {
        await transporter.sendMail(mailOptions);
        return { success: true };
    } catch (error) {
        console.error("Detailed Email Error:", error); // هذا سيطبع السبب الحقيقي في الـ Logs
        throw new functions.https.HttpsError('internal', error.message);
    }
});