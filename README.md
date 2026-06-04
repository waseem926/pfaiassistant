# PF AI Assistant

Flutter finance assistant with AI-powered expense parsing, local storage, PIN/biometric auth, and dark mode.

## Requirements

- Flutter SDK 3.11+
- Dart 3.11+
- Gemini API key

## Setup

```bash
git clone https://github.com/waseem926/pfaiassistant.git
cd pfaiassistant
copy .env.example .env   # Windows
# cp .env.example .env   # macOS/Linux
```

Edit `.env`:

```env
GEMINI_API_KEY=your_gemini_api_key_here
API_BASE_URL=
```

Install dependencies and run:

```bash
flutter pub get
flutter run
```

## Commands

```bash
flutter analyze
flutter test
flutter run -d chrome
flutter build apk --release
```

## Architecture

```text
UI (pages) -> BLoC/Cubit -> Repository -> DataSource
                              |-> Gemini (remote)
                              |-> Drift DB (local)
```

## Features

- Add expenses via text or voice
- Gemini parses amount, category, and description
- Local transaction history and analytics
- PIN + biometric login
- Light/dark theme with persistence

## Release signing (Android)

1. Create a keystore
2. Copy `android/key.properties.example` to `android/key.properties`
3. Configure release signing in `android/app/build.gradle.kts`

## CI

GitHub Actions runs `flutter analyze` and `flutter test` on push/PR.

## Roadmap (Phase 3)

- Node.js API proxy for Gemini
- Crash reporting
- Store release pipeline
