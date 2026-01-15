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

  // دالة فحص أمنية أولية
  void _checkSecurity() {
    // ملاحظة: برمجياً تحتاج مكتبات مثل flutter_jailbreak_detection
    // هنا سنضع منطقاً يمنع المشاهدة إذا تم اكتشاف بيئة غير آمنة
    setState(() {
      // هذه القيمة يجب أن تأتي من فحص حقيقي للنظام
      isJailbroken = false; 
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isRewardReady = points >= targetPoints;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              const Icon(Icons.stars_rounded, size: 80, color: Colors.amber),
              const SizedBox(height: 15),
              const Text('نظام تجميع النقاط', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                'جمع 50 نقطة للحصول على إعفاء كامل من عمولة التحويل القادمة.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // عداد النقاط الدائري
              _buildPointsCounter(),

              const SizedBox(height: 40),

              // زر مشاهدة الإعلان
              _buildWatchAdButton(isRewardReady),

              const SizedBox(height: 20),

              // رسالة التنبيه في حال اكتمال النقاط
              if (isRewardReady)
                _buildRewardAlert(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsCounter() {
    double progress = points / targetPoints;
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(emeraldColor),
                ),
              ),
              Column(
                children: [
                  Text('$points', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: emeraldColor)),
                  const Text('نقطة', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('باقي لك ${targetPoints - points} نقطة للإعفاء', style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildWatchAdButton(bool isRewardReady) {
    // الزر يصبح شفافاً وغير قابل للضغط عند الوصول لـ 50 نقطة أو عند كشف جيلبريك
    bool disableButton = isRewardReady || isJailbroken;

    return SizedBox(
      width: double.infinity,
      child: Opacity(
        opacity: disableButton ? 0.4 : 1.0,
        child: ElevatedButton.icon(
          onPressed: disableButton ? null : () {
            setState(() {
              points += 2; // إضافة نقطتين لكل إعلان
            });
          },
          icon: const Icon(Icons.play_circle_fill, color: Colors.white),
          label: Text(isJailbroken ? 'بيئة غير آمنة' : 'شاهد إعلان (+2 نقطة)', 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: emeraldColor,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardAlert() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('لقد حصلت على إعفاء من العمولة! سيتم تطبيقه تلقائياً في عمليتك القادمة.',
              style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
