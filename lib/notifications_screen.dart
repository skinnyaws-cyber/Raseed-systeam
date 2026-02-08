import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart' as intl;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    // عند فتح الشاشة، نقوم بتحديث تاريخ آخر تفقد للإشعارات
    _markNotificationsAsSeen();
  }

  // هذه الدالة هي الحل السحري: تحدث ملف المستخدم ليقول للنظام "لقد رأيت كل شيء حتى هذه اللحظة"
  Future<void> _markNotificationsAsSeen() async {
    if (currentUserId != null) {
      await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'last_notification_check': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color emeraldColor = const Color(0xFF50878C);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      appBar: AppBar(
        title: const Text('الإشعارات', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: currentUserId == null
          ? _buildLoginError()
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', whereIn: [currentUserId, 'all']) // جلب الخاص والعام
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('حدث خطأ في تحميل البيانات'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  padding: const EdgeInsets.all(20),
                  itemBuilder: (context, index) {
                    var notification = snapshot.data!.docs[index];
                    var data = notification.data() as Map<String, dynamic>;

                    String title = data['title'] ?? 'إشعار إداري';
                    String body = data['body'] ?? '';
                    bool isGlobal = data['userId'] == 'all'; 
                    Timestamp? timestamp = data['timestamp'];

                    String timeAgo = timestamp != null ? _formatTimestamp(timestamp) : '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                        // تمييز الإشعار العام بإطار خفيف
                        border: isGlobal ? Border.all(color: Colors.orange.withOpacity(0.3)) : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: isGlobal 
                              ? Colors.orange.withOpacity(0.1) 
                              : const Color(0xFFCCFF00).withOpacity(0.2),
                            child: Icon(
                              isGlobal ? Icons.campaign_rounded : Icons.notifications_active,
                              color: isGlobal ? Colors.orange : emeraldColor,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'IBMPlexSansArabic')),
                                    Text(timeAgo, style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontFamily: 'IBMPlexSansArabic')),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(body, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontFamily: 'IBMPlexSansArabic')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  // ... (نفس الدوال المساعدة _formatTimestamp و _buildEmptyState و _buildLoginError الموجودة سابقاً) ...
  // فقط تأكد من نسخها أو إبقائها كما هي في الكود الأصلي
  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    Duration diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return intl.DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          const Text('لا توجد إشعارات حالياً', style: TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'IBMPlexSansArabic')),
        ],
      ),
    );
  }

  Widget _buildLoginError() {
    return const Center(child: Text("يرجى تسجيل الدخول"));
  }
}
