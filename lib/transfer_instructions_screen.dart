import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ضروري لحفظ حالة ظهور الإيماءة

class TransferInstructionsScreen extends StatefulWidget {
  const TransferInstructionsScreen({super.key});

  @override
  State<TransferInstructionsScreen> createState() => _TransferInstructionsScreenState();
}

class _TransferInstructionsScreenState extends State<TransferInstructionsScreen> {
  // === الألوان المطلوبة ===
  final Color _zainColor = const Color(0xFF570053); 
  final Color _asiaColor = const Color(0xFF9b0000); 
  final Color _instructionsColor = const Color(0xFF4CAF50); 

  // === حالة الواجهة ===
  int _selectedIndex = 0; 
  bool _showInstructions = false; 
  bool _showSwipeHint = false; // التحكم بظهور إيماءة السحب
  
  late PageController _pageController;

  // بيانات الشركات (الصور والنصوص المحدثة)
  final List<Map<String, dynamic>> _providers = [
    {
      'name': 'Zain',
      'image': 'assets/fonts/images/zain_info.png',
      'color': const Color(0xFF570053),
      'instructions': [
        "طريقة تحويل الرصيد من خلال تطبيق رصيد لمستخدمين زين العراق يتم بالألية الاتية ",
        "اولاً : اختر بطاقة زين العراق من الواجهة الرئيسية",
        "ثانياً : ملئ كل المعلومات لأتمام عملية التحويل",
        "ملاحظة : في الحقل المخصص لأدخال رقم الهاتف تأكد جيداً من كتابة الرقم الصحيح الذي يحتوي على الرصيد الفعلي . مع مراعاة الانتباه ان الرقم المكتوب تابع لنفس الشريحة المدخله في هاتفك",
        "في حال قمت بكتابة رقم مختلف عن الرقم الذي تم تحويل الرصيد من خلاله داخل الحقل المخصص لأدخال الرقم لن تتم معالجة طلبك وستكون عملية غير ناجحة (فشل) .",
        "عند حدوث هكذا اخطاء سهواً يرجى متابعة قسم الدعم الفني بأسرع وقت ممكن للتحقق من حالتك",
        "ثالثاً : بعد اتمام ادخال كل المعلومات داخل بطاقة التحويل اضغط على زر تأكيد الطلب",
        "سوف يتم تحويلك على تطبيق الرسائل النصية لأتمام عملية التحويل من خلال ضغطك على زر ارسال",
        "ملاحظة : عند تحويلك الى تطبيق الرسائل النصية سيتم لصق الرقم المخصص لفريق تطبيق رصيد مع قيمة الرصيد التي ادخلتها في الحقل المخصص",
        "في حال لم تضغط على زر ارسال لن يتم اتمام الطلب ومعالجته ، مثال توضيحي في الصورة ادناه",
        "رابعاً : يجب التنويه كلفة تحويل الرصيد هي 350 دينار من رصيدك داخل الشريحة بالاضافة لقيمة الرصيد الذي تم تحويله من خلال تطبيق رصيد ونحن غير مسؤولين عليها هي عمولة تابعة لشركة الاتصالات المذكورة (زين العراق) وغير مسؤولين عن زيادتها او نقصان هذه الكلفة هي تابعة بشكل مباشر لشروط وسياسية شركة الاتصالات داخل العراق",
        "قدر عمولة تحويل الرصيد واستلام مقابله مال على البطاقة البنكية من خلال تطبيق رصيد هي 10% من قيمة الرصيد الكلي المرسل والذي تم تأكيد استلامه حصراً (العملية ناجحة). وايضاً تطبق في الحالة المذكورة بالنقطة الاولى من ارشادات تحويل الرصيد"
      ]
    },
    {
      'name': 'Asiacell',
      'image': 'assets/fonts/images/asiacell_info.png',
      'color': const Color(0xFF9b0000),
      'instructions': [
        "طريقة تحويل الرصيد من خلال تطبيق رصيد لمستخدمين شبكة اسياسيل العراق يتم بألالية الاتية :",
        "اولاً : اختر بطاقة اسياسيل المخصصة من الواجهة الرئيسية",
        "ثانياً : قم بملئ كل الحقول لأتمام عملية التحويل",
        "ملاحظة : في الحقل المخصص لأدخال رقم الهاتف تأكد جيداً من كتابة الرقم الصحيح الذي يحتوي على الرصيد الفعلي . مع مراعاة الانتباه ان الرقم المكتوب تابع لنفس الشريحة المدخله في هاتفك",
        "في حال قمت بكتابة رقم مختلف عن الرقم الذي تم تحويل الرصيد من خلاله داخل الحقل المخصص لأدخال الرقم لن تتم معالجة طلبك وستكون عملية غير ناجحة (فشل) .",
        "عند حدوث هكذا اخطاء سهواً يرجى متابعة قسم الدعم الفني بأسرع وقت ممكن للتحقق من حالتك",
        "ثالثاً : بعد اتمام ادخال كل المعلومات داخل بطاقة التحويل اضغط على زر تأكيد الطلب",
        "لمستخدمين الهواتف المحمولة بنظام اندرويد : سوف يتم تحويلك الى لوحة الاتصال مع الصيغة المخصصه لأرسال الرصيد على احد ارقام فريق المخصص لأستلام الرصيد مع قيمة الرصيد الذي قمت بأدخاله داخل الحقل المخصص",
        "يجب الضغط على زر \"اتصال\" من اجل اتمام عملية التحويل بشكل سليم . في حال عدم الضغط على الزر المذكور لن يتم معالجة طلبك وسوف يعتبر طلبك غير ناجح (فشل العلمية)",
        "ملاحظة: تم ارفاق صورة توضحية ادناه تظهر الصيغة المخصصه لتحويل الرصيد بالنسبة لمستخدمين شرائح شركة اسياسيل للأتصالات داخل العراق",
        "مستخدمين الهواتف المحمولة ايفون : في بعض الاصدارات لن يتم تحويلك الى لوحة الاتصال ، بعد الضغط على زر تأكيد الطلب سينبثق مباشرة الامر المخصص لتحويل الرصيد بالصيغة الموضحة ادناه .",
        "يجب الضغط على امر الاتصال لأتمام عملية التحويل بشكل سليم ومعالجة طلبك المرسل",
        "ملاحظة : كلفة تحويل الرصيد لشريحة شركة الأتصالات المذكوره اعلاه (اسياسيل العراق) هي 300 دينار بالاضافة الى القيمة الكلية للرصيد المحول ونحن غير مسؤولين عليها وغير مسؤولين عن زيادتها او نقصانها هي تابعة لسياسية خصوصية شركة الاتصالات المذكورة داخل العراق"
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.7);
    _checkAndShowSwipeHint(); // التحقق من عرض الإيماءة
  }

  // التعديل 1: عرض الإيماءة لمرة واحدة فقط لكل مستخدم
  Future<void> _checkAndShowSwipeHint() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasShown = prefs.getBool('hasShownTransferSwipeHint') ?? false;
    
    if (!hasShown) {
      setState(() {
        _showSwipeHint = true;
      });
      // حفظ الحالة لكي لا تظهر مرة أخرى
      await prefs.setBool('hasShownTransferSwipeHint', true);
      
      // إخفاء الإيماءة تلقائياً بعد 3 ثوانٍ
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSwipeHint = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color _getCurrentBackgroundColor() {
    if (_showInstructions) return _instructionsColor;
    return _selectedIndex == 0 ? _zainColor : _asiaColor;
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = _getCurrentBackgroundColor();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. الخلفية الفنية (الطلاء المسكوب)
          _buildSpilledBackground(activeColor),

          // 2. المحتوى الرئيسي (المروحة + العنوان)
          SafeArea(
            child: Column(
              children: [
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

                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _showInstructions ? 0.0 : 1.0, 
                    child: _buildFanSelector(),
                  ),
                ),
                
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
          
          // زر إغلاق الصفحة في الأعلى
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 5. طبقة الإيماءة التوضيحية (Swipe Hint)
          if (_showSwipeHint)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(0.5), // تعتيم خفيف للتركيز على الحركة
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _AnimatedSwipeHand(), // اليد المتحركة
                      const SizedBox(height: 20),
                      const Text(
                        "اختر الارشادات المناسبة",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBMPlexSansArabic',
                          shadows: [Shadow(color: Colors.black45, blurRadius: 5)],
                        ),
                      ),
                    ],
                  ),
                ),
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
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          height: MediaQuery.of(context).size.height * 0.65, 
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color, 
                color.withOpacity(0.8),
                color.withOpacity(0.0), 
              ],
            ),
          ),
        ),
        
        // التعديل 2: الطبقة البيضاء السفلية تتغير مساحتها ديناميكياً
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            // إذا كانت الإرشادات معروضة، يأخذ الربع (0.25)، وإلا يأخذ النصف (0.5)
            height: MediaQuery.of(context).size.height * (_showInstructions ? 0.18 : 0.5),
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
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double value = 1.0;
            if (_pageController.position.haveDimensions) {
              value = _pageController.page! - index;
              value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
            }
            
            final double rotate = (index - (_pageController.position.haveDimensions ? _pageController.page! : _selectedIndex)) * 0.1;
            
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) 
                ..rotateZ(rotate) 
                ..scale(value), 
              alignment: Alignment.center,
              child: Opacity(
                opacity: value < 0.8 ? 0.5 : 1.0, 
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
                fit: BoxFit.cover, 
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
      curve: Curves.fastOutSlowIn, 
      top: _showInstructions ? 100 : MediaQuery.of(context).size.height, 
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
              ...(_providers[_selectedIndex]['instructions'] as List<String>).map((text) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 18,
                      height: 1.6, 
                      fontWeight: FontWeight.w600,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),

              if (_selectedIndex == 0) ...[
                 _buildFramedImage('assets/fonts/images/zain_exp.png'), 
              ] else ...[
                 _buildFramedImage('assets/fonts/images/asiacell_exp.png'),
                 const SizedBox(height: 20),
                 _buildFramedImage('assets/fonts/images/asiacell_exp2.png'),
              ],

              const SizedBox(height: 150), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFramedImage(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black, 
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(2), 
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent, 
          borderRadius: BorderRadius.circular(13),
        ),
        padding: const EdgeInsets.all(3), 
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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 0.45, 0.6, 1.0],
            colors: [
              Color(0xFFFFFFFF),       
              Color(0xFFE0E0E0),       
              Color(0xFFF5F5F5),       
              Color(0xFFBDBDBD),       
              Color(0xFF9E9E9E),       
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(5, 5),
              blurRadius: 15,
              spreadRadius: 1,
            ),
             BoxShadow(
              color: Colors.white.withOpacity(0.9),
              offset: const Offset(-2, -2),
              blurRadius: 5,
              spreadRadius: 0,
            ),
          ],
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
              fontFamily: 'IBMPlexSansArabic', 
              fontWeight: FontWeight.bold,
              color: const Color(0xFF454545), 
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

// ==========================================
// ويدجت مساعدة: اليد المتحركة للإيماءة
// ==========================================
class _AnimatedSwipeHand extends StatefulWidget {
  const _AnimatedSwipeHand({Key? key}) : super(key: key);

  @override
  __AnimatedSwipeHandState createState() => __AnimatedSwipeHandState();
}

class __AnimatedSwipeHandState extends State<_AnimatedSwipeHand> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1200)
    )..repeat(reverse: false);
    
    // الحركة من اليمين (موجب) إلى اليسار (سالب)
    _animation = Tween<double>(begin: 60.0, end: -60.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: Opacity(
            // تتلاشى اليد تدريجياً كلما اتجهت لليسار لتوضيح نهاية السحب
            opacity: 1.0 - (_controller.value * 0.8), 
            child: const Icon(Icons.swipe_left_rounded, size: 70, color: Colors.white),
          ),
        );
      },
    );
  }
}
