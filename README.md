# WCR PMIS Mobile

Production-grade Flutter starter focused on Android and iOS.

## Stack

- State management: Riverpod (`flutter_riverpod`)
- Routing: `go_router`
- Networking: `dio` + `pretty_dio_logger`
- Architecture: feature-first clean architecture
- Quality: strict lints + analyzer rules
- Codegen ready: `build_runner`, `json_serializable`

## Project Structure

```text
lib/
  src/
    app/
      config/
      bootstrap/
      router/
      theme/
    core/
      constants/
      network/
      result/
    features/
      auth/
        data/
        domain/
        presentation/
      dashboard/
        presentation/
```

## Setup

```bash
flutter pub get
flutter analyze
flutter test
```

## Run

```bash
flutter run -d android --flavor dev -t lib/main.dart
flutter run -d android --flavor staging -t lib/main_staging.dart
flutter run -d android --flavor prod -t lib/main_prod.dart
flutter run -d ios -t lib/main.dart
```

## Build

```bash
flutter build apk --flavor prod -t lib/main_prod.dart --release
flutter build ios --release
```

## Auth Starter Flow

- Login route is the app entry screen.
- Temporary local credentials for quick testing:
  - Email: `admin@wcr.com`
  - Password: `admin123`

## Environment Example

Base URL is configured with `--dart-define`:

```bash
flutter run --dart-define=BASE_URL=https://api.yourdomain.com
```
