import 'package:fyp_helper_app/screens/student/utils/student_deadline_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isStudentDeadlinePassed', () {
    test('returns false when date is missing or invalid', () {
      expect(isStudentDeadlinePassed(null, null), isFalse);
      expect(isStudentDeadlinePassed('', null), isFalse);
      expect(isStudentDeadlinePassed('not-a-date', '10:00 AM'), isFalse);
    });

    test('returns true for a date far in the past', () {
      expect(isStudentDeadlinePassed('2000-01-01', '9:00 AM'), isTrue);
    });

    test('returns false for a date far in the future', () {
      expect(isStudentDeadlinePassed('2099-12-31', '11:59 PM'), isFalse);
    });
  });
}
