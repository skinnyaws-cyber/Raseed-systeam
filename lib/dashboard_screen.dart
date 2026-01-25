import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:io' show Platform; // لتحديد النظام
import 'package:flutter/foundation.dart'; // للويب
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

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

  // --- متغيرات النظام الحية ---
  final User? currentUser = FirebaseAuth.instance.currentUser;
  int userPoints = 0; // سيتم تحديثها من Firebase
  String? _hiddenQiNumber; // لتخزين رقم البطاقة بالخفاء
  
  String? _transferType; 
  String? _telecomProvider;
  String? _receivingCard;

  // الكنترولرز
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _senderPhoneController = TextEditingController();

  // متغيرات الحسابات والتحقق
  int _receiveAmount = 0;
  int _commission = 0;
  bool _isProcessing = false;
  bool _isInvalidAmount = false;
  
  // متغيرات الحد اليومي
  int _dailyLimit = 50000; // الحد الأقصى اليومي الافتراضي
  int _todayTransferredAmount = 0; // مجموع تحويلات اليوم
  bool _isOverDailyLimit = false; // حالة تجاوز الحد

  // متغيرات التحقق من الشريحة
  bool _isCheckingSim = false;
  bool _isSimMatch = true; // نفترض الصحة مبدئياً حتى يكتب المستخدم
  String _simErrorMsg = "";

  // أرقام الشركة للاستلام (للاستخدام الداخلي في USSD)
  final String _ourZainNumber = "07800000000"; 
  final String _ourAsiaNumber = "07700000000";

  @override
  void initState() {
    super.initState();
    // جلب رقم الهاتف المسجل تلقائياً ورقم الكي كارد المخفي
    _fetchUserData();
  }

  void _fetchUserData() async {
    if (currentUser != null) {
      var doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _senderPhoneController.text = doc.data()?['phone_number'] ?? "";
          userPoints = doc.data()?['points'] ?? 0;
          _hiddenQiNumber = doc.data()?['qi_number']; // جلب الرقم بالخفاء
        });
      }
    }
  }

  // حساب مجموع تحويلات اليوم الحالي
  Future<void> _calculateTodayTotal() async {
    if (currentUser == null) return;
    // تحديد بداية اليوم الحالي
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    try {
      // جلب الطلبات الناجحة أو قيد الانتظار لهذا اليوم فقط
      var query = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: currentUser!.uid)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      int total = 0;
      for (var doc in query.docs) {
        // نستثني العمليات المرفوضة
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

  // --- دالة التحقق من الشريحة (Android Only) ---
  Future<void> _validateSimCard(String inputNumber) async {
    if (kIsWeb || Platform.isIOS) return; // الايفون والويب لا يدعمان هذا التحقق

    setState(() { _isCheckingSim = true; _simErrorMsg = ""; });

    // محاكاة التحقق (لأن الوصول لرقم الشريحة مقيد في أندرويد الحديث)
    await Future.delayed(const Duration(milliseconds: 500));

    bool isValid = true;
    String msg = "";

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

  // --- دوال المساعدة (QR, USSD, Process) ---
  void _scanQRCode() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent, elevation: 0,
              leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
              title: const Text("مسح الكود", style: TextStyle(color: Colors.white)),
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

  String _generateUSSDCode(String provider, String amount) {
    String cleanAmount = amount.replaceAll(',', '');
    if (provider == "Zain") {
      return "*211*$_ourZainNumber*$cleanAmount#";
    } else { // Asiacell
      return "*222*$cleanAmount*$_ourAsiaNumber#";
    }
  }

  Future<void> _executeCall(String ussdCode) async {
    String encoded = ussdCode.replaceAll("#", "%23");
    final Uri url = Uri.parse("tel:$encoded");
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  void _showIOSTutorialDialog(String ussdCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تأكيد التحويل"),
        content: const Text("سيتم نقلك للوحة الاتصال، يرجى الضغط على زر الاتصال لإتمام التحويل."),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
            onPressed: () { Navigator.pop(context); _executeCall(ussdCode); },
            child: const Text("موافق", style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  // --- الدالة الرئيسية لمعالجة الطلب ---
  void _processOrder(StateSetter setModalState) async {
    // 1. التحقق من المدخلات
    if (_amountController.text.isEmpty || _transferType == null || _telecomProvider == null || _senderPhoneController.text.isEmpty) {
       return;
    }

    if (_isOverDailyLimit) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تجاوزت سقف التحويل اليومي")));
      return;
    }

    // 2. التحقق من الشريحة (أندرويد + تحويل مباشر)
    if (!kIsWeb && Platform.isAndroid && _transferType == 'direct' && !_isSimMatch) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_simErrorMsg.isNotEmpty ? _simErrorMsg : "يرجى التحقق من رقم الشريحة")));
       return;
    }

    setModalState(() => _isProcessing = true);
    try {
      // جلب الاسم الحالي
      var userSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).get();
      String userName = userSnapshot.data()?['full_name'] ?? "مستخدم";

      // 3. رفع الطلب لـ Firebase
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': currentUser?.uid,
        'userFullName': userName,
        'userPhone': _senderPhoneController.text,
        'amount': int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0,
        'transferType': _transferType,
        'telecomProvider': _telecomProvider,
        // هنا نحدد نوع البطاقة، وإذا كانت كي كارد نرسل الرقم المخفي في حقل الهدف
        'receivingCard': _receivingCard, 
        'targetAccount': _receivingCard == 'QiCard' ? (_hiddenQiNumber ?? 'No Qi Number') : 'ZainCash', // الحقل السري
        'targetInfo': _transferType == 'direct' ? 'Direct Transfer' : _codeController.text,
        'commission': _commission,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'deviceType': kIsWeb ? 'Web' : (Platform.isAndroid ? 'Android' : 'iOS'),
      });

      setModalState(() => _isProcessing = false);

      // 4. تنفيذ العملية
      if (_transferType == 'direct') {
        String ussd = _generateUSSDCode(_telecomProvider!, _amountController.text);
        if (!kIsWeb && Platform.isIOS) {
          _showIOSTutorialDialog(ussd);
        } else {
          await _executeCall(ussd);
          _showDoubleCheckDialog();
        }
      } else {
        _showDoubleCheckDialog();
      }

    } catch (e) {
      setModalState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ: $e")));
    }
  }

  // --- تحديث الحسابات والتحقق من السقف اليومي ---
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
      // التحقق من صحة الرقم (آلاف)
      _isInvalidAmount = (amount >= 1000 && amount % 1000 != 0);
      
      // التحقق من السقف اليومي (المجموع الحالي + المبلغ المدخل)
      if ((_todayTransferredAmount + amount) > _dailyLimit) {
        _isOverDailyLimit = true;
      } else {
        _isOverDailyLimit = false;
      }

      // حساب العمولة
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
              const Text("تم إرسال الطلب!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("جاري معالجة طلبك، سيصلك إشعار فور اكتمال التحويل.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: emeraldColor, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    Navigator.pop(context); // إغلاق الدايلوج
                    Navigator.pop(context); // إغلاق الـ Sheet
                    _amountController.clear();
                    _codeController.clear();
                  },
                  child: const Text("حسناً", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final List<Widget> _pages = [_buildHomeContent(), const OrdersScreen(), const DiscountsScreen(), const ProfileScreen()];
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildGlassHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  _buildMainCard(),
                  const SizedBox(height: 40),
                  const Text('حول رصيدك الآن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  // --- قائمة المعاملات الحية ---
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('orders')
                        .where('userId', isEqualTo: currentUser?.uid)
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
                          bool isSuccess = data['status'] == 'success';
                          bool isPending = data['status'] == 'pending';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100)),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSuccess ? neonGreen.withOpacity(0.2) : (isPending ? Colors.orange.withOpacity(0.1) : Colors.red.withOpacity(0.1)),
                                    shape: BoxShape.circle
                                  ),
                                  child: Icon(
                                    isSuccess ? Icons.arrow_outward : (isPending ? Icons.access_time : Icons.close),
                                    color: isSuccess ? Colors.green[700] : (isPending ? Colors.orange : Colors.red),
                                    size: 20
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("تحويل إلى ${data['telecomProvider']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(isPending ? "قيد المراجعة..." : (isSuccess ? "تم بنجاح" : "فشل"), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                    ],
                                  ),
                                ),
                                Text("-${data['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
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
    // --- ربط الهيدر ببيانات المستخدم الحية ---
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).snapshots(),
      builder: (context, snapshot) {
        String displayName = "أهلاً بك في رصيد";
        String balance = "0";

        if (snapshot.hasData && snapshot.data!.data() != null) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          displayName = "أهلاً بك، ${data['full_name'] ?? 'مستخدم'}";
          balance = "${data['balance'] ?? 0}";
        }

        return Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: neonGreen,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
          ),
          child: Stack(
            children: [
              Positioned(top: -40, right: -40, child: CircleAvatar(radius: 80, backgroundColor: Colors.black.withOpacity(0.05))),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 60, 25, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(displayName, style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
                        Container(
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87), 
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text('إجمالي الرصيد المحول', style: TextStyle(color: Colors.black54, fontSize: 14)),
                    const SizedBox(height: 5),
                    Text('$balance د.ع', style: const TextStyle(color: Colors.black, fontSize: 34, fontWeight: FontWeight.bold)),
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
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('حالة المحفظة', style: TextStyle(color: Colors.grey, fontSize: 14)), SizedBox(height: 5), Text('فعالة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
        Icon(Icons.account_balance_wallet_outlined, color: emeraldColor, size: 30),
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
            Positioned.fill(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover, 
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showConversionSheet(name, color),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      minimumSize: const Size(double.infinity, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('تحويل', style: TextStyle(color: Colors.white, fontSize: 12)),
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
    // حساب مجموع تحويلات اليوم قبل فتح النافذة لضمان الدقة
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
                Text('تحويل رصيد $provider', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      // === التعديل المطلوب: إظهار الخطأ إذا كان الرقم غير موجود ===
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
                  _buildFieldLabel('رقم الهاتف المسجل:'),
                  TextFormField(
                    controller: _senderPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('أدخل رقم شريحتك').copyWith(
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
                          ? 'هذه القيمة اكثر من اعلى من سقف التحويل اليومي' 
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
    // === التحقق من وجود رقم Qi Card قبل تفعيل الزر ===
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
          child: _isProcessing ? const CircularProgressIndicator(color: Colors.black) : const Text('تأكيد الطلب', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) => Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))));
  InputDecoration _inputDecoration(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12));
  Widget _buildRecentTransactionsHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('آخر التحويلات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), TextButton(onPressed: () {}, child: Text('الكل', style: TextStyle(color: emeraldColor)))]);
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
            const Text('لا توجد عمليات حالياً', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
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
