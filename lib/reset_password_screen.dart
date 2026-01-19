import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart'; // إضافة المكتبة اللازمة للسيرفر
import 'dashboard_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email; 
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // --- الدالة الاحترافية المحدثة ---
  Future<void> _updatePassword() async {
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // 1. التحقق من المدخلات
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يرجى ملء كافة الحقول")));
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("كلمة المرور غير متطابقة")));
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يجب أن تكون كلمة المرور 6 رموز على الأقل")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. استدعاء الدالة الاحترافية من السيرفر (تحدث Auth و Firestore معاً)
      final result = await FirebaseFunctions.instance
          .httpsCallable('updateUserPassword')
          .call({
        "email": widget.email,
        "newPassword": newPassword,
      });

      if (result.data['success'] == true) {
        // 3. نجاح العملية
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم تحديث كلمة المرور بنجاح، يمكنك الآن الدخول")),
          );

          // التوجه للرئيسية مباشرة (أو يمكنك توجيهه لصفحة تسجيل الدخول)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false,
          );
        }
      }
    } on FirebaseFunctionsException catch (e) {
      // التعامل مع أخطاء السيرفر
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل التحديث: ${e.message}")),
      );
    } catch (e) {
      // التعامل مع الأخطاء العامة
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ غير متوقع أثناء التحديث")),
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
        leading: const BackButton(color: Colors.black)
      ),
      body: SingleChildScrollView( // أضفت هذا لضمان عدم حدوث Overflow عند ظهور الكيبورد
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Icon(Icons.security_rounded, size: 80, color: Colors.teal.shade700),
            const SizedBox(height: 30),
            const Text('تعيين كلمة مرور جديدة', 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            
            _buildPasswordField(_newPasswordController, 'كلمة المرور الجديدة'),
            const SizedBox(height: 20),
            _buildPasswordField(_confirmPasswordController, 'تأكيد كلمة المرور'),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('تغيير كلمة المرور', 
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock_outline, color: Colors.teal.shade700),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}