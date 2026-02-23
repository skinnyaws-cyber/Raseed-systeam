import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui'; // مطلوب لتأثير الزجاج (Glassmorphism)

class DiscountsScreen extends StatefulWidget {
  const DiscountsScreen({super.key});

  @override
  State<DiscountsScreen> createState() => _DiscountsScreenState();
}

class _DiscountsScreenState extends State<DiscountsScreen> with SingleTickerProviderStateMixin {
  final Color emeraldColor = const Color(0xFF50878C);
  final Color neonGreen = const Color(0xFFCCFF00); // لون ملفت للأزرار
  final Color darkGrey = const Color(0xFF2F3542);

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isAdShowing = false;

  // معرف الوحدة الإعلانية الخاص بك (تم الحفاظ عليه بدقة كما طلبت)
  final String _adUnitId = 'ca-app-pub-7534144177667566/9634851744';
  
  final int targetPoints = 50; // الحد الأقصى والمطلوب حصراً

  // متحكم الحركة لزر الإعلان (لجعله ينبض)
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();

    // إعداد حركة النبض للزر
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
            _isAdLoaded = true;
          });
          debugPrint('تم تحميل الإعلان بنجاح');
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) => _isAdShowing = true,
            onAdDismissedFullScreenContent: (ad) {
              _isAdShowing = false;
              ad.dispose();
              setState(() => _isAdLoaded = false);
              _loadRewardedAd(); // تحميل إعلان جديد للمرة القادمة
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              _isAdShowing = false;
              ad.dispose();
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('فشل تحميل الإعلان: ${error.message}');
          setState(() => _isAdLoaded = false);
        },
      ),
    );
  }

  void _showAdAndReward() {
    if (_rewardedAd != null && !_isAdShowing) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
          _addPointsToUser(); // إضافة النقاط فقط إذا شاهد الإعلان
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('جاري تجهيز الإعلان، يرجى المحاولة بعد قليل...', style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
          backgroundColor: darkGrey,
        ),
      );
    }
  }

  Future<void> _addPointsToUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(userRef);
          int currentPoints = 0;
          
          if (snapshot.exists) {
            // استخدام حقل points ليتطابق مع واجهة dashboard
            currentPoints = snapshot.data()?['points'] ?? 0;
          }

          if (currentPoints < targetPoints) {
            int newPoints = currentPoints + 2;
            // ضمان صارم: لا يمكن أن تتجاوز النقاط 50 بأي حال من الأحوال
            if (newPoints > targetPoints) {
              newPoints = targetPoints;
            }
            transaction.set(userRef, {'points': newPoints}, SetOptions(merge: true));
          }
        });
      } catch (e) {
        debugPrint("Error adding points: $e");
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: user != null 
          ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
          : null,
      builder: (context, snapshot) {
        int points = 0;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          points = data['points'] ?? 0; // قراءة من حقل points
        }

        bool isRewardReady = points >= targetPoints;

        return Scaffold(
          body: Stack(
            children: [
              // 1. الخلفية المبهجة (Gradient)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      emeraldColor,
                      const Color(0xFF1A212D), // لون داكن عميق
                    ],
                  ),
                ),
              ),
              
              // 2. دوائر الزينة في الخلفية
              Positioned(
                top: -50, right: -50,
                child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.05)),
              ),
              Positioned(
                bottom: -80, left: -50,
                child: CircleAvatar(radius: 120, backgroundColor: neonGreen.withOpacity(0.05)),
              ),

              // 3. المحتوى الرئيسي
              SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(),
                    
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                          child: Column(
                            children: [
                              // العنوان الترحيبي
                              const Icon(Icons.stars_rounded, size: 60, color: Colors.amber),
                              const SizedBox(height: 15),
                              const Text(
                                'صندوق المكافآت', 
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'IBMPlexSansArabic'),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'شاهد الإعلانات، واجمع 50 نقطة\nلتحصل على تحويل مجاني بدون عمولة!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5, fontFamily: 'IBMPlexSansArabic'),
                              ),
                              
                              const SizedBox(height: 40),

                              // بطاقة النقاط الزجاجية
                              _buildGlassCounter(points, isRewardReady),

                              const SizedBox(height: 40),

                              // زر الإعلان التفاعلي
                              _buildGamifiedButton(isRewardReady),

                              const SizedBox(height: 30),

                              // رسالة النجاح
                              if (isRewardReady) _buildSuccessBadge(),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text('المكافآت', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white70),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كل إعلان يمنحك نقطتين', style: TextStyle(fontFamily: 'IBMPlexSansArabic'))));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCounter(int points, bool isRewardReady) {
    double progress = (points / targetPoints).clamp(0.0, 1.0);
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 15,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(isRewardReady ? neonGreen : Colors.amber),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '$points', 
                        style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: isRewardReady ? neonGreen : Colors.white, fontFamily: 'IBMPlexSansArabic'),
                      ),
                      Text(
                        'من $targetPoints', 
                        style: const TextStyle(fontSize: 14, color: Colors.white70, fontFamily: 'IBMPlexSansArabic'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Text(
                isRewardReady ? 'الخصم جاهز للاستخدام!' : 'باقي لك ${targetPoints - points} نقطة',
                style: TextStyle(
                  color: isRewardReady ? neonGreen : Colors.white, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  fontFamily: 'IBMPlexSansArabic'
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGamifiedButton(bool isRewardReady) {
    if (isRewardReady) {
      return Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text('الخصم مُفعل', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
        ),
      );
    }

    return ScaleTransition(
      scale: _isAdLoaded ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      child: GestureDetector(
        onTap: () => _showAdAndReward(),
        child: Container(
          width: double.infinity,
          height: 65,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isAdLoaded 
                ? [neonGreen, const Color(0xFFAACC00)] 
                : [Colors.grey.shade600, Colors.grey.shade700],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isAdLoaded ? [
              BoxShadow(color: neonGreen.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))
            ] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_isAdLoaded ? Icons.play_arrow_rounded : Icons.hourglass_empty_rounded, color: darkGrey, size: 30),
              const SizedBox(width: 10),
              Text(
                _isAdLoaded ? 'شاهد إعلان (+2 نقطة)' : 'جاري تحميل الإعلان...',
                style: TextStyle(color: darkGrey, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBadge() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: neonGreen.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: neonGreen.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: neonGreen, size: 30),
          const SizedBox(width: 15),
          const Expanded(
            child: Text(
              'تهانينا! توجه الآن للرئيسية وسيتم خصم العمولة تلقائياً عند التحويل.',
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5, fontFamily: 'IBMPlexSansArabic'),
            ),
          ),
        ],
      ),
    );
  }
}