import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'notifications_screen.dart'; // هذا هو السطر المضاف للربط
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
  final Color neonGreen = const Color(0xFFCCFF00); // اللون الفسفوري المطلوب

  String? _transferType; 
  String? _telecomProvider;
  String? _receivingCard;
  final String _userRegisteredPhone = "07701234567"; 
  
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  
  int _receiveAmount = 0;
  int _commission = 0;
  bool _isProcessing = false;
  bool _isInvalidAmount = false;

  void _calculateAmount(String value) {
    if (value.isEmpty) { setState(() { _isInvalidAmount = false; _receiveAmount = 0; }); return; }
    int amount = int.tryParse(value) ?? 0;
    setState(() {
      _isInvalidAmount = (amount >= 1000 && amount % 1000 != 0);
      if (amount < 2000) { _commission = 0; _receiveAmount = 0; }
      else if (amount >= 10000) {
        _commission = ((amount * 0.10) / 1000).round() * 1000;
        _receiveAmount = amount - _commission;
      } else { _commission = 1000; _receiveAmount = amount - _commission; }
    });
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
                      // تم تعديل المسارات هنا لتطابق مسارك الخاص: assets/fonts/images/
                      Expanded(child: _buildNetworkCard('آسيا سيل', 'Asiacell', 'assets/fonts/images/asiacell_logo.png', const Color(0xFFEE2737))),
                      const SizedBox(width: 15),
                      Expanded(child: _buildNetworkCard('زين العراق', 'Zain IQ', 'assets/fonts/images/zain_logo.png', const Color(0xFF00B2A9))),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildRecentTransactionsHeader(),
                  _buildEmptyState(),
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
                    const Text('أهلاً بك في رصيد', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
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
                const Text('150,000 د.ع', style: TextStyle(color: Colors.black, fontSize: 34, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('حالة المحفظة', style: TextStyle(color: Colors.grey, fontSize: 14)), SizedBox(height: 5), Text('0 عملية ناجحة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
        Icon(Icons.account_balance_wallet_outlined, color: emeraldColor, size: 30),
      ]),
    );
  }

  void _showConversionSheet(String provider, Color color) {
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
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 22, color: Colors.black87), 
                      onPressed: () => Navigator.pop(context),
                    ),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                    const SizedBox(width: 40), 
                  ],
                ),
                const SizedBox(height: 10),
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
                      decoration: _inputDecoration('ادخل الكود').copyWith(suffixIcon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.blue)),
                    ),
                    const SizedBox(height: 15),
                  ],
                  _buildFieldLabel('شركة الاتصالات:'),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('اختر الشركة'),
                    items: const [DropdownMenuItem(value: 'Asiacell', child: Text('آسيا سيل')), DropdownMenuItem(value: 'Zain', child: Text('زين العراق'))],
                    onChanged: (val) => setModalState(() => _telecomProvider = val),
                  ),
                ],
                if (_telecomProvider != null) ...[
                  const SizedBox(height: 15),
                  _buildFieldLabel('بطاقة الاستلام:'),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('اختر البطاقة'),
                    items: const [DropdownMenuItem(value: 'ZainCash', child: Text('ZainCash')), DropdownMenuItem(value: 'QiCard', child: Text('Qi card'))],
                    onChanged: (val) => setModalState(() => _receivingCard = val),
                  ),
                ],
                if (_receivingCard != null) ...[
                  const SizedBox(height: 15),
                  _buildFieldLabel('رقم الهاتف المسجل:'),
                  TextField(enabled: false, controller: TextEditingController(text: _userRegisteredPhone), decoration: _inputDecoration('').copyWith(fillColor: Colors.blueGrey.shade50, suffixIcon: const Icon(Icons.lock_outline, size: 18))),
                  const SizedBox(height: 15),
                  _buildFieldLabel('قيمة الرصيد (بالآلاف):'),
                  TextField(
                    controller: _amountController,
                    decoration: _inputDecoration('مثلاً 5000').copyWith(errorText: _isInvalidAmount ? 'يرجى إدخال آلاف كاملة' : null),
                    keyboardType: TextInputType.number,
                    onChanged: (val) { _calculateAmount(val); setModalState(() {}); },
                  ),
                  if (_amountController.text.isNotEmpty && !_isInvalidAmount)
                    Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('العمولة: $_commission د.ع', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), Text('الصافي: $_receiveAmount د.ع', style: const TextStyle(fontWeight: FontWeight.bold))])),
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
    bool canConfirm = !_isInvalidAmount && _amountController.text.isNotEmpty;
    return Opacity(
      opacity: canConfirm ? 1.0 : 0.4,
      child: SizedBox(
        width: double.infinity, height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: neonGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          onPressed: canConfirm ? () async {
            setModalState(() => _isProcessing = true);
            await Future.delayed(const Duration(seconds: 4));
            setModalState(() => _isProcessing = false);
            _showDoubleCheckDialog();
          } : null,
          child: _isProcessing ? const RasedPayAnimation() : const Text('تأكيد الطلب', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) => Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))));
  InputDecoration _inputDecoration(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12));
  
  // الدالة المعدلة لعرض الصور من الـ Assets
  Widget _buildNetworkCard(String name, String sub, String imagePath, Color color) { 
    return Container(
      padding: const EdgeInsets.all(20), 
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)), 
      child: Column(children: [
        Image.asset(imagePath, height: 60, width: 60, fit: BoxFit.contain), // استخدام الصور المحلية
        const SizedBox(height: 10), 
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), 
        const SizedBox(height: 10), 
        ElevatedButton(onPressed: () => _showConversionSheet(name, color), style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(double.infinity, 36)), child: const Text('تحويل', style: TextStyle(color: Colors.white, fontSize: 12))) 
      ])); 
  }

  Widget _buildRecentTransactionsHeader() { return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('آخر التحويلات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), TextButton(onPressed: () {}, child: Text('الكل', style: TextStyle(color: emeraldColor)))]); }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]
              ),
              child: Icon(Icons.history_toggle_off_rounded, size: 50, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 15),
            const Text('لا توجد عمليات حالياً', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() { return BottomNavigationBar(currentIndex: _selectedIndex, onTap: (i) => setState(() => _selectedIndex = i), type: BottomNavigationBarType.fixed, selectedItemColor: emeraldColor, items: const [BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'), BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'الطلبات'), BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'العروض'), BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الملف')]); }

  void _showDoubleCheckDialog() {
    showDialog(context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: const Text('تأكيد نهائي'), content: const Text('هل أنت متأكد من إرسال الطلب؟'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), ElevatedButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('تأكيد'))]));
  }
}

