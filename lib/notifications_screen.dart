import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart' as intl;

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. الحصول على معرف المستخدم الحالي
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final Color emeraldColor = const Color(0xFF50878C);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      appBar: AppBar(
        title: const Text('الإشعارات', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // 2. بناء القائمة بناءً على البيانات القادمة من Firebase
      body: currentUserId == null
          ? _buildLoginError()
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  // --- التعديل الجوهري هنا ---
                  // بدلاً من طلب إشعارات المستخدم فقط، نطلب إشعاراته + الإشعارات العامة (all)
                  .where('userId', whereIn: [currentUserId, 'all']) 
                  .orderBy('timestamp', descending: true) // ترتيب حسب الوقت (الأحدث فوق)
                  .snapshots(),
              builder: (context, snapshot) {
                // معالجة حالات الانتظار والأخطاء
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ بسيط في التحميل', style: TextStyle(color: Colors.grey.shade400)));
                  // ملاحظة: إذا ظهر خطأ في أول مرة، قد يطلب منك Firebase إنشاء Index عبر رابط في الكونسول
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                // عرض القائمة النهائية
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  padding: const EdgeInsets.all(20),
                  itemBuilder: (context, index) {
                    var notification = snapshot.data!.docs[index];
                    var data = notification.data() as Map<String, dynamic>;

                    // استخراج البيانات (العناوين والنصوص تأتي من قاعدة البيانات ديناميكياً)
                    String title = data['title'] ?? 'إشعار إداري';
                    String body = data['body'] ?? '';
                    bool isRead = data['isRead'] ?? false;
                    // تمييز الإشعار العام بأيقونة مختلفة (اختياري)
                    bool isGlobal = data['userId'] == 'all'; 
                    Timestamp? timestamp = data['timestamp'];

                    String timeAgo = '';
                    if (timestamp != null) {
                      timeAgo = _formatTimestamp(timestamp);
                    }

                    return Dismissible(
                      key: Key(notification.id),
                      direction: DismissDirection.endToStart,
                      // المستخدم لا يستطيع حذف الإشعارات العامة (لأنها لكل الناس)
                      confirmDismiss: (direction) async {
                        return !isGlobal; 
                      },
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(15)),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      onDismissed: (direction) {
                        if (!isGlobal) {
                          FirebaseFirestore.instance.collection('notifications').doc(notification.id).delete();
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          // تمييز الإشعار غير المقروء بلون خلفية مختلف
                          color: isRead ? Colors.white : const Color(0xFFCCFF00).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                          border: isRead ? null : Border.all(color: const Color(0xFFCCFF00).withOpacity(0.5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: isGlobal 
                                ? Colors.orange.withOpacity(0.2) // لون مميز للإشعارات العامة
                                : const Color(0xFFCCFF00).withOpacity(0.2),
                              child: Icon(
                                isGlobal ? Icons.campaign_rounded : (data['type'] == 'alert' ? Icons.warning_amber_rounded : Icons.notifications_active),
                                color: isGlobal ? Colors.orange[800] : emeraldColor,
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
                                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text(timeAgo, style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(body, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

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
          const Text('لا توجد إشعارات حالياً', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildLoginError() {
    return const Center(child: Text("يرجى تسجيل الدخول"));
  }
}
