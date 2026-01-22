import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // ملف الإعدادات الخاص بك
import 'onboarding_screen.dart';
import 'signup_screen.dart';

void main() async {
  // 1. التأكد من تهيئة الودجتس
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // === التعديل الجديد (الحل لمشكلة Duplicate App) ===
    // نتحقق أولاً: هل فايربيس تم تشغيله بالفعل؟
    if (Firebase.apps.isEmpty) {
      // إذا لم يكن يعمل، قم بتهيئته
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      // إذا كان يعمل مسبقاً، تخطى هذه الخطوة (وهذا ما سيمنع الخطأ)
      debugPrint('Firebase was already initialized! Skipping re-initialization.');
    }
    // =================================================

    // 2. تشغيل تطبيقك الأصلي
    runApp(const RaseedApp());
    
  } catch (e, stackTrace) {
    // 3. في حال حدث أي خطأ آخر، اعرض شاشة الخطأ بدلاً من الشاشة البيضاء
    runApp(ErrorApp(errorMessage: e.toString(), stackTrace: stackTrace.toString()));
  }
}

// === تطبيقك الأصلي (كما هو تماماً) ===
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

// === شاشة كشف الأخطاء (للاحتياط) ===
class ErrorApp extends StatelessWidget {
  final String errorMessage;
  final String stackTrace;

  const ErrorApp({super.key, required this.errorMessage, required this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[50],
        appBar: AppBar(
          title: const Text("Startup Error ⚠️"), 
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "حدث خطأ أثناء تشغيل التطبيق:", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  errorMessage,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              const Divider(height: 30),
              const Text("التفاصيل التقنية:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              SelectableText(
                stackTrace, 
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
