import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart'; // تأكد من أن هذا الملف موجود
import 'onboarding_screen.dart'; // تأكد من أن هذا الملف موجود

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // متغير للتحكم في شفافية الشعار (يبدأ مخفياً)
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    
    // 1. بدء تأثير الظهور (Fade In) بعد وقت قصير جداً من فتح الصفحة
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0; // يصبح ظاهراً بالكامل
        });
      }
    });

    // 2. بدء عملية الانتقال للصفحة التالية
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // الانتظار لمدة 3 ثواني لكي يرى المستخدم الشعار
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // التحقق من حالة المستخدم
    User? user = FirebaseAuth.instance.currentUser;
    
    // إذا كان مسجلاً يذهب للرئيسية، وإلا يذهب لشاشة الترحيب
    Widget nextScreen = (user != null) ? const DashboardScreen() : const OnboardingScreen();

    // الانتقال السلس (Fade Transition)
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800), // مدة الانتقال
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // اللون الأخضر المينيماليست الموحد (مطابق لإعدادات النظام)
      backgroundColor: const Color(0xFF50878C),
      
      body: Center(
        // الشعار يظهر بتأثير شفافية ناعم
        child: AnimatedOpacity(
          duration: const Duration(seconds: 2), // الشعار يأخذ ثانيتين ليظهر بالكامل
          opacity: _opacity,
          curve: Curves.easeOut, // منحنى حركة ناعم
          child: Image.asset(
            'assets/fonts/images/logo.png', // تأكد من وجود الصورة بهذا المسار
            width: 180, // حجم متوسط وأنيق للشعار
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // في حال لم تكن الصورة موجودة بعد، يظهر نص مؤقت
              return const Text(
                "RaseedPay",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBMPlexSansArabic',
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
