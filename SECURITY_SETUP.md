# Security & Environment Setup Guide

## Firebase Credentials Management

Your Firebase credentials are now **excluded from version control** for security.

### Setup

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Fill in your Firebase credentials in `.env`:**
   - Open `.env` and replace placeholder values with your actual Firebase credentials
   - This file is in `.gitignore` and will never be committed to Git

3. **Run the app with environment variables:**

   **Windows (PowerShell):**
   ```powershell
   .\run_app.ps1 -device chrome
   # or for Android
   .\run_app.ps1 -device android
   # or for building
   .\run_app.ps1 -build
   ```

   **macOS/Linux (Bash):**
   ```bash
   chmod +x run_app.sh
   ./run_app.sh chrome
   # or for Android
   ./run_app.sh android
   # or for building
   ./run_app.sh --build
   ```

   **Manual (any platform):**
   ```bash
   flutter run -d chrome \
     --dart-define=FIREBASE_WEB_API_KEY=your_key_here \
     --dart-define=FIREBASE_ANDROID_API_KEY=your_key_here
   ```

### What Changed

- **`.env`** - Local file (ignored by Git) containing your actual Firebase credentials
- **`.env.example`** - Template showing the structure (safe to commit)
- **`lib/firebase_options.dart`** - Now reads API keys from environment variables instead of hardcoding them
- **`run_app.ps1` / `run_app.sh`** - Helper scripts that load credentials and run the app

### Security Notes

✓ API keys are never committed to Git  
✓ Credentials are read at build-time via `--dart-define`  
✓ Each developer/CI system uses their own `.env` file  
✓ GitHub secret scanning will not flag these values  

### CI/CD Deployment

For GitHub Actions or other CI/CD:

```yaml
- name: Run Flutter App
  run: |
    flutter run -d chrome \
      --dart-define=FIREBASE_WEB_API_KEY=${{ secrets.FIREBASE_WEB_API_KEY }} \
      --dart-define=FIREBASE_ANDROID_API_KEY=${{ secrets.FIREBASE_ANDROID_API_KEY }}
```

Store credentials in GitHub Secrets instead of committing them.
