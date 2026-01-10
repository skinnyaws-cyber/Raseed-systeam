import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F4),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF006D5B),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 16),
              title: const Text('رصيد الزمردي', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            ),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.qr_code_scanner, color: Colors.white)),
              const SizedBox(width: 10),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // بطاقة الرصيد
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF008080), Color(0xFF004D40)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('رصيدك المتاح', style: TextStyle(color: Colors.white70, fontSize: 16)),
                            const Icon(Icons.credit_card, color: Colors.white54, size: 30),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text('1,250,500 د.ع', 
                          style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('**** **** **** 4421', style: TextStyle(color: Colors.white54, fontSize: 14)),
                            // تم تصحيح اللون هنا من emeraldAccent إلى Color(0xFFA7FFE4)
                            const Text('عضو زمردي', 
                              style: TextStyle(color: Color(0xFFA7FFE4), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text('الخدمات الأساسية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMainAction(Icons.send_to_mobile_rounded, 'تحويل'),
                      _buildMainAction(Icons.account_balance_wallet, 'شحن'),
                      _buildMainAction(Icons.receipt_long, 'فواتير'),
                      _buildMainAction(Icons.grid_view_rounded, 'المزيد'),
                    ],
                  ),

                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('آخر التحركات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () {}, child: const Text('عرض السجل', style: TextStyle(color: Color(0xFF008080)))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTransactionCard('أحمد محمد', 'منذ 5 دقائق', '+ 25,000', Colors.green),
                  _buildTransactionCard('سوبر ماركت الهدى', 'اليوم، 12:30 م', '- 12,000', Colors.redAccent),
                  _buildTransactionCard('تسديد فاتورة إنترنت', 'أمس', '- 40,000', Colors.redAccent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, spreadRadius: 2)],
          ),
          child: Icon(icon, color: const Color(0xFF008080), size: 28),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildTransactionCard(String title, String time, String amount, Color amountColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFF0F7F7),
                child: Icon(amount.contains('+') ? Icons.arrow_downward : Icons.arrow_upward, 
                  color: amountColor, size: 18),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          Text(amount, style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
