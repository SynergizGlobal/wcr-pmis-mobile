import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:wcr_pmis_mobile/firebase_options.dart';

/// Initializes Firebase and wires Flutter / async errors to Crashlytics.
///
/// No-op on web; otherwise initializes Crashlytics when Firebase options are set.
Future<void> initializeFirebaseCrashlytics() async {
  if (kIsWeb || !DefaultFirebaseOptions.isConfigured) {
    if (kDebugMode && !DefaultFirebaseOptions.isConfigured) {
      debugPrint(
        'Firebase Crashlytics skipped: run flutterfire configure. '
        'See docs/FIREBASE_CRASHLYTICS_SETUP.md',
      );
    }
    return;
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

/// Runs [body] in a single zone so [WidgetsFlutterBinding.ensureInitialized]
/// and [runApp] share the same zone (required by Flutter).
///
/// Uncaught async errors in that zone are reported to Crashlytics when configured.
Future<void> runAppWithCrashlyticsZone(Future<void> Function() body) async {
  if (!DefaultFirebaseOptions.isConfigured) {
    await body();
    return;
  }
  await runZonedGuarded(
    body,
    (Object error, StackTrace stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    },
  );
}
