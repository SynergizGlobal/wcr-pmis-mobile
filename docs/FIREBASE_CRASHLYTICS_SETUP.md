# Firebase Crashlytics – WCR PMIS Mobile

Crashlytics is integrated in code. Complete **one-time Firebase project setup** so builds and crash reporting work.

## 1. Prerequisites

- Firebase project (create at [Firebase Console](https://console.firebase.google.com/) or reuse an existing Synergiz project)
- [Firebase CLI login](https://firebase.google.com/docs/cli): `npx -y firebase-tools@latest login`

## 2. Android package name (Firebase Console)

When registering the Android app manually in Firebase, use this **package name** (must match the app exactly):

```
com.synergiz.wcr.pmis
```

**iOS bundle ID:** `com.synergiz.wcr.pmis` (same string as Android)

## 3. Platform config (done)

Project **syntrack-pmis-wcr** is wired via:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

To regenerate after Firebase console changes, from the project root:

```bash
dart pub global activate flutterfire_cli
export PATH="$PATH:$HOME/.pub-cache/bin"
flutterfire configure \
  --project=syntrack-pmis-wcr \
  --platforms=android,ios \
  --ios-bundle-id=com.synergiz.wcr.pmis \
  --android-package-name=com.synergiz.wcr.pmis \
  --yes
```

This updates:

| File | Purpose |
|------|---------|
| `lib/firebase_options.dart` | Dart Firebase options |
| `android/app/google-services.json` | Android Firebase config |
| `ios/Runner/GoogleService-Info.plist` | iOS Firebase config |

**Android package:** `com.synergiz.wcr.pmis`  
**iOS bundle ID:** `com.synergiz.wcr.pmis`

## 4. Enable Crashlytics in Firebase Console

1. Open your Firebase project → **Build** → **Crashlytics**
2. Click **Enable Crashlytics** if prompted
3. Register the Android and iOS apps if they are not already added

## 5. Build and verify

```bash
flutter pub get
cd ios && pod install && cd ..
flutter run --release
```

- **Debug builds:** Crashlytics collection is **off** (no noise during development).
- **Profile / release builds:** Crashes and fatal Flutter errors are sent automatically.

Optional test (release only):

```dart
FirebaseCrashlytics.instance.crash();
```

## 6. What the app reports

- Uncaught Flutter framework errors
- Uncaught async errors (zone handler)
- Non-fatal errors recorded via `FirebaseCrashlytics.instance.recordError(...)`

## 7. Code locations

- `lib/src/core/firebase/firebase_initializer.dart` – init and error hooks
- `lib/src/app/bootstrap/bootstrap.dart` – called at app startup

Until `flutterfire configure` is run, the app starts normally but Crashlytics is skipped (debug log only).

## 8. Remote Config — in-app update prompts

After login, the dashboard checks Firebase Remote Config and compares versions with `package_info_plus`.

| Key | Type | Purpose |
|-----|------|---------|
| `update_check_enabled` | Boolean | Master switch (`false` disables all prompts) |
| `min_version` | String | Force update below this version (both platforms) |
| `latest_version` | String | Optional update below this version |
| `min_version_android` / `min_version_ios` | String | Platform override (optional) |
| `latest_version_android` / `latest_version_ios` | String | Platform override (optional) |
| `optional_update_interval_hours` | Number | Hours before optional dialog shows again after **Later** (default `24`) |
| `force_update_message` | String | Force-update copy |
| `optional_update_message` | String | Optional-update copy |
| `android_store_url` | String | Override Play Store URL (optional) |
| `ios_store_url` | String | Override App Store URL (optional) |
| `ios_app_store_id` | String | Numeric App Store ID for iOS link |

**Defaults in app:** `min_version` / `latest_version` = `0.0.0` (no prompts until you set values in Firebase Console).

**Example (force 1.0.1+, optional nudge for 1.0.2):**

- `min_version` = `1.0.1`
- `latest_version` = `1.0.2`
- `ios_app_store_id` = your App Store numeric ID

Code: `lib/src/core/app_update/` and `lib/src/core/firebase/remote_config_initializer.dart`.
