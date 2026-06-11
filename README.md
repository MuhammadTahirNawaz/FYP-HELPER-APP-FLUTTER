# FYP Helper

A Flutter app for managing final-year projects (FYP) across universities. It supports role-based workflows for **Students**, **Supervisors**, **Committee** members, and **Admins**.

**Supported platforms:** Android (phones) and Windows (desktop PC) only.

## Features

- Role-based dashboards (Student, Supervisor, Committee, Admin)
- Firebase Authentication and Realtime Database
- Document uploads, proposals, progress reports, and viva scheduling
- Encrypted phone storage and admin user provisioning via Cloud Functions

## Requirements

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
2. Git
3. Platform tools for your target:
   - **Android:** Android Studio, Android SDK, emulator or physical device
   - **Windows:** Visual Studio with **Desktop development with C++** workload

Verify your setup:

```bash
flutter doctor
```

## Setup

1. Clone the repository and install dependencies:

```bash
git clone <your-repository-url>
cd FYP-HELPER-APP-FLUTTER
flutter pub get
```

2. Configure Firebase credentials:

```bash
cp .env.example .env
```

Edit `.env` with your Firebase keys. See [SECURITY_SETUP.md](SECURITY_SETUP.md) for details.

3. Register platform apps in the [Firebase Console](https://console.firebase.google.com/):
   - **Android** app (for mobile builds)
   - **Windows** app (for desktop builds)

## Run the App

**Recommended — use the helper script (Windows PC):**

```powershell
.\run_app.ps1              # Run on Windows desktop
.\run_app.ps1 -android     # Run on Android emulator/device
```

**Manual commands:**

```bash
flutter run -d windows \
  --dart-define=FIREBASE_WINDOWS_API_KEY=your_key \
  --dart-define=FIREBASE_WINDOWS_APP_ID=your_app_id \
  --dart-define=FIREBASE_ANDROID_API_KEY=your_key

flutter run -d android \
  --dart-define=FIREBASE_WINDOWS_API_KEY=your_key \
  --dart-define=FIREBASE_WINDOWS_APP_ID=your_app_id \
  --dart-define=FIREBASE_ANDROID_API_KEY=your_key
```

## Build Release

```powershell
.\run_app.ps1 -build -windows   # Windows desktop executable
.\run_app.ps1 -build -android   # Android APK
```

Or manually:

```bash
flutter build windows --dart-define=...
flutter build apk --dart-define=...
```

## Project Structure

```
lib/
  core/       Platform helpers and app-wide constants
  models/     Data models (UserProfile, etc.)
  screens/    UI by role (admin, student, supervisor, committee, auth, shared)
              student/sections/ and student/widgets/ split large dashboards
  services/   Firebase, auth, crypto, file upload
  theme/      Colors and styling tokens
  widgets/    Reusable UI components
  utils/      Download helpers, profiling
functions/    Firebase Cloud Functions (admin user provisioning)
```

## Troubleshooting

```bash
flutter clean
flutter pub get
```

If platform files are missing:

```bash
flutter create --platforms=android,windows .
```

## Security

Never commit `.env`, keystores, or `google-services.json`. See [SECURITY_SETUP.md](SECURITY_SETUP.md).

Before pushing:

```bash
git status
git diff --staged
```
