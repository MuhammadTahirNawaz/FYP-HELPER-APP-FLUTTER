const functions = require("firebase-functions");
const admin = require("firebase-admin");
const crypto = require("crypto");

admin.initializeApp();

const ALLOWED_ROLES = new Set(["Student", "Supervisor", "Committee"]);

async function isAdminUser(uid) {
  const roleSnap = await admin.database().ref(`users/${uid}/role`).get();
  return roleSnap.exists() && roleSnap.val() === "Admin";
}

async function listAllAuthUsers() {
  const users = [];
  let pageToken;

  do {
    const result = await admin.auth().listUsers(1000, pageToken);
    users.push(...result.users);
    pageToken = result.pageToken;
  } while (pageToken);

  return users;
}

function generateTempPassword() {
  return crypto.randomBytes(24).toString("base64").replace(/[^a-zA-Z0-9]/g, "").slice(0, 20);
}

exports.provisionUser = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Sign in required.");
  }

  const email = String(data?.email || "").trim();
  const role = String(data?.role || "").trim();
  const fullName = String(data?.fullName || "").trim();

  if (!email || !email.includes("@")) {
    throw new functions.https.HttpsError("invalid-argument", "Valid email is required.");
  }
  if (!ALLOWED_ROLES.has(role)) {
    throw new functions.https.HttpsError("invalid-argument", "Invalid role.");
  }

  const requesterUid = context.auth.uid;
  const requesterRoleSnap = await admin.database().ref(`users/${requesterUid}/role`).get();
  if (!requesterRoleSnap.exists() || requesterRoleSnap.val() !== "Admin") {
    throw new functions.https.HttpsError("permission-denied", "Admin access required.");
  }

  let userRecord;
  try {
    userRecord = await admin.auth().getUserByEmail(email);
  } catch (error) {
    if (error.code === "auth/user-not-found") {
      userRecord = await admin.auth().createUser({
        email,
        password: generateTempPassword(),
      });
    } else {
      throw new functions.https.HttpsError("internal", "Failed to lookup user.");
    }
  }

  const userRef = admin.database().ref(`users/${userRecord.uid}`);
  const existing = await userRef.get();
  const now = admin.database.ServerValue.TIMESTAMP;

  if (!existing.exists()) {
    await userRef.set({
      email,
      role,
      fullName: fullName || null,
      status: "Invited",
      invitedBy: requesterUid,
      createdAt: now,
      updatedAt: now,
    });
  } else {
    await userRef.update({
      role,
      fullName: fullName || null,
      status: "Invited",
      invitedBy: requesterUid,
      updatedAt: now,
    });
  }

  return { uid: userRecord.uid, email, role };
});

exports.resetSystemExceptAdmins = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Sign in required.");
  }

  const requesterUid = context.auth.uid;
  const requesterIsAdmin = await isAdminUser(requesterUid);

  if (!requesterIsAdmin) {
    throw new functions.https.HttpsError("permission-denied", "Admin access required.");
  }

  const authUsers = await listAllAuthUsers();
  const database = admin.database();
  const adminUsers = {};
  const nonAdminUids = [];

  for (const userRecord of authUsers) {
    const roleSnap = await database.ref(`users/${userRecord.uid}/role`).get();
    const role = roleSnap.exists() ? String(roleSnap.val()) : "";

    if (role === "Admin") {
      adminUsers[userRecord.uid] = {
        email: userRecord.email || null,
        role: "Admin",
        status: "Active",
        fullName: null,
      };
    } else {
      nonAdminUids.push(userRecord.uid);
    }
  }

  for (const uid of nonAdminUids) {
    try {
      await admin.auth().deleteUser(uid);
    } catch (error) {
      if (error.code !== "auth/user-not-found") {
        throw error;
      }
    }
  }

  try {
    const bucket = admin.storage().bucket();
    const [files] = await bucket.getFiles({ autoPaginate: true });
    await Promise.all(
      files.map((file) => file.delete().catch(() => null)),
    );
  } catch (error) {
    throw new functions.https.HttpsError(
      "internal",
      `Failed to clear storage: ${error.message}`,
    );
  }

  await database.ref().remove();

  if (Object.keys(adminUsers).length > 0) {
    await database.ref('users').set(adminUsers);
  }

  return {
    deletedAuthUsers: nonAdminUids.length,
    preservedAdmins: Object.keys(adminUsers).length,
  };
});
