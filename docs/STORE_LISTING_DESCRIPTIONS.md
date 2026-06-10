# Store listing copy — IMPACT-WCR (v1.0.1)

Use when uploading the next version to **Google Play** and **App Store Connect**.  
Package / bundle ID stays **`com.synergiz.wcr.pmis`** (do not change).

---

## Shared overview paragraph (use at top of both listings)

IMPACT-WCR is the official Project Management Information System (PMIS) for West Central Railway, developed by Synergiz Global Services Pvt. Ltd. The application enables end-to-end monitoring and management of railway construction projects, providing real-time tracking of project progress from DPR (Detailed Project Report) stage through planning, execution, monitoring, and commissioning. It offers stakeholders a centralized platform for project updates, approvals, document management, inspections, reporting, and decision-making across all phases of project delivery.

---

## Google Play Console

### Main store listing

| Field | Value |
|-------|--------|
| **App name** | `IMPACT-WCR by Synergiz` (max 30 chars — fits) |
| **Short description** | WCR railway PMIS — projects, RFI, inspections & site updates |
| **Developer** | SYNERGIZ GLOBAL SERVICES PRIVATE LIMITED |
| **Privacy policy** | https://pmis-wcrindianrailways.org/wcrpmis/impact-pmis-privacy-policy.html |

### Full description (paste)

IMPACT-WCR is the official Project Management Information System (PMIS) for West Central Railway, developed by Synergiz Global Services Pvt. Ltd. The application enables end-to-end monitoring and management of railway construction projects, providing real-time tracking of project progress from DPR (Detailed Project Report) stage through planning, execution, monitoring, and commissioning. It offers stakeholders a centralized platform for project updates, approvals, document management, inspections, reporting, and decision-making across all phases of project delivery.

Authorized access to WCR PMIS and RFI on mobile: projects, inspections, issues, utility shifting, and site updates for approved users.

Sign in with your organization account to work with live project data on Android.

Features
• Dashboard with project overview and status
• Projects, issues, utility shifting, and quality inspections
• New activities updates and related forms
• Request for Inspection (RFI) — create, submit, and track inspections
• Attach photos and documents from your device
• Record site location when required by an inspection workflow
• Real-time status tracking for submitted RFIs
• Project-based organization and digital record keeping

Requirements
• Valid PMIS credentials issued by your organization
• Network connection to WCR PMIS services

Support: synergizglobalservicespvtltd@gmail.com

### What to update for this release

1. **Store presence → Main store listing** — app name, short + full description  
2. **Release → Production** — upload new **AAB** (`versionCode` 3 / `1.0.1`)  
3. **Graphics** — replace screenshots if they still show “IMPACT PMIS”  
4. **App icon** — Play uses the icon from the uploaded AAB (rebuild with new logo)  
5. **Data safety / privacy** — no change unless you added new permissions  

---

## App Store Connect

### App Information

| Field | Value |
|-------|--------|
| **Name** | `IMPACT-WCR by Synergiz` |
| **Subtitle** | WCR railway project PMIS |
| **Privacy policy** | https://pmis-wcrindianrailways.org/wcrpmis/impact-pmis-privacy-policy.html |

### Description (paste)

IMPACT-WCR is the official Project Management Information System (PMIS) for West Central Railway, developed by Synergiz Global Services Pvt. Ltd. The application enables end-to-end monitoring and management of railway construction projects, providing real-time tracking of project progress from DPR (Detailed Project Report) stage through planning, execution, monitoring, and commissioning. It offers stakeholders a centralized platform for project updates, approvals, document management, inspections, reporting, and decision-making across all phases of project delivery.

Authorized access to WCR PMIS and RFI on mobile: projects, inspections, issues, utility shifting, and site updates for approved users.

IMPACT-WCR by Synergiz is the mobile companion for authorized users of the Western Central Railway Project Management Information System (PMIS).

Sign in with your organization account to work with live project data on iPhone and iPad.

Features
• Dashboard with project overview and status
• Projects, issues, utility shifting, and quality inspections
• New activities updates and related forms
• Request for Inspection (RFI) workflows
• Attach photos and documents from your device
• Record site location when required by an inspection workflow

Requirements
• Valid PMIS credentials issued by your organization
• Network connection to WCR PMIS services

Support: synergizglobalservicespvtltd@gmail.com

### What to update for this release

1. **App Information** — Name (if allowed; Apple may restrict name changes — home screen uses build `CFBundleDisplayName` = IMPACT-WCR)  
2. **iOS App → 1.0.1** — upload new build **3** (`flutter build ipa --release`)  
3. **Screenshots** — update if old branding visible  
4. **Promotional text** (optional) — WCR PMIS now branded as IMPACT-WCR  
5. **What’s New in This Version** — see below  
6. **Availability** — confirm countries (e.g. India) if users reported “not available in region”  

### What’s New (both stores, suggested)

• Rebranded to IMPACT-WCR with updated app icon  
• Improved RFI error handling and stability  
• Production server configuration for release builds  

---

## Build commands

```bash
# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ipa --release
```

Version in `pubspec.yaml`: **1.0.1+3** (marketing 1.0.1, build 3).
