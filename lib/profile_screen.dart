import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // تأكد من إضافة الحزمة في pubspec.yaml
import 'manage_payments_screen.dart';
import 'successful_operations_screen.dart'; 
import 'signup_screen.dart'; // استيراد واجهة التسجيل للربط

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
              _buildTotalTransferredCard(),
              const SizedBox(height: 25),
              _buildSettingsSection(context),
              const SizedBox(height: 20),
              _buildAccountActions(context), // قسم إضافة وتبديل الحسابات الجديد
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: emeraldColor.withOpacity(0.1),
          child: Icon(Icons.person_rounded, size: 50, color: emeraldColor),
        ),
        const SizedBox(height: 15),
        const Text('أحمد العراقي', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), // 
        const Text('ID: #882190', style: TextStyle(color: Colors.grey, fontSize: 13)), // 
        const SizedBox(height: 8),
        // تم حذف جملة "عضو زمردي" بناءً على طلبك 
      ],
    );
  }

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
          const Icon(Icons.account_balance_wallet_rounded, color: Colors.grey, size: 30), // [cite: 213]
          const SizedBox(height: 10),
          const Text('إجمالي الأموال المحولة لمحفظتك', 
            style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)), // [cite: 213]
          const SizedBox(height: 10),
          Text('145,500 د.ع', 
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: emeraldColor)), // 
          const SizedBox(height: 5),
          const Text('تم حسابها تلقائياً بعد خصم العمولة', 
            style: TextStyle(color: Colors.grey, fontSize: 11)), // 
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          _buildSettingsTile(
            Icons.phone_android_rounded, 
            'أرقام استلام المستحقات', 
            'إدارة أرقام ZainCash و Qi Card',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManagePaymentsScreen())), // [cite: 216]
          ),
          _buildSettingsTile(
            Icons.assignment_turned_in_rounded, 
            'سجل العمليات الناجحة', 
            'عرض تفاصيل الأرباح السابقة',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SuccessfulOperationsScreen())),
          ),
          _buildSettingsTile(
            Icons.headset_mic_outlined, 
            'الدعم الفني', 
            'تواصل معنا في حال تأخر التحويل',
            onTap: () => _showSupportSheet(context), 
          ),
          const Divider(indent: 20, endIndent: 20),
          _buildSettingsTile(Icons.info_outline_rounded, 'عن تطبيق رصيد', 'شروط الاستخدام والعمولات'), // [cite: 217]
          _buildSettingsTile(Icons.logout_rounded, 'تسجيل الخروج', '', isLogout: true), // [cite: 218]
        ],
      ),
    );
  }

  Widget _buildAccountActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          _buildActionBtn(context, 'اضافة حساب', Icons.person_add_alt_1_rounded, Colors.blueGrey, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())); // توجيه لواجهة التسجيل 
          }),
          const SizedBox(height: 10),
          _buildActionBtn(context, 'تبديل الحساب', Icons.swap_horiz_rounded, emeraldColor, () {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('جاري الانتقال للحساب الآخر...'))
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: color),
        label: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  void _showSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text('Support Center', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 25),
            _buildSupportOption(Icons.telegram, 'Telegram', 'Support via Telegram', () async {
              final Uri url = Uri.parse('https://t.me/black4crow');
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                throw 'Could not launch $url';
              }
            }),
            _buildSupportOption(Icons.whatsapp, 'WhatsApp', 'Support via WhatsApp', () {
              // سطر مخصص للمستقبل: أضف رابط الواتساب هنا (api.whatsapp.com/send?phone=...)
            }),
            _buildSupportOption(Icons.email_outlined, 'Email', 'Support via Email', () {
              // سطر مخصص للمستقبل: أضف رابط الإيميل هنا (mailto:support@raseed.com)
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(IconData icon, String title, String sub, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: emeraldColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: emeraldColor, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      onTap: onTap,
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle, {bool isLogout = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red.withOpacity(0.05) : const Color(0xFFF4F7F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isLogout ? Colors.red : emeraldColor, size: 20), // [cite: 220]
      ),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isLogout ? Colors.red : Colors.black)), // [cite: 220]
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)) : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}
