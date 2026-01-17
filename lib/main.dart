import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // إضافة مكتبة فيربيز الأساسية
import 'firebase_options.dart'; // إضافة ملف الإعدادات الذي أنشأته
import 'onboarding_screen.dart'; 
import 'signup_screen.dart';     

void main() async {
  // التأكد من أن جميع أدوات فلاتر جاهزة قبل بدء التهيئة
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة تطبيق فيربيز باستخدام الإعدادات اليدوية التي وضعتها
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const SignUpScreen(),
      },
    );
  }
}
