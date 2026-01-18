import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // مكتبة قاعدة البيانات
import 'reset_password_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  // دالة التحقق من الرمز الحقيقي من Firestore
  Future<void> _verifyCode() async {
    String enteredCode = _codeController.text.trim();
    if (enteredCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال رمز التحقق")),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // 1. البحث عن سجل المستخدم باستخدام إيميل الاسترداد
      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('recovery_email', isEqualTo: widget.email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        var userData = userQuery.docs.first.data();
        String? actualCode = userData['temp_otp']; // جلب الرمز المرسل فعلياً

        // 2. مقارنة الرمز المدخل بالرمز الموجود في السيرفر
        if (enteredCode == actualCode) {
          if (mounted) {
            // الانتقال لواجهة تعيين كلمة مرور جديدة
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordScreen(email: widget.email),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("الرمز الذي أدخلته غير صحيح")),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("فشل العثور على بيانات المستخدم")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ أثناء التحقق: $e")),
        );
      }
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
          children: [
            const SizedBox(height: 20),
            Icon(Icons.mark_email_read_outlined, size: 80, color: Colors.teal.shade700),
            const SizedBox(height: 30),
            const Text('تحقق من بريدك', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(
              'أدخل الرمز المكون من 6 أرقام والذي أرسلناه إلى\n${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 40),
            
            // حقل إدخال الرمز
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
              inputFormatters: [
                LengthLimitingTextInputFormatter(6),
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: '000000',
                hintStyle: TextStyle(color: Colors.grey.shade300),
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
                onPressed: _isLoading ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('تحقق الآن', 
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // هنا يمكن إعادة استدعاء دالة الإرسال من الواجهة السابقة إذا أردت
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("يرجى العودة للخطوة السابقة لإعادة إرسال الرمز")),
                );
              },
              child: Text('إعادة إرسال الرمز', style: TextStyle(color: Colors.teal.shade700)),
            ),
          ],
        ),
      ),
    );
  }
}
