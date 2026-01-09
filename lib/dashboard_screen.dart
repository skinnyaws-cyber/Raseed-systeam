import 'package:flutter/material.dart';
import 'transfer_screen.dart';
import 'activity_screen.dart';
import 'rewards_screen.dart';
import 'settings_screen.dart'; // استدعاء واجهة الإعدادات

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // القائمة المحدثة لتشمل الإعدادات
  final List<Widget> _pages = [
    const MainDashboardContent(),
    const ActivityScreen(),
    const RewardsScreen(),
    const SettingsScreen(), // الصفحة الرابعة
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, // لضمان ظهور 4 أيقونات بشكل متوازن
        selectedItemColor: const Color(0xFF50C878),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'النشاط'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'المكافآت'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
  }
}

class MainDashboardContent extends StatelessWidget {
  const MainDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 60, bottom: 30, left: 25, right: 25),
          decoration: const BoxDecoration(
            color: Color(0xFF50C878),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('مرحباً، مرتضى', style: TextStyle(color: Colors.white, fontSize: 18)),
              SizedBox(height: 10),
              Text('إجمالي تحويلاتك', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text('150,000 د.ع', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('اختر شبكة التحويل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
              const SizedBox(height: 20),
              _buildNetworkCard(
                context,
                name: 'Asiacell',
                color: const Color(0xFFED1C24),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TransferScreen(networkName: 'Asiacell', networkColor: Color(0xFFED1C24)))),
              ),
              const SizedBox(height: 15),
              _buildNetworkCard(
                context,
                name: 'Zain IQ',
                color: Colors.black,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TransferScreen(networkName: 'Zain IQ', networkColor: Colors.black))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildNetworkCard(BuildContext context, {required String name, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Row(
          children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.cell_tower, color: color)),
            const SizedBox(width: 20),
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
