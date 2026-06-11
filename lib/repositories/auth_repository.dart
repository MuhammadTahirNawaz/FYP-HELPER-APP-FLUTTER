import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

/// Authentication boundary — UI talks to this, not [AuthService] directly.
class AuthRepository {
  AuthRepository({AuthService? authService, FirebaseAuth? auth})
      : _authService = authService ?? AuthService(auth: auth),
        _auth = auth ?? FirebaseAuth.instance;

  final AuthService _authService;
  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  String encryptPhone(String phone) => _authService.encryptPhone(phone);

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _authService.signIn(email: email, password: password);
  }

  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _authService.register(email: email, password: password);
  }

  Future<void> sendEmailVerification(User user) =>
      _authService.sendEmailVerification(user);

  Future<void> reloadUser(User user) => _authService.reloadUser(user);

  Future<void> sendPasswordResetEmail(String email) =>
      _authService.sendPasswordResetEmail(email);

  Future<void> signOut() => _authService.signOut();

  Future<void> deleteAccount() => _authService.deleteAccount();
}
