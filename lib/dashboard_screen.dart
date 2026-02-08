import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart' as intl; // استيراد intl لتنسيق الأرقام

import 'notifications_screen.dart'; 
import 'discounts_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final Color emeraldColor = const Color(0xFF50878C);
  final Color neonGreen = const Color(0xFFCCFF00); 
  final Color darkGrey = const Color(0xFF2F3542); // اللون الرمادي الداكن للبطاقة العلوية

  // --- متغيرات النظام الحية ---
  final User? currentUser = FirebaseAuth.instance.currentUser;
  int userPoints = 0;
  String? _hiddenQiNumber;
  late int _randomMemoji; 

  String? _transferType; 
  String? _telecomProvider;
  String? _receivingCard;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _senderPhoneController = TextEditingController();

  int _receiveAmount = 0;
  int _commission = 0;
  bool _isProcessing = false;
  bool _isInvalidAmount = false;
  
  int _dailyLimit = 50000;
  int _todayTransferredAmount = 0;
  bool _isOverDailyLimit = false;

  bool _isCheckingSim = false;
  bool _isSimMatch = true;
  String _simErrorMsg = "";

  // أرقام الخدمة الخاصة بالتطبيق
  final String _ourZainNumber = "07800000000"; // استبدل بالرقم الحقيقي
  final String _ourAsiaNumber = "07700000000"; // استبدل بالرقم الحقيقي

  @override
  void initState() {
    super.initState();
    // اختيار رقم عشوائي بين 1 و 7 لصور الميموجي
    _randomMemoji = math.Random().nextInt(7) + 1;
    _fetchUserData();
    _calculateTodayTotal(); // حساب إجمالي تحويلات اليوم للتحقق من السقف اليومي
  }

  // جلب بيانات المستخدم (النقاط، رقم البطاقة المخفي)
  void _fetchUserData() async {
    if (currentUser != null) {
      var doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          // التعديل: ترك حقل الهاتف فارغاً ليقوم المستخدم بإدخال رقم الشريحة الفعلي
          _senderPhoneController.text = ""; 
          userPoints = doc.data()?['points'] ?? 0;
          _hiddenQiNumber = doc.data()?['qi_number'];
        });
      }
    }
  }

  // حساب ما تم تحويله اليوم للتحقق من الحد اليومي (50,000)
  Future<void> _calculateTodayTotal() async {
    if (currentUser == null) return;
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    try {
      var query = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: currentUser!.uid)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();
      int total = 0;
      for (var doc in query.docs) {
        // نستثني العمليات الفاشلة فقط
        if (doc.data()['status'] != 'failed') {
          total += (doc.data()['amount'] as num).toInt();
        }
      }
      setState(() {
        _todayTransferredAmount = total;
      });
    } catch (e) {
      debugPrint("Error calculating today total: $e");
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _codeController.dispose();
    _senderPhoneController.dispose();
    super.dispose();
  }

  // التحقق من تطابق الشريحة (أندرويد فقط)
  Future<void> _validateSimCard(String inputNumber) async {
    if (kIsWeb || Platform.isIOS) return;
    
    setState(() { _isCheckingSim = true; _simErrorMsg = ""; });
    
    // محاكاة وقت التحقق (أو استبدالها بكود التحقق الفعلي من الشريحة إذا توفرت المكتبة)
    await Future.delayed(const Duration(milliseconds: 500));
    
    bool isValid = true;
    String msg = "";

    // التحقق من البادئات
    if (_telecomProvider == 'Zain' && !inputNumber.startsWith('078')) {
      isValid = false;
      msg = "رقم زين يجب أن يبدأ بـ 078";
    } else if (_telecomProvider == 'Asiacell' && !inputNumber.startsWith('077')) {
      isValid = false;
      msg = "رقم آسيا يجب أن يبدأ بـ 077";
    }

    if (mounted) {
      setState(() {
        _isCheckingSim = false;
        _isSimMatch = isValid;
        _simErrorMsg = msg;
      });
    }
  }

  // مسح QR Code
  void _scanQRCode() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.black, 
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent, 
              elevation: 0,
              leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
              title: const Text("مسح الكود", style: TextStyle(color: Colors.white, fontFamily: 'IBMPlexSansArabic')),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      String? raw = barcode.rawValue;
                      if (raw != null) {
                        // استخراج الأرقام فقط من الكود
                        setState(() => _codeController.text = raw.replaceAll(RegExp(r'[^0-9]'), ''));
                        Navigator.pop(context);
                        break;
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // توليد كود التحويل USSD
  String _generateUSSDCode(String provider, String amount) {
    String cleanAmount = amount.replaceAll(',', '');
    if (provider == "Zain") {
      return "*211*$_ourZainNumber*$cleanAmount#";
    } else {
      return "*222*$cleanAmount*$_ourAsiaNumber#";
    }
  }

  // تنفيذ الاتصال
  Future<void> _executeCall(String ussdCode) async {
    String encoded = ussdCode.replaceAll("#", "%23");
    final Uri url = Uri.parse("tel:$encoded");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("لا يمكن إجراء الاتصال")));
    }
  }

  // رسالة توجيه لمستخدمي iOS
  void _showIOSTutorialDialog(String ussdCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تأكيد التحويل", style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
        content: const Text("سيتم نقلك للوحة الاتصال، يرجى الضغط على زر الاتصال لإتمام التحويل.", style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
            onPressed: () { Navigator.pop(context); _executeCall(ussdCode); },
            child: const Text("موافق", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
          )
        ],
      ),
    );
  }

  // المعالجة الرئيسية للطلب وإرساله لقاعدة البيانات
  void _processOrder(StateSetter setModalState) async {
    // التحقق من المدخلات
    if (_amountController.text.isEmpty || _transferType == null || _telecomProvider == null || _senderPhoneController.text.isEmpty) {
       return;
    }

    if (_isOverDailyLimit) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تجاوزت سقف التحويل اليومي", style: TextStyle(fontFamily: 'IBMPlexSansArabic'))));
      return;
    }

    // التحقق من الشريحة (أندرويد فقط وتحويل مباشر)
    if (!kIsWeb && Platform.isAndroid && _transferType == 'direct' && !_isSimMatch) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_simErrorMsg.isNotEmpty ? _simErrorMsg : "يرجى التحقق من رقم الشريحة", style: const TextStyle(fontFamily: 'IBMPlexSansArabic'))));
       return;
    }

    setModalState(() => _isProcessing = true);
    
    try {
      // جلب اسم المستخدم الحالي
      var userSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).get();
      String userName = userSnapshot.data()?['full_name'] ?? "مستخدم";

      // إضافة الطلب لقاعدة البيانات مع الحقول الجديدة المطلوبة
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': currentUser?.uid,
        'userFullName': userName,
        'userPhone': _senderPhoneController.text, // رقم الشريحة المدخل
        'amount': int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0,
        'payout_amount': _receiveAmount, // المبلغ الصافي (بعد خصم العمولة)
        'createdAt': FieldValue.serverTimestamp(), // حقل الوقت المخفي للترتيب في الآدمن
        'transferType': _transferType,
        'telecomProvider': _telecomProvider,
        // إرسال رقم البطاقة الفعلي بدلاً من الاسم ليتمكن المدير من التحويل
        'receivingCard': _receivingCard == 'QiCard' ? (_hiddenQiNumber ?? '---') : _receivingCard, 
        'targetAccount': _receivingCard == 'QiCard' ? (_hiddenQiNumber ?? 'No Qi Number') : 'ZainCash',
        'targetInfo': _transferType == 'direct' ? 'Direct Transfer' : _codeController.text,
        'commission': _commission,
        'status': 'pending', // الحالة المبدئية
        'timestamp': FieldValue.serverTimestamp(), // وقت العرض للمستخدم
        'deviceType': kIsWeb ? 'Web' : (Platform.isAndroid ? 'Android' : 'iOS'),
      });

      setModalState(() => _isProcessing = false);

      // تنفيذ التحويل الفعلي (USSD) إذا كان مباشراً
      if (_transferType == 'direct') {
        String ussd = _generateUSSDCode(_telecomProvider!, _amountController.text);
        if (!kIsWeb && Platform.isIOS) {
          _showIOSTutorialDialog(ussd);
        } else {
          await _executeCall(ussd);
          _showDoubleCheckDialog();
        }
      } else {
        // إذا كان كود/QR فقط نعرض رسالة النجاح
        _showDoubleCheckDialog();
      }

    } catch (e) {
      setModalState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ: $e")));
    }
  }

  // حساب العمولة والصافي والتحقق من المبالغ
  void _calculateAmount(String value) {
    if (value.isEmpty) { 
      setState(() { 
        _isInvalidAmount = false; 
        _isOverDailyLimit = false;
        _receiveAmount = 0; 
      });
      return; 
    }

    int amount = int.tryParse(value.replaceAll(',', '')) ?? 0;
    
    setState(() {
      // التحقق من أن المبلغ من مضاعفات الألف
      _isInvalidAmount = (amount >= 1000 && amount % 1000 != 0);
      
      // التحقق من الحد اليومي
      if ((_todayTransferredAmount + amount) > _dailyLimit) {
        _isOverDailyLimit = true;
      } else {
        _isOverDailyLimit = false;
      }

      // حساب العمولة
      if (amount < 2000) { 
        _commission = 0; _receiveAmount = 0; 
      } else {
        if (userPoints >= 50) { // خصم خاص للنقاط
          _commission = 0; 
        } else if (amount >= 10000) {
          _commission = ((amount * 0.10) / 1000).round() * 1000;
        } else { 
          _commission = 1000; 
        }
        _receiveAmount = amount - _commission;
      }
    });
  }
  
  // حوار تأكيد النجاح
  void _showDoubleCheckDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.green, size: 40),
              ),
              const SizedBox(height: 20),
              const Text("تم إرسال الطلب!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
              const SizedBox(height: 10),
              const Text("جاري معالجة طلبك، سيصلك إشعار فور اكتمال التحويل.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontFamily: 'IBMPlexSansArabic')),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: emeraldColor, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    Navigator.pop(context); // إغلاق الديالوج
                    Navigator.pop(context); // إغلاق الشيت
                    _amountController.clear();
                    _codeController.clear();
                  },
                  child: const Text("حسناً", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // صفحات التنقل السفلية
    final List<Widget> _pages = [
      _buildHomeContent(), 
      const OrdersScreen(), 
      const DiscountsScreen(), 
      const ProfileScreen()
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // === المحتوى الرئيسي للصفحة الرئيسية ===
  Widget _buildHomeContent() {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildGlassHeader(), // الهيدر المعدل
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  _buildMainCard(),
                  const SizedBox(height: 40),
                  const Text('حول رصيدك الآن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildNetworkCard('آسيا سيل', 'Asiacell', 'assets/fonts/images/asiacell_logo.png', const Color(0xFFEE2737))),
                      const SizedBox(width: 15),
                      Expanded(child: _buildNetworkCard('زين العراق', 'Zain IQ', 'assets/fonts/images/zain_logo.png', const Color(0xFF00B2A9))),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildRecentTransactionsHeader(),
                  
                  // تعديل: عرض آخر 5 تحويلات *ناجحة* فقط 
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('orders')
                        .where('userId', isEqualTo: currentUser?.uid)
                        .where('status', isEqualTo: 'successful') // الشرط الجديد: ناجحة فقط
                        .orderBy('timestamp', descending: true)
                        .limit(5)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildEmptyState();
                      }
                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100)),
                            child: Row(
                              children: [
                                // أيقونة النجاح الثابتة لأننا نعرض الناجحة فقط
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    shape: BoxShape.circle
                                  ),
                                  child: const Icon(Icons.check_rounded, color: Colors.green, size: 20),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("تحويل إلى ${data['telecomProvider']}", style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
                                      Text("تم بنجاح", style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontFamily: 'IBMPlexSansArabic')),
                                    ],
                                  ),
                                ),
                                Text("-${data['amount']} د.ع", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === الهيدر المعدل (الرمادي الداكن + الميموجي + الإشعارات) ===
  Widget _buildGlassHeader() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).snapshots(),
      builder: (context, snapshot) {
        String fullName = "تحميل...";
        if (snapshot.hasData && snapshot.data!.data() != null) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          fullName = data['full_name'] ?? 'مستخدم رصيد';
        }

        return Container(
          width: double.infinity,
          height: 260,
          decoration: BoxDecoration(
            color: darkGrey, // تغيير اللون للرمادي الداكن
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
          ),
          child: Stack(
            children: [
              // دوائر خلفية جمالية
              Positioned(top: -40, right: -40, child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.03))),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 50, 25, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الصف العلوي: الترحيب + زر الإشعارات بالنقطة الحمراء
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("أهلاً بك", style: TextStyle(color: Colors.white60, fontSize: 14, fontFamily: 'IBMPlexSansArabic')),
                        
                        // منطق النقطة الحمراء للإشعارات
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('notifications')
                              .where('userId', isEqualTo: currentUser?.uid)
                              .where('isRead', isEqualTo: false) // البحث عن غير المقروءة
                              .snapshots(),
                          builder: (context, notifSnap) {
                            // التحقق من وجود إشعارات غير مقروءة
                            bool hasUnread = notifSnap.hasData && notifSnap.data!.docs.isNotEmpty;
                            
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                                  child: IconButton(
                                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.white), 
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
                                  ),
                                ),
                                // رسم النقطة الحمراء إذا وجدت إشعارات
                                if (hasUnread)
                                  Positioned(
                                    right: 10,
                                    top: 10,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: darkGrey, width: 2)
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // صف الصورة والاسم (تم التعديل: إزالة الإطار وتصغير الحجم)
                    Row(
                      children: [
                        // صورة الميموجي بدون إطار أخضر
                        CircleAvatar(
                          radius: 28, // تصغير الحجم (كان 35)
                          backgroundColor: Colors.transparent, // خلفية شفافة
                          backgroundImage: AssetImage('assets/fonts/images/memoji_$_randomMemoji.png'), // التأكد من المسار
                        ),
                        const SizedBox(width: 15),
                        Text(
                          fullName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    // عرض إجمالي الرصيد المحول (المحسوب من الطلبات الناجحة فقط)
                    const Text('إجمالي الرصيد المحول', style: TextStyle(color: Colors.white54, fontSize: 13, fontFamily: 'IBMPlexSansArabic')),
                    const SizedBox(height: 5),
                    
                    // حساب المجموع بشكل حي
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('orders')
                          .where('userId', isEqualTo: currentUser?.uid)
                          .where('status', isEqualTo: 'successful') // فقط الناجحة
                          .snapshots(),
                      builder: (context, snapshot) {
                        int totalTransferred = 0;
                        if (snapshot.hasData) {
                          for (var doc in snapshot.data!.docs) {
                            totalTransferred += (doc.data() as Map<String, dynamic>)['amount'] as int? ?? 0;
                          }
                        }
                        return Text('${intl.NumberFormat('#,###').format(totalTransferred)} د.ع', 
                          style: const TextStyle(color: Color(0xFFCCFF00), fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic'));
                      }
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('حالة المحفظة', style: TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'IBMPlexSansArabic')), SizedBox(height: 5), Text('فعالة ونشطة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'IBMPlexSansArabic'))]),
        Icon(Icons.verified_user_rounded, color: emeraldColor, size: 30),
      ]),
    );
  }

  Widget _buildNetworkCard(String name, String sub, String imagePath, Color color) { 
    return Container(
      height: 180, 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset(imagePath, fit: BoxFit.cover)),
            Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.7)])))),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'IBMPlexSansArabic')),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showConversionSheet(name, color),
                    style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(double.infinity, 36), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('تحويل', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'IBMPlexSansArabic')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ورقة التحويل السفلية
  void _showConversionSheet(String provider, Color color) {
    setState(() {
      _telecomProvider = (provider.contains("Zain") || provider.contains("زين")) ? "Zain" : "Asiacell";
    });
    // تحديث إجمالي اليوم قبل الفتح
    _calculateTodayTotal();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 25, right: 25, top: 15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_forward_ios_rounded, size: 22), onPressed: () => Navigator.pop(context)),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                    const SizedBox(width: 40),
                  ],
                ),
                Text('تحويل رصيد $provider', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
                const SizedBox(height: 25),
                
                _buildFieldLabel('اختر نوع التحويل:'),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('نوع التحويل'),
                  items: const [DropdownMenuItem(value: 'direct', child: Text('تحويل رصيد مباشر')), DropdownMenuItem(value: 'code', child: Text('ارسال كود السري / QR'))],
                  onChanged: (val) => setModalState(() => _transferType = val),
                ),
          
                if (_transferType != null) ...[
                  const SizedBox(height: 15),
                  if (_transferType == 'code') ...[
                    _buildFieldLabel('الكود السري للكرت:'),
                    TextField(
                      controller: _codeController,
                      decoration: _inputDecoration('ادخل الكود').copyWith(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.blue),
                          onPressed: _scanQRCode,
                        )
                      )
                    ),
                    const SizedBox(height: 15),
                  ],
                ],

                if (_telecomProvider != null) ...[
                  const SizedBox(height: 15),
                  _buildFieldLabel('بطاقة الاستلام:'),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('اختر البطاقة').copyWith(
                      errorText: (_receivingCard == 'QiCard' && (_hiddenQiNumber == null || _hiddenQiNumber!.isEmpty))
                          ? "يرجى إضافة رقم البطاقة من الملف الشخصي"
                          : null,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'QiCard', 
                        child: Row(
                          children: [
                            Image.asset('assets/fonts/images/qi_card_icon.png', width: 24, height: 24),
                            const SizedBox(width: 10),
                            const Text('Qi card'),
                          ],
                        )
                      )
                    ],
                    onChanged: (val) => setModalState(() => _receivingCard = val),
                  ),
                ],

                if (_receivingCard != null) ...[
                  const SizedBox(height: 15),
                  _buildFieldLabel('رقم شريحة الهاتف:'),
                  TextFormField(
                    controller: _senderPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('أدخل رقم شريحته الحالية').copyWith(
                      fillColor: Colors.blueGrey.shade50,
                      suffixIcon: _isCheckingSim ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)) : 
                        (_senderPhoneController.text.isNotEmpty ? Icon(_isSimMatch ? Icons.check_circle : Icons.error, color: _isSimMatch ? Colors.green : Colors.red, size: 18) : const Icon(Icons.phone_android, size: 18)),
                      helperText: (!_isSimMatch && _simErrorMsg.isNotEmpty) ? _simErrorMsg : null,
                      helperStyle: const TextStyle(color: Colors.red),
                    ),
                    onChanged: (val) {
                      if (!kIsWeb && Platform.isAndroid && val.length > 9) {
                        _validateSimCard(val);
                        setModalState(() {});
                      }
                    },
                  ),

                  const SizedBox(height: 15),
                  _buildFieldLabel('قيمة الرصيد (بالآلاف):'),
                  TextField(
                    controller: _amountController,
                    decoration: _inputDecoration('مثلاً 5000').copyWith(
                      errorText: _isOverDailyLimit 
                          ? 'تجاوزت سقف التحويل اليومي' 
                          : (_isInvalidAmount ? 'يرجى إدخال آلاف كاملة' : null),
                      errorStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                       _calculateAmount(val);
                       setModalState(() {});
                    },
                  ),

                  if (_amountController.text.isNotEmpty && !_isInvalidAmount && !_isOverDailyLimit)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('العمولة: $_commission د.ع', style: TextStyle(color: _commission == 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                          Text('الصافي: $_receiveAmount د.ع', style: const TextStyle(fontWeight: FontWeight.bold))
                        ]
                      )
                    ),

                  const SizedBox(height: 25),
                  _buildRasedPayButton(color, setModalState),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRasedPayButton(Color color, StateSetter setModalState) {
    bool isQiCardMissing = _receivingCard == 'QiCard' && (_hiddenQiNumber == null || _hiddenQiNumber!.isEmpty);
    bool canConfirm = !isQiCardMissing && !_isInvalidAmount && !_isOverDailyLimit && _amountController.text.isNotEmpty && _senderPhoneController.text.isNotEmpty && _isSimMatch;
    
    return Opacity(
      opacity: canConfirm ? 1.0 : 0.4,
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: neonGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
          onPressed: canConfirm ? () => _processOrder(setModalState) : null,
          child: _isProcessing ? const CircularProgressIndicator(color: Colors.black) : const Text('تأكيد الطلب', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'IBMPlexSansArabic')),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) => Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'IBMPlexSansArabic'))));
  InputDecoration _inputDecoration(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12));
  
  Widget _buildRecentTransactionsHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('آخر التحويلات الناجحة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')), TextButton(onPressed: () {}, child: Text('الكل', style: TextStyle(color: emeraldColor, fontFamily: 'IBMPlexSansArabic')))]);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
              child: Icon(Icons.history_toggle_off_rounded, size: 50, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 15),
            const Text('لا توجد عمليات ناجحة حالياً', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'IBMPlexSansArabic')),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex, 
      onTap: (i) => setState(() => _selectedIndex = i), 
      type: BottomNavigationBarType.fixed, 
      selectedItemColor: emeraldColor, 
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'), 
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'الطلبات'), 
        BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'العروض'), 
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي')
      ]
    );
  }
}
