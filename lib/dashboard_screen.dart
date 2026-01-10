import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const ModernDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6), // خلفية رمادية فاتحة جداً مريحة
      body: SingleChildScrollView(
        child: Column(
          children: [
            // الجزء العلوي (Header) المستوحى من فخامة EasyPay
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 40, left: 25, right: 25),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('مرحباً بك،', style: TextStyle(color: Colors.white70, fontSize: 16)),
                          Text('مرتضى محمد', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.notifications_none, color: Colors.white),
                      )
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Text('إجمالي رصيدك القابل للسحب', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 5),
                  const Text('245,500 د.ع', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // قسم الخدمات (هنا قمت بحذف الخدمات غير اللازمة وأبقيت المهم)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('تحويل رصيد جديد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
                  const SizedBox(height: 20),
                  
                  // بطاقة آسيا سيل - تصميم عصري
                  _buildNetworkCard(
                    context,
                    name: 'Asiacell',
                    sub: 'تحويل مباشر أو عبر الكود',
                    color: const Color(0xFFED1C24),
                    icon: Icons.cell_tower,
                  ),
                  
                  const SizedBox(height: 15),

                  // بطاقة زين - تصميم عصري
                  _buildNetworkCard(
                    context,
                    name: 'Zain IQ',
                    sub: 'أسرع معالجة لطلبات زين',
                    color: Colors.black,
                    icon: Icons.flash_on,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // سجل العمليات الأخير (كما في EasyPay)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('آخر العمليات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text('رؤية الكل', style: TextStyle(color: Color(0xFF50C878)))),
                ],
              ),
            ),

            // قائمة العمليات المصغرة
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index) => _buildMiniTransaction(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkCard(BuildContext context, {required String name, required String sub, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildMiniTransaction() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Color(0xFFFFF9C4), child: Icon(Icons.hourglass_bottom, color: Colors.orange, size: 20)),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تحويل آسيا سيل', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('منذ 5 دقائق', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Spacer(),
          const Text('25,000 د.ع', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
          const SizedBox(width: 10),
          // الضوء الأصفر الذي طلبته
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}
