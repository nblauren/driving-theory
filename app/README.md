# Driving Theory - German Class B Theory Exam Trainer

A Flutter app for learning German driving theory questions using spaced repetition.

## Features

- **Practice Mode** with Leitner-box spaced repetition (5 boxes: 1d, 3d, 7d, 14d, 30d)
- **Exam Simulation** — 30 questions (20 Grundstoff + 10 Zusatzstoff Klasse B), scored per official rules
- **Progress Tracking** — per-theme stats and overall completion
- **Exam Readiness Indicator** — traffic light (red/amber/green) based on SRS box levels across all questions
- **Filter Modes** — Due for review, Unseen, Mistakes, Bookmarked, All
- **Bookmarks** — flag any question for quick re-review later
- **Zoomable Images** — pinch-to-zoom on question images (up to 4x)
- **Text-to-Speech** — read questions and answers aloud (English or German)
- **Swipe Navigation** — swipe left/right between questions in practice mode
- **Two-Language Support** — English and German question content, switchable at runtime
- **Cloud Sync** — progress syncs across devices via Firebase Firestore
- **Authentication** — Google Sign-In and Apple Sign-In
- **Theme modes** — Dark, Light, and System (follows device setting), persisted via `theme_mode` preference key
- Offline-first — all data stored locally via Drift (SQLite), Firestore is sync-only

## Two-Language System

The app supports two languages for question content:

- **English** — loaded from `assets/driving_theory_questions.json`
- **German** — loaded from `assets/driving_theory_questions_de.json`

Both JSON files share the same `question_id` structure. The selected language is persisted via `shared_preferences` and accessible globally via the `selectedLanguageProvider` Riverpod provider.

**How it works:**
- The Drift database stores question structure (seeded from the English JSON on first launch)
- At runtime, the `localizedQuestionMapProvider` loads the selected language's JSON into a `Map<String, QuestionModel>` keyed by `question_id`
- When displaying questions, the localized text (question text, options, correct answers, comment, theme name, chapter name) is overlaid onto the base question from the database
- SRS progress in `QuestionProgress` is shared across both languages (keyed by `question_id` only)
- Switching language does **not** reseed or reload the database — it only changes which JSON is used for display text
- Language can be switched from the home screen top bar or the Settings screen

## Daily Streaks

The app tracks consecutive days of study. A "study day" is any calendar day where the user answers at least one question. The current streak count is displayed on the home screen. A daily local notification at 19:00 reminds users who haven't studied yet. When a user studies, the notification is cancelled and rescheduled for the following day.

Streak data is stored in `shared_preferences`:
- `streak_current`, `streak_longest`, `streak_last_studied`
- `study_history` — JSON map of date → questions answered (used for exam readiness prediction)

## Daily Challenge

Each day, 10 questions are selected using this priority:
1. Questions answered incorrectly most often (highest `incorrectCount`, lowest `boxLevel`)
2. Unseen questions (no `QuestionProgress` entry)
3. Box 1 and box 2 questions (fill remaining slots)

The same 10 questions persist for the entire calendar day. Daily challenge completion counts toward the streak. Challenge state is stored in `shared_preferences` (`daily_challenge_date`, `daily_challenge_ids`, `daily_challenge_answered`).

## GDPR Consent

The app shows a consent gate on first launch. The consent version is defined as a single constant in `lib/consent_config.dart`. Bump `currentConsentVersion` to force the consent screen to reappear for all users.

## Data

- **2413 questions** parsed from `driving_theory_questions.json`
- **823 Grundstoff** (Theme 1.x) — basic knowledge for all licence classes
- **1590 Zusatzstoff** (Theme 2.x) — car-specific knowledge (Klasse B)
- Point values: 2, 3, 4, or 5 points per question
- Question types: 3-option MCQ, 2-option MCQ, and numeric input (104 questions with no options)

### Grundstoff / Zusatzstoff Detection

Questions are classified by the leading digit of their `question_id`:
- Starts with `1.` → **Grundstoff** (themes: 1.1 through 1.8)
- Starts with `2.` → **Zusatzstoff Klasse B** (themes: 2.1 through 2.8)

This matches the official German theory exam structure.

### Exam Scoring

- 20 Grundstoff + 10 Zusatzstoff = 30 questions
- **Fail** if penalty points > 10, OR if 2+ questions worth 5 points are answered incorrectly
- Exam results do **not** affect SRS progress

**Fallback**: If the dataset doesn't have enough questions per category, a random 30-question mix is used and a notice is displayed.

## Firebase Setup

This app uses Firebase for optional cross-device progress sync. Follow these steps to set up Firebase for the project.

### 1. Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project** and follow the wizard
3. Give it a name (e.g. "driving-theory")
4. You can disable Google Analytics (not needed)

