// Firebase configuration for IMPACT PMIS (project: syntrack-pmis-wcr).
// Platform files: android/app/google-services.json, ios/Runner/GoogleService-Info.plist

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for the current platform.
class DefaultFirebaseOptions {
  static bool get isConfigured => true;

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'IMPACT PMIS does not support web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'macOS is not configured for IMPACT PMIS.',
        );
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Desktop platforms are not configured for IMPACT PMIS.',
        );
      default:
        throw UnsupportedError(
          'Unsupported platform: $defaultTargetPlatform',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBx_3V9RyZTVMMgkP_DEa_bwd11-WdsvE4',
    appId: '1:736698706404:android:d3790f2581385a92597ff1',
    messagingSenderId: '736698706404',
    projectId: 'syntrack-pmis-wcr',
    storageBucket: 'syntrack-pmis-wcr.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCStWe-BN1LCbY4DVDbM1XvGZ5VWSJOaZA',
    appId: '1:736698706404:ios:966b75ed01f3870f597ff1',
    messagingSenderId: '736698706404',
    projectId: 'syntrack-pmis-wcr',
    storageBucket: 'syntrack-pmis-wcr.firebasestorage.app',
    iosBundleId: 'com.synergiz.wcr.pmis',
  );
}
