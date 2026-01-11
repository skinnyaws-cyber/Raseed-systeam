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
    // هذه بيانات تجريبية (Mock Data) سنربطها لاحقاً بقاعدة البيانات
    final List<Map<String, dynamic>> orders = isActive 
      ? [
          {'id': '8821', 'provider': 'آسيا سيل', 'amount': '50,000', 'net': '40,000', 'status': 'قيد المعالجة', 'date': 'منذ 5 دقائق', 'logo': 'https://upload.wikimedia.org/wikipedia/ar/thumb/2/23/Asiacell_Logo.svg/1024px-Asiacell_Logo.svg.png'},
        ]
      : [
          {'id': '7750', 'provider': 'زين العراق', 'amount': '10,000', 'net': '9,000', 'status': 'تم التحويل', 'date': 'أمس، 10:30 م', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Zain_Logo.svg/1200px-Zain_Logo.svg.png'},
          {'id': '7749', 'provider': 'آسيا سيل', 'amount': '25,000', 'net': '20,000', 'status': 'تم التحويل', 'date': '22 يناير 2024', 'logo': 'https://upload.wikimedia.org/wikipedia/ar/thumb/2/23/Asiacell_Logo.svg/1024px-Asiacell_Logo.svg.png'},
        ];

    if (orders.isEmpty) {
      return const Center(child: Text('لا توجد طلبات حالياً', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Row(
            children: [
              // شعار الشركة
              Image.network(order['logo'], width: 40, height: 40),
              const SizedBox(width: 15),
              
              // تفاصيل الطلب
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
              
              // المبالغ والحالة
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
                      style: TextStyle(
                        fontSize: 10, 
                        color: isActive ? Colors.orange : emeraldColor,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
