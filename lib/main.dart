import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // ملف الإعدادات الخاص بك
import 'onboarding_screen.dart';
import 'signup_screen.dart';

void main() async {
  // 1. التأكد من تهيئة الودجتس
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. محاولة تهيئة فايربيس داخل بلوك try-catch
    // هذا هو السطر الذي نشك أنه يسبب التعليق
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 3. إذا نجح الاتصال، شغل التطبيق الطبيعي
    runApp(const RaseedApp());
    
  } catch (e, stackTrace) {
    // 4. إذا حدث خطأ، شغل شاشة الخطأ الحمراء بدلاً من الشاشة البيضاء
    runApp(ErrorApp(errorMessage: e.toString(), stackTrace: stackTrace.toString()));
  }
}

// === تطبيقك الأصلي (لم أغير فيه شيئاً) ===
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

// === شاشة كشف الأخطاء (الجديدة) ===
class ErrorApp extends StatelessWidget {
  final String errorMessage;
  final String stackTrace;

  const ErrorApp({super.key, required this.errorMessage, required this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[50], // لون خلفية فاتح
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
                child: SelectableText( // يسمح لك بنسخ النص إذا أردت
                  errorMessage,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              const Divider(height: 30),
              const Text("التفاصيل التقنية (Stack Trace):", style: TextStyle(fontWeight: FontWeight.bold)),
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
