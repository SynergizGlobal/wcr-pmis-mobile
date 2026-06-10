# App naming & store identifiers

## Branding

| Where | Value |
|-------|--------|
| **Google Play / App Store listing title** | `IMPACT-WCR by Synergiz` |
| **Android & iOS home screen** (under icon) | `IMPACT-WCR` |
| **Tagline** | WCR Project Management & Construction Tracking |
| **App Store subtitle** (max 30 chars) | `WCR railway project PMIS` |

Store descriptions: [STORE_LISTING_DESCRIPTIONS.md](STORE_LISTING_DESCRIPTIONS.md)

In-repo constants: `lib/src/core/constants/legal_constants.dart`

On-device names:

- Android: `android/app/src/main/res/values/strings.xml` → `app_name`
- iOS: `ios/Runner/Info.plist` → `CFBundleDisplayName`

## Package name & bundle ID (keep as-is)

| Platform | Identifier | Change? |
|----------|------------|---------|
| **Android package** | `com.synergiz.wcr.pmis` | **Keep** |
| **iOS bundle ID** | `com.synergiz.wcr.pmis` | **Keep** |

## Privacy policy URL

https://pmis-wcrindianrailways.org/wcrpmis/impact-pmis-privacy-policy.html
