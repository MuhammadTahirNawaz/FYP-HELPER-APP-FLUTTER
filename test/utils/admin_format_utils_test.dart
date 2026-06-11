import 'package:fyp_helper_app/screens/admin/utils/admin_format_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatAdminBytes', () {
    test('formats bytes and kilobytes', () {
      expect(formatAdminBytes(512), '512 B');
      expect(formatAdminBytes(2048), '2.0 KB');
    });
  });

  group('formatAdminTimestamp', () {
    test('returns Unknown for non-int values', () {
      expect(formatAdminTimestamp('bad'), 'Unknown');
      expect(formatAdminTimestamp(null), 'Unknown');
    });

    test('formats epoch milliseconds', () {
      final formatted = formatAdminTimestamp(0);
      expect(formatted, matches(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$'));
    });
  });

  group('adminTimestampToInt', () {
    test('coerces supported types', () {
      expect(adminTimestampToInt(10), 10);
      expect(adminTimestampToInt(10.9), 10);
      expect(adminTimestampToInt('42'), 42);
      expect(adminTimestampToInt('bad'), 0);
    });
  });
}
