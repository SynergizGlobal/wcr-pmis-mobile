

## Firebase Crashlytics

Integrated for Android and iOS. Run **`flutterfire configure`** once before release builds — see [docs/FIREBASE_CRASHLYTICS_SETUP.md](docs/FIREBASE_CRASHLYTICS_SETUP.md).

## Environment

Default (in `lib/src/core/constants/api_constants.dart`):

| Environment | PMIS base | RFI base |
|-------------|-----------|----------|
| **QA** (`useQaServer = true`) | `https://pmis-wcrindianrailways.org/wcrpmis_qa/` | `https://pmis-wcrindianrailways.org/rfiSystem_qa/` |
| Production (`useQaServer = false`) | `https://pmis-wcrindianrailways.org/wcrpmis/` | `https://pmis-wcrindianrailways.org/rfiSystem/` |

Override PMIS base URL only:

```bash
flutter run --dart-define=BASE_URL=https://pmis-wcrindianrailways.org/wcrpmis_qa/
```
