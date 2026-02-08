import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  final Color emeraldColor = const Color(0xFF50878C);

  @override
  Widget build(BuildContext context) {
    // الحصول على معرف المستخدم الحالي لضمان الخصوصية 
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('سجل الطلبات', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
          bottom: TabBar(
            labelColor: emeraldColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: emeraldColor,
            tabs: const [
              Tab(text: 'النشطة'),
              Tab(text: 'المكتملة'),
            ],
          ),
        ),
        body: currentUserId == null 
            ? const Center(child: Text("يرجى تسجيل الدخول"))
            : TabBarView(
                children: [
                  // التعديل: إضافة حالة waiting_admin_confirmation للتبويب النشط 
                  _buildOrdersList(
                    userId: currentUserId, 
                    statusList: ['pending', 'waiting_admin_confirmation', 'failed'], 
                    isActiveTab: true
                  ),
                  // التعديل: عرض الحالات الناجحة فقط باسم successful 
                  _buildOrdersList(
                    userId: currentUserId, 
                    statusList: ['successful'], 
                    isActiveTab: false
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOrdersList({required String userId, required List<String> statusList, required bool isActiveTab}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId) // فلترة الطلبات للمستخدم الحالي فقط 
          .where('status', whereIn: statusList) 
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('حدث خطأ في تحميل البيانات', style: TextStyle(fontFamily: 'IBMPlexSansArabic')));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(isActiveTab);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;
           
            return GestureDetector(
              onTap: () => _showOrderDetails(context, data, doc.id),
              child: _buildOrderCard(data, doc.id, isActiveTab),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> data, String docId, bool isActiveTab) {
    String provider = data['telecomProvider'] ?? 'غير محدد';
    String logoPath = _getLogoPath(provider);
    int amount = data['amount'] ?? 0;
    int commission = data['commission'] ?? 0;
    int net = amount - commission;
    String status = data['status'] ?? 'unknown';
    
    Timestamp? timestamp = data['timestamp'];
    String dateStr = timestamp != null 
        ? DateFormat('yyyy-MM-dd').format(timestamp.toDate()) 
        : '---';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Image.asset(logoPath, width: 40, height: 40, errorBuilder: (c,o,s) => const Icon(Icons.error)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('طلب تحويل #${docId.substring(0, 5)}', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
                const SizedBox(height: 5),
                Text('$provider - $dateStr', style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'IBMPlexSansArabic')),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$net د.ع', style: TextStyle(color: emeraldColor, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(status),
                  style: TextStyle(fontSize: 10, color: _getStatusColor(status), fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> data, String docId) {
    String provider = data['telecomProvider'] ?? '---';
    String type = data['transferType'] == 'direct' ? 'تحويل مباشر' : 'كود / QR';
    String target = data['targetInfo'] ?? '---';
    String userPhone = data['userPhone'] ?? '---';
    int amount = data['amount'] ?? 0;
    int commission = data['commission'] ?? 0;
    int net = amount - commission;
    String status = data['status'] ?? 'pending';
    
    Timestamp? timestamp = data['timestamp'];
    String dateFull = timestamp != null 
        ? DateFormat('yyyy-MM-dd hh:mm a').format(timestamp.toDate()) 
        : '---';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.70,
        decoration: const BoxDecoration(
          color: Color(0xFFF4F7F7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text('تفاصيل الوصل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
            const SizedBox(height: 15),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildReceiptRow('رقم الطلب', '#$docId'),
                  _buildReceiptRow('الشركة', provider),
                  _buildReceiptRow('نوع العملية', type),
                  _buildReceiptRow('هاتف المرسل', userPhone),
                  _buildReceiptRow('المستهدف/الكود', target.length > 15 ? '${target.substring(0,10)}...' : target),
                  const Divider(height: 20),
                  _buildReceiptRow('المبلغ المرسل', '$amount د.ع'),
                  _buildReceiptRow('العمولة', '$commission د.ع', isNegative: true),
                  const Divider(height: 20),
                  _buildReceiptRow('الصافي المستلم', '$net د.ع', isBold: true),
                  _buildReceiptRow('التاريخ', dateFull),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text(
                          _getStatusText(status),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _getStatusColor(status), fontFamily: 'IBMPlexSansArabic'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: emeraldColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إغلاق', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'IBMPlexSansArabic')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isNegative = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'IBMPlexSansArabic')),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                fontSize: isBold ? 15 : 13,
                color: isNegative ? Colors.red : Colors.black,
                fontFamily: 'IBMPlexSansArabic',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isActiveTab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isActiveTab ? Icons.hourglass_empty_rounded : Icons.check_circle_outline, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text(isActiveTab ? 'لا توجد طلبات نشطة حالياً' : 'لا توجد طلبات مكتملة حالياً', style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontFamily: 'IBMPlexSansArabic')),
        ],
      ),
    );
  }

  String _getLogoPath(String provider) {
    if (provider.contains('Zain') || provider.contains('زين')) {
      return 'assets/fonts/images/zain_logo.png';
    } else {
      return 'assets/fonts/images/asiacell_logo.png';
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'successful': return 'تم التحويل بنجاح';
      case 'pending': 
      case 'waiting_admin_confirmation': return 'قيد المعالجة (انتظار)';
      case 'failed': return 'فشل التحويل';
      default: return 'قيد الانتظار';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'successful': return Colors.green;
      case 'pending':
      case 'waiting_admin_confirmation': return Colors.orange;
      case 'failed': return Colors.red;
      default: return Colors.grey;
    }
  }
}
