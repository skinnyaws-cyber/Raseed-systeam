import 'package:flutter/material.dart';

class SuccessfulOperationsScreen extends StatelessWidget {
  const SuccessfulOperationsScreen({super.key});
  final Color emeraldColor = const Color(0xFF50878C);

  @override
  Widget build(BuildContext context) {
    // هذه البيانات ستأتي مستقبلاً من قاعدة البيانات
    final List<Map<String, dynamic>> operations = [
      {'date': '2024-05-10', 'amount': '50,000', 'net': '45,000'},
      {'date': '2024-05-08', 'amount': '25,000', 'net': '22,500'},
      {'date': '2024-05-05', 'amount': '100,000', 'net': '90,000'},
    ];

    // حاسبة المجموع الكلي
    double totalNet = operations.fold(0, (sum, item) => sum + double.parse(item['net'].replaceAll(',', '')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل العمليات الناجحة', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          // الحاسبة في الأعلى
          Container(
            padding: const EdgeInsets.all(25),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: emeraldColor, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('المجموع الكلي المستلم', style: TextStyle(color: Colors.white, fontSize: 16)),
                Text('${totalNet.toStringAsFixed(0)} د.ع', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: operations.length,
              itemBuilder: (context, index) {
                final op = operations[index];
                return ListTile(
                  title: Text('صافي العملية: ${op['net']} د.ع', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('التاريخ: ${op['date']}'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
