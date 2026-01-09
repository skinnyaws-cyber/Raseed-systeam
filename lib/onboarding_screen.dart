import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // البيانات الخاصة بالواجهات
  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "رصيدك.. صار كاش!",
      "desc": "حول رصيد آسيا وزين إلى أموال حقيقية في محفظتك بضغطة زر واحدة.",
      "icon": Icons.account_balance_wallet_outlined,
    },
    {
      "title": "سرعة وأمان",
      "desc": "عمليات تحويل فورية محمية بأعلى معايير الأمان المصرفي الرقمي.",
      "icon": Icons.speed_outlined,
    },
    {
      "title": "ادعو أصدقاءك واربح",
      "desc": "ادعُ 5 من أصدقائك واحصل على كود خصم 100% لعمليتك القادمة.",
      "icon": Icons.card_giftcard_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // صفحات التمرير
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // تأثير المورفينج للأيقونة
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        _onboardingData[index]['icon'],
                        key: ValueKey<int>(index),
                        size: 120,
                        color: const Color(0xFF50C878),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      _onboardingData[index]['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332), // كحلي غامق مائل للخضرة
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _onboardingData[index]['desc'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                    ),
                  ],
                ),
              );
            },
          ),

          // الجزء السفلي (النقاط والأزرار)
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // نقاط التمرير
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? const Color(0xFF50C878) : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // ظهور الأزرار في الصفحة الأخيرة فقط
                _currentPage == _onboardingData.length - 1
                    ? Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {}, // سنربطه بواجهة Sign Up لاحقاً
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF50C878),
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 5,
                              shadowColor: const Color(0xFF50C878).withOpacity(0.4),
                            ),
                            child: const Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: () {}, // سنربطه بواجهة Login لاحقاً
                            child: const Text(
                              'هل لديك حساب مسبقاً؟ سجل دخول',
                              style: TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(height: 110), // مساحة فارغة للحفاظ على التوازن
              ],
            ),
          ),
        ],
      ),
    );
  }
}
