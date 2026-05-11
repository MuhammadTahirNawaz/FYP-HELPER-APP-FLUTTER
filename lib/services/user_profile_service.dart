import 'package:firebase_database/firebase_database.dart';

import 'crypto_service.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.role,
    this.fullName,
    this.studentId,
    this.phoneNumber,
    this.university,
  });

  final String uid;
  final String email;
  final String role;
  final String? fullName;
  final String? studentId;
  final String? phoneNumber;
  final String? university;

  factory UserProfile.fromMap(
    String uid,
    Map<String, dynamic> data, {
    required CryptoService crypto,
  }) {
    final encryptedPhone = data['phoneEncrypted'] as String?;
    return UserProfile(
      uid: uid,
      email: (data['email'] as String?) ?? '',
      role: (data['role'] as String?) ?? '',
      fullName: data['fullName'] as String?,
      studentId: data['studentId'] as String?,
      university: data['university'] as String?,
      phoneNumber: encryptedPhone == null
          ? null
          : _safeDecrypt(crypto, encryptedPhone),
    );
  }

  static String? _safeDecrypt(CryptoService crypto, String input) {
    try {
      return crypto.decryptText(input);
    } catch (_) {
      return null;
    }
  }
}

class UserProfileService {
  UserProfileService({FirebaseDatabase? database, CryptoService? crypto})
      : _usersRef = (database ?? FirebaseDatabase.instance).ref('users'),
        _crypto = crypto ?? CryptoService();

  final DatabaseReference _usersRef;
  final CryptoService _crypto;

  Future<UserProfile?> fetchProfile(String uid) async {
    final snapshot = await _usersRef.child(uid).get();
    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return UserProfile.fromMap(uid, data, crypto: _crypto);
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
      if (requestedRole != null) 'requestedRole': requestedRole,
      if (status != null) 'status': status,
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
    await _usersRef.child(uid).update({
      if (fullName != null) 'fullName': fullName,
      if (studentId != null) 'studentId': studentId,
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
}
