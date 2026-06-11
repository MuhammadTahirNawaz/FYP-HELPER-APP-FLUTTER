import 'package:fyp_helper_app/models/user_account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserAccount', () {
    test('fromMap parses RTDB user fields', () {
      final account = UserAccount.fromMap('uid-1', {
        'email': 'student@uet.edu.pk',
        'role': 'Pending',
        'university': 'UET',
        'requestedRole': 'Student',
        'status': 'Pending',
      });

      expect(account.uid, 'uid-1');
      expect(account.email, 'student@uet.edu.pk');
      expect(account.role, 'Pending');
      expect(account.university, 'UET');
      expect(account.requestedRole, 'Student');
      expect(account.status, 'Pending');
    });

    test('listFromSnapshot returns empty list for invalid data', () {
      expect(UserAccount.listFromSnapshot(null), isEmpty);
      expect(UserAccount.listFromSnapshot('invalid'), isEmpty);
    });

    test('listFromSnapshot maps all entries', () {
      final accounts = UserAccount.listFromSnapshot({
        'a': {'email': 'a@test.com', 'role': 'Student'},
        'b': {'email': 'b@test.com', 'role': 'Supervisor'},
      });

      expect(accounts, hasLength(2));
      expect(accounts.map((u) => u.uid), containsAll(['a', 'b']));
    });

    test('empty sentinel reports isEmpty', () {
      expect(UserAccount.empty.isEmpty, isTrue);
      expect(
        const UserAccount(uid: 'x', email: 'x@test.com', role: 'Student').isEmpty,
        isFalse,
      );
    });
  });
}
