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

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'إدارة أموالك بذكاء',
      subtitle: 'نظام رصيد يوفر لك تحكماً كاملاً بميزانيتك بلمسة واحدة.',
      icon: Icons.account_balance_wallet_rounded,
      color: Colors.teal.shade700,
    ),
    OnboardingData(
      title: 'تحويل سريع وآمن',
      subtitle: 'حول رصيدك لأي شخص في ثوانٍ مع تشفير وحماية عالية.',
      icon: Icons.bolt_rounded,
      color: Colors.emerald.shade600,
    ),
    OnboardingData(
      title: 'تقارير تفصيلية',
      subtitle: 'راقب مصروفاتك من خلال رسوم بيانية واضحة وسهلة الفهم.',
      icon: Icons.pie_chart_rounded,
      color: Colors.teal.shade900,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
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
              // حساب قيمة الـ 3D بناءً على موضع الصفحة
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
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      _currentPage.round() == _pages.length - 1 ? 'ابدأ الآن' : 'التالي',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
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
    // تأثير الـ 3D: دوران حول المحور Y ومحور Z
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // الكاميرا (Perspective)
              ..rotateY(position)    // دوران ثلاثي الأبعاد عند السحب
              ..rotateZ(position * 0.5), 
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: _pages[index].color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _pages[index].icon,
                size: 150,
                color: _pages[index].color,
              ),
            ),
          ),
          const SizedBox(height: 50),
          Text(
            _pages[index].title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade900,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _pages[index].subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: _currentPage.round() == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage.round() == index ? Colors.teal.shade700 : Colors.teal.shade100,
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
