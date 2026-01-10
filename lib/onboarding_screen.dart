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
      subtitle: 'نظام رصيد يوفر لك تحكماً كامل بميزانيتك بلمسة واحدة.',
      icon: Icons.account_balance_wallet_rounded,
      color: const Color(0xFF008080),
    ),
    OnboardingData(
      title: 'تحويل سريع وآمن',
      subtitle: 'حول رصيدك لأي شخص في ثوانٍ مع تشفير وحماية عالية.',
      icon: Icons.bolt_rounded,
      color: const Color(0xFF50C878),
    ),
    OnboardingData(
      title: 'تقارير تفصيلية',
      subtitle: 'راقب مصروفاتك من خلال رسوم بيانية واضحة وسهلة الفهم.',
      icon: Icons.pie_chart_rounded,
      color: const Color(0xFF004D40),
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
          // 1. الدائرة الثابتة في الخلفية (The Stage)
          Align(
            alignment: const Alignment(0, -0.4),
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: _pages[_currentPage.round()].color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 2. الأيقونة التي تتشقلب (The Morphing Icon)
          Align(
            alignment: const Alignment(0, -0.4),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(_currentPage * math.pi), // تتشقلب مع كل سحبة
              child: Icon(
                _pages[_currentPage.round()].icon,
                size: 120,
                color: _pages[_currentPage.round()].color,
              ),
            ),
          ),

          // 3. PageView للنصوص فقط (لتعطي إحساس خفة الحركة)
          Column(
            children: [
              const Spacer(flex: 3),
              Expanded(
                flex: 2,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
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
                  },
                ),
              ),
              
              // المؤشر والزر
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (index) => _buildDot(index)),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage.round() < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
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
