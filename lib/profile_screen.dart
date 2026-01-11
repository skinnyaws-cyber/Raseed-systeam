import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final Color emeraldColor = const Color(0xFF50878C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              _buildProfileHeader(),
              const SizedBox(height: 25),
              _buildWalletCard(),
              const SizedBox(height: 25),
              _buildSettingsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  // رأس الصفحة (المعلومات الشخصية)
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: emeraldColor.withOpacity(0.1),
              child: Icon(Icons.person_rounded, size: 50, color: emeraldColor),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.stars_rounded, color: emeraldColor, size: 25),
            ),
          ],
        ),
        const SizedBox(height: 15),
        const Text('أحمد العراقي', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const Text('ID: #882190', style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: emeraldColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text('عضو زمردي ✨', style: TextStyle(color: emeraldColor, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }

  // بطاقة المحفظة (الرصيد المتاح للسحب)
  Widget _buildWalletCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الرصيد القابل للسحب', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  SizedBox(height: 5),
                  Text('75,250 د.ع', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: emeraldColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Text('سحب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // قسم الإعدادات والخيارات
  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          _buildSettingsTile(Icons.account_balance_wallet_outlined, 'معلومات المحفظة البنكية', 'إدارة ZainCash و AsiaHawala'),
          _buildSettingsTile(Icons.history_rounded, 'سجل عمليات السحب', 'تتبع الأموال التي استلمتها'),
          _buildSettingsTile(Icons.headset_mic_outlined, 'الدعم الفني والشكاوى', 'نحن هنا لمساعدتك 24/7'),
          const Divider(indent: 20, endIndent: 20),
          _buildSettingsTile(Icons.language_rounded, 'لغة التطبيق', 'العربية (العراق)'),
          _buildSettingsTile(Icons.info_outline_rounded, 'عن تطبيق رصيد', 'الشروط والأحكام والسياسات'),
          _buildSettingsTile(Icons.logout_rounded, 'تسجيل الخروج', '', isLogout: true),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle, {bool isLogout = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red.withOpacity(0.05) : const Color(0xFFF4F7F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isLogout ? Colors.red : emeraldColor, size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isLogout ? Colors.red : Colors.black)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)) : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }
}
