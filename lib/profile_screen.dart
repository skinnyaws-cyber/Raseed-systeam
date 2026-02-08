import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'successful_operations_screen.dart'; 
import 'login_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color emeraldColor = const Color(0xFF50878C);
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _qiAccountController = TextEditingController();
  final TextEditingController _recoveryEmailController = TextEditingController();

  @override
  void dispose() {
    _qiAccountController.dispose();
    _recoveryEmailController.dispose();
    super.dispose();
  }

  Future<void> _launchLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تعذر فتح الرابط")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) return const Center(child: Text("يرجى تسجيل الدخول"));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            var userData = userSnapshot.data!.data() as Map<String, dynamic>;
            String name = userData['full_name'] ?? "مستخدم رصيد";
            String phone = userData['phone_number'] ?? "---";
            String qiNumber = userData['qi_number'] ?? ""; 
            String recoveryEmail = userData['recovery_email'] ?? "";

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  _buildProfileHeader(name, phone),
                  const SizedBox(height: 25),
                  _buildLiveTotalCard(),
                  const SizedBox(height: 25),
                  _buildSettingsSection(context, qiNumber, recoveryEmail),
                  const SizedBox(height: 20),
                  _buildSupportSection(),
                  const SizedBox(height: 20),
                  _buildAccountActions(context),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String phone) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: emeraldColor.withOpacity(0.1),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : "U",
            style: TextStyle(fontSize: 40, color: emeraldColor, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 15),
        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(phone, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildLiveTotalCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: currentUser?.uid)
          .where('status', isEqualTo: 'success')
          .snapshots(),
      builder: (context, snapshot) {
        int totalReceived = 0;
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            int amount = data['amount'] ?? 0;
            int commission = data['commission'] ?? 0;
            totalReceived += (amount - commission);
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: emeraldColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: emeraldColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('إجمالي الأموال المستلمة', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 10),
                  Text('$totalReceived د.ع', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 30),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection(BuildContext context, String currentQiNumber, String currentRecoveryEmail) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _buildSettingsTile(
            Icons.history_rounded, 
            'سجل العمليات الناجحة', 
            'عرض تفاصيل الأموال المستلمة', 
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SuccessfulOperationsScreen())),
          ),
          const Divider(indent: 20, endIndent: 20),
          
          _buildSettingsTile(
            Icons.credit_card_rounded, 
            'حساب Qi Card', 
            currentQiNumber.isEmpty ? 'لم يتم إضافة حساب' : '...${currentQiNumber.length > 4 ? currentQiNumber.substring(currentQiNumber.length - 4) : currentQiNumber}',
            onTap: () => _showQiCardSheet(context, currentQiNumber),
          ),
          const Divider(indent: 20, endIndent: 20),

          _buildSettingsTile(
            Icons.mark_email_read_rounded, 
            'ايميل الاسترداد', 
            currentRecoveryEmail.isEmpty ? 'اضغط للإضافة' : currentRecoveryEmail, 
            onTap: () => _showRecoveryEmailSheet(context, currentRecoveryEmail),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _buildSettingsTile(Icons.headset_mic_rounded, 'الدعم الفني', 'تواصل مع فريق رصيد', onTap: () => _showSupportSheet(context)),
          const Divider(indent: 20, endIndent: 20),
          _buildSettingsTile(Icons.info_outline_rounded, 'عن رصيد', 'الموقع الرسمي', onTap: () => _launchLink('https://raseedpay.netlify.app/')), 
        ],
      ),
    );
  }

  Widget _buildAccountActions(BuildContext context) {
    return Column(
      children: [
        TextButton.icon(
          onPressed: () {}, 
          icon: Icon(Icons.add_circle_outline, color: emeraldColor),
          label: Text('إضافة حساب جديد', style: TextStyle(color: emeraldColor, fontWeight: FontWeight.bold)),
        ),
        TextButton.icon(
          onPressed: () => _showSwitchAccountSheet(context),
          icon: const Icon(Icons.swap_horiz_rounded, color: Colors.orange),
          label: const Text('التبديل بين الحسابات', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        ),
        TextButton.icon(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginScreen()), (route) => false);
            }
          },
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // --- النوافذ المنبثقة ---

  void _showQiCardSheet(BuildContext context, String currentNumber) {
    _qiAccountController.text = currentNumber;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("حساب Qi Card للاستلام", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("سيتم تحويل أموالك لهذا الحساب تلقائياً", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
            
            TextField(
              controller: _qiAccountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "رقم الحساب البنكي",
                hintText: "الرقم القصير أسفل الرقم الطويل",
                filled: true, fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                prefixIcon: const Icon(Icons.credit_card),
              ),
            ),
            const SizedBox(height: 15),

            // زر المساعدة
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.help_outline, size: 18, color: Colors.blue),
                label: const Text("أين أجد الرقم؟ اضغط للتوضيح", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                onPressed: () {
                  showDialog(
                    context: context, 
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Colors.transparent, 
                      elevation: 0,
                      contentPadding: EdgeInsets.zero,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Animated3DCard(), // استدعاء البطاقة بالصورة المحلية
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: const CircleBorder(), padding: const EdgeInsets.all(15)),
                            child: const Icon(Icons.close, color: Colors.black),
                          )
                        ],
                      ),
                    )
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: emeraldColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
                    'qi_number': _qiAccountController.text
                  });
                  if(context.mounted) Navigator.pop(context);
                },
                child: const Text("حفظ الحساب", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showRecoveryEmailSheet(BuildContext context, String currentEmail) {
    _recoveryEmailController.text = currentEmail;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("تحديث ايميل الاسترداد", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _recoveryEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "البريد الإلكتروني",
                filled: true, fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: emeraldColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
                    'recovery_email': _recoveryEmailController.text
                  });
                  if(context.mounted) Navigator.pop(context);
                },
                child: const Text("حفظ التغييرات", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("تواصل معنا", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildSupportItem(Icons.telegram, "Telegram", "تواصل مباشر", () => _launchLink("https://t.me/raseedpay"), Colors.blue),
            _buildSupportItem(Icons.email, "Email", "راسلنا عبر البريد", () => _launchLink("mailto:payrassed@gmail.com"), Colors.red),
            _buildSupportItem(Icons.chat, "WhatsApp", "قريباً", () {}, Colors.green),
            _buildSupportItem(Icons.camera_alt, "Instagram", "اتطلع على اخر التحديثات", () => _launchLink("https://www.instagram.com/raseedpay?igsh=MTFtZWcyZzNkb3diZw%3D%3D&utm_source=qr"), Colors.pink),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSwitchAccountSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("تبديل الحساب", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text("الحساب الحالي"),
              subtitle: Text(currentUser?.email ?? ""),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            const Divider(),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.black)),
              title: const Text("تسجيل الدخول بحساب آخر"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginScreen()), (route) => false);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportItem(IconData icon, String title, String sub, VoidCallback onTap, Color color) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      onTap: onTap,
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: emeraldColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: emeraldColor, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}

// --- ويدجيت البطاقة المتحركة (الصورة المحلية) ---
class Animated3DCard extends StatefulWidget {
  const Animated3DCard({super.key});

  @override
  State<Animated3DCard> createState() => _Animated3DCardState();
}

class _Animated3DCardState extends State<Animated3DCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: -0.06, end: 0.06).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) 
            ..rotateY(_animation.value) 
            ..rotateX(_animation.value * 0.3), 
          alignment: Alignment.center,
          child: child,
        );
      },
      child: Container(
        height: 190,
        width: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 15))
          ],
        ),
        // === هنا تم وضع الصورة المحلية ===
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            'assets/fonts/images/raseed-card.png', // المسار الذي طلبته
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade300,
              child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),
        ),
      ),
    );
  }
}
