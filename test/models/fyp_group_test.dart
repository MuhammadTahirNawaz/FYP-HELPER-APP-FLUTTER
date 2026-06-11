import 'package:fyp_helper_app/models/fyp_group.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FypGroup', () {
    test('fromMap counts members and applies defaults', () {
      final group = FypGroup.fromMap('G123', {
        'status': 'Pending',
        'supervisorEmail': 'sup@uet.edu.pk',
        'university': 'UET',
        'members': {'u1': true, 'u2': true},
      });

      expect(group.code, 'G123');
      expect(group.status, 'Pending');
      expect(group.supervisorEmail, 'sup@uet.edu.pk');
      expect(group.university, 'UET');
      expect(group.memberCount, 2);
    });

    test('fromMap defaults status to Pending', () {
      final group = FypGroup.fromMap('G999', {});
      expect(group.status, 'Pending');
      expect(group.memberCount, 0);
    });

    test('listFromSnapshot returns empty list for invalid data', () {
      expect(FypGroup.listFromSnapshot(null), isEmpty);
      expect(FypGroup.listFromSnapshot([]), isEmpty);
    });
  });
}
