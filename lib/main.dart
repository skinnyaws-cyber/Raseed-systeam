import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // إضافة مكتبة المصادقة
import 'firebase_options.dart';
import 'onboarding_screen.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart'; // تأكد من استيراد الشاشة الرئيسية

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // محاولة تهيئة فايربيس
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error (ignored if duplicate): $e");
  }

  runApp(const RaseedApp());
}

class RaseedApp extends StatelessWidget {
  const RaseedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'رصيد',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF50C878),
        fontFamily: 'IBMPlexSansArabic',
        useMaterial3: true,
      ),
      // نلغي initialRoute ونستخدم home بدلاً منها لتطبيق المنطق
      home: const AuthWrapper(), 
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const SignUpScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}

// === كلاس جديد وظيفته توجيه المستخدم ===
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // التحقق من حالة المستخدم الحالي
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // إذا كان هناك بيانات للمستخدم (يعني مسجل دخول)
        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen(); // اذهب للرئيسية فوراً
        }
        // غير مسجل دخول؟ اذهب لشاشة البداية
        return const OnboardingScreen();
      },
    );
  }
}
