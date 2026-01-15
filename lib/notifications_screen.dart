import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: ListView.builder(
        itemCount: 3, 
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 15), // تم تصحيح هذا السطر هنا
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFCCFF00).withOpacity(0.2),
                  child: const Icon(Icons.notifications_active, color: Color(0xFF50878C)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('تنبيه من رصيد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 5),
                      Text('تم استلام طلب تحويل الرصيد بنجاح، جاري المعالجة.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
