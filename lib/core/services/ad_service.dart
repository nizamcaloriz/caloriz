import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdService extends GetxController {
  RewardedAd? _rewardedAd;
  final RxBool isAdLoaded = false.obs;
  final RxBool isAdLoading = false.obs;
  final RxBool useTestAds = true.obs; // Toggle between test and production

  // Test Ad Unit IDs (For development/testing)
  static const String _testAndroidRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testIosRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313';
  
  // Production Ad Unit IDs (Loaded from .env)
  late String _prodAndroidRewardedAdUnitId;
  late String _prodIosRewardedAdUnitId;

  @override
  void onInit() {
    super.onInit();
    _loadProductionKeys();
    _initializeAds();
  }

  void _loadProductionKeys() {
    print('📋 [AD SERVICE] Loading Ad Unit IDs...');
    
    // Load from .env file
    _prodAndroidRewardedAdUnitId = dotenv.env['ADMOB_ANDROID_REWARDED_AD_UNIT_ID'] ?? _testAndroidRewardedAdUnitId;
    _prodIosRewardedAdUnitId = dotenv.env['ADMOB_IOS_REWARDED_AD_UNIT_ID'] ?? _testIosRewardedAdUnitId;
    
    // Check if production keys are set
    bool hasProductionAndroid = _prodAndroidRewardedAdUnitId != _testAndroidRewardedAdUnitId;
    bool hasProductionIos = _prodIosRewardedAdUnitId != _testIosRewardedAdUnitId;
    
    print('📱 Platform: ${GetPlatform.isAndroid ? 'Android' : 'iOS'}');
    
    if (GetPlatform.isAndroid) {
      if (hasProductionAndroid) {
        useTestAds.value = false;
        print('✅ Production Android Ad Unit ID loaded');
        print('🔴 Using PRODUCTION ads');
      } else {
        useTestAds.value = true;
        print('⚠️ Android production Ad Unit ID not in .env');
        print('🟡 Using TEST ads');
      }
      print('Android Rewarded ID: ${_getAndroidRewardedAdUnitId()}');
    } else {
      // iOS - not live yet, always use test ads
      useTestAds.value = true;
      print('📲 iOS app not yet on App Store');
      print('🟡 Using TEST ads for iOS development');
      print('iOS Rewarded ID: ${_getIosRewardedAdUnitId()}');
    }
    print('');
  }

  String _getAndroidRewardedAdUnitId() {
    return useTestAds.value ? _testAndroidRewardedAdUnitId : _prodAndroidRewardedAdUnitId;
  }

  String _getIosRewardedAdUnitId() {
    return useTestAds.value ? _testIosRewardedAdUnitId : _prodIosRewardedAdUnitId;
  }

  Future<void> _initializeAds() async {
    print('🚀 Initializing Google Mobile Ads...');
    await MobileAds.instance.initialize();
    print('✅ Google Mobile Ads initialized\n');
    loadRewardedAd();
  }

  void loadRewardedAd() {
    if (isAdLoading.value) {
      print('⏳ Ad already loading - skipping');
      return;
    }
    
    isAdLoading.value = true;
    
    final adUnitId = GetPlatform.isAndroid ? _getAndroidRewardedAdUnitId() : _getIosRewardedAdUnitId();
    print('📡 Loading Rewarded Ad on ${GetPlatform.isAndroid ? 'Android' : 'iOS'}');
    print('Ad Unit ID: $adUnitId');
    
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          isAdLoaded.value = true;
          isAdLoading.value = false;
          print('✅ Rewarded Ad loaded successfully\n');
          
          // Set full screen content callback
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              print('👋 Ad dismissed by user');
              ad.dispose();
              _rewardedAd = null;
              isAdLoaded.value = false;
              loadRewardedAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('❌ Ad failed to show: $error');
              ad.dispose();
              _rewardedAd = null;
              isAdLoaded.value = false;
              loadRewardedAd(); // Load next ad
            },
          );
        },
        onAdFailedToLoad: (error) {
          isAdLoaded.value = false;
          isAdLoading.value = false;
          print('❌ RewardedAd failed to load: $error');
          print('⏰ Retrying in 60 seconds...\n');
          
          // Retry after 60 seconds
          Future.delayed(const Duration(seconds: 60), () {
            print('🔄 Retrying ad load...');
            loadRewardedAd();
          });
        },
      ),
    );
  }

  Future<bool> showRewardedAd({required Function() onRewarded}) async {
    if (_rewardedAd == null || !isAdLoaded.value) {
      print('❌ Ad not ready for display');
      Get.snackbar(
        'Ad Not Ready',
        'Please wait while we load the ad...',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Try to load if not loading
      if (!isAdLoading.value) {
        print('🔄 Ad not loading - initiating load...');
        loadRewardedAd();
      }
      return false;
    }

    print('🎬 Showing Rewarded Ad...');
    bool wasRewarded = false;

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        wasRewarded = true;
        print('✅ User earned reward!');
        onRewarded();
      },
    );

    return wasRewarded;
  }

  @override
  void onClose() {
    _rewardedAd?.dispose();
    super.onClose();
  }
}
