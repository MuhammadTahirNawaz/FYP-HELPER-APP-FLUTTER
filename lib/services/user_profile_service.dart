import 'package:firebase_database/firebase_database.dart';

import '../models/user_profile.dart';
import '../utils/profiler.dart';
import 'crypto_service.dart';

class UserProfileService {
  UserProfileService({FirebaseDatabase? database, CryptoService? crypto})
      : _usersRef = (database ?? FirebaseDatabase.instance).ref('users'),
        _crypto = crypto ?? CryptoService();

  final DatabaseReference _usersRef;
  final CryptoService _crypto;

  Future<UserProfile?> fetchProfile(String uid) async {
    return Profiler.profileAsync('Firebase RTDB User Profile Read', () async {
      final snapshot = await _usersRef.child(uid).get();
      if (!snapshot.exists || snapshot.value == null) {
        return null;
      }
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return UserProfile.fromMap(
        uid,
        data,
        phoneNumber: _decryptPhone(data['phoneEncrypted'] as String?),
      );
    });
  }

  Future<void> writeProfileUpdate(
    String uid,
    Map<String, Object?> updates,
  ) {
    return Profiler.profileAsync('Firebase RTDB User Profile Write', () async {
      await _usersRef.child(uid).update(updates);
    });
  }

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
  }) async {
    final finalPhoneEncrypted = phoneEncrypted ?? _encryptIfPresent(phoneNumber);
    await _usersRef.child(uid).set({
      'email': email.toLowerCase(),
      'role': role,
      'fullName': fullName,
      'studentId': studentId,
      'university': university,
      'phoneEncrypted': finalPhoneEncrypted,
      'requestedRole': ?requestedRole,
      'status': ?status,
      'createdAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> updateProfile({
    required String uid,
    String? fullName,
    String? studentId,
    String? phoneNumber,
  }) async {
    await writeProfileUpdate(uid, {
      'fullName': ?fullName,
      'studentId': ?studentId,
      if (phoneNumber != null)
        'phoneEncrypted': _encryptIfPresent(phoneNumber),
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> touchProfile(String uid) async {
    await _usersRef.child(uid).update({
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> deleteProfile(String uid) async {
    await _usersRef.child(uid).remove();
  }

  String? _encryptIfPresent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return _crypto.encryptText(value.trim());
  }

  String? _decryptPhone(String? encryptedPhone) {
    if (encryptedPhone == null) {
      return null;
    }
    try {
      return _crypto.decryptText(encryptedPhone);
    } catch (_) {
      return null;
    }
  }
}
