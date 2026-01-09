import 'package:flutter/material.dart';
import 'transaction_details_screen.dart'; // استدعاء واجهة التفاصيل

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('نشاطات التحويل', style: TextStyle(color: Color(0xFF1B4332))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('العمليات الأخيرة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 15),

          // مثال لعملية قيد الانتظار
          _buildClickableTransaction(
            context,
            id: 'RS8821',
            network: 'Asiacell',
            amount: '25,000',
            received: '20,000',
            date: '2026/01/09 - 10:30 م',
            status: 'قيد الانتظار',
            method: 'تحويل مباشر',
            bank_account: '10029384',
            color: Colors.amber,
            icon: Icons.hourglass_empty,
          ),

          const SizedBox(height: 15),

          // مثال لعملية مكتملة
          _buildClickableTransaction(
            context,
            id: 'RS8740',
            network: 'Zain IQ',
            amount: '10,000',
            received: '8,000',
            date: '2026/01/08 - 02:15 م',
            status: 'تم التحويل بنجاح',
            method: 'كود كرت رصيد',
            bank_account: '10029384',
            color: const Color(0xFF50C878),
            icon: Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildClickableTransaction(BuildContext context, {
    required String id,
    required String network,
    required String amount,
    required String received,
    required String date,
    required String status,
    required String method,
    required String bank_account,
    required Color color,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        // فتح واجهة التفاصيل وتمرير البيانات لها
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailsScreen(data: {
              'id': id,
              'network': network,
              'amount': amount,
              'received': received,
              'date': date,
              'status': status,
              'method': method,
              'bank_account': bank_account,
              'color': color,
              'icon': icon,
            }),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
            ),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تحويل رصيد $network', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
