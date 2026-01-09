import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('برنامج المكافآت', style: TextStyle(color: Color(0xFF1B4332))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // بطاقة كود الخصم
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF50C878), Color(0xFF1B4332)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: const Color(0xFF50C878).withOpacity(0.3), blurRadius: 15)],
              ),
              child: Column(
                children: [
                  const Icon(Icons.card_giftcard, color: Colors.white, size: 50),
                  const SizedBox(height: 15),
                  const Text('كود الخصم الخاص بك', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                    child: const Text('RASEED100', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                  const SizedBox(height: 15),
                  const Text('شارك الكود مع 5 أصدقاء للحصول على تحويل مجاني 100%', 
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // عداد الأصدقاء (Progress)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('تقدمك الحالي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('أصدقاء انضموا: 3/5'),
                      Text('60%', style: TextStyle(color: Color(0xFF50C878), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: 0.6,
                    backgroundColor: Colors.grey[200],
                    color: const Color(0xFF50C878),
                    minHeight: 10,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // قائمة الأصدقاء الذين سجلوا
            const Align(
              alignment: Alignment.centerRight,
              child: Text('الأصدقاء الذين انضموا', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            _buildFriendTile('أحمد علي', 'منذ يومين'),
            _buildFriendTile('سارة محمود', 'منذ 5 ساعات'),
            _buildFriendTile('ياسين كمال', 'منذ ساعة'),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendTile(String name, String time) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: const Color(0xFF50C878).withOpacity(0.1), child: const Icon(Icons.person, color: Color(0xFF50C878))),
      title: Text(name),
      subtitle: Text(time),
      trailing: const Icon(Icons.check_circle, color: Color(0xFF50C878), size: 20),
    );
  }
}
