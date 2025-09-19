# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Project Stack
- **Language:** Dart, Kotlin
- **Framework:** Flutter
- **Build Tools:** Gradle (Android), Xcode/CocoaPods (iOS)
- **Package Manager:** Pub
- **Key Dependencies:** Firebase, Drift (SQLite ORM)

## Non-Obvious Commands & Setup
- **Native Splash Screen:** After `flutter_native_splash.yaml` config, run `flutter pub run flutter_native_splash:create`.
- **Custom App Icons:** After `flutter_launcher_icons.yaml` config, run `flutter pub run flutter_launcher_icons`.
- **Drift ORM Code Generation:** After schema changes, run `flutter pub run build_runner build` to generate `lib/data/local/app_database.g.dart`.
- **Firebase Setup:** Requires platform-specific config files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS).
- **Custom Asset Structure:** Assets are located in non-standard paths like `images/backgrounds/` and `images/launcher/`.

## Non-Obvious Architectural Aspects
- **Layered Persistence Strategy:** Combines `SharedPreferences` for flags, Firebase for authentication/cloud data, and Drift for robust local relational data.
- **Orchestrated User Onboarding:** The `AuthGate` manages a multi-step onboarding and authentication process.
- **Granular State Management:** Multiple, specialized `ChangeNotifierProvider` instances are used for fine-grained state control.
- **Offline Capability (Implied):** Strong reliance on Drift suggests the application is designed with offline capabilities.

## Non-Obvious Critical Patterns
- **Custom Conversion Functions:** Refer to `_convertToUiTransaction` in [`lib/screens/dashboard/navbar/home.dart`](lib/screens/dashboard/navbar/home.dart) for database to UI model conversion.
- **Custom Formatting Functions:** Refer to `_formatDateRange` in [`lib/screens/dashboard/navbar/home/analytics/calendar/calendar_screen.dart`](lib/screens/dashboard/navbar/home/analytics/calendar/calendar_screen.dart) for date range formatting.
- **Singleton Database Pattern:** `lib/data/local/app_database.dart` implements a singleton for database access.
- **Custom State Management for Screen Refresh:** `HomeScreenProvider` in [`lib/viewmodels/home_screen_provider.dart`](lib/viewmodels/home_screen_provider.dart) coordinates screen refreshes.
- **Extended Transaction Model:** The `Transactions` table in [`lib/data/local/models/transaction_model.dart`](lib/data/local/models/transaction_model.dart) includes custom fields like `accountId`, `time`, `repeat`, `remind`, `icon`, `color`, `notes`, `paid`.
- **Error Handling Conventions:** Consistent use of try/catch, specific Firebase exception handling, and graceful degradation.
- **Form Validation Conventions:** Consistent `FormBuilderValidators` with custom error text and `errorBorder` styling.

## Non-Obvious Code Style
- The `avoid_print` lint rule is disabled.
- The `prefer_single_quotes` lint rule is disabled.

## Non-Obvious Testing Specifics
- The project uses the standard `flutter test` setup.
- There is a lack of Dart-based unit/widget tests.
- iOS tests exist but are platform-specific.
- No custom test patterns or configurations were found.