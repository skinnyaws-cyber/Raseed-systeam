import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'dashboard_screen.dart'; // تأكد من استيراد الواجهة الرئيسية
import 'login_screen.dart';     // تأكد من استيراد واجهة تسجيل الدخول

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _starAnimation;

  // نص الشعار
  final String textPart1 = "Raseed";
  final String textPart2 = "Pay";

  @override
  void initState() {
    super.initState();
    
    // زيادة مدة الأنيميشن لتسمح بظهور الحروف براحة (3.5 ثانية)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // النجمة تنتهي عند 60% من وقت الأنيميشن
    _starAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.60, curve: Curves.easeInOutQuart),
    );

    _controller.forward();

    // الانتقال للصفحة التالية بعد انتهاء العرض
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 5)); // انتظار كافٍ لرؤية الشعار

    if (!mounted) return;

    User? user = FirebaseAuth.instance.currentUser;
    Widget nextScreen = (user != null) ? const DashboardScreen() : const LoginScreen();

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF004D40), // أخضر غامق جداً
              Color(0xFF00695C), 
              Color(0xFF50878C), // الزمردي
            ],
            stops: [0.2, 0.6, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. رسم النجمة
              AnimatedBuilder(
                animation: _starAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(140, 140),
                    painter: GeometricStarPainter(progress: _starAnimation.value),
                  );
                },
              ),
              const SizedBox(height: 40),
              
              // 2. رسم النص حرفاً بحرف
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الجزء الأول: Raseed (بالأبيض)
                  ..._buildAnimatedLetters(textPart1, Colors.white, 0),
                  // الجزء الثاني: Pay (بالأخضر النيون)
                  ..._buildAnimatedLetters(textPart2, const Color(0xFFCCFF00), textPart1.length),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة بناء الحروف المتحركة
  List<Widget> _buildAnimatedLetters(String text, Color color, int startIndex) {
    List<Widget> letters = [];
    
    // بدء ظهور الحروف بعد النجمة (بعد 0.60)
    double startTime = 0.60;
    // الزمن بين كل حرف وحرف (سرعة الكتابة)
    double step = 0.04; 

    for (int i = 0; i < text.length; i++) {
      // حساب توقيت كل حرف
      double start = startTime + ((startIndex + i) * step);
      double end = start + 0.2; // مدة ظهور الحرف الواحد
      if (end > 1.0) end = 1.0;

      final Animation<double> opacityAnim = CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      );

      final Animation<Offset> slideAnim = Tween<Offset>(
        begin: const Offset(0, 0.5), // يأتي من الأسفل قليلاً
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      ));

      letters.add(
        FadeTransition(
          opacity: opacityAnim,
          child: SlideTransition(
            position: slideAnim,
            child: Text(
              text[i],
              style: TextStyle(
                fontFamily: 'IBMPlexSans', // الخط المستخدم في تطبيقك
                fontSize: 34,
                fontWeight: FontWeight.w600, // وزن شبه عريض للفخامة
                color: color,
                letterSpacing: 1.2, // تباعد بسيط للأناقة
              ),
            ),
          ),
        ),
      );
    }
    return letters;
  }
}

// --- الرسام الهندسي (كما هو) ---
class GeometricStarPainter extends CustomPainter {
  final double progress;
  GeometricStarPainter({required this.progress});

  final Color lineColor = const Color(0xFFCCFF00); 

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double mapX(double x) => (x / 100) * size.width;
    double mapY(double y) => size.height - ((y / 100) * size.height); 

    final List<List<double>> lines = [
      [48, 50, 48, 90], [50, 50, 50, 90], [52, 50, 52, 90],
      [48, 50, 48, 10], [50, 50, 50, 10], [52, 50, 52, 10],
      [50, 48, 90, 48], [50, 50, 90, 50], [50, 52, 90, 52],
      [50, 48, 10, 48], [50, 50, 10, 50], [50, 52, 10, 52],
      [50, 50, 82, 82], [48, 50, 80, 84], [52, 50, 84, 80],
      [50, 50, 18, 82], [48, 50, 20, 84], [52, 50, 16, 80],
      [50, 50, 82, 18], [48, 50, 80, 16], [52, 50, 84, 20],
      [50, 50, 18, 18], [48, 50, 20, 16], [52, 50, 16, 20],
    ];

    for (var line in lines) {
      double startX = mapX(line[0]);
      double startY = mapY(line[1]);
      double endX = mapX(line[2]);
      double endY = mapY(line[3]);

      double currentEndX = startX + (endX - startX) * progress;
      double currentEndY = startY + (endY - startY) * progress;

      if (progress > 0) {
        canvas.drawLine(
          Offset(startX, startY),
          Offset(currentEndX, currentEndY),
          paint,
        );
      }
    }
    
    if (progress > 0.8) {
      final Paint glowPaint = Paint()
        ..color = Colors.white.withOpacity((progress - 0.8) * 2) 
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(mapX(50), mapY(50)), 5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GeometricStarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
