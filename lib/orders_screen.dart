import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  final Color emeraldColor = const Color(0xFF50878C);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('سجل الطلبات', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            labelColor: emeraldColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: emeraldColor,
            tabs: const [
              Tab(text: 'النشطة'),
              Tab(text: 'المكتملة'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrdersList(isActive: true),
            _buildOrdersList(isActive: false),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList({required bool isActive}) {
    // البيانات التجريبية المحدثة لتشمل تفاصيل الوصل
    final List<Map<String, dynamic>> orders = isActive 
      ? [
          {
            'id': '8821', 
            'provider': 'آسيا سيل', 
            'amount': '50,000', 
            'net': '45,000', 
            'commission': '5,000',
            'phone': '07701234567',
            'type': 'تحويل مباشر',
            'status': 'قيد المعالجة', 
            'date': '2024-05-12', 
            'time': '10:30 AM',
            'logo': 'assets/fonts/images/asiacell_logo.png'
          },
        ]
      : [
          {
            'id': '7750', 
            'provider': 'زين العراق', 
            'amount': '10,000', 
            'net': '9,000', 
            'commission': '1,000',
            'phone': '07801234567',
            'type': 'كود سري / QR',
            'status': 'تم التحويل', 
            'date': '2024-05-11', 
            'time': '09:15 PM',
            'logo': 'assets/fonts/images/zain_logo.png'
          },
        ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return GestureDetector(
          onTap: () => _showOrderDetails(context, order), // عند الضغط يفتح التفاصيل
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Image.asset(order['logo'], width: 40, height: 40),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('طلب تحويل #${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text('${order['provider']} - ${order['date']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${order['net']} د.ع', style: TextStyle(color: emeraldColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.orange.withOpacity(0.1) : emeraldColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order['status'],
                        style: TextStyle(fontSize: 10, color: isActive ? Colors.orange : emeraldColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // دالة عرض تفاصيل الطلب (الوصل)
  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFFF4F7F7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text('تفاصيل الوصل', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // تصميم الوصل
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildReceiptRow('رقم الطلب', '#${order['id']}'),
                  _buildReceiptRow('الشركة', order['provider']),
                  _buildReceiptRow('نوع العملية', order['type']),
                  _buildReceiptRow('رقم الهاتف', order['phone']),
                  const Divider(height: 30),
                  _buildReceiptRow('المبلغ المرسل', '${order['amount']} د.ع'),
                  _buildReceiptRow('العمولة', '${order['commission']} د.ع', isNegative: true),
                  const Divider(height: 30),
                  _buildReceiptRow('الصافي المستلم', '${order['net']} د.ع', isBold: true),
                  _buildReceiptRow('التاريخ', order['date']),
                  _buildReceiptRow('الوقت', order['time']),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: order['status'] == 'تم التحويل' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'حالة الطلب: ${order['status']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: order['status'] == 'تم التحويل' ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emeraldColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isNegative = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 16 : 14,
              color: isNegative ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
