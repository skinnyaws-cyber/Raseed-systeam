import 'package:flutter/material.dart';
import 'discounts_screen.dart'; // الربط مع الملف الجديد
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

  // حقول الحاسبة المدمجة (بقيت كما هي في كودك)
  final TextEditingController _amountController = TextEditingController();
  double _receiveAmount = 0.0;
  double _commission = 0.0;

  void _calculateAmount(String value) {
    double amount = double.tryParse(value) ?? 0;
    setState(() {
      if (amount >= 10000) {
        _commission = amount * 0.20; // عمولة 20%
      } else {
        _commission = amount * 0.10; // عمولة 10%
      }
      _receiveAmount = amount - _commission;
    });
  }

  @override
  Widget build(BuildContext context) {
    // مصفوفة الصفحات التي يتم التنقل بينها
    final List<Widget> _pages = [
      _buildHomeContent(),     // الواجهة الرئيسية الحالية
      const OrdersScreen(),
      const DiscountsScreen(),  // واجهة الخصومات من الملف الجديد
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F7),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // الواجهة الرئيسية (نفس كودك الأصلي تماماً تم تجميعه هنا)
  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 30),
              _buildMainCard(),
              const SizedBox(height: 40),
              const Text('حول رصيدك الآن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildNetworkCard(
                      'آسيا سيل', 
                      'Asiacell', 
                      'https://upload.wikimedia.org/wikipedia/ar/thumb/2/23/Asiacell_Logo.svg/1024px-Asiacell_Logo.svg.png',
                      const Color(0xFFEE2737),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildNetworkCard(
                      'زين العراق', 
                      'Zain IQ', 
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Zain_Logo.svg/1200px-Zain_Logo.svg.png',
                      const Color(0xFF00B2A9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildRecentTransactionsHeader(),
              _buildEmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  // --- دوال المكونات (بقيت كما هي في كودك لضمان ثبات التصميم) ---

  void _showConversionSheet(String provider, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 25, right: 25, top: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text('تحويل رصيد $provider', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'أدخل المبلغ المرسل',
                  hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
                onChanged: (val) {
                  _calculateAmount(val);
                  setModalState(() {});
                },
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: emeraldColor.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: emeraldColor.withOpacity(0.1))),
                child: Column(
                  children: [
                    _buildCalcRow('العمولة المستقطعة:', '${_commission.toStringAsFixed(0)} د.ع', Colors.redAccent),
                    const Divider(height: 30),
                    _buildCalcRow('المبلغ الذي ستستلمه:', '${_receiveAmount.toStringAsFixed(0)} د.ع', emeraldColor, isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text('تأكيد وإرسال', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalcRow(String title, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 17, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
      ],
    );
  }

  Widget _buildNetworkCard(String name, String subName, String logoUrl, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        children: [
          Image.network(logoUrl, height: 50, width: 50, fit: BoxFit.contain, errorBuilder: (c,e,s) => Icon(Icons.signal_cellular_alt, color: color)),
          const SizedBox(height: 15),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(subName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () => _showConversionSheet(name, color),
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), minimumSize: const Size(double.infinity, 38)),
            child: const Text('تحويل', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('أهلاً بك، مستخدم رصيد', style: TextStyle(fontSize: 14, color: Colors.grey)),
          Text('عضو زمردي ✨', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: emeraldColor)),
        ]),
        Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: IconButton(onPressed: () {}, icon: Icon(Icons.notifications_none_rounded, color: emeraldColor))),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [emeraldColor, const Color(0xFF3D666A)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24)),
      child: Column(children: [
        const Text('إجمالي الرصيد المحول', style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 10),
        const Text('0 د.ع', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(30)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_circle_outline, color: Colors.white, size: 16), SizedBox(width: 8), Text('0 عملية ناجحة', style: TextStyle(color: Colors.white, fontSize: 12))])),
      ]),
    );
  }

  Widget _buildRecentTransactionsHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text('آخر التحويلات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      TextButton(onPressed: () {}, child: Text('الكل', style: TextStyle(color: emeraldColor))),
    ]);
  }

  Widget _buildEmptyState() {
    return Center(child: Padding(padding: const EdgeInsets.all(40.0), child: Column(children: [Icon(Icons.history_toggle_off_rounded, size: 60, color: Colors.grey.shade300), const SizedBox(height: 10), const Text('لا توجد عمليات حالياً', style: TextStyle(color: Colors.grey))])));
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: emeraldColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'الطلبات'),
        BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_rounded), label: 'الخصومات'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'الملف'),
      ],
    );
  }
}
