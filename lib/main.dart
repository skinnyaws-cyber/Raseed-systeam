import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'onboarding_screen.dart';
import 'signup_screen.dart';

void main() async {
  // 1. تهيئة الودجتس
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تشغيل فايربيس (الآن هذا هو المكان الوحيد الذي يشغله)
  // لن يحدث تضارب Duplicate لأننا عطلنا التلقائي
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. تشغيل التطبيق
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
