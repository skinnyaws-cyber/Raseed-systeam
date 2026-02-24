import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:upgrader/upgrader.dart'; // إضافة مكتبة التحديث الإجباري
import 'package:firebase_messaging/firebase_messaging.dart'; // إضافة مكتبة الإشعارات
import 'firebase_options.dart';

// استيراد الشاشات
import 'splash_screen.dart'; 
import 'onboarding_screen.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';

// هذه الدالة تعمل في الخلفية حتى لو كان التطبيق مغلقاً تماماً
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // تأكد من تهيئة فايربيس أولاً
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("تم استلام إشعار في الخلفية: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // محاولة تهيئة فايربيس
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // تفعيل مستمع الإشعارات في الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
