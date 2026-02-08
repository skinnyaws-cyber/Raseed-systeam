import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart'; // المكتبة المطلوبة لتشغيل الفيديو
import 'dashboard_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  // تهيئة مشغل الفيديو وتشغيله تلقائياً
  void _initializeVideo() {
    _controller = VideoPlayerController.asset('assets/fonts/images/logo_motion.MOV')
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play(); // بدء التشغيل فور الجاهزية
        
        // ضبط وقت الانتظار لمدة 6 ثوانٍ (مدة الفيديو) قبل الانتقال
        Future.delayed(const Duration(seconds: 6), () {
          _navigateToNextScreen();
        });
      });
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    // التحقق من حالة المستخدم: مسجل دخول أم مستخدم جديد 
    User? user = FirebaseAuth.instance.currentUser;
    Widget nextScreen = (user != null) ? const DashboardScreen() : const OnboardingScreen();

    // الانتقال المباشر مع تأثير تلاشي ناعم [cite: 441]
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1000), // تلاشي لمدة ثانية واحدة لراحة العين
      ),
    );
  }

  @override
  void dispose() {
    // إغلاق مشغل الفيديو لتحرير الذاكرة
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // التعديل: تغيير لون الخلفية إلى الأخضر المشع المطلوب
      backgroundColor: const Color(0xFFCCFF00),
      
      body: Center(
        child: _isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const SizedBox(), // يظهر فراغ بسيط أثناء التحميل الأولي (جزء من الثانية)
      ),
    );
  }
}