class RasedPayAnimation extends StatefulWidget {
  const RasedPayAnimation({super.key});
  @override
  State<RasedPayAnimation> createState() => _RasedPayAnimationState();
}

class _RasedPayAnimationState extends State<RasedPayAnimation> with TickerProviderStateMixin {
  late AnimationController _dotsCtrl;
  late AnimationController _slideCtrl;
  late AnimationController _rotateCtrl;
  bool _showCheck = false;
  bool _hideText = false;

  @override
  void initState() {
    super.initState();
    _dotsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..repeat(reverse: true);
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _rotateCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _hideText = true);
        _slideCtrl.forward().then((_) {
          _rotateCtrl.repeat();
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _rotateCtrl.stop();
              setState(() => _showCheck = true);
            }
          });
        });
      }
    });
  }

  @override
  void dispose() { _dotsCtrl.dispose(); _slideCtrl.dispose(); _rotateCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (!_hideText)
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Text("RasedPay", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            AnimatedBuilder(animation: _dotsCtrl, builder: (context, child) => Text("...", style: TextStyle(color: Colors.black, fontSize: 18, letterSpacing: 2 * _dotsCtrl.value))),
          ]),
        AnimatedBuilder(
          animation: _slideCtrl,
          builder: (context, child) => Transform.translate(
            offset: Offset(150 * (1 - _slideCtrl.value), 0),
            child: Opacity(
              opacity: _hideText ? 1.0 : 0.0,
              child: _showCheck 
                ? Container(width: 35, height: 35, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Icon(Icons.check, color: Color(0xFFCCFF00), size: 20))
                : RotationTransition(turns: _rotateCtrl, child: const Icon(Icons.credit_card, color: Colors.black, size: 30)),
            ),
          ),
        ),
      ],
    );
  }
}
