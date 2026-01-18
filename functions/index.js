const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 465,
    secure: true, 
    auth: {
        user: 'payrassed@gmail.com',
        pass: 'ldbq coan zidk njkt' 
    },
    tls: {
        rejectUnauthorized: false
    }
});

exports.sendRecoveryCode = functions.https.onCall(async (request) => {
    // تعديل طريقة استقبال البيانات لضمان عدم وجود "No recipients defined"
    const email = request.data.email || request.data; 
    const code = request.data.code;

    console.log("Attempting to send email to:", email); // لمراقبة الإيميل في الـ Logs

    const mailOptions = {
        from: '"رصيد الزمردي" <YOUR_EMAIL@gmail.com>',
        to: email, // هنا كان الخطأ، الآن سيتم ملؤه بشكل صحيح
        subject: 'رمز استعادة كلمة المرور',
        text: `رمز التحقق الخاص بك هو: ${code}`,
        html: `<b>رمز التحقق الخاص بك هو: ${code}</b>`
    };

    try {
        await transporter.sendMail(mailOptions);
        return { success: true };
    } catch (error) {
        console.error("Detailed Email Error:", error);
        throw new functions.https.HttpsError('internal', error.message);
    }
});