import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:upgrader/upgrader.dart'; // إضافة مكتبة التحديث الإجباري
import 'firebase_options.dart';

// استيراد الشاشات
import 'splash_screen.dart'; 
import 'onboarding_screen.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';

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
        // تم التأكد من الاسم بناءً على ملف pubspec الخاص بك
        fontFamily: 'IBMPlexSansArabic',
        useMaterial3: true,
      ),
      // صمام الأمان: إحاطة الشاشة الأولى (SplashScreen) بنافذة التحديث الإجبارية
      home: UpgradeAlert(
        // الخصائص البرمجية
        upgrader: Upgrader(
          messages: UpgraderMessages(code: 'ar'), // واجهة باللغة العربية
        ),
        // خصائص التحكم بالواجهة (تم نقلها إلى هنا في الإصدارات الحديثة)
        showIgnore: false, // إخفاء زر التجاهل
        showLater: false,  // إخفاء زر التحديث لاحقاً
        showReleaseNotes: false, // إخفاء ملاحظات الإصدار (لجعل النافذة أصغر وأجمل)
        barrierDismissible: false, // منع المستخدم من الخروج من النافذة بالضغط خارجها
        child: const SplashScreen(),
      ),
      
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const SignUpScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
