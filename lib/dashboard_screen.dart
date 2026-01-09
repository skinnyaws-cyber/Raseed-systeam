import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // الجزء العلوي: البطاقة الخضراء الزمردية
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 25, right: 25),
            decoration: const BoxDecoration(
              color: Color(0xFF50C878),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مرحباً، مرتضى', // اسم المستخدم الافتراضي حالياً
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 10),
                const Text(
                  'إجمالي تحويلاتك',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Text(
                  '150,000 د.ع',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // قسم اختيار الشبكة
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'اختر شبكة التحويل',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
                ),
                const SizedBox(height: 20),
                
                // بطاقة آسيا سيل
                _buildNetworkCard(
                  name: 'Asiacell',
                  imagePath: 'assets/images/asiacell_logo.png', // سنضيف الصور لاحقاً
                  color: const Color(0xFFED1C24),
                  onTap: () {
                    // سننتقل لواجهة التحويل لاحقاً
                  },
                ),

                const SizedBox(height: 15),

                // بطاقة زين
                _buildNetworkCard(
                  name: 'Zain IQ',
                  imagePath: 'assets/images/zain_logo.png',
                  color: Colors.black,
                  onTap: () {
                    // سننتقل لواجهة التحويل لاحقاً
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      
      // شريط التنقل السفلي
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF50C878),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'النشاط'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }

  // دالة بناء بطاقة الشبكة
  Widget _buildNetworkCard({required String name, required String imagePath, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.cell_tower, color: color), // أيقونة مؤقتة لحين رفع الشعارات
            ),
            const SizedBox(width: 20),
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
