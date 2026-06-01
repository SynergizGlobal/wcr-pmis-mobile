# Store listings, privacy URL, and rejection avoidance

Use this checklist when submitting **IMPACT PMIS by Synergiz** (`com.synergiz.wcr.pmis`) to Google Play and App Store Connect.

## 1. Host the privacy policy (required before review)

Upload the HTML file to your WCR PMIS web server:

| Item | Value |
|------|--------|
| **Source file in repo** | `docs/impact-pmis-privacy-policy.html` |
| **Deploy as** | `impact-pmis-privacy-policy.html` under the `/wcrpmis/` web root |
| **Public URL (use everywhere)** | `https://pmis-wcrindianrailways.org/wcrpmis/impact-pmis-privacy-policy.html` |

Verify in a browser (incognito): the page loads over **HTTPS** with no login wall. Play and Apple reject apps when the privacy URL returns 404 or requires authentication.

The same URL is defined in code as `LegalConstants.privacyPolicyUrl` and linked from **Settings → Privacy Policy** in the app.

---

## 2. Google Play Console

### Store listing

| Field | Value |
|-------|--------|
| App name | IMPACT PMIS by Synergiz |
| Short / full description | Intelligent Management of Projects And Construction Tracking |
| Package name | `com.synergiz.wcr.pmis` |
| Privacy policy URL | `https://pmis-wcrindianrailways.org/wcrpmis/impact-pmis-privacy-policy.html` |

### Data safety (align with the policy — do not over-declare)

| Question | Suggested answer |
|----------|------------------|
| Does your app collect or share user data? | **Yes** (account, workflow, optional location/photos, crash diagnostics) |
| Is all data encrypted in transit? | **Yes** (HTTPS for APIs) |
| Can users request data deletion? | **Yes** (email in policy) |
| **Advertising ID** | **No** — app does not use ads or ad ID |
| **Location** | **Yes**, approximate/precise, **only while in use**, for app functionality (RFI/inspection) |
| **Photos / videos** | **Yes**, user-selected, for app functionality |
| **App activity / crash logs** | **Yes** — Firebase Crashlytics, diagnostics only |
| **Personal info** (name, email, user IDs) | **Yes**, if collected via login — account management |
| **Files and docs** | **Yes**, user-provided uploads |
| **Contacts, SMS, microphone, background location** | **No** |

### Permissions declaration (Android)

Only declare what the merged manifest actually uses after our removals:

- Internet  
- Camera  
- Fine + coarse location (**foreground / while in use** only)

Do **not** declare: storage (unless Play forces a merged permission you cannot remove — then explain “user-selected files only”), microphone, phone, notifications, AD_ID.

### Other Play rejection avoiders

- Target API level meets current Play requirements.  
- No misleading screenshots or description (native PMIS + RFI, not a generic browser app).  
- If using **Photo and video permissions** form: explain camera/gallery are for inspection attachments only.  
- **Families / ads**: No ads SDK; answer accordingly.

---

## 3. Apple App Store Connect

### App Information

| Field | Value |
|-------|--------|
| Name | IMPACT PMIS by Synergiz |
| Subtitle | Projects & construction PMIS |
| Bundle ID | `com.synergiz.wcr.pmis` |
| Privacy Policy URL | `https://pmis-wcrindianrailways.org/wcrpmis/impact-pmis-privacy-policy.html` |

### App Privacy (nutrition labels)

| Data type | Collected? | Linked to user? | Tracking? |
|-----------|------------|-----------------|-----------|
| Contact info / identifiers (login) | Yes | Yes | No |
| Location (precise/coarse) | Yes, when feature used | Yes | No |
| Photos / user content | Yes, user-selected | Yes | No |
| Diagnostics / crash data | Yes (Crashlytics) | No or Yes per your legal review | **No** |
| Usage analytics | **No** (no Firebase Analytics in app) | — | No |
| Advertising data | **No** | — | No |

**Tracking:** Set to **No** — the app does not track users across apps/websites for advertising.

**Privacy Nutrition Label** must match `Info.plist` usage strings:

- `NSCameraUsageDescription`  
- `NSLocationWhenInUseUsageDescription`  
- `NSPhotoLibraryUsageDescription` / `NSPhotoLibraryAddUsageDescription` (only if you save to library)

No `NSMicrophoneUsageDescription`, no `NSUserTrackingUsageDescription`, no background location keys.

### Review notes (optional but helpful)

> Native Flutter app for authorized WCR PMIS users. Test credentials: [provide]. Camera and location are used only in RFI/inspection flows when the user taps those actions. Privacy policy: [URL above].

---

## 4. In-app consistency (reviewers check this)

- On-device name: **IMPACT PMIS** (`strings.xml`, `CFBundleDisplayName`).  
- Settings includes **Privacy Policy** opening the same HTTPS URL.  
- Permission prompts appear only when the user uses camera, location, or file pickers.  
- No login screen claiming data practices that differ from the hosted policy.

---

## 5. Firebase console

- Project: **syntrack-pmis-wcr**  
- Android package / iOS bundle: `com.synergiz.wcr.pmis`  
- Crashlytics enabled; Analytics/Ads not required for this app.

---

## 6. Quick pre-submit test

1. Open privacy URL in browser → 200 OK, readable policy.  
2. Install release build → Settings → Privacy Policy → opens same URL.  
3. Trigger camera/location only from RFI/inspection → permission dialog matches policy text.  
4. Play/App Store forms match the policy (no extra data types).

See also [APP_AND_STORE_NAMES.md](APP_AND_STORE_NAMES.md) and [FIREBASE_CRASHLYTICS_SETUP.md](FIREBASE_CRASHLYTICS_SETUP.md).
