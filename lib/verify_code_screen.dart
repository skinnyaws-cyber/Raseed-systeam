import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'reset_password_screen.dart'; // الواجهة التي سننشئها في الخطوة التالية

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  void _verifyCode() {
    setState(() => _isLoading = true);
    
    // محاكاة التحقق من الرمز
    // في التطبيق الحقيقي، نقوم بمقارنة الرمز المدخل مع الرمز المرسل للإيميل
    String enteredCode = _codeController.text.trim();
    
    Future.delayed(const Duration(seconds: 1), () {
      if (enteredCode == "123456") { // الرمز الافتراضي للتجربة حالياً
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(email: widget.email),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("الرمز الذي أدخلته غير صحيح")),
        );
      }
      if (mounted) setState(() => _isLoading = false);
    });
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
            const Text('تحقق من الرمز', 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(
              'تم إرسال رمز التحقق إلى:\n${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 40),
            
            // حقل إدخال الرمز
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 10),
              inputFormatters: [
                LengthLimitingTextInputFormatter(6), // تحديد الطول بـ 6 أرقام
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: '------',
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم إعادة إرسال الرمز للإيميل")),
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
