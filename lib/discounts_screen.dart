import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiscountsScreen extends StatefulWidget {
  const DiscountsScreen({super.key});

  @override
  State<DiscountsScreen> createState() => _DiscountsScreenState();
}

class _DiscountsScreenState extends State<DiscountsScreen> {
  final Color emeraldColor = const Color(0xFF50878C);
  
  // متغيرات الإعلان
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  
  // معرف الوحدة الإعلانية الخاص بك
  // ملاحظة: أثناء التطوير، جوجل تنصح باستخدام معرف الاختبار لتجنب الحظر
  // لكن تم وضع معرفك الخاص بناءً على طلبك
  final String _adUnitId = 'ca-app-pub-7534144177667566/9634851744';

  final int targetPoints = 50; // الهدف المطلوب

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  // دالة تحميل الإعلان
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
          
          // إعداد كول باك عند إغلاق الإعلان لتحميل واحد جديد
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              setState(() {
                _isAdLoaded = false;
              });
              _loadRewardedAd(); // تحميل إعلان تالي
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('فشل تحميل الإعلان: ${error.message}');
          setState(() {
            _isAdLoaded = false;
          });
        },
      ),
    );
  }

  // دالة عرض الإعلان ومنح المكافأة
  void _showAdAndReward() {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
          // لن يتم تنفيذ هذا الكود إلا إذا شاهد المستخدم الإعلان للنهاية
          _addPointsToUser();
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جاري تحميل الإعلان، يرجى الانتظار لحظة...')),
      );
    }
  }

  // إضافة النقاط لقاعدة البيانات
  Future<void> _addPointsToUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(userRef);
          if (snapshot.exists) {
            int currentPoints = snapshot.data()?['discount_points'] ?? 0;
            if (currentPoints < targetPoints) {
              // إضافة نقطتين فقط إذا لم يصل للحد الأقصى
              transaction.update(userRef, {'discount_points': currentPoints + 2});
            }
          } else {
             // إنشاء الحقل إذا لم يكن موجوداً
            transaction.set(userRef, {'discount_points': 2}, SetOptions(merge: true));
          }
        });

      } catch (e) {
        debugPrint("Error adding points: $e");
      }
    }
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // استخدام StreamBuilder للاستماع المباشر للتغييرات في النقاط
    return StreamBuilder<DocumentSnapshot>(
      stream: user != null 
          ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
          : null,
      builder: (context, snapshot) {
        int points = 0;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          points = data['discount_points'] ?? 0;
        }

        // التحقق هل وصل للهدف (50 نقطة)
        bool isRewardReady = points >= targetPoints;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F7),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'مكافآت رصيد',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(Icons.info_outline, color: emeraldColor),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // الرأس العلوي
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.stars_rounded, size: 60, color: Colors.amber),
                      const SizedBox(height: 15),
                      const Text('نظام تجميع النقاط', 
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text(
                        'جمع 50 نقطة للحصول على إعفاء كامل من عمولة التحويل القادمة.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: [
                      // عداد النقاط
                      _buildPointsCounter(points, isRewardReady),

                      const SizedBox(height: 30),

                      // زر مشاهدة الإعلان
                      _buildWatchAdButton(isRewardReady),

                      const SizedBox(height: 20),

                      // رسالة التنبيه عند الاكتمال
                      if (isRewardReady)
                        _buildRewardAlert(),
                      
                      const SizedBox(height: 40),
                      
                      const Text(
                        "مشاهدة الإعلانات تدعم استمرارية الخدمة مجاناً",
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointsCounter(int points, bool isRewardReady) {
    double progress = (points / targetPoints).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(emeraldColor),
                ),
              ),
              Column(
                children: [
                  Text('$points', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: emeraldColor)),
                  const Text('نقطة', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            isRewardReady
                ? 'تهانينا! وصلت للهدف' 
                : 'باقي لك ${targetPoints - points} نقطة للإعفاء', 
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)
          ),
        ],
      ),
    );
  }

  Widget _buildWatchAdButton(bool isRewardReady) {
    // تعطيل الزر إذا اكتملت النقاط أو الإعلان لم يتحمل بعد
    bool disableButton = isRewardReady;

    return SizedBox(
      width: double.infinity,
      child: Opacity(
        // نجعل الزر شفافاً نوعاً ما إذا كان معطلاً
        opacity: disableButton ? 0.3 : 1.0, 
        child: ElevatedButton.icon(
          onPressed: disableButton 
              ? null // لا يمكن الضغط
              : () => _showAdAndReward(),
          icon: Icon(
            Icons.play_circle_fill, 
            color: Colors.white, 
            size: 28
          ),
          label: Text(
            isRewardReady 
                ? 'لديك خصم متاح الآن' 
                : (_isAdLoaded ? 'شاهد إعلان الآن (+2 نقطة)' : 'جاري تحميل الإعلان...'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: emeraldColor,
            padding: const EdgeInsets.symmetric(vertical: 15),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardAlert() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50, 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.withOpacity(0.3))
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 30),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'رائع! حصلت على إعفاء كامل. سيتم تصفير العمولة في شاشة التحويل تلقائياً.',
              style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
