import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart'; // المكتبة الجديدة للاتصال بالسيرفر
import 'dart:math'; // لتوليد الرقم العشوائي
import 'verify_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  // 1. دالة توليد رمز عشوائي من 6 أرقام
  String _generateOTP() {
    var rnd = Random();
    var next = rnd.nextInt(899999) + 100000;
    return next.toString();
  }

  // 2. دالة التحقق من الإيميل وإرسال الرمز عبر السيرفر
  Future<void> _verifyEmailAndSendCode() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى إدخال الإيميل")));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      [cite_start]// البحث عن المستخدم في Firestore [cite: 253]
      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('recovery_email', isEqualTo: email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        // أ. توليد الرمز
        String otpCode = _generateOTP();

        // ب. استدعاء الـ Cloud Function التي قمنا برفعها (sendRecoveryCode)
        HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendRecoveryCode');
        
        final results = await callable.call(<String, dynamic>{
          'email': email,
          'code': otpCode,
        });

        if (results.data['success'] == true) {
          // ج. حفظ الرمز في Firestore تحت سجل المستخدم للتحقق منه لاحقاً
          String docId = userQuery.docs.first.id;
          await FirebaseFirestore.instance.collection('users').doc(docId).update({
            'temp_otp': otpCode,
            'otp_created_at': FieldValue.serverTimestamp(),
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم إرسال الرمز بنجاح")));
            Navigator.push(
              context,
              MaterialPageRoute(
                [cite_start]builder: (context) => VerifyCodeScreen(email: email), // الانتقال لواجهة التحقق [cite: 254]
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          [cite_start]const SnackBar(content: Text("عذراً، هذا الإيميل غير مرتبط بأي حساب [cite: 256]")),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في السيرفر: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ غير متوقع، حاول ثانية")),
      );
    } finally {
      [cite_start]if (mounted) setState(() => _isLoading = false); [cite: 258]
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            [cite_start]Icon(Icons.lock_reset_rounded, size: 80, color: Colors.teal.shade700), [cite: 260]
            const SizedBox(height: 30),
            [cite_start]const Text('استعادة كلمة المرور', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), [cite: 261]
            const SizedBox(height: 15),
            const Text(
              [cite_start]'أدخل إيميل الاسترداد المرتبط بحسابك، وسنقوم بإرسال رمز التحقق إليه [cite: 261]',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              [cite_start]keyboardType: TextInputType.emailAddress, [cite: 263]
              decoration: InputDecoration(
                [cite_start]labelText: 'إيميل الاسترداد', [cite: 263]
                prefixIcon: Icon(Icons.email_outlined, color: Colors.teal.shade700),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                [cite_start]onPressed: _isLoading ? null : _verifyEmailAndSendCode, [cite: 267]
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading 
                    [cite_start]? const CircularProgressIndicator(color: Colors.white) [cite: 269]
                    : const Text('إرسال رمز التحقق', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
