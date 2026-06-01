# App naming & store identifiers

## Branding

| Where | Value |
|-------|--------|
| **Google Play / App Store listing title** | `IMPACT PMIS by Synergiz` |
| **Android & iOS home screen** (under icon) | `IMPACT PMIS` |
| **Tagline / description** | Intelligent Management of Projects And Construction Tracking |
| **App Store subtitle** (max 30 chars) | `Projects & construction PMIS` |

Store titles and descriptions are set in **Play Console** and **App Store Connect**. In-repo constants: `lib/src/core/constants/legal_constants.dart`.

On-device names:

- Android: `android/app/src/main/res/values/strings.xml` → `app_name`
- iOS: `ios/Runner/Info.plist` → `CFBundleDisplayName`

## Package name & bundle ID (keep as-is)

| Platform | Identifier | Change? |
|----------|------------|---------|
| **Android package** | `com.synergiz.wcr.pmis` | **Keep** — required for the same Play listing and in-place updates |
| **iOS bundle ID** | `com.synergiz.wcr.pmis` | **Keep** — required for the same App Store app and Firebase iOS app |

You only need new IDs if you publish a **separate** new app on the stores (new listing, users reinstall, new Firebase Android/iOS apps).

Current Firebase project **syntrack-pmis-wcr** is already registered with these IDs.

## Firebase / `google-services.json`

```bash
flutterfire configure \
  --project=syntrack-pmis-wcr \
  --platforms=android,ios \
  --android-package-name=com.synergiz.wcr.pmis \
  --ios-bundle-id=com.synergiz.wcr.pmis \
  --yes
```

See [FIREBASE_CRASHLYTICS_SETUP.md](FIREBASE_CRASHLYTICS_SETUP.md).

## Privacy policy URL (Play + App Store)

Host `docs/impact-pmis-privacy-policy.html` on the WCR PMIS server as:

```
https://pmis-wcrindianrailways.org/wcrpmis/impact-pmis-privacy-policy.html
```

Must be live (HTTPS, no login) before store submission. Full checklist: [STORE_PRIVACY_AND_LISTINGS.md](STORE_PRIVACY_AND_LISTINGS.md).

## Play Console quick copy

- **App name:** IMPACT PMIS by Synergiz  
- **Short description:** Intelligent Management of Projects And Construction Tracking  
- **Developer:** SYNERGIZ GLOBAL SERVICES PRIVATE LIMITED  
- **Package name:** `com.synergiz.wcr.pmis` (cannot change after first upload)  
- **Privacy policy URL:** see above

## App Store Connect quick copy

- **Name:** IMPACT PMIS by Synergiz  
- **Subtitle:** Projects & construction PMIS  
- **Promotional text / description:** Intelligent Management of Projects And Construction Tracking  
- **Bundle ID:** `com.synergiz.wcr.pmis`  
- **Privacy policy URL:** `https://pmis-wcrindianrailways.org/wcrpmis/impact-pmis-privacy-policy.html`
