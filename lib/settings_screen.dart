import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userName = "مرتضى محمد"; // الاسم الافتراضي
  bool notificationsEnabled = true;

  // دالة لإظهار نافذة تعديل الاسم
  void _showEditNameDialog() {
    TextEditingController nameController = TextEditingController(text: userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الاسم', textAlign: TextAlign.right),
        content: TextField(
          controller: nameController,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(hintText: "أدخل اسمك الجديد"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => userName = nameController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF50C878)),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(color: Color(0xFF1B4332))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // قسم الملف الشخصي
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color(0xFF50C878).withOpacity(0.1),
                    child: const Icon(Icons.person, size: 40, color: Color(0xFF50C878)),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Text('0770XXXXXXX', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit_note, color: Color(0xFF50C878), size: 30),
                    onPressed: _showEditNameDialog, // فتح نافذة تعديل الاسم
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // قائمة الخيارات
            _buildSettingsItem(
              icon: Icons.notifications_none,
              title: 'الإشعارات',
              trailing: Switch(
                value: notificationsEnabled,
                onChanged: (val) => setState(() => notificationsEnabled = val),
                activeColor: const Color(0xFF50C878),
              ),
            ),
            _buildSettingsItem(
              icon: Icons.lock_outline,
              title: 'تغيير كلمة المرور',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.language,
              title: 'اللغة',
              subtitle: 'العربية',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.help_outline,
              title: 'مركز المساعدة',
              onTap: () {},
            ),
            
            const SizedBox(height: 30),

            // زر تسجيل الخروج
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                // منطق الخروج
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({required IconData icon, required String title, String? subtitle, Widget? trailing, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1B4332)),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
