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
