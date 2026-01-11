import 'package:flutter/material.dart';

class DiscountsScreen extends StatelessWidget {
  const DiscountsScreen({super.key});

  final Color emeraldColor = const Color(0xFF50878C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'نظام المكافآت والخصم',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 10),
              const Text(
                'شارك كود الخصم الخاص بك مع أصدقائك واحصل على مكافآت نقدية عند كل عملية تحويل يقومون بها.',
                style: TextStyle(color: Colors.grey, height: 1.6, fontSize: 15),
              ),
              const SizedBox(height: 35),
              
              // بطاقة كود الخصم الفاخرة
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                  border: Border.all(color: emeraldColor.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.stars_rounded, color: emeraldColor, size: 50),
                    const SizedBox(height: 20),
                    const Text('كودك الخاص', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      decoration: BoxDecoration(
                        color: emeraldColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'RASEED-2024',
                        style: TextStyle(
                          fontSize: 28, 
                          fontWeight: FontWeight.bold, 
                          color: emeraldColor, 
                          letterSpacing: 2
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton.icon(
                      onPressed: () {
                        // هنا نضع كود النسخ لاحقاً
                      },
                      icon: const Icon(Icons.copy_all_rounded, size: 20),
                      label: const Text('نسخ الكود ومشاركته'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: emeraldColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // قسم الإحصائيات البسيط
              _buildStatTile(Icons.people_alt_rounded, 'الأصدقاء المدعوين', '12 شخص'),
              _buildStatTile(Icons.account_balance_wallet_rounded, 'أرباحك من الخصومات', '15,500 د.ع'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: emeraldColor.withOpacity(0.1), child: Icon(icon, color: emeraldColor, size: 20)),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: emeraldColor)),
        ],
      ),
    );
  }
}
