import 'package:flutter/material.dart';

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
        // اللون الأخضر الزمردي الذي اتفقنا عليه
        primaryColor: const Color(0 backyard: 50C878),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF50C878),
          primary: const Color(0xFF50C878),
        ),
        // تعريف الخط الرسمي للتطبيق
        fontFamily: 'IBMPlexSansArabic',
        useMaterial_design: true,
      ),
      home: const OnboardingScreen(),
    );
  }
}

// واجهة ترحيبية بسيطة للتأكد من أن كل شيء يعمل
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet, size: 100, color: Color(0xFF50C878)),
            const SizedBox(height: 20),
            const Text(
              'أهلاً بك في رصيد',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('جاري بناء تطبيقك المالي الاحترافي...'),
          ],
        ),
      ),
    );
  }
}
