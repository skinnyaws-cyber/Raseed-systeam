import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // خلفية رمادية فاتحة جداً
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal.shade700,
        title: const Text('رصيد الزمردي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.white)),
          const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // قسم الرصيد (البطاقة الرئيسية)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade700,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Text('إجمالي الرصيد المتوفر', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 10),
                  const Text('د.ع 1,250,000', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickAction(Icons.add_circle_outline, 'شحن'),
                      _buildQuickAction(Icons.send_rounded, 'تحويل'),
                      _buildQuickAction(Icons.qr_code_scanner, 'دفع QR'),
                    ],
                  ),
                ],
              ),
            ),

            // قسم الخدمات
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الخدمات السريعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _buildServiceItem(Icons.phone_android, 'رصيد'),
                      _buildServiceItem(Icons.language, 'إنترنت'),
                      _buildServiceItem(Icons.electric_bolt, 'كهرباء'),
                      _buildServiceItem(Icons.water_drop, 'ماء'),
                    ],
                  ),
                ],
              ),
            ),

            // قسم العمليات الأخيرة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('آخر العمليات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () {}, child: const Text('عرض الكل')),
                    ],
                  ),
                  _buildTransactionItem('شركة زين العراق', 'منذ ساعتين', '- 10,000 د.ع', Colors.red),
                  _buildTransactionItem('تحويل من أحمد', 'أمس', '+ 50,000 د.ع', Colors.green),
                  _buildTransactionItem('تسديد فاتورة ماء', '2 يناير', '- 15,000 د.ع', Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ودجت للأزرار السريعة فوق
  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(backgroundColor: Colors.white.withOpacity(0.2), child: Icon(icon, color: Colors.white)),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  // ودجت لأيقونات الخدمات
  Widget _buildServiceItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
          child: Icon(icon, color: Colors.teal.shade700),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // ودجت لقائمة العمليات
  Widget _buildTransactionItem(String title, String date, String amount, Color amountColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.teal.withOpacity(0.1), child: Icon(Icons.receipt_long, color: Colors.teal.shade700)),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          Text(amount, style: TextStyle(color: amountColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
