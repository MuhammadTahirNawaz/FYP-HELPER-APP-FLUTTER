import 'package:firebase_auth/firebase_auth.dart';
import 'user_data_cleanup_service.dart';
import 'crypto_service.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  final UserDataCleanupService _cleanupService = UserDataCleanupService();
  final CryptoService _cryptoService = CryptoService();

  String encryptPhone(String phone) => _cryptoService.encryptText(phone);

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendEmailVerification(User user) async {
    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> reloadUser(User user) => user.reload();

  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _auth.signOut();

  /// Delete user account and all associated data from database
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No user logged in');
    }

    try {
      // 1. Clean up all database and storage data
      await _cleanupService.deleteAllUserData(user.uid, user.email);

      // 2. Delete the Firebase Auth account
      await user.delete();
      print('DEBUG AUTH: Successfully deleted auth account for ${user.email}');
    } catch (e) {
      print('DEBUG AUTH ERROR: Failed to delete account: $e');
      rethrow;
    }
  }
}
