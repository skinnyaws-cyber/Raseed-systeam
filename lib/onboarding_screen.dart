import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  double _currentPage = 0.0;

  // قائمة الصفحات مع الألوان المصححة (Hex Codes)
  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'إدارة أموالك بذكاء',
      subtitle: 'نظام رصيد يوفر لك تحكماً كامل بميزانيتك بلمسة واحدة.',
      icon: Icons.account_balance_wallet_rounded,
      color: const Color(0xFF008080), // Teal
    ),
    OnboardingData(
      title: 'تحويل سريع وآمن',
      subtitle: 'حول رصيدك لأي شخص في ثوانٍ مع تشفير وحماية عالية.',
      icon: Icons.bolt_rounded,
      color: const Color(0xFF50C878), // Emerald Green
    ),
    OnboardingData(
      title: 'تقارير تفصيلية',
      subtitle: 'راقب مصروفاتك من خلال رسوم بيانية واضحة وسهلة الفهم.',
      icon: Icons.pie_chart_rounded,
      color: const Color(0xFF004D40), // Dark Teal
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          _currentPage = _pageController.page!;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              // حساب وضعية الصفحة لعمل تأثير الـ 3D
              double relativePosition = index - _currentPage;
              return _buildPage(index, relativePosition);
            },
          ),
          
          // مؤشر النقاط والزر السفلي
          Positioned(
            bottom: 50,
            left: 30,
            right: 30,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) => _buildDot(index)),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage.round() < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOutCubic,
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008080),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage.round() == _pages.length - 1 ? 'ابدأ الآن' : 'التالي',
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index, double position) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // تأثير الـ 3D الاحترافي
          Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002) // Perspective العمق
              ..rotateY(position * 0.8) // دوران جانبي
              ..rotateZ(position * 0.2), // دوران طفيف للزاوية
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: _pages[index].color.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _pages[index].color.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ]
              ),
              child: Icon(
                _pages[index].icon,
                size: 140,
                color: _pages[index].color,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Text(
            _pages[index].title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _pages[index].subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    bool isSelected = _currentPage.round() == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isSelected ? 24 : 8,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF008080) : const Color(0xFFD1D1D1),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
