import 'package:firebase_database/firebase_database.dart';

import '../models/user_account.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';

/// User profile and account data access for RTDB `users/`.
class UserRepository {
  UserRepository({
    FirebaseDatabase? database,
    UserProfileService? profileService,
  })  : _database = database ?? FirebaseDatabase.instance,
        _profileService = profileService ??
            UserProfileService(database: database ?? FirebaseDatabase.instance);

  final FirebaseDatabase _database;
  final UserProfileService _profileService;

  DatabaseReference get usersRef => _database.ref('users');

  Future<UserProfile?> fetchProfile(String uid) =>
      _profileService.fetchProfile(uid);

  Future<void> createProfile({
    required String uid,
    required String email,
    required String role,
    String? fullName,
    String? studentId,
    String? phoneNumber,
    String? university,
    String? phoneEncrypted,
    String? requestedRole,
    String? status,
  }) {
    return _profileService.createProfile(
      uid: uid,
      email: email,
      role: role,
      fullName: fullName,
      studentId: studentId,
      phoneNumber: phoneNumber,
      university: university,
      phoneEncrypted: phoneEncrypted,
      requestedRole: requestedRole,
      status: status,
    );
  }

  Future<void> updateProfile({
    required String uid,
    String? fullName,
    String? studentId,
    String? phoneNumber,
  }) {
    return _profileService.updateProfile(
      uid: uid,
      fullName: fullName,
      studentId: studentId,
      phoneNumber: phoneNumber,
    );
  }

  Stream<DatabaseEvent> watchAllUsers() => usersRef.onValue;

  List<UserAccount> listFromSnapshot(Object? data) =>
      UserAccount.listFromSnapshot(data);

  Future<void> approveAccount({
    required String uid,
    required String role,
  }) async {
    await usersRef.child(uid).update({
      'role': role,
      'status': 'Active',
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> rejectAccount(String uid) async {
    await usersRef.child(uid).update({
      'role': 'Rejected',
      'status': 'Rejected',
      'updatedAt': ServerValue.timestamp,
    });
  }
}
