import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_helper_app/core/student_workflow_gate.dart';

void main() {
  const uid = 'student-1';

  final verifiedUser = {
    'role': 'Student',
    'status': 'Active',
  };

  final approvedGroupWithSupervisor = {
    'status': 'Approved',
    'supervisorId': 'sup-1',
    'supervisorEmail': 'supervisor@uet.edu.pk',
    'members': {
      uid: {'status': 'accepted'},
    },
  };

  group('StudentWorkflowGate.forProposal', () {
    test('blocks pending account verification', () {
      final result = StudentWorkflowGate.forProposal(
        user: {'role': 'Pending', 'status': 'Pending'},
        group: approvedGroupWithSupervisor,
        uid: uid,
      );

      expect(result.allowed, isFalse);
      expect(result.message, contains('verification'));
    });

    test('blocks when no group exists', () {
      final result = StudentWorkflowGate.forProposal(
        user: verifiedUser,
        group: null,
        uid: uid,
      );

      expect(result.allowed, isFalse);
      expect(result.message, contains('create a group'));
    });

    test('blocks when supervisor is not assigned', () {
      final result = StudentWorkflowGate.forProposal(
        user: verifiedUser,
        group: {
          'status': 'Approved',
          'supervisorEmail': '',
          'members': {uid: {'status': 'accepted'}},
        },
        uid: uid,
      );

      expect(result.allowed, isFalse);
      expect(result.message, contains('supervisor assigned'));
    });

    test('allows when all prerequisites are met', () {
      final result = StudentWorkflowGate.forProposal(
        user: verifiedUser,
        group: approvedGroupWithSupervisor,
        uid: uid,
      );

      expect(result.allowed, isTrue);
    });
  });

  group('StudentWorkflowGate.forMeeting', () {
    test('blocks when supervisor is not assigned', () {
      final result = StudentWorkflowGate.forMeeting(
        user: verifiedUser,
        group: {
          'status': 'Approved',
          'members': {uid: {'status': 'accepted'}},
        },
        uid: uid,
      );

      expect(result.allowed, isFalse);
      expect(result.message, contains('supervisor assigned'));
    });
  });
}
