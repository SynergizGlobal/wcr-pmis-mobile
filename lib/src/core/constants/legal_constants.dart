import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Legal URLs and branding used in store listings and in-app copy.
class LegalConstants {
  const LegalConstants._();

  /// Public HTTPS URL for Google Play, App Store Connect, and in-app Settings.
  static const String privacyPolicyUrl =
      'https://syntrackpro.com/images/impact-pmis-privacy-policy.html';

  static const String developerName =
      'SYNERGIZ GLOBAL SERVICES PRIVATE LIMITED';

  static const String supportEmail =
      'synergizglobalservicespvtltd@gmail.com';

  /// Android package / iOS bundle — keep unchanged for existing store listings & Firebase.
  static const String androidPackageName = 'com.synergiz.wcr.pmis';

  static const String iosBundleId = 'com.synergiz.wcr.pmis';

  /// Numeric Apple App Store ID (Settings → rate app → App Store).
  static const String iosAppStoreId = '6776117451';

  static String get androidStoreUrl =>
      'https://play.google.com/store/apps/details?id=$androidPackageName';

  static String get iosStoreUrl =>
      'https://apps.apple.com/app/id$iosAppStoreId';

  /// Play Store on Android, App Store on iOS.
  static String get platformStoreUrl {
    if (!kIsWeb && Platform.isIOS) {
      return iosStoreUrl;
    }
    return androidStoreUrl;
  }

  /// Google Play / App Store listing title.
  static const String storeListingName = 'IMPACT-WCR by Synergiz';

  /// Name shown under the app icon on the device.
  static const String onDeviceAppName = 'IMPACT-WCR';

  /// Store listing short / full description tagline.
  static const String storeTagline =
      'WCR Project Management & Construction Tracking';

  /// App Store subtitle (max 30 characters).
  static const String appStoreSubtitle = 'WCR railway project PMIS';
}
