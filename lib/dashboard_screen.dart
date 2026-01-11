import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // لون الهوية الزمردي المعتمد في المخطط
  final Color emeraldColor = const Color(0xFF50878C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7), // خلفية رمادية مخضرة فاتحة جداً
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // رأس الصفحة (Header)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'أهلاً بك، مستخدم رصيد',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          'عضو زمردي ✨',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: emeraldColor
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.notifications_none_rounded, color: emeraldColor),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // بطاقة الرصيد الإجمالي (الخطة في الـ PDF)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [emeraldColor, const Color(0xFF3D666A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: emeraldColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'إجمالي الرصيد المحول',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '0 د.ع', // سيتغير عند ربط قاعدة البيانات
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 32, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              '0 عملية ناجحة',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // قسم اختيار الشبكة (تحويل الرصيد)
                const Text(
                  'حول رصيدك الآن',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildNetworkCard(
                        'آسيا سيل', 
                        'Asiacell', 
                        const Color(0xFFEE2737), // لون آسيا سيل
                        Icons.signal_cellular_alt
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildNetworkCard(
                        'زين العراق', 
                        'Zain IQ', 
                        const Color(0xFF00B2A9), // لون زين
                        Icons.cell_tower_rounded
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // قسم العمليات الأخيرة (نسخة مبسطة)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'آخر التحويلات',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {}, 
                      child: Text('الكل', style: TextStyle(color: emeraldColor))
                    ),
                  ],
                ),
                
                // حالة فارغة (بانتظار العمليات)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.history_toggle_off_rounded, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        const Text('لا توجد عمليات حالياً', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      
      // شريط التنقل السفلي كما طلبت في الخطة
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: emeraldColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'الطلبات'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate_rounded), label: 'الحاسبة'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'الملف'),
        ],
      ),
    );
  }

  Widget _buildNetworkCard(String name, String subName, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 15),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(subName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(double.infinity, 36),
            ),
            child: const Text('تحويل', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
