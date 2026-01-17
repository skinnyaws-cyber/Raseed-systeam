import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'verify_code_screen.dart'; // سنقوم بإنشائها في الخطوة القادمة

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  // دالة التحقق من وجود الإيميل في قاعدة البيانات
  Future<void> _verifyEmailAndSendCode() async {
    setState(() => _isLoading = true);
    
    try {
      String email = _emailController.text.trim();
      
      // البحث عن المستخدم الذي يملك هذا الإيميل في Firestore
      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('recovery_email', isEqualTo: email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        // إذا وجدنا الإيميل، ننتقل لواجهة إدخال الرمز
        // ملاحظة: هنا يجب إرسال إيميل حقيقي لاحقاً، حالياً سننتقل للواجهة التالية
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyCodeScreen(email: email),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("عذراً، هذا الإيميل غير مرتبط بأي حساب")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ في الاتصال بقاعدة البيانات")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(Icons.lock_reset_rounded, size: 80, color: Colors.teal.shade700),
            const SizedBox(height: 30),
            const Text('استعادة كلمة المرور', 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Text(
              'أدخل إيميل الاسترداد المرتبط بحسابك، وسنقوم بإرسال رمز التحقق إليه',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 40),
            
            // حقل الإيميل
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'إيميل الاسترداد',
                prefixIcon: Icon(Icons.email_outlined, color: Colors.teal.shade700),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), 
                  borderSide: BorderSide(color: Colors.teal.shade700, width: 1)
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyEmailAndSendCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('إرسال رمز التحقق', 
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
