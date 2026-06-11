import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../services/notification_delivery_service.dart';
import '../services/push_notification_service.dart';

/// Holds the signed-in user's profile and session lifecycle.
class SessionProvider extends ChangeNotifier {
  SessionProvider({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository;

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  UserProfile? _profile;
  bool _isLoading = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _authRepository.currentUser != null;
  String? get uid => _profile?.uid ?? _authRepository.currentUid;
  String? get role => _profile?.role;
  String? get university => _profile?.university;
  String? get email => _profile?.email;

  /// Load profile for the current Firebase Auth user, if any.
  Future<void> bootstrap() async {
    final currentUid = _authRepository.currentUid;
    if (currentUid == null) {
      _profile = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _userRepository.fetchProfile(currentUid);
      if (_profile != null) {
        await PushNotificationService.instance.syncTokenForUser(currentUid);
        await NotificationDeliveryService.instance.startListening(currentUid);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set session after a successful sign-in flow.
  void establishSession(UserProfile profile) {
    _profile = profile;
    notifyListeners();
    unawaited(PushNotificationService.instance.syncTokenForUser(profile.uid));
    unawaited(NotificationDeliveryService.instance.startListening(profile.uid));
  }

  /// Reload profile from the database (e.g. after profile edit).
  Future<void> refreshProfile() async {
    final currentUid = uid;
    if (currentUid == null) return;

    _profile = await _userRepository.fetchProfile(currentUid);
    notifyListeners();
  }

  /// Clear in-memory session after sign-out.
  void endSession() {
    unawaited(NotificationDeliveryService.instance.stopListening());
    _profile = null;
    notifyListeners();
  }
}
