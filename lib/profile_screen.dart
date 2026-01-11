import 'package:flutter/material.dart';
import 'manage_payments_screen.dart'; // استيراد واجهة أرقام الاستلام للربط

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
              _buildTotalTransferredCard(), // عرض إجمالي الأموال المحولة
              const SizedBox(height: 25),
              _buildSettingsSection(context), // تمرير الـ context هنا للربط
            ],
          ),
        ),
      ),
    );
  }

  // رأس الصفحة (معلومات المستخدم)
  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: emeraldColor.withOpacity(0.1),
          child: Icon(Icons.person_rounded, size: 50, color: emeraldColor),
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

  // بطاقة إجمالي الأموال (تم تحديثها بناءً على منطق مشروعك)
  Widget _buildTotalTransferredCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(25),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Column(
        children: [
          const Icon(Icons.account_balance_wallet_rounded, color: Colors.grey, size: 30),
          const SizedBox(height: 10),
          const Text('إجمالي الأموال المحولة لمحفظتك', 
            style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Text('145,500 د.ع', 
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: emeraldColor)),
          const SizedBox(height: 5),
          const Text('تم حسابها تلقائياً بعد خصم العمولة', 
            style: TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  // قسم الإعدادات مع تفعيل الانتقال لواجهة أرقام الاستلام
  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          // تم ربط هذا الزر بواجهة ManagePaymentsScreen
          _buildSettingsTile(
            Icons.phone_android_rounded, 
            'أرقام استلام المستحقات', 
            'إدارة أرقام ZainCash و Qi Card',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManagePaymentsScreen()),
              );
            },
          ),
          _buildSettingsTile(Icons.assignment_turned_in_rounded, 'سجل العمليات الناجحة', 'عرض تفاصيل الأرباح السابقة'),
          _buildSettingsTile(Icons.headset_mic_outlined, 'الدعم الفني', 'تواصل معنا في حال تأخر التحويل'),
          const Divider(indent: 20, endIndent: 20),
          _buildSettingsTile(Icons.info_outline_rounded, 'عن تطبيق رصيد', 'شروط الاستخدام والعمولات'),
          _buildSettingsTile(Icons.logout_rounded, 'تسجيل الخروج', '', isLogout: true),
        ],
      ),
    );
  }

  // مكون الخيار الواحد في القائمة (Tile) مع تفعيل خاصية الضغط onTap
  Widget _buildSettingsTile(IconData icon, String title, String subtitle, {bool isLogout = false, VoidCallback? onTap}) {
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
      onTap: onTap, // هنا يتم تفعيل وظيفة الضغط
    );
  }
}
