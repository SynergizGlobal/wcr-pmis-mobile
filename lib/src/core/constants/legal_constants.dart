/// Legal URLs and branding used in store listings and in-app copy.
class LegalConstants {
  const LegalConstants._();

  /// Public HTTPS URL for Google Play and App Store Connect.
  /// Host [docs/impact-pmis-privacy-policy.html] at this path on the WCR PMIS server.
  static const String privacyPolicyUrl =
      'https://pmis-wcrindianrailways.org/wcrpmis/impact-pmis-privacy-policy.html';

  static const String developerName =
      'SYNERGIZ GLOBAL SERVICES PRIVATE LIMITED';

  static const String supportEmail =
      'synergizglobalservicespvtltd@gmail.com';

  /// Android package / iOS bundle — keep unchanged for existing store listings & Firebase.
  static const String androidPackageName = 'com.synergiz.wcr.pmis';

  static const String iosBundleId = 'com.synergiz.wcr.pmis';

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
