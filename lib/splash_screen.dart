import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  // مؤقت لعرض الصورة لمدة 3 ثوانٍ ثم الانتقال
  void _startTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    // فحص حالة المستخدم لتوجيهه للوجهة الصحيحة
    User? user = FirebaseAuth.instance.currentUser;
    Widget nextScreen = (user != null) ? const DashboardScreen() : const OnboardingScreen();

    // الانتقال الناعم (Fade Transition)
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // لا نحتاج للون خلفية هنا لأن الصورة ستغطي الشاشة بالكامل
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          'assets/fonts/images/splash_bg.png', // تأكد من اسم صورتك هنا
          fit: BoxFit.cover, // هذا هو السر: يجعل الصورة تغطي كامل الشاشة بذكاء ودون حواف فارغة
        ),
      ),
    );
  }
}
