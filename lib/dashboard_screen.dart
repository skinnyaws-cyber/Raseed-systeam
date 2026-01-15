import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
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

  // --- نظام النقاط المدمج ---
  // ملاحظة: لجعل هذا الرقم حقيقياً، سنستخدم لاحقاً قاعدة بيانات بسيطة
  int userPoints = 50; // افتراضياً 50 لتجربة الإعفاء التلقائي

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
    if (value.isEmpty) { 
      setState(() { _isInvalidAmount = false; _receiveAmount = 0; }); 
      return; 
    }
    int amount = int.tryParse(value) ?? 0;
    
    setState(() {
      _isInvalidAmount = (amount >= 1000 && amount % 1000 != 0);
      
      if (amount < 2000) {
        _commission = 0;
        _receiveAmount = 0;
      } else {
        // فحص الإعفاء من العمولة (خفياً)
        if (userPoints >= 50) {
          _commission = 0; // إعفاء كامل لأن النقاط مكتملة
        } else {
          // الحساب الطبيعي للعمولة
          if (amount >= 10000) {
            _commission = ((amount * 0.10) / 1000).round() * 1000;
          } else {
            _commission = 1000;
          }
        }
        _receiveAmount = amount - _commission;
      }
    });
  }

  void _resetPointsAfterSuccess() {
    if (userPoints >= 50) {
      setState(() {
        userPoints = 0; // تصفير النقاط بعد استخدام الميزة
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildHomeContent(),
      const OrdersScreen(),
      const DiscountsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        _buildGlassHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              _buildSectionTitle('تحويل الرصيد إلى كاش'),
              const SizedBox(height: 15),
              _buildTransferCard('Asiacell', 'آسيا سيل', Colors.red.shade600),
              _buildTransferCard('Zain', 'زين العراق', Colors.black),
              _buildTransferCard('Korek', 'كـورك', Colors.orange.shade700),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('أهلاً بك،', style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text('أحمد العراقي', style: TextStyle(color: emeraldColor, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
            icon: const Icon(Icons.notifications_none_rounded, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  Widget _buildTransferCard(String id, String name, Color color) {
    return GestureDetector(
      onTap: () => _showConversionSheet(name, color),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.1), radius: 25, child: Icon(Icons.phone_android_rounded, color: color)),
            const SizedBox(width: 15),
            Expanded(child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showConversionSheet(String provider, Color color) {
    _amountController.clear();
    _receiveAmount = 0;
    _commission = 0;
    _receivingCard = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 25, right: 25, top: 15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 20),
                Text('تحويل رصيد $provider', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 25),
                _buildFieldLabel('اختر طريقة الاستلام:'),
                Row(
                  children: [
                    _buildChoiceChip('ZainCash', Icons.wallet, setModalState),
                    const SizedBox(width: 10),
                    _buildChoiceChip('Qi Card', Icons.credit_card, setModalState),
                  ],
                ),
                if (_receivingCard != null) ...[
                  const SizedBox(height: 20),
                  _buildFieldLabel('قيمة الرصيد (بالآلاف):'),
                  TextField(
                    controller: _amountController,
                    decoration: _inputDecoration('مثلاً 5000').copyWith(
                      errorText: _isInvalidAmount ? 'يرجى إدخال آلاف كاملة (5000, 10000...)' : null,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      _calculateAmount(val);
                      setModalState(() {});
                    },
                  ),
                  if (_amountController.text.isNotEmpty && !_isInvalidAmount)
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: emeraldColor.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('العمولة: $_commission د.ع', style: TextStyle(color: _commission == 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                          Text('تستلم: $_receiveAmount د.ع', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 25),
                  _buildConfirmButton(color, setModalState),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String title, IconData icon, StateSetter setModalState) {
    bool isSelected = _receivingCard == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setModalState(() => _receivingCard = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? emeraldColor : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? emeraldColor : Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(Color color, StateSetter setModalState) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        onPressed: _isProcessing ? null : () async {
          setModalState(() => _isProcessing = true);
          await Future.delayed(const Duration(seconds: 2));
          
          _resetPointsAfterSuccess(); // تصفير النقاط خفياً

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الطلب بنجاح!')));
            setModalState(() => _isProcessing = false);
          }
        },
        child: _isProcessing 
            ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
            : const Text('تأكيد الطلب', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.5))),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: emeraldColor,
        unselectedItemColor: Colors.grey.shade400,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'طلباتي'),
          BottomNavigationBarItem(icon: Icon(Icons.stars_rounded), label: 'النقاط'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'حسابي'),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) => Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))));

  InputDecoration _inputDecoration(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12));
}
