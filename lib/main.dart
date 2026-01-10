import 'package:flutter/material.dart';
import 'onboarding_screen.dart'; // استدعاء الملف الجديد

void main() {
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
      home: const OnboardingScreen(), // فتح واجهة الترحيب
    );
  }
}
