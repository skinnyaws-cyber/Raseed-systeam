import 'package:flutter/material.dart';

class DiscountsScreen extends StatefulWidget {
  const DiscountsScreen({super.key});

  @override
  State<DiscountsScreen> createState() => _DiscountsScreenState();
}

class _DiscountsScreenState extends State<DiscountsScreen> {
  final Color emeraldColor = const Color(0xFF50878C);

  // متغيرات الحالة
  int points = 0; // عداد النقاط
  final int targetPoints = 50; // الهدف
  bool isJailbroken = false; // كشف الحماية (افتراضي خطأ)

  @override
  void initState() {
    super.initState();
    _checkSecurity(); // فحص الحماية عند فتح الصفحة
  }

  void _checkSecurity() {
    setState(() {
      isJailbroken = false; 
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isRewardReady = points >= targetPoints;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      // إضافة شريط علوي لملء الفراغ وإعطاء هوية للواجهة
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'مكافآت رصيد',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(Icons.info_outline, color: emeraldColor),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // جزء علوي ملون لربط التصميم
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.stars_rounded, size: 60, color: Colors.amber),
                  const SizedBox(height: 15),
                  const Text('نظام تجميع النقاط', 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'جمع 50 نقطة للحصول على إعفاء كامل من عمولة التحويل القادمة.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  // عداد النقاط الدائري (داخل تصميم محسّن)
                  _buildPointsCounter(),

                  const SizedBox(height: 30),

                  // زر مشاهدة الإعلان
                  _buildWatchAdButton(isRewardReady),

                  const SizedBox(height: 20),

                  // رسالة التنبيه في حال اكتمال النقاط
                  if (isRewardReady)
                    _buildRewardAlert(),
                  
                  const SizedBox(height: 40),
                  
                  // نص إضافي لملء المساحة السفلية وجعل الواجهة ممتلئة
                  const Text(
                    "مشاهدة الإعلانات تدعم استمرارية الخدمة مجاناً",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCounter() {
    double progress = points / targetPoints;
    return Container(
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(emeraldColor),
                ),
              ),
              Column(
                children: [
                  Text('$points', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: emeraldColor)),
                  const Text('نقطة', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            points >= targetPoints 
                ? 'تهانينا! وصلت للهدف' 
                : 'باقي لك ${targetPoints - points} نقطة للإعفاء', 
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)
          ),
        ],
      ),
    );
  }

  Widget _buildWatchAdButton(bool isRewardReady) {
    bool disableButton = isRewardReady || isJailbroken;

    return SizedBox(
      width: double.infinity,
      child: Opacity(
        opacity: disableButton ? 0.4 : 1.0,
        child: ElevatedButton.icon(
          onPressed: disableButton ? null : () {
            setState(() {
              if (points < targetPoints) points += 2; 
            });
          },
          icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
          label: Text(
            isJailbroken ? 'بيئة غير آمنة' : 'شاهد إعلان الآن (+2 نقطة)', 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: emeraldColor,
            padding: const EdgeInsets.symmetric(vertical: 15),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardAlert() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50, 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.withOpacity(0.3))
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 30),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'رائع! حصلت على إعفاء كامل. سيتم تصفير العمولة في شاشة التحويل تلقائياً.',
              style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
