import 'dart:ui';
import 'package:flutter/material.dart';

class TransferInstructionsScreen extends StatefulWidget {
  const TransferInstructionsScreen({super.key});

  @override
  State<TransferInstructionsScreen> createState() => _TransferInstructionsScreenState();
}

class _TransferInstructionsScreenState extends State<TransferInstructionsScreen> {
  // === الألوان المطلوبة ===
  final Color _zainColor = const Color(0xFF570053); // البنفسجي الغامق
  final Color _asiaColor = const Color(0xFF9b0000); // الأحمر الغامق
  final Color _instructionsColor = const Color(0xFF4CAF50); // أخضر عشبي للتعليمات

  // === حالة الواجهة ===
  int _selectedIndex = 0; // 0 = Zain, 1 = Asiacell
  bool _showInstructions = false; // هل نعرض التعليمات الآن؟
  
  late PageController _pageController;

  // بيانات الشركات (الصور والنصوص)
  final List<Map<String, dynamic>> _providers = [
    {
      'name': 'Zain',
      'image': 'assets/fonts/images/zain_info.png',
      'color': const Color(0xFF570053),
      'instructions': [
        "طريقة تحويل الرصيد من خلال تطبيق RaseedPay لمستخدمين زين العراق يتم بالألية الاتية :",
        "اولاً : اختر بطاقة زين العراق من الواجهة الرئيسية",
        "ثانياً : ملئ كل المعلومات لأتمام عملية التحويل",
        "ملاحظة : في الحقل المخصص لأدخال رقم الهاتف تأكد جيداً من كتابة الرقم الصحيح الذي يحتوي على الرصيد الفعلي . مع مراعاة الانتباه ان الرقم المكتوب تابع لنفس الشريحة المدخله في هاتفك",
        "في حال قمت بكتابة رقم مختلف عن الرقم الذي تم تحويل الرصيد من خلاله داخل الحقل المخصص لأدخال الرقم لن تتم معالجة طلبك وستكون عملية غير ناجحة (فشل) .",
        "عند حدوث هكذا اخطاء سهواً يرجى متابعة قسم الدعم الفني بأسرع وقت ممكن للتحقق من حالتك",
        "ثالثاً : بعد اتمام ادخال كل المعلومات داخل بطاقة التحويل اضغط على زر تأكيد الطلب",
        "سوف يتم تحويلك على تطبيق الرسائل SMS لأتمام عملية التحويل من خلال ضغطك على زر ارسال",
        "ملاحظة : عند تحويلك الى تطبيق الرسائل النصية سيتم لصق الرقم المخصص لفريق RaseedPay مع قيمة الرصيد التي ادخلتها في الحقل المخصص",
        "في حال لم تضغط على زر ارسال لن يتم اتمام الطلب ومعالجته ، مثال توضيحي في الصورة ادناه",
        "رابعاً : يجب التنويه كلفة تحويل الرصيد هي 350 دينار من رصيدك داخل الشريحة بالاضافة لقيمة الرصيد الذي تم تحويله من خلال تطبيق RaseedPay ونحن غير مسؤولين عليها هي عمولة تابعة لشركة الاتصالات المذكورة (زين العراق) وغير مسؤولين عن زيادتها او نقصان هذه الكلفة هي تابعة بشكل مباشر لشروط وسياسية شركة الاتصالات داخل العراق",
        "قدر عمولة تحويل الرصيد واستلام مقابله مال على البطاقة البنكية من خلال تطبيق RaseedPay هي 10% من قيمة الرصيد الكلي المرسل والذي تم تأكيد استلامه حصراً (العملية ناجحة). وايضاً تطبق في الحالة المذكورة بالنقطة الاولى من ارشادات تحويل الرصيد"
      ]
    },
    {
      'name': 'Asiacell',
      'image': 'assets/fonts/images/asiacell_info.png',
      'color': const Color(0xFF9b0000),
      'instructions': [
        "طريقة تحويل الرصيد من خلال تطبيق RaseedPay لمستخدمين شبكة اسياسيل العراق يتم بألالية الاتية :",
        "اولاً : اختر بطاقة اسياسيل المخصصة من الواجهة الرئيسية",
        "ثانياً : قم بملئ كل الحقول لأتمام عملية التحويل",
        "ملاحظة : في الحقل المخصص لأدخال رقم الهاتف تأكد جيداً من كتابة الرقم الصحيح الذي يحتوي على الرصيد الفعلي . مع مراعاة الانتباه ان الرقم المكتوب تابع لنفس الشريحة المدخله في هاتفك",
        "في حال قمت بكتابة رقم مختلف عن الرقم الذي تم تحويل الرصيد من خلاله داخل الحقل المخصص لأدخال الرقم لن تتم معالجة طلبك وستكون عملية غير ناجحة (فشل) .",
        "عند حدوث هكذا اخطاء سهواً يرجى متابعة قسم الدعم الفني بأسرع وقت ممكن للتحقق من حالتك",
        "ثالثاً : بعد اتمام ادخال كل المعلومات داخل بطاقة التحويل اضغط على زر تأكيد الطلب",
        "لمستخدمين الهواتف المحمولة بنظام اندرويد (Android) : سوف يتم تحويلك الى لوحة الاتصال مع الصيغة المخصصه لأرسال الرصيد على احد ارقام فريق RaseedPay المخصص لأستلام الرصيد مع قيمة الرصيد الذي قمت بأدخاله داخل الحقل المخصص",
        "يجب الضغط على زر \"اتصال\" من اجل اتمام عملية التحويل بشكل سليم . في حال عدم الضغط على الزر المذكور لن يتم معالجة طلبك وسوف يعتبر طلبك غير ناجح (فشل العلمية)",
        "ملاحظة: تم ارفاق صورة توضحية ادناه تظهر الصيغة المخصصه لتحويل الرصيد بالنسبة لمستخدمين شرائح شركة اسياسيل للأتصالات داخل العراق",
        "مستخدمين الهواتف المحمولة بنظام ios : في بعض الاصدارات لن يتم تحويلك الى لوحة الاتصال ، بعد الضغط على زر تأكيد الطلب سينبثق مباشرة الامر المخصص لتحويل الرصيد بالصيغة الموضحة ادناه .",
        "يجب الضغط على امر الاتصال لأتمام عملية التحويل بشكل سليم ومعالجة طلبك المرسل",
        "ملاحظة : كلفة تحويل الرصيد لشريحة شركة الأتصالات المذكوره اعلاه (اسياسيل العراق) هي 300 دينار بالاضافة الى القيمة الكلية للرصيد المحول ونحن غير مسؤولين عليها وغير مسؤولين عن زيادتها او نقصانها هي تابعة لسياسية خصوصية شركة الاتصالات المذكورة داخل العراق"
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    // viewportFraction يسمح بظهور جزء من البطاقات المجاورة (تأثير المروحة)
    _pageController = PageController(initialPage: 0, viewportFraction: 0.7);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // دالة لتغيير الخلفية بناءً على الحالة
  Color _getCurrentBackgroundColor() {
    if (_showInstructions) return _instructionsColor;
    return _selectedIndex == 0 ? _zainColor : _asiaColor;
  }

  @override
  Widget build(BuildContext context) {
    // تحديد اللون الحالي للخلفية
    final Color activeColor = _getCurrentBackgroundColor();

    return Scaffold(
      backgroundColor: Colors.white, // الأساس أبيض
      body: Stack(
        children: [
          // 1. الخلفية الفنية (الطلاء المسكوب)
          _buildSpilledBackground(activeColor),

          // 2. المحتوى الرئيسي (المروحة + العنوان)
          SafeArea(
            child: Column(
              children: [
                // العنوان العلوي
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "تعليمات التحويل",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBMPlexSansArabic',
                          shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))]
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.info_outline_rounded, color: Colors.white, size: 24),
                    ],
                  ),
                ),

                // مساحة المروحة (تأخذ باقي الشاشة تقريباً)
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _showInstructions ? 0.0 : 1.0, // تختفي عند ظهور التعليمات
                    child: _buildFanSelector(),
                  ),
                ),
                
                // مساحة للزر السفلي لكي لا يغطي المحتوى
                const SizedBox(height: 100), 
              ],
            ),
          ),

          // 3. لوحة التعليمات (تصعد من الأسفل - Lyrics Style)
          _buildSlidingInstructions(),

          // 4. الزر الفضي (Silver Button) - ثابت في الأسفل
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: _buildLiquidSilverButton(
                text: _showInstructions ? "رجوع" : "التالي",
                onTap: () {
                  setState(() {
                    _showInstructions = !_showInstructions;
                  });
                },
              ),
            ),
          ),
          
          // زر إغلاق الصفحة في الأعلى (اختياري للعودة للرئيسية)
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // === 1. بناء الخلفية الفنية (Spilled Paint) ===
  Widget _buildSpilledBackground(Color color) {
    return Stack(
      children: [
        // الطبقة العلوية الملونة (مسكوبة للأسفل)
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          height: MediaQuery.of(context).size.height * 0.65, // تغطي 65% من الشاشة
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color, // اللون الغامق في الأعلى
                color.withOpacity(0.8),
                color.withOpacity(0.0), // يتلاشى في المنتصف
              ],
            ),
          ),
        ),
        
        // الطبقة البيضاء السفلية (تصعد للأعلى لتندمج)
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),

        // طبقة الضباب (Blur) لدمج الألوان بنعومة فائقة
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }

  // === 2. مروحة الاختيار (Fan Selector) ===
  Widget _buildFanSelector() {
    return PageView.builder(
      controller: _pageController,
      itemCount: _providers.length,
      onPageChanged: (index) {
        setState(() => _selectedIndex = index);
      },
      itemBuilder: (context, index) {
        // حساب نسبة الحركة لعمل تأثير المروحة
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double value = 1.0;
            if (_pageController.position.haveDimensions) {
              value = _pageController.page! - index;
              value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
            }
            
            // التدوير والحجم
            final double rotate = (index - (_pageController.position.haveDimensions ? _pageController.page! : _selectedIndex)) * 0.1;
            
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateZ(rotate) // تدوير بسيط
                ..scale(value), // تصغير العناصر البعيدة
              alignment: Alignment.center,
              child: Opacity(
                opacity: value < 0.8 ? 0.5 : 1.0, // شفافة اذا لم تكن في الوسط
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: _providers[index]['color'].withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                _providers[index]['image'],
                fit: BoxFit.cover, // الصورة تملأ البطاقة بالكامل
              ),
            ),
          ),
        );
      },
    );
  }

  // === 3. لوحة التعليمات المنزلقة (Lyrics Style) ===
  Widget _buildSlidingInstructions() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.fastOutSlowIn, // حركة ناعمة مثل أبل
      top: _showInstructions ? 100 : MediaQuery.of(context).size.height, // تصعد من الأسفل
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // النصوص (فقرات)
              ...(_providers[_selectedIndex]['instructions'] as List<String>).map((text) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white, // نص أبيض على الخلفية العشبية
                      fontSize: 18,
                      height: 1.6, // تباعد أسطر مريح للقراءة
                      fontWeight: FontWeight.w600,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),

              // صور التوضيح داخل الإطارات الخاصة
              if (_selectedIndex == 0) ...[
                 // زين: صورة واحدة
                 _buildFramedImage('assets/fonts/images/zain_exp.png'), // مثال، استبدلها بصورة توضيحية حقيقية
              ] else ...[
                 // آسيا: صورتين
                 _buildFramedImage('assets/fonts/images/asiacell_exp.png'),
                 const SizedBox(height: 20),
                 _buildFramedImage('assets/fonts/images/asiacell_exp2.png'),
              ],

              const SizedBox(height: 150), // مساحة إضافية في الأسفل عشان الزر ما يغطي الكلام
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت الإطار الخاص بالصور (Double Border)
  Widget _buildFramedImage(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black, // الإطار الخارجي الأسود
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(2), // سمك الإطار الأسود النحيف
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent, // الفراغ الصغير
          borderRadius: BorderRadius.circular(13),
        ),
        padding: const EdgeInsets.all(3), // الفراغ بين الأسود والصورة
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }

  // === 4. الزر الفضي الرهيب (Liquid Metal Button) ===
  Widget _buildLiquidSilverButton({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          // محاكاة المعدن السائل باستخدام تدرج لوني دقيق
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 0.45, 0.6, 1.0],
            colors: [
              Color(0xFFFFFFFF),       // أبيض لامع (إضاءة)
              Color(0xFFE0E0E0),       // رمادي فاتح
              Color(0xFFF5F5F5),       // أبيض (لمعة الوسط)
              Color(0xFFBDBDBD),       // رمادي داكن قليلاً
              Color(0xFF9E9E9E),       // رمادي الظل
            ],
          ),
          boxShadow: [
            // الظل الخارجي القوي لرفع الزر
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(5, 5),
              blurRadius: 15,
              spreadRadius: 1,
            ),
            // محاكاة الظل الداخلي الأبيض (Inset Glow)
            // بما أن فلاتر لا يدعم Inset Shadow مباشرة، نستخدم خدعة الظل الأبيض السالب
             BoxShadow(
              color: Colors.white.withOpacity(0.9),
              offset: const Offset(-2, -2),
              blurRadius: 5,
              spreadRadius: 0,
            ),
          ],
          // الحدود المتغيرة (بيضاء من الأعلى، شفافة من الأسفل)
          border: Border.all(
            color: Colors.white.withOpacity(0.6),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'IBMPlexSansArabic', // أو الخط Goldman حسب ملف CSS
              fontWeight: FontWeight.bold,
              color: const Color(0xFF454545), // لون النص الرمادي الغامق
              shadows: [
                Shadow(
                  color: Colors.white.withOpacity(0.8),
                  offset: const Offset(1, 1),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}