import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wcr_pmis_mobile/firebase_options.dart';
import 'package:wcr_pmis_mobile/src/app/app.dart';
import 'package:wcr_pmis_mobile/src/app/config/app_config.dart';
import 'package:wcr_pmis_mobile/src/app/config/app_config_provider.dart';
import 'package:wcr_pmis_mobile/src/core/firebase/firebase_initializer.dart';
import 'package:wcr_pmis_mobile/src/core/firebase/remote_config_initializer.dart';
import 'package:wcr_pmis_mobile/src/core/notifications/fcm_background_handler.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/core/providers/shared_prefs_provider.dart';

Future<void> bootstrap(AppConfig config) async {
  await runAppWithCrashlyticsZone(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeFirebaseCrashlytics();
    if (DefaultFirebaseOptions.isConfigured) {
      FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler,
      );
    }
    await RemoteConfigInitializer.initialize();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    runApp(
      ProviderScope(
        overrides: <Override>[
          appConfigProvider.overrideWithValue(config),
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const App(),
      ),
    );
  });
}
