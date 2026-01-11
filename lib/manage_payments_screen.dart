import 'package:flutter/material.dart';

class ManagePaymentsScreen extends StatefulWidget {
  const ManagePaymentsScreen({super.key});

  @override
  State<ManagePaymentsScreen> createState() => _ManagePaymentsScreenState();
}

class _ManagePaymentsScreenState extends State<ManagePaymentsScreen> {
  final Color emeraldColor = const Color(0xFF50878C);
  
  // وحدات التحكم بالنصوص (لجعلها قابلة للتعديل)
  final TextEditingController _qiController = TextEditingController(text: "4444-xxxx-xxxx-1234");
  final TextEditingController _zainController = TextEditingController(text: "07800000000");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      appBar: AppBar(
        title: const Text('أرقام الاستلام', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('حدد الأرقام التي تود استلام الكاش عليها:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            // حقل كي كارد
            _buildPaymentField(
              label: "رقم بطاقة كي كارد (Qi Card)",
              controller: _qiController,
              logoUrl: "https://qi.iq/assets/images/logo.png", // شعار كي كارد
            ),

            const SizedBox(height: 25),

            // حقل زين كاش
            _buildPaymentField(
              label: "رقم محفظة زين كاش (Zain Cash)",
              controller: _zainController,
              logoUrl: "https://zaincash.iq/wp-content/uploads/2019/12/zain-cash-logo.png", // شعار زين كاش
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // هنا يتم حفظ البيانات في السيرفر لاحقاً
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: emeraldColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text('حفظ التعديلات', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentField({required String label, required TextEditingController controller, required String logoUrl}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Image.network(logoUrl, height: 25, errorBuilder: (c,e,s) => const Icon(Icons.credit_card)), // الشعار في طرف الحقل
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: emeraldColor)),
          ),
        ),
      ],
    );
  }
}
