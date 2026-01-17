import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; // تمت الإضافة للإصلاح
import 'manage_payments_screen.dart';
import 'successful_operations_screen.dart'; 
import 'signup_screen.dart'; 
import 'login_screen.dart'; // تمت الإضافة للإصلاح

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
              _buildSupportSection(),
              const SizedBox(height: 20),
              _buildAccountActions(context),
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
          child: Icon(Icons.person, size: 50, color: emeraldColor),
        ),
        const SizedBox(height: 15),
        const Text(
          "مستخدم رصيد",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Text(
          "raseed_user@example.com",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalTransferredCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "إجمالي المحول",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 5),
              Text(
                "0 د.ع",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: emeraldColor,
                ),
              ),
            ],
          ),
          Icon(Icons.account_balance_wallet_outlined, color: emeraldColor, size: 30),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            Icons.history_rounded,
            "سجل العمليات الناجحة",
            "عرض كافة التحويلات السابقة",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SuccessfulOperationsScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsTile(
            Icons.payment_rounded,
            "إدارة طرق الدفع",
            "بطاقاتك المحفوظة والتحويل",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManagePaymentsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildSupportOption(
            Icons.headset_mic_rounded,
            "الدعم الفني",
            "تحدث معنا لحل مشاكلك",
            () async {
              final Uri url = Uri.parse('https://wa.me/9647700000000');
              if (!await launchUrl(url)) throw 'Could not launch $url';
            },
          ),
          const Divider(height: 1, indent: 60),
          _buildSupportOption(
            Icons.info_outline_rounded,
            "عن رصيد",
            "تعرف على خدماتنا وشروطنا",
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            Icons.person_add_alt_1_rounded,
            "إنشاء حساب جديد",
            "",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignupScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsTile(
            Icons.logout_rounded,
            "تسجيل الخروج",
            "الخروج من الحساب الحالي",
            isLogout: true,
            onTap: () async {
              // --- منطق الإصلاح الجديد هنا ---
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption(IconData icon, String title, String sub, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: emeraldColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
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
        child: Icon(icon, color: isLogout ? Colors.red : emeraldColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isLogout ? Colors.red : Colors.black,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey))
          : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}
