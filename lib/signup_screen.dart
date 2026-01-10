import 'package:flutter/material.dart';
import 'dashboard_screen.dart'; // التأكد من الاستيراد

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;

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
              // أيقونة ترحيبية أو شعار
              Icon(Icons.person_add_outlined, size: 80, color: Colors.teal.shade700),
              const SizedBox(height: 20),
              Text('إنشاء حساب جديد', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal.shade900)),
              const SizedBox(height: 10),
              const Text('انضم إلى نظام رصيد الزمردي وابدأ بإدارة أموالك', 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),

              // حقل الاسم
              _buildTextField(label: 'الاسم الكامل', icon: Icons.person_outline),
              const SizedBox(height: 20),

              // حقل رقم الهاتف
              _buildTextField(label: 'رقم الهاتف', icon: Icons.phone_android_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 20),

              // حقل كلمة المرور
              _buildTextField(
                label: 'كلمة المرور',
                icon: Icons.lock_outline,
                isPassword: true,
                isVisible: _isPasswordVisible,
                onToggleVisibility: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
              const SizedBox(height: 40),

              // زر إنشاء الحساب
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                  ),
                  child: const Text('إنشاء الحساب', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),

              // العودة لتسجيل الدخول
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('لديك حساب بالفعل؟'),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('تسجيل الدخول', style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ودجت بناء حقول الإدخال لتوفير تكرار الكود
  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      obscureText: isPassword && !isVisible,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal.shade700),
        suffixIcon: isPassword 
            ? IconButton(icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off), onPressed: onToggleVisibility)
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.teal.shade700, width: 1)),
      ),
    );
  }
}