### 2. Enable Authentication

1. In the Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Google** sign-in provider
   - Set a support email
3. Enable **Apple** sign-in provider (required for iOS App Store)
   - Follow Apple's setup instructions for Sign in with Apple (requires an Apple Developer account)

### 3. Enable Cloud Firestore

1. Go to **Firestore Database** → **Create database**
2. Choose **Start in production mode**
3. Select your preferred region
4. After creation, go to **Rules** and set:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/progress/{questionId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4. Add Platform Apps

#### Android

1. In Firebase Console → **Project settings** → **Add app** → Android
2. Package name: `com.example.driving_theory` (or your custom package name)
3. Download `google-services.json` and place it in `app/android/app/`

#### iOS

1. In Firebase Console → **Project settings** → **Add app** → iOS
2. Bundle ID: your iOS bundle identifier
3. Download `GoogleService-Info.plist` and add it to the Xcode project under `Runner/`
4. For Google Sign-In: add the `REVERSED_CLIENT_ID` from the plist as a URL scheme in Xcode:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select Runner → Info → URL Types → Add the reversed client ID

### 5. Generate FlutterFire Configuration

```bash
# Install the FlutterFire CLI (one-time)
dart pub global activate flutterfire_cli

# Run from the app directory
cd app
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

This generates `lib/firebase_options.dart` which is imported by `main.dart`. This file is gitignored since it contains project-specific configuration.

### Firestore Data Model

Progress is stored at: `users/{uid}/progress/{questionId}`

Each document contains:
- `questionId` (string)
- `boxLevel` (number, 0-5)
- `nextReviewDate` (timestamp)
- `correctCount` (number)
- `incorrectCount` (number)
- `updatedAt` (server timestamp)

### Sync Strategy

- **On login**: pull from Firestore, merge with local (higher boxLevel wins, ties broken by correctCount), then push local progress
- **On answer**: write updated progress to Firestore immediately (fire-and-forget)
- **On app launch** (if logged in): pull and merge from Firestore
- **Offline**: Firestore's built-in offline persistence handles connectivity gaps

## How to Run

### Prerequisites

- Flutter SDK (latest stable)
- Xcode (for iOS) / Android Studio (for Android)
- Firebase project set up (see above) — or skip sign-in and use offline only

### Run

```bash
cd app
flutter pub get
flutter run
```

### iOS

```bash
cd ios && pod install && cd ..
flutter run -d ios
```

### Android

```bash
flutter run -d android
```

## New Packages

| Package | Purpose |
|---------|---------|
| `shared_preferences` | Persists language selection, TTS toggle, and theme mode (`theme_mode`: 'dark'/'light'/'system') across app restarts |
| `flutter_tts` | Text-to-Speech engine for reading questions aloud in EN/DE |
| `flutter_local_notifications` | Daily streak reminder notification at 19:00 |
| `timezone` | Timezone-aware scheduling for local notifications |
| `confetti` | Confetti animation for milestone celebrations |

## Drift Code Generation

If you modify any Drift table definitions in `lib/database/app_database.dart`, regenerate:

```bash
cd app
dart run build_runner build --delete-conflicting-outputs
```

## Architecture

- **State management**: Riverpod
- **Database**: Drift (SQLite) — single `AppDatabase` instance, local source of truth
- **Cloud sync**: Firebase Firestore — sync-only, never blocks UI
- **Auth**: Firebase Auth with Google Sign-In and Apple Sign-In
- **Tables**: `Questions` (all JSON fields + `isGrundstoff`), `QuestionProgress` (SRS state + `isBookmarked`)
- **Seeding**: On first launch, the app parses `assets/driving_theory_questions.json` and bulk-inserts via Drift batch
- **Language**: Runtime JSON loading via `localizedQuestionMapProvider` — no DB changes on language switch

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart         # Generated by flutterfire configure
├── database/
│   ├── app_database.dart         # Drift tables + queries
│   └── app_database.g.dart       # Generated
├── models/
│   └── question_model.dart       # JSON parsing model
├── providers/
│   ├── database_provider.dart    # DB instance + seeding
│   ├── question_provider.dart    # SRS logic, exam, stats, readiness
│   ├── language_provider.dart    # Language selection, TTS toggle, localized question map
│   └── auth_provider.dart        # Auth & sync providers
├── services/
│   ├── auth_service.dart         # Google/Apple sign-in
│   └── firebase_sync_service.dart # Firestore sync logic
├── screens/
│   ├── home_screen.dart
│   ├── practice_screen.dart
│   ├── exam_screen.dart
│   ├── stats_screen.dart
│   ├── auth_screen.dart          # Sign-in screen
│   └── account_screen.dart       # Account management + app settings
└── widgets/
    └── question_card.dart        # Reusable question display
```
