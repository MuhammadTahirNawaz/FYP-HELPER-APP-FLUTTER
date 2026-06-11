import 'package:flutter/foundation.dart';

/// Platform helpers for supported targets: Android, Windows desktop, and Web.
class SupportedPlatform {
  SupportedPlatform._();

  static bool get isWeb => kIsWeb;

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get isWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  static bool get isSupported => isAndroid || isWindows || isWeb;

  /// Google Mobile Ads are only available on native Android.
  static bool get supportsMobileAds => isAndroid;

  static String get name {
    if (isWeb) return 'web';
    if (isAndroid) return 'android';
    if (isWindows) return 'windows';
    return defaultTargetPlatform.name;
  }
}
