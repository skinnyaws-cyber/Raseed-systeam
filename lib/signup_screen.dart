import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // مكتبة المصادقة [cite: 26]
import 'package:cloud_firestore/cloud_firestore.dart'; // مكتبة قاعدة البيانات [cite: 26]
import 'dashboard_screen.dart'; // [cite: 26]

class SignUpScreen extends StatefulWidget { // [cite: 27]
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> { // [cite: 28]
  bool _isPasswordVisible = false;
  bool _isTermsAccepted = false;
  bool _isLoading = false; // لمتابعة حالة عملية التسجيل [cite: 28, 29]
  
  final TextEditingController _phoneController = TextEditingController(); // [cite: 29]
  final TextEditingController _nameController = TextEditingController(); // [cite: 29]
  final TextEditingController _passwordController = TextEditingController(); // [cite: 30]
  final TextEditingController _emailController = TextEditingController(); // المتحكم الجديد لإيميل الاسترداد
  String? _errorMessage;

  // دالة التحقق من الرقم (استبعاد كورك وقبول آسيا وزين) [cite: 30]
  bool _validateIraqiNumber(String value) {
    if (value.isEmpty) { // [cite: 31]
      setState(() => _errorMessage = null);
      return false;
    }
    if (value.startsWith('075') || value.startsWith('75')) { // [cite: 32]
      setState(() => _errorMessage = "نعتذر، الخدمة لا تدعم أرقام شركة كورك حالياً");
      return false;
    }
    RegExp activeNetworks = RegExp(r'^(077|77|078|78|079|79)'); // [cite: 33]
    if (!activeNetworks.hasMatch(value)) { // [cite: 34]
      setState(() => _errorMessage = "يرجى إدخال رقم آسيا سيل أو زين العراق صحيح");
      return false;
    }
    setState(() => _errorMessage = null);
    return true; // [cite: 35]
  }

  // --- دالة الربط مع Firebase --- [cite: 35]
  Future<void> _handleSignUp() async {
    setState(() => _isLoading = true); // [cite: 35]
    try { // [cite: 36]
      // 1. تحويل رقم الهاتف إلى بريد وهمي للنظام [cite: 36]
      String phoneNumber = _phoneController.text.trim();
      String email = "$phoneNumber@raseed.com"; // [cite: 37]
      String password = _passwordController.text.trim();
      String recoveryEmail = _emailController.text.trim(); // جلب إيميل الاسترداد

      // 2. إنشاء الحساب في Firebase Authentication [cite: 37]
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. تخزين بيانات المستخدم الإضافية في Firestore 
      // سيتم إنشاء جدول 'users' تلقائياً عند أول عملية كتابة 
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'full_name': _nameController.text.trim(),
        'phone_number': phoneNumber,
        'password': password, // حفظ كلمة المرور كما طلبت 
        'recovery_email': recoveryEmail, // حفظ إيميل الاسترداد الجديد
        'uid': userCredential.user!.uid, // 
        'balance': 0.0, // الرصيد الافتراضي عند التسجيل 
        'created_at': FieldValue.serverTimestamp(), // 
      });

      // 4. الانتقال للشاشة الرئيسية بعد النجاح [cite: 39]
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        ); // [cite: 39]
      }
    } on FirebaseAuthException catch (e) { // [cite: 40]
      String message = "حدث خطأ أثناء التسجيل";
      if (e.code == 'email-already-in-use') { // [cite: 41]
        message = "هذا الرقم مسجل مسبقاً، جرب تسجيل الدخول";
      } else if (e.code == 'weak-password') { // [cite: 42]
        message = "كلمة المرور ضعيفة جداً";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))); // [cite: 43]
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("فشل الاتصال بالسيرفر"))); // [cite: 43]
    } finally { // [cite: 44]
      if (mounted) setState(() => _isLoading = false); // [cite: 44]
    }
  }

  void _showTermsDialog() { // [cite: 45]
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('بنود وشروط الاستخدام', 
          textAlign: TextAlign.center, 
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')), // [cite: 45]
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // [cite: 46]
            children: const [
              Text(
                'مرحباً بك في نظام رصيد الزمردي. باستخدامك لهذا التطبيق، أنت توافق على البنود التالية:\n\n'
                '1. الالتزام بكافة القوانين المحلية المعمول بها في العراق.\n'
                '2. التطبيق غير مسؤول عن التحويلات الخاطئة الناتجة عن إدخال أرقام هواتف غير صحيحة.\n'
                '3. يحق لإدارة التطبيق حظر أي حساب يثبت تلاعبه بنظام النقاط.\n'
                '4. يتم معالجة الطلبات المالية خلال أوقات العمل الرسمية فقط.\n'
                '5. خصوصية بياناتك محمية ولن يتم مشاركتها مع أي طرف ثالث.', // [cite: 47, 48]
                style: TextStyle(fontSize: 14, height: 1.5, fontFamily: 'Cairo'),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        actions: [ // [cite: 49]
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('فهمت ذلك', style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold)), // [cite: 49]
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) { // [cite: 50]
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Icon(Icons.person_add_outlined, size: 80, color: Colors.teal.shade700), // [cite: 51]
              const SizedBox(height: 20),
              const Text('إنشاء حساب جديد', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))), // [cite: 51]
              const SizedBox(height: 10),
              const Text('انضم إلى نظام رصيد الزمردي وابدأ بإدارة أموالك', 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)), // [cite: 51, 52]
              const SizedBox(height: 40),

              _buildTextField(
                controller: _nameController,
                label: 'الاسم الكامل', 
                icon: Icons.person_outline
              ), // [cite: 52, 53]
              const SizedBox(height: 20),

              _buildPhoneField(), // [cite: 53]
              const SizedBox(height: 20),

              // حقل إيميل الاسترداد الجديد
              _buildTextField(
                controller: _emailController,
                label: 'إيميل الاسترداد (اختياري)', 
                icon: Icons.email_outlined
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _passwordController,
                label: 'كلمة المرور',
                icon: Icons.lock_outline,
                isPassword: true,
                isVisible: _isPasswordVisible,
                onToggleVisibility: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible); // [cite: 54, 55]
                },
              ),
              const SizedBox(height: 20),

              _buildTermsCheckbox(), // [cite: 55]

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55, // [cite: 56]
                child: ElevatedButton(
                  onPressed: (_isTermsAccepted && _errorMessage == null && _phoneController.text.isNotEmpty && !_isLoading) 
                  ? _handleSignUp : null, 
                  style: ElevatedButton.styleFrom( // [cite: 56, 57]
                    backgroundColor: Colors.teal.shade700,
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ), // [cite: 58]
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('إنشاء الحساب', 
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)), // [cite: 58, 59]
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('لديك حساب بالفعل؟'), // [cite: 60]
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('تسجيل الدخول', 
                      style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold)), // [cite: 61]
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ), // [cite: 62]
      ),
    );
  }

  Widget _buildPhoneField() { // [cite: 63]
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
          onChanged: (v) => _validateIraqiNumber(v),
          decoration: InputDecoration(
            labelText: 'رقم الهاتف', // [cite: 63, 64]
            errorText: _errorMessage,
            prefixIcon: Container(
              width: 95,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Text('🇮🇶', style: TextStyle(fontSize: 20)), // [cite: 65]
                  const SizedBox(width: 5),
                  Text('+964', style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold)), // [cite: 65]
                ],
              ),
            ), // [cite: 66]
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.teal.shade700, width: 1)),
          ),
        ),
      ],
    ); // [cite: 67]
  }

  Widget _buildTermsCheckbox() { // [cite: 67]
    return Row(
      children: [
        Checkbox(
          value: _isTermsAccepted,
          activeColor: Colors.teal.shade700,
          onChanged: (value) => setState(() => _isTermsAccepted = value!),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _showTermsDialog, // [cite: 68]
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Cairo'),
                children: [
                  const TextSpan(text: 'أوافق على '),
                  TextSpan( // [cite: 69]
                    text: 'بنود وشروط الاستخدام وسياسة الخصوصية',
                    style: TextStyle(
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.bold, // [cite: 70]
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ], // [cite: 71]
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
  }) { // [cite: 72]
    return TextField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal.shade700),
        suffixIcon: isPassword // [cite: 73]
            ? IconButton(icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off), onPressed: onToggleVisibility)
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.teal.shade700, width: 1)),
      ),
    ); // [cite: 74]
  }
}
