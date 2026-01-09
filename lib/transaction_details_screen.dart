import 'package:flutter/material.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const TransactionDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('تفاصيل العملية', style: TextStyle(color: Color(0xFF1B4332))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            // أيقونة الحالة الكبيرة
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: data['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(data['icon'], size: 60, color: data['color']),
            ),
            const SizedBox(height: 20),
            Text(
              data['status'],
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: data['color']),
            ),
            const SizedBox(height: 40),

            // جدول المعلومات
            _buildDetailRow('شبكة التحويل', data['network']),
            _buildDetailRow('المبلغ المرسل', '${data['amount']} د.ع'),
            _buildDetailRow('صافي المستلم', '${data['received']} د.ع'),
            _buildDetailRow('التاريخ والوقت', data['date']),
            _buildDetailRow('طريقة التحويل', data['method']),
            _buildDetailRow('رقم الحساب المستلم', data['bank_account']),
            _buildDetailRow('رقم المرجع (ID)', '#${data['id']}'),

            const Spacer(),

            // أزرار التحكم بالوصل
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة الوصل'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Color(0xFF50C878)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.support_agent),
                    label: const Text('دعم فني'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B4332),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
