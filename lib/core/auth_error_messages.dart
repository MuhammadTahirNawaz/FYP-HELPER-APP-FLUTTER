import 'package:firebase_auth/firebase_auth.dart';

/// Maps Firebase Auth errors to short, user-friendly copy.
class AuthErrorMessages {
  AuthErrorMessages._();

  static String from(Object error) {
    if (error is String) {
      return error;
    }

    if (error is FirebaseAuthException) {
      return _fromCode(error.code, error.message);
    }

    final text = error.toString();
    final match = RegExp(r'\[firebase_auth/([^\]]+)\]').firstMatch(text);
    if (match != null) {
      return _fromCode(match.group(1)!, null);
    }

    return 'Something went wrong. Please try again.';
  }

  static String _fromCode(String code, String? fallback) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-login-credentials':
        return 'Invalid email or password. Please check your details and try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact your administrator.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection and try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'This sign-in method is not available right now.';
      case 'requires-recent-login':
        return 'Please sign out and sign in again to continue.';
      default:
        return fallback ?? 'Something went wrong. Please try again.';
    }
  }
}
