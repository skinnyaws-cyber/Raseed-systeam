import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'onboarding_screen.dart';
import 'signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // نحاول تهيئة فايربيس
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // إذا كان الخطأ بسبب أن النظام قام بالتهيئة مسبقاً، نتجاهله ونكمل
    if (e.toString().contains('duplicate') || e.toString().contains('already exists')) {
      debugPrint("Firebase initialized by Native side, proceeding...");
    } else {
      // إذا كان خطأ آخر، اطبعه (أو اظهر شاشة الخطأ إذا أردت)
      debugPrint("Error initializing Firebase: $e");
    }
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
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const SignUpScreen(),
      },
    );
  }
}
