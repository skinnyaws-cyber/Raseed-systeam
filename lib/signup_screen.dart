import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ضروري لمنع إدخال الأحرف
import 'dashboard_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  bool _isTermsAccepted = false; // حالة الموافقة على الشروط
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage; // لعرض رسالة خطأ الرقم

  // دالة التحقق من الرقم (استبعاد كورك وقبول آسيا وزين)
  bool _validateIraqiNumber(String value) {
    if (value.isEmpty) {
      setState(() => _errorMessage = null);
      return false;
    }
    
    // استبعاد شركة كورك (تبدأ بـ 075 أو 75)
    if (value.startsWith('075') || value.startsWith('75')) {
      setState(() => _errorMessage = "نعتذر، الخدمة لا تدعم أرقام شركة كورك حالياً");
      return false;
    }
    
    // قبول آسيا سيل وزين العراق فقط (المقدمات: 077, 77, 078, 78, 079, 79)
    RegExp activeNetworks = RegExp(r'^(077|77|078|78|079|79)');
    if (!activeNetworks.hasMatch(value)) {
      setState(() => _errorMessage = "يرجى إدخال رقم آسيا سيل أو زين العراق صحيح");
      return false;
    }

    setState(() => _errorMessage = null);
    return true;
  }

  // دالة لإظهار نافذة البنود والشروط
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('بنود وشروط الاستخدام', 
          textAlign: TextAlign.center, 
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'مرحباً بك في نظام رصيد الزمردي. باستخدامك لهذا التطبيق، أنت توافق على البنود التالية:\n\n'
                '1. الالتزام بكافة القوانين المحلية المعمول بها في العراق.\n'
                '2. التطبيق غير مسؤول عن التحويلات الخاطئة الناتجة عن إدخال أرقام هواتف غير صحيحة.\n'
                '3. يحق لإدارة التطبيق حظر أي حساب يثبت تلاعبه بنظام النقاط أو مشاهدة الإعلانات بطرق غير شرعية.\n'
                '4. يتم معالجة الطلبات المالية خلال أوقات العمل الرسمية فقط.\n'
                '5. خصوصية بياناتك محمية ولن يتم مشاركتها مع أي طرف ثالث.\n\n'
                'ملاحظة: يمكنك تعديل هذه البنود لاحقاً من الكود.',
                style: TextStyle(fontSize: 14, height: 1.5, fontFamily: 'Cairo'),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('فهمت ذلك', style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Icon(Icons.person_add_outlined, size: 80, color: Colors.teal.shade700),
              const SizedBox(height: 20),
              const Text('إنشاء حساب جديد', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 10),
              const Text('انضم إلى نظام رصيد الزمردي وابدأ بإدارة أموالك', 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),

              // حقل الاسم
              _buildTextField(
                controller: _nameController,
                label: 'الاسم الكامل', 
                icon: Icons.person_outline
              ),
              const SizedBox(height: 20),

              // حقل الهاتف مع العلم ومنطق الفحص
              _buildPhoneField(),
              
              const SizedBox(height: 20),

              // حقل كلمة المرور
              _buildTextField(
                controller: _passwordController,
                label: 'كلمة المرور',
                icon: Icons.lock_outline,
                isPassword: true,
                isVisible: _isPasswordVisible,
                onToggleVisibility: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
              
              const SizedBox(height: 20),

              // مربع شروط الاستخدام التفاعلي
              _buildTermsCheckbox(),

              const SizedBox(height: 30),

              // زر إنشاء الحساب
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (_isTermsAccepted && _errorMessage == null && _phoneController.text.isNotEmpty) 
                  ? () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      );
                  } : null, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text('إنشاء الحساب', 
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('لديك حساب بالفعل؟'),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('تسجيل الدخول', 
                      style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // حقل الهاتف مع علم العراق ومنع الحروف
  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
          onChanged: (v) => _validateIraqiNumber(v),
          decoration: InputDecoration(
            labelText: 'رقم الهاتف',
            errorText: _errorMessage,
            prefixIcon: Container(
              width: 95,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Text('🇮🇶', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 5),
                  Text('+964', style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.teal.shade700, width: 1)),
          ),
        ),
      ],
    );
  }

  // ودجت شروط الاستخدام مع رابط قابل للضغط
  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isTermsAccepted,
          activeColor: Colors.teal.shade700,
          onChanged: (value) => setState(() => _isTermsAccepted = value!),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _showTermsDialog,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Cairo'),
                children: [
                  const TextSpan(text: 'أوافق على '),
                  TextSpan(
                    text: 'بنود وشروط الاستخدام وسياسة الخصوصية',
                    style: TextStyle(
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
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
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal.shade700),
        suffixIcon: isPassword 
            ? IconButton(icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off), onPressed: onToggleVisibility)
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.teal.shade700, width: 1)),
      ),
    );
  }
}
