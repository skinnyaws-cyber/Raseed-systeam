import 'package:flutter/material.dart';

class ManagePaymentsScreen extends StatefulWidget {
  const ManagePaymentsScreen({super.key});

  @override
  State<ManagePaymentsScreen> createState() => _ManagePaymentsScreenState();
}

class _ManagePaymentsScreenState extends State<ManagePaymentsScreen> {
  final Color emeraldColor = const Color(0xFF50878C);
  
  // وحدات التحكم (Controllers) لإدارة النصوص وجعلها قابلة للتعديل
  final TextEditingController _qiController = TextEditingController(text: "4444-xxxx-xxxx-1234");
  final TextEditingController _zainController = TextEditingController(text: "07800000000");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      appBar: AppBar(
        title: const Text('أرقام الاستلام', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('حدد الأرقام التي تود استلام الكاش عليها:', 
              style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 35),

            // --- حقل كي كارد مع الشعار المرسوم ---
            _buildPaymentField(
              label: "رقم بطاقة كي كارد (Qi Card)",
              controller: _qiController,
              logo: _drawQiLogo(), // رسم الشعار هنا
            ),

            const SizedBox(height: 30),

            // --- حقل زين كاش مع الشعار المرسوم ---
            _buildPaymentField(
              label: "رقم محفظة زين كاش (Zain Cash)",
              controller: _zainController,
              logo: _drawZainLogo(), // رسم الشعار هنا
            ),

            const Spacer(),
            
            // زر الحفظ
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // إشعار نجاح الحفظ
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ التعديلات بنجاح'), backgroundColor: Colors.green),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: emeraldColor, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: const Text('حفظ التعديلات', 
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة بناء الحقل مع الشعار في الطرف
  Widget _buildPaymentField({required String label, required TextEditingController controller, required Widget logo}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
            logo, // هنا يظهر الشعار المرسوم
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: emeraldColor, width: 1.5)),
          ),
        ),
      ],
    );
  }

  // --- رسم شعار Qi Card باللون الأسود ---
  Widget _drawQiLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.credit_card_rounded, color: Colors.white, size: 12),
          SizedBox(width: 4),
          Text("Qi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
        ],
      ),
    );
  }

  // --- رسم شعار Zain Cash باللون الأسود ---
  Widget _drawZainLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wallet_rounded, color: Colors.black, size: 12),
          SizedBox(width: 4),
          Text("Zain", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }
}
