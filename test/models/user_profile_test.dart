import 'package:fyp_helper_app/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile', () {
    test('fromMap parses profile fields', () {
      final profile = UserProfile.fromMap('uid-1', {
        'email': 'student@uet.edu.pk',
        'role': 'Student',
        'fullName': 'Ali Khan',
        'studentId': 'F21-1234',
        'university': 'UET',
      }, phoneNumber: '03001234567');

      expect(profile.uid, 'uid-1');
      expect(profile.email, 'student@uet.edu.pk');
      expect(profile.role, 'Student');
      expect(profile.fullName, 'Ali Khan');
      expect(profile.studentId, 'F21-1234');
      expect(profile.university, 'UET');
      expect(profile.phoneNumber, '03001234567');
    });

    test('fromMap uses empty defaults for missing strings', () {
      final profile = UserProfile.fromMap('uid-2', {});
      expect(profile.email, '');
      expect(profile.role, '');
      expect(profile.fullName, isNull);
    });
  });
}
