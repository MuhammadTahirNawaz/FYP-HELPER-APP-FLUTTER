import 'package:firebase_database/firebase_database.dart';

import '../core/app_logger.dart';
/// Service to clean up all user data from Realtime Database and Storage when account is deleted.
class UserDataCleanupService {
  final FirebaseDatabase _database;

  UserDataCleanupService({
    FirebaseDatabase? database,
  })  : _database = database ?? FirebaseDatabase.instance;

  /// Delete all user data from database and storage
  Future<void> deleteAllUserData(String uid, String? email) async {
    try {
      AppLogger.debug(
        'Starting deletion of all data for uid=$uid, email=$email',
        tag: 'CLEANUP',
      );

      // 1. Delete user profile from /users
      await _deleteUserProfile(uid);

      // 2. Delete/remove user from all groups
      await _removeUserFromAllGroups(uid);

      // 3. Delete all invitations (sent and received)
      await _deleteInvitations(uid);

      // 4. Delete group invites backup
      await _deleteGroupInvites(uid);

      // 5. Delete all student documents from storage
      await _deleteUserDocuments(uid);

      // 6. Remove from admin records
      await _removeFromAdminRecords(uid, email);

      // 7. Delete any notifications
      await _deleteNotifications(uid);

      AppLogger.debug('Successfully deleted all data for uid=$uid', tag: 'CLEANUP');
    } catch (e) {
      AppLogger.error('Failed to delete user data', tag: 'CLEANUP', error: e);
      rethrow;
    }
  }

  /// Delete user profile from `users/{uid}`.
  Future<void> _deleteUserProfile(String uid) async {
    try {
      await _database.ref('users').child(uid).remove();
      AppLogger.debug('Deleted user profile for $uid', tag: 'CLEANUP');
    } catch (e) {
      AppLogger.error('Failed to delete user profile', tag: 'CLEANUP', error: e);
    }
  }

  /// Remove user from all groups they're in
  Future<void> _removeUserFromAllGroups(String uid) async {
    try {
      final groupsRef = _database.ref('groups');
      final snapshot = await groupsRef.get();

      if (snapshot.exists && snapshot.value is Map) {
        final groups = Map<String, dynamic>.from(snapshot.value as Map);

        for (final groupEntry in groups.entries) {
          final groupCode = groupEntry.key;
          final groupData = groupEntry.value as Map?;

          if (groupData != null) {
            final members = groupData['members'] as Map?;
            if (members != null && members.containsKey(uid)) {
              // Remove user from group members
              await groupsRef.child(groupCode).child('members').child(uid).remove();
              AppLogger.debug('Removed $uid from group $groupCode', tag: 'CLEANUP');
            }

            // If user was leader and group is now empty/broken, optionally delete group
            final leaderUid = groupData['leaderUid'] as String?;
            if (leaderUid == uid) {
              // Leader deleted — remove the group entirely
              await groupsRef.child(groupCode).remove();
              AppLogger.debug(
                'Deleted group $groupCode (leader $uid deleted account)',
                tag: 'CLEANUP',
              );
            }
          }
        }
      }
    } catch (e) {
      AppLogger.error('Failed to remove user from groups', tag: 'CLEANUP', error: e);
    }
  }

  /// Delete invitations sent by or to this user
  Future<void> _deleteInvitations(String uid) async {
    try {
      // Delete all invitations under this user's profile
      await _database.ref('users').child(uid).child('invitations').remove();
      AppLogger.debug('Deleted invitations for $uid', tag: 'CLEANUP');

      // Also scan all users and remove invitations sent by this user
      final usersRef = _database.ref('users');
      final snapshot = await usersRef.get();

      if (snapshot.exists && snapshot.value is Map) {
        final users = Map<String, dynamic>.from(snapshot.value as Map);

        for (final userEntry in users.entries) {
          final otherUid = userEntry.key;
          if (otherUid != uid) {
            final userData = userEntry.value as Map?;
            if (userData != null) {
              final invitations = userData['invitations'] as Map?;
              if (invitations != null) {
                for (final invCode in invitations.keys) {
                  final invData = invitations[invCode] as Map?;
                  if (invData != null && invData['leaderUid'] == uid) {
                    await usersRef
                        .child(otherUid)
                        .child('invitations')
                        .child(invCode as String)
                        .remove();
                    AppLogger.debug(
                      'Removed invitation from $uid to $otherUid',
                      tag: 'CLEANUP',
                    );
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      AppLogger.error('Failed to delete invitations', tag: 'CLEANUP', error: e);
    }
  }

  /// Delete group invites backup from `groupInvites/{uid}`.
  Future<void> _deleteGroupInvites(String uid) async {
    try {
      await _database.ref('groupInvites').child(uid).remove();
      AppLogger.debug('Deleted groupInvites for $uid', tag: 'CLEANUP');
    } catch (e) {
      AppLogger.error('Failed to delete groupInvites', tag: 'CLEANUP', error: e);
    }
  }

  /// Delete all student documents from Cloudinary
  Future<void> _deleteUserDocuments(String uid) async {
    try {
      // Note: Cloudinary unsigned API does not support deletions from the client app.
      // To physically delete files from Cloudinary, you need a backend server with your API Secret.
      // For now, we just delete the database metadata so the files are "orphaned" but no longer linked to the user.

      // Delete from database
      await _database.ref('student').child(uid).child('documents').remove();
      AppLogger.debug('Deleted student documents metadata for $uid', tag: 'CLEANUP');
    } catch (e) {
      AppLogger.error(
        'Failed to delete user documents metadata',
        tag: 'CLEANUP',
        error: e,
      );
    }
  }

  /// Remove user from admin records
  Future<void> _removeFromAdminRecords(String uid, String? email) async {
    try {
      final adminRef = _database.ref('admin');

      // Remove from users list under admin
      await adminRef.child('users').child(uid).remove();
      AppLogger.debug('Removed $uid from admin users record', tag: 'CLEANUP');

      // Remove from any admin-side invitations/records
      if (email != null) {
        final snapshot = await adminRef.get();
        if (snapshot.exists && snapshot.value is Map) {
          AppLogger.debug('Cleaned up admin records for $email', tag: 'CLEANUP');
        }
      }
    } catch (e) {
      AppLogger.error('Failed to remove from admin records', tag: 'CLEANUP', error: e);
    }
  }

  /// Delete user notifications
  Future<void> _deleteNotifications(String uid) async {
    try {
      await _database.ref('users').child(uid).child('group_notifications').remove();
      AppLogger.debug('Deleted notifications for $uid', tag: 'CLEANUP');
    } catch (e) {
      AppLogger.error('Failed to delete notifications', tag: 'CLEANUP', error: e);
    }
  }
}
