import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;

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

              _buildInput(label: 'رقم الهاتف أو البريد', icon: Icons.email_outlined),
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

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('تسجيل الدخول', style: TextStyle(fontSize: 18, color: Colors.white)),
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
      ),
    );
  }
}
