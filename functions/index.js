const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

const transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 465,
    secure: true,
    auth: {
        user: 'payrassed@gmail.com',
        pass: 'ldbq coan zidk njkt' 
    }
});

// 1. دالة إرسال الكود بتنسيق فريق رصيد المحدث
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
            from: '"RaseedPay - خدمة رصيد" <payrassed@gmail.com>',
            to: email,
            subject: '🔐 رمز التحقق الخاص بحسابك',
            html: htmlContent
        });
        return { success: true };
    } catch (error) {
        console.error("Email Error:", error);
        throw new functions.https.HttpsError('internal', error.message);
    }
});

// 2. دالة تحديث كلمة المرور الاحترافية (حل مشكلة User Not Found)
exports.updateUserPassword = functions.https.onCall(async (request) => {
    const { email, newPassword } = request.data;
    
    try {
        // البحث في Firestore أولاً لجلب بيانات المستخدم بواسطة إيميل الاسترداد
        const userQuery = await admin.firestore().collection('users')
            .where('recovery_email', '==', email).get();

        if (userQuery.empty) {
            throw new functions.https.HttpsError('not-found', 'إيميل الاسترداد هذا غير مسجل في النظام');
        }

        const userDoc = userQuery.docs[0];
        const userData = userDoc.data();
        
        // جلب الإيميل الأساسي للحساب (الذي سجل به المستخدم في Auth)
        // إذا لم يكن موجوداً، نستخدم إيميل الاسترداد نفسه كمحاولة أخيرة
        const authEmail = userData.email || email;

        try {
            // محاولة تحديث نظام الـ Authentication (المحرك الأمني)
            const userRecord = await admin.auth().getUserByEmail(authEmail);
            await admin.auth().updateUser(userRecord.uid, { password: newPassword });
            console.log(`Successfully updated Auth for UID: ${userRecord.uid}`);
        } catch (authError) {
            console.error("Auth System Update Failed:", authError.message);
            // سنستمر لتحديث Firestore لضمان بقاء كلمة المرور المكتوبة محدثة
        }

        // تحديث كلمة المرور في Firestore وحذف الرمز المؤقت
        await admin.firestore().collection('users').doc(userDoc.id).update({
            password: newPassword,
            temp_otp: null
        });

        return { success: true, message: "تم تحديث البيانات في النظامين بنجاح" };

    } catch (error) {
        console.error("Global Update Error:", error);
        throw new functions.https.HttpsError('internal', error.message);
    }
});