import 'package:flutter/material.dart';

class DiscountsScreen extends StatefulWidget {
  const DiscountsScreen({super.key});

  @override
  State<DiscountsScreen> createState() => _DiscountsScreenState();
}

class _DiscountsScreenState extends State<DiscountsScreen> {
  final Color emeraldColor = const Color(0xFF50878C);

  // متغيرات الحالة (سنتحكم بها برمجياً لاحقاً من قاعدة البيانات)
  int inviteCount = 3; // عدد الأشخاص الذين سجلوا (مثال: 3 من 5)
  bool isRewardReady = false; // هل وصل لـ 5 ونسمح له بتوليد الكود؟
  bool hasGeneratedCode = false; // هل قام بتوليد الكود فعلاً؟
  bool isWaitingPeriod = false; // هل هو في فترة الـ 72 ساعة؟

  @override
  Widget build(BuildContext context) {
    // تحديث الحالة بناءً على عدد الدعوات
    if (inviteCount >= 5 && !hasGeneratedCode) {
      isRewardReady = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('نظام المكافآت', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildStatusMessage(),
              const SizedBox(height: 30),

              // عرض التقدم (عداد النقاط من 1 إلى 5)
              _buildProgressIndicator(),

              const SizedBox(height: 30),

              // قسم المشاركة (يختفي إذا تم توليد الكود)
              if (!hasGeneratedCode && !isWaitingPeriod) _buildInviteSection(),

              // زر توليد الكود (يظهر فقط عند اكتمال 5 نقاط)
              if (isRewardReady) _buildGenerateButton(),

              // عرض كود الخصم المستعمل (يظهر بعد الضغط على توليد)
              if (hasGeneratedCode) _buildGeneratedDiscountCode(),

              // واجهة الانتظار (تظهر في فترة الـ 72 ساعة)
              if (isWaitingPeriod) _buildWaitingState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    String msg = 'ادعُ 5 أصدقاء للحصول على كود خصم لعمليتك القادمة.';
    if (isRewardReady) msg = 'تهانينا! لقد اكتملت الدعوات، يمكنك الآن توليد الكود.';
    if (hasGeneratedCode) msg = 'استخدم كود الخصم الخاص بك الآن (صالح لمرة واحدة).';
    if (isWaitingPeriod) msg = 'لقد استخدمت ميزتك، انتظر انتهاء الموعد لبدء دورة جديدة.';
    
    return Text(msg, style: const TextStyle(color: Colors.grey, height: 1.5, fontSize: 15));
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              bool isDone = index < inviteCount;
              return CircleAvatar(
                radius: 20,
                backgroundColor: isDone ? emeraldColor : Colors.grey.shade200,
                child: Icon(
                  isDone ? Icons.check : Icons.person_add_alt_1_rounded,
                  color: isDone ? Colors.white : Colors.grey,
                  size: 18,
                ),
              );
            }),
          ),
          const SizedBox(height: 15),
          Text('$inviteCount من أصل 5 دعوات مكتملة', style: TextStyle(fontWeight: FontWeight.bold, color: emeraldColor)),
        ],
      ),
    );
  }

  Widget _buildInviteSection() {
    return Column(
      children: [
        _buildShareBox('رابط الدعوة الفريد', 'https://raseed.app/invite/user77', Icons.link),
        const SizedBox(height: 15),
        _buildShareBox('كود الدعوة الخاص بك', 'ABC-99', Icons.qr_code_2),
      ],
    );
  }

  Widget _buildShareBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Icon(icon, color: emeraldColor),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ])),
          IconButton(onPressed: () {}, icon: const Icon(Icons.copy_rounded, size: 20, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: () => setState(() { hasGeneratedCode = true; isRewardReady = false; }),
        style: ElevatedButton.styleFrom(backgroundColor: emeraldColor, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: const Text('توليد كود الخصم الآن 🎁', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildGeneratedDiscountCode() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber)),
      child: Column(
        children: [
          const Text('كود الخصم جاهز للاستخدام!'),
          const SizedBox(height: 10),
          const Text('GIFT-8822-XY', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 15),
          const Text('سيتم قفل هذا الكود والدعوات بعد الاستخدام مباشرة.', style: TextStyle(fontSize: 11, color: Colors.amber), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildWaitingState() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.timer_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 15),
          const Text('نظام الدعوات في حالة راحة', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('يمكنك البدء بدورة دعوات جديدة بعد 72 ساعة', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
