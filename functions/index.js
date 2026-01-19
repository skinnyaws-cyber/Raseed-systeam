const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

const transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 465,
    secure: true,
    auth: {
        user: 'payrassed@gmail.com', // بريدك
        pass: 'ldbq coan zidk njkt'  // الـ App Password
    }
});

exports.sendRecoveryCode = functions.https.onCall(async (request) => {
    const email = request.data.email || request.data;
    const code = request.data.code;

    const htmlContent = `
    <div dir="rtl" style="font-family: 'Segoe UI', Tahoma, sans-serif; max-width: 500px; margin: 40px auto; background-color: #ffffff; border-radius: 15px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.1); border: 1px solid #eee;">
        <div style="background-color: #00796b; height: 120px;"></div>
        <div style="text-align: center; margin-top: -60px;">
            <img src="https://j.top4top.io/s_3671afl9v1.jpg" alt="Raseed Logo" style="width: 110px; height: 110px; border-radius: 50%; border: 5px solid #ffffff; box-shadow: 0 4px 10px rgba(0,0,0,0.1); object-fit: cover;">
        </div>
        <div style="padding: 30px; text-align: center;">
            <h2 style="color: #00796b; margin-bottom: 10px;">تحقق من حسابك</h2>
            <p style="color: #555; font-size: 16px; line-height: 1.5;">عزيزي مستخدم <strong>رصيد</strong>، استخدم الرمز التالي لإعادة تعيين كلمة المرور الخاصة بك:</p>
            <div style="margin: 30px auto; padding: 15px; background-color: #f8fafc; border: 2px dashed #00796b; border-radius: 10px; width: fit-content;">
                <span style="font-size: 32px; font-weight: bold; letter-spacing: 8px; color: #00796b;">${code}</span>
            </div>
            <p style="color: #888; font-size: 13px;">هذا الرمز صالح لمدة 15 دقيقة فقط. إذا لم تطلب هذا الرمز، يرجى تجاهل الرسالة.</p>
        </div>
        <div style="background-color: #f1f5f9; padding: 15px; text-align: center; font-size: 12px; color: #94a3b8;">
            &copy; 2026 تطبيق رصيد - أمان وسهولة في التعامل
        </div>
    </div>
    `;

    try {
        await transporter.sendMail({
            from: '"RaseedPay - خدمة رصيد" <YOUR_EMAIL@gmail.com>',
            to: email,
            subject: '🔐 رمز التحقق الخاص بحسابك',
            html: htmlContent
        });
        return { success: true };
    } catch (error) {
        throw new functions.https.HttpsError('internal', error.message);
    }
});

exports.updateUserPassword = functions.https.onCall(async (request) => {
    const { email, newPassword } = request.data;
    try {
        const userRecord = await admin.auth().getUserByEmail(email);
        await admin.auth().updateUser(userRecord.uid, { password: newPassword });

        const userQuery = await admin.firestore().collection('users').where('recovery_email', '==', email).get();
        if (!userQuery.empty) {
            await admin.firestore().collection('users').doc(userQuery.docs[0].id).update({
                password: newPassword,
                temp_otp: null
            });
        }
        return { success: true };
    } catch (error) {
        throw new functions.https.HttpsError('internal', error.message);
    }
});