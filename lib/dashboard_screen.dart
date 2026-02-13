import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart' as intl;

import 'notifications_screen.dart'; 
import 'discounts_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'transfer_instructions_screen.dart'; // استدعاء واجهة التعليمات الجديدة

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final Color emeraldColor = const Color(0xFF50878C);
  final Color neonGreen = const Color(0xFFCCFF00); 
  final Color darkGrey = const Color(0xFF2F3542);

  // --- متغيرات النظام الحية ---
  final User? currentUser = FirebaseAuth.instance.currentUser;
  int userPoints = 0;
  String? _hiddenQiNumber;
  late int _randomMemoji; 

  String? _transferType = 'direct'; // تعيين مباشر كقيمة افتراضية ووحيدة
  String? _telecomProvider;
  String? _receivingCard;

  final TextEditingController _amountController = TextEditingController();
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
    _randomMemoji = math.Random().nextInt(7) + 1;
    _fetchUserData();
    _calculateTodayTotal();
  }

  void _fetchUserData() async {
    if (currentUser != null) {
      var doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _senderPhoneController.text = ""; 
          userPoints = doc.data()?['points'] ?? 0;
          _hiddenQiNumber = doc.data()?['qi_number'];
        });
      }
    }
  }

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
    _senderPhoneController.dispose();
    super.dispose();
  }

  Future<void> _validateSimCard(String inputNumber) async {
    if (kIsWeb || Platform.isIOS) return;
    setState(() { _isCheckingSim = true; _simErrorMsg = ""; });
    
    await Future.delayed(const Duration(milliseconds: 500));
    bool isValid = true;
    String msg = "";

    // التعديل: زين يقبل 078 و 079
    if (_telecomProvider == 'Zain' && !inputNumber.startsWith('078') && !inputNumber.startsWith('079')) {
      isValid = false;
      msg = "رقم زين يجب أن يبدأ بـ 078 أو 079";
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

  // التعديل: صيغة آسيا سيل الجديدة
  String _generateUSSDCode(String provider, String amount) {
    String cleanAmount = amount.replaceAll(',', '');
    if (provider == "Asiacell") {
      return "*123*$cleanAmount*$_ourAsiaNumber#";
    }
    return "";
  }

  Future<void> _executeCall(String ussdCode) async {
    String encoded = ussdCode.replaceAll("#", "%23");
    final Uri url = Uri.parse("tel:$encoded");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("لا يمكن إجراء الاتصال")));
    }
  }

  // دالة مساعدة لترميز بيانات الرسالة (تجنب مشاكل iOS/Android)
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  // التعديل: تنفيذ إرسال رسالة SMS الخاصة بزين
  Future<void> _executeSMS(String amount) async {
    String cleanAmount = amount.replaceAll(',', '');
    String message = "$_ourZainNumber $cleanAmount";
    
    final Uri smsLaunchUri = Uri(
      scheme: 'sms',
      path: '21112',
      query: encodeQueryParameters(<String, String>{
        'body': message,
      }),
    );

    if (await canLaunchUrl(smsLaunchUri)) {
      await launchUrl(smsLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("لا يمكن فتح تطبيق الرسائل")));
    }
  }

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

  // ديالوج تحذير زين قبل الانتقال للرسائل
  void _showZainSmsDialog(StateSetter setModalState) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تأكيد التحويل (زين)", style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold)),
        content: const Text(
          "سيتم تحويلك إلى تطبيق الرسائل لإكمال عملية تحويل الرصيد.\nالرجاء إرسال الرسالة المجهزة مسبقاً دون أي تعديل.",
          style: TextStyle(fontFamily: 'IBMPlexSansArabic', height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // إلغاء
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey, fontFamily: 'IBMPlexSansArabic')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
            onPressed: () {
              Navigator.pop(dialogContext); // إغلاق الديالوج
              _finalizeOrder(setModalState); // المتابعة للحفظ والتحويل
            },
            child: const Text("موافق", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
          )
        ],
      ),
    );
  }

  void _processOrder(StateSetter setModalState) async {
    if (_amountController.text.isEmpty || _transferType == null || _telecomProvider == null || _senderPhoneController.text.isEmpty) {
       return;
    }

    if (_isOverDailyLimit) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تجاوزت سقف التحويل اليومي", style: TextStyle(fontFamily: 'IBMPlexSansArabic'))));
      return;
    }

    if (!kIsWeb && Platform.isAndroid && !_isSimMatch) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_simErrorMsg.isNotEmpty ? _simErrorMsg : "يرجى التحقق من رقم الشريحة", style: const TextStyle(fontFamily: 'IBMPlexSansArabic'))));
       return;
    }

    // إذا كان زين، نعرض التحذير أولاً، وإلا ننفذ فوراً
    if (_telecomProvider == 'Zain') {
      _showZainSmsDialog(setModalState);
    } else {
      _finalizeOrder(setModalState);
    }
  }

  // عملية حفظ الطلب في قاعدة البيانات وتشغيل التحويل
  void _finalizeOrder(StateSetter setModalState) async {
    setModalState(() => _isProcessing = true);
    try {
      var userSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).get();
      String userName = userSnapshot.data()?['full_name'] ?? "مستخدم";

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': currentUser?.uid,
        'userFullName': userName,
        'userPhone': _senderPhoneController.text, 
        'amount': int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0,
        'payout_amount': _receiveAmount,
        'createdAt': FieldValue.serverTimestamp(),
        'transferType': 'direct', // ثابت دائماً
        'telecomProvider': _telecomProvider,
        'receivingCard': _receivingCard == 'QiCard' ? (_hiddenQiNumber ?? '---') : _receivingCard, 
        'targetAccount': _receivingCard == 'QiCard' ? (_hiddenQiNumber ?? 'No Qi Number') : 'ZainCash',
        'targetInfo': 'Direct Transfer',
        'commission': _commission,
        'status': 'pending', 
        'timestamp': FieldValue.serverTimestamp(),
        'deviceType': kIsWeb ? 'Web' : (Platform.isAndroid ? 'Android' : 'iOS'),
      });

      setModalState(() => _isProcessing = false);

      if (_telecomProvider == 'Zain') {
        await _executeSMS(_amountController.text);
        _showDoubleCheckDialog();
      } else {
        String ussd = _generateUSSDCode(_telecomProvider!, _amountController.text);
        if (!kIsWeb && Platform.isIOS) {
          _showIOSTutorialDialog(ussd);
        } else {
          await _executeCall(ussd);
          _showDoubleCheckDialog();
        }
      }

    } catch (e) {
      setModalState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ: $e")));
    }
  }

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
      _isInvalidAmount = (amount >= 1000 && amount % 1000 != 0);
      
      if ((_todayTransferredAmount + amount) > _dailyLimit) {
        _isOverDailyLimit = true;
      } else {
        _isOverDailyLimit = false;
      }

      if (amount < 2000) { 
        _commission = 0; _receiveAmount = 0; 
      } else {
        if (userPoints >= 50) { 
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
                    Navigator.pop(context);
                    Navigator.pop(context);
                    _amountController.clear();
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
    final List<Widget> pages = [
      _buildHomeContent(), 
      const OrdersScreen(), 
      const DiscountsScreen(), 
      const ProfileScreen()
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(), // التعديل: إلغاء الارتداد المزعج بأمان تام
        child: Column(
          children: [
            _buildGlassHeader(), 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  _buildMainCard(), // المستطيل الذي تم تحويله لزر
                  
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
                  
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('orders')
                        .where('userId', isEqualTo: currentUser?.uid)
                        .where('status', isEqualTo: 'successful') 
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
          height: 275,
          decoration: BoxDecoration(
            color: darkGrey, 
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
          ),
          child: Stack(
            children: [
              Positioned(top: -40, right: -40, child: CircleAvatar(radius: 40, backgroundColor: Colors.white.withOpacity(0.03))),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 50, 25, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("أهلاً بك", style: TextStyle(color: Colors.white60, fontSize: 20, fontFamily: 'IBMPlexSansArabic')),
                        
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('notifications')
                              .where('userId', whereIn: [currentUser?.uid, 'all'])
                              .orderBy('timestamp', descending: true)
                              .limit(1) 
                              .snapshots(),
                          builder: (context, notificationSnapshot) {
                            return StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).snapshots(),
                              builder: (context, userSnapshot) {
                                
                                bool showRedDot = false;
                                if (notificationSnapshot.hasData && notificationSnapshot.data!.docs.isNotEmpty && 
                                    userSnapshot.hasData && userSnapshot.data!.data() != null) {
                                  
                                  var latestNotification = notificationSnapshot.data!.docs.first;
                                  Timestamp? notifTime = latestNotification['timestamp'];

                                  var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                  Timestamp? lastCheckTime = userData['last_notification_check'];

                                  if (notifTime != null) {
                                    if (lastCheckTime == null) {
                                      showRedDot = true;
                                    } else if (notifTime.compareTo(lastCheckTime) > 0) {
                                      showRedDot = true;
                                    }
                                  }
                                }
                                                    
                                return Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                                      child: IconButton(
                                        icon: const Icon(Icons.notifications_none_rounded, color: Colors.white), 
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                                        },
                                      ),
                                    ),
                                    if (showRedDot)
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
                            );
                          }
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32, 
                          backgroundColor: Colors.transparent, 
                          backgroundImage: AssetImage('assets/fonts/images/memoji_$_randomMemoji.png'), 
                        ),
                        const SizedBox(width: 15),
                        Text(
                          fullName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),
                    const Text('إجمالي الرصيد المحول', style: TextStyle(color: Colors.white54, fontSize: 15, fontFamily: 'IBMPlexSansArabic')),
                    const SizedBox(height: 5),
                    
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('orders')
                          .where('userId', isEqualTo: currentUser?.uid)
                          .where('status', isEqualTo: 'successful') 
                          .snapshots(),
                      builder: (context, snapshot) {
                        int totalTransferred = 0;
                        if (snapshot.hasData) {
                          for (var doc in snapshot.data!.docs) {
                            totalTransferred += (doc.data() as Map<String, dynamic>)['amount'] as int? ?? 0;
                          }
                        }
                        return Text('${intl.NumberFormat('#,###').format(totalTransferred)} د.ع', 
                          style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic'));
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

  // التعديل: تحويل المستطيل الجامد إلى زر إرشادات أنيق بحجم أصغر
  Widget _buildMainCard() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TransferInstructionsScreen()));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(25), 
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // ليأخذ المستطيل حجم المحتوى فقط ولا يكون عريضاً جداً
            children: [
              const Text('إرشادات التحويل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'IBMPlexSansArabic')),
              const SizedBox(width: 15),
              Image.asset('assets/fonts/images/info.png', width: 24, height: 24),
            ],
          ),
        ),
      ),
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

  void _showConversionSheet(String provider, Color color) {
    setState(() {
      _telecomProvider = (provider.contains("Zain") || provider.contains("زين")) ? "Zain" : "Asiacell";
    });
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
                  value: _transferType,
                  decoration: _inputDecoration('نوع التحويل'),
                  items: const [DropdownMenuItem(value: 'direct', child: Text('تحويل رصيد مباشر'))],
                  onChanged: (val) => setModalState(() => _transferType = val),
                ),
                
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
                  // التعديل: تغيير اسم الحقل
                  _buildFieldLabel('ادخل رقم الهاتف الذي يحتوي على الرصيد:'),
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
                  
                  // التعديل: إضافة التحذير باللون الأحمر
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, bottom: 5.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'تحذير : يجب ادخال رقم SIM Card الذي يحتوي على الرصيد الفعلي وتأكد أن الرقم مطابق للـSIM card المدخل في هاتفك',
                        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic'),
                      ),
                    ),
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
