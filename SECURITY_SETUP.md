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

   This project targets **Android** and **Windows desktop** only.

   **Windows PC (PowerShell):**
   ```powershell
   .\run_app.ps1                  # run on Windows desktop
   .\run_app.ps1 -android         # run on Android emulator/device
   .\run_app.ps1 -build -windows  # build Windows release
   .\run_app.ps1 -build -android  # build APK
   ```

   **Manual:**
   ```bash
   flutter run -d windows \
     --dart-define=FIREBASE_WINDOWS_API_KEY=your_key \
     --dart-define=FIREBASE_WINDOWS_APP_ID=your_app_id \
     --dart-define=FIREBASE_ANDROID_API_KEY=your_key
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
    flutter run -d windows \
      --dart-define=FIREBASE_WINDOWS_API_KEY=${{ secrets.FIREBASE_WINDOWS_API_KEY }} \
      --dart-define=FIREBASE_WINDOWS_APP_ID=${{ secrets.FIREBASE_WINDOWS_APP_ID }} \
      --dart-define=FIREBASE_ANDROID_API_KEY=${{ secrets.FIREBASE_ANDROID_API_KEY }}
```

Store credentials in GitHub Secrets instead of committing them.

## Firebase Security Rules

The project uses **role-based Realtime Database rules** in `firebase.database.rules.json`.

### What the rules enforce

| Path | Who can read | Who can write |
|------|----------------|---------------|
| `users` | Signed-in users (email lookup for invites/messages) | Own profile, or Admin |
| `users/{uid}/role` | — | Self on signup (`Pending`/`Admin` only), or Admin |
| `groups` | Signed-in users | Group leader, members, supervisor, Committee, Admin |
| `admin/*` | Mostly Admin; university docs readable by all roles | Admin only |
| `supervisor/{uid}` | Supervisor, students (requests), Admin | Supervisor, students, Admin |
| `student/{uid}` | Owner, staff roles | Owner, Admin |
| `messages/*` | Signed-in users | Thread participants; messages must match `senderUid` |
| `committee/notifications` | Committee, Admin | Committee, Admin |

Root default is **deny all**; only listed paths are accessible.

Storage rules (`firebase.storage.rules`) require sign-in; student uploads are limited to the owner's UID folder.

### Deploy rules to Firebase

After changing rules locally, deploy them:

```bash
npx firebase-tools@latest login
npx firebase-tools@latest deploy --only database,storage --project fyp-helper
```

Test the app after deploy (sign-in, group invite, messaging, admin approval). If something is blocked, check the Firebase Console **Realtime Database → Rules** simulator.

### Known limitation

`users` is readable by any signed-in user so the app can look up accounts by email (group invites, messaging). Tightening this further would require a Cloud Function lookup instead of client-side queries.
