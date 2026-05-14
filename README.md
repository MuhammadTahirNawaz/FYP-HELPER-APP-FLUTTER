# Flutter Application 1

Flutter project with multi-platform support: Android, iOS, Web, Windows, macOS, and Linux.

## Requirements

Install these tools first:

1. Flutter SDK (stable channel)
2. Dart SDK (included with Flutter)
3. Git
4. Platform tools based on where you want to run:
	- Android: Android Studio + Android SDK + emulator or device
	- iOS (macOS only): Xcode + CocoaPods
	- Web: Chrome
	- Windows desktop: Visual Studio with "Desktop development with C++"
	- Linux desktop: build essentials and GTK development packages
	- macOS desktop: Xcode command line tools

## Verify Environment

Run:

```bash
flutter doctor
```

Fix any issues shown by the doctor output before continuing.

## Get the Project

```bash
git clone <your-repository-url>
cd flutter_application_1
flutter pub get
```

## Run the App

1. List available devices:

```bash
flutter devices
```

2. Run on a selected target:

```bash
flutter run
```

Examples:

```bash
flutter run -d chrome
flutter run -d windows
flutter run -d android
```

## Build Release Artifacts

Use one of these commands depending on your target:

```bash
flutter build apk
flutter build appbundle
flutter build ios
flutter build web
flutter build windows
flutter build macos
flutter build linux
```

## Common Troubleshooting

If dependency or cache issues happen:

```bash
flutter clean
flutter pub get
```

If platform files are missing or outdated:

```bash
flutter create .
```

