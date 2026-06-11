import 'package:fyp_helper_app/models/admin_content_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdminContentItem', () {
    test('fromMap parses announcement fields', () {
      final item = AdminContentItem.fromMap('ann-1', {
        'title': 'Midterm schedule',
        'details': 'Submit reports by Friday',
        'date': '2026-06-15',
        'university': 'UET',
      });

      expect(item.id, 'ann-1');
      expect(item.title, 'Midterm schedule');
      expect(item.details, 'Submit reports by Friday');
      expect(item.date, '2026-06-15');
      expect(item.university, 'UET');
    });

    test('listFromSnapshot ignores invalid snapshot', () {
      expect(AdminContentItem.listFromSnapshot(42), isEmpty);
    });
  });
}
