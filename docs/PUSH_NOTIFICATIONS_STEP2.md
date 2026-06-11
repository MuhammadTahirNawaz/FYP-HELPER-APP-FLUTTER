# Push Notifications — Step 2 (Deploy Guide)

Step 2 adds **Firebase Cloud Functions** that send **FCM push notifications** when:

- A new chat message is sent (`onNewChatMessage`)
- A group notification is created (`onGroupNotificationCreated`)
- Committee schedules a viva date (`onVivaScheduled`)

## Prerequisites

1. **Blaze (pay-as-you-go) plan** on Firebase project `fyp-helper` (required for Cloud Functions).
2. Step 1 complete: phones have `users/{uid}/fcmToken` saved after sign-in.
3. Firebase CLI logged in: `firebase login`

## Deploy (run once after code changes)

```powershell
cd "D:\MAD PROJECT\FYP-HELPER-APP-FLUTTER"
firebase deploy --only functions,database
```

## Test message push (2 phones)

1. Install updated app on **Phone A** and **Phone B** (`.\run_app.ps1 -android`).
2. Sign in as different users on each phone.
3. Confirm both have `fcmToken` in Firebase Console → Realtime Database → `users`.
4. Send a message from Phone A to Phone B.
5. Phone B should receive a **system notification** (even if app is in background).

## Troubleshooting

| Issue | Fix |
|-------|-----|
| No push | Check `fcmToken` exists for recipient |
| Functions not running | `firebase functions:log` |
| Permission denied on deploy | Enable Blaze plan |
| Invalid token | Sign out/in to refresh token |
