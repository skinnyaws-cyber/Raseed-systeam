import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ضروري لمنع إدخال الأحرف
import 'dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController _phoneController = TextEditingController();
  String? _errorMessage; // لعرض رسالة خطأ الرقم

  // دالة التحقق من الرقم (استبعاد كورك وقبول آسيا وزين)
  bool _validateIraqiNumber(String value) {
    if (value.isEmpty) {
      setState(() => _errorMessage = null);
      return false;
    }
    
    // استبعاد شركة كورك (تبدأ بـ 075 أو 75)
    if (value.startsWith('075') || value.startsWith('75')) {
      setState(() => _errorMessage = "نعتذر، الخدمة لا تدعم أرقام شركة كورك");
      return false;
    }
    
    // قبول آسيا سيل وزين العراق فقط
    RegExp activeNetworks = RegExp(r'^(077|77|078|78|079|79)');
    if (!activeNetworks.hasMatch(value)) {
      setState(() => _errorMessage = "يرجى إدخال رقم آسيا سيل أو زين صحيح");
      return false;
    }

    setState(() => _errorMessage = null);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الشعار (Emerald Logo)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle),
                child: Icon(Icons.account_balance_wallet_rounded, size: 60, color: Colors.teal.shade700),
              ),
              const SizedBox(height: 30),
              Text('مرحباً بك مجدداً', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal.shade900)),
              const SizedBox(height: 10),
              const Text('سجل دخولك للمتابعة في نظام رصيد', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),

              // حقل الهاتف المطور (نفس منطق واجهة التسجيل)
              _buildPhoneField(),
              
              const SizedBox(height: 20),

              _buildInput(
                label: 'كلمة المرور',
                icon: Icons.lock_outline,
                isPassword: true,
                isVisible: _isPasswordVisible,
                onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(onPressed: () {}, child: const Text('نسيت كلمة المرور؟')),
              ),
              const SizedBox(height: 20),

              // زر تسجيل الدخول
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (_errorMessage == null && _phoneController.text.isNotEmpty) ? () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('تسجيل الدخول', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ليس لديك حساب؟'),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                    child: Text('اشترك الآن', style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ودجت حقل الهاتف مع علم العراق
  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly], // أرقام فقط
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
    );
  }

  Widget _buildInput({required String label, required IconData icon, bool isPassword = false, bool isVisible = false, VoidCallback? onToggleVisibility}) {
    return TextField(
      obscureText: isPassword && !isVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal.shade700),
        suffixIcon: isPassword ? IconButton(icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off), onPressed: onToggleVisibility) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.teal.shade700, width: 1)),
      ),
    );
  }
}
