import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService { 
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedAd? _rewardedAd;
  bool _isLoadingAd = false; 
  int _quizCount = 0;
  final int _freeLimit = 1;

  // ✅ TEST AD UNIT ID (Android)
  final String _adUnitId = "ca-app-pub-9548640268387299/3279512839";

  // Initialize
  Future<void> initialize() async {
    await MobileAds.instance.initialize(); // Ensure SDK is initialized first
    await _loadQuizCount();
    _loadRewardedAd();
  }

  Future<void> _loadQuizCount() async {
    final prefs = await SharedPreferences.getInstance();
    _quizCount = prefs.getInt('quiz_count') ?? 0;
    debugPrint('📊 Current Quiz Count: $_quizCount');
  }

  int getRemainingFreeQuizzes() {
    int remaining = _freeLimit - _quizCount;
    return remaining < 0 ? 0 : remaining;
  }

  Future<void> incrementQuizCount() async {
    _quizCount++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quiz_count', _quizCount);
  }

  bool isLimitReached() {
    return _quizCount >= _freeLimit;
  }

  void _loadRewardedAd() {
    // ✅ 1. SAFETY CHECK: If ad is already loaded, DO NOT load another one.
    if (_rewardedAd != null) {
      debugPrint('⚠️ AdService: Ad is already loaded. Skipping load request.');
      return;
    }

    // ✅ 2. SAFETY CHECK: If ad is currently loading, wait.
    if (_isLoadingAd) {
      debugPrint('⚠️ AdService: Ad is currently loading...');
      return;
    }

    _isLoadingAd = true;
    debugPrint('📥 AdService: Loading new ad...');

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ AdService: Rewarded Ad Loaded');
          _rewardedAd = ad;
          _isLoadingAd = false;

          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('👋 AdService: Ad dismissed');
              ad.dispose();
              _rewardedAd = null; // Clear reference immediately
              // Load next ad after short delay
              Future.delayed(const Duration(seconds: 1), () {
                _loadRewardedAd();
              });
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              debugPrint('❌ AdService: Ad failed to show: $err');
              ad.dispose();
              _rewardedAd = null;
              // Retry loading
              Future.delayed(const Duration(seconds: 1), () {
                _loadRewardedAd();
              });
            },
          );
        },
        onAdFailedToLoad: (err) {
          debugPrint('❌ AdService: Ad Failed to Load: $err');
          _rewardedAd = null;
          _isLoadingAd = false; 
          // Retry with longer delay
          Future.delayed(const Duration(seconds: 5), () {
            _loadRewardedAd();
          });
        },
      ),
    );
  }

  // Show Ad Logic
  Future<void> showRewardedAd({
    required VoidCallback onRewardEarned,
    required VoidCallback onAdFailed,
  }) async {
    if (_rewardedAd != null) {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('💰 User earned reward');
          onRewardEarned();
        },
      );
      // Note: Disposal happens in onAdDismissedFullScreenContent
    } else {
      debugPrint('⚠️ AdService: Ad not ready yet');
      // Try loading one for next time
      _loadRewardedAd();
      onAdFailed();
    }
  }
}