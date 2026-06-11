import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/supported_platform.dart';

class AdService {
  static bool _hasShownLaunchAd = false;
  static InterstitialAd? _interstitialAd;

  static Future<void> initialize() async {
    if (!SupportedPlatform.supportsMobileAds) return;
    await MobileAds.instance.initialize();
    _loadInterstitialAd();
  }

  static void _loadInterstitialAd() {
    if (!SupportedPlatform.supportsMobileAds) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('InterstitialAd loaded successfully.');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Shows the preloaded interstitial ad if it hasn't been shown this session.
  /// Calls `onAdComplete` when the ad is closed or fails to show (so the app can continue).
  static void showLaunchAdIfAvailable({required VoidCallback onAdComplete}) {
    if (!SupportedPlatform.supportsMobileAds ||
        _hasShownLaunchAd ||
        _interstitialAd == null) {
      onAdComplete();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _hasShownLaunchAd = true; // Mark as shown for this session!
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        onAdComplete(); // Continue to next screen
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        onAdComplete(); // Continue even if there's an error
      },
    );

    _interstitialAd!.show();
  }

  /// Test Banner Ad Unit ID (Android only).
  static String get bannerAdUnitId {
    if (!SupportedPlatform.isAndroid) return '';
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  /// Test Interstitial Video Ad Unit ID (Android only).
  static String get interstitialAdUnitId {
    if (!SupportedPlatform.isAndroid) return '';
    return 'ca-app-pub-3940256099942544/1033173712';
  }
}
