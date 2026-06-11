const admin = require("firebase-admin");
const functions = require("firebase-functions");

const db = () => admin.database();

/**
 * Writes an in-app notification under users/{uid}/notifications.
 */
async function writeInAppNotification(recipientUid, payload) {
  const notifRef = db().ref(`users/${recipientUid}/notifications`).push();
  await notifRef.set({
    title: payload.title,
    message: payload.message,
    type: payload.type || "general",
    isRead: false,
    timestamp: admin.database.ServerValue.TIMESTAMP,
    ...payload.extra,
  });
  return notifRef.key;
}

/**
 * Sends an FCM push to the user's saved device token (Step 1 registration).
 */
async function sendPushToUser(recipientUid, { title, body, data = {} }) {
  const tokenSnap = await db().ref(`users/${recipientUid}/fcmToken`).get();
  if (!tokenSnap.exists() || !tokenSnap.val()) {
    functions.logger.info(`No FCM token for user ${recipientUid}`);
    return false;
  }

  const token = String(tokenSnap.val());
  const stringData = {};
  for (const [key, value] of Object.entries(data)) {
    if (value !== undefined && value !== null) {
      stringData[key] = String(value);
    }
  }

  try {
    await admin.messaging().send({
      token,
      notification: { title, body },
      data: stringData,
      android: {
        priority: "high",
        notification: {
          channelId: "fyp_helper_alerts",
          sound: "default",
        },
      },
    });
    return true;
  } catch (error) {
    const code = error?.code || error?.errorInfo?.code || "";
    if (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token"
    ) {
      await db().ref(`users/${recipientUid}`).update({ fcmToken: null });
    }
    functions.logger.error(`FCM send failed for ${recipientUid}`, error);
    return false;
  }
}

/**
 * In-app badge + device push (background/lock-screen on Android).
 */
async function notifyUser(recipientUid, { title, body, type, data = {}, extra = {} }) {
  if (!recipientUid) {
    return { pushed: false, inApp: false };
  }

  await writeInAppNotification(recipientUid, {
    title,
    message: body,
    type,
    extra,
  });

  const pushed = await sendPushToUser(recipientUid, {
    title,
    body,
    data: { type, ...data },
  });

  return { pushed, inApp: true };
}

async function getUserDisplayName(uid) {
  const snap = await db().ref(`users/${uid}`).get();
  if (!snap.exists()) {
    return "Someone";
  }
  const data = snap.val() || {};
  return data.fullName || data.email || "Someone";
}

function resolveMessageRecipient(thread, senderUid) {
  if (!thread || !senderUid) {
    return null;
  }

  const p1 = thread.participantUid1;
  const p2 = thread.participantUid2;
  if (p1 && p2) {
    if (senderUid === p1) return p2;
    if (senderUid === p2) return p1;
  }

  const userUid = thread.userUid;
  const initiatorUid = thread.initiatorUid;
  if (userUid && initiatorUid) {
    if (senderUid === userUid) return initiatorUid;
    if (senderUid === initiatorUid) return userUid;
  }

  return null;
}

module.exports = {
  writeInAppNotification,
  sendPushToUser,
  notifyUser,
  getUserDisplayName,
  resolveMessageRecipient,
};
