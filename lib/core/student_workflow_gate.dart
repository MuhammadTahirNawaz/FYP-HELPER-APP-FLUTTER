/// Result of a student workflow prerequisite check.
class WorkflowGateResult {
  const WorkflowGateResult({required this.allowed, required this.message});

  final bool allowed;
  final String message;

  static const allowedResult = WorkflowGateResult(allowed: true, message: '');
}

/// Thrown when a gated student action is attempted before prerequisites are met.
class WorkflowGateException implements Exception {
  WorkflowGateException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Enforces ordered prerequisites for student submission actions.
class StudentWorkflowGate {
  StudentWorkflowGate._();

  static WorkflowGateResult checkAccountVerified(Map<String, dynamic>? user) {
    if (user == null) {
      return const WorkflowGateResult(
        allowed: false,
        message:
            'Your account must be verified by your university admin before continuing.',
      );
    }

    final role = (user['role'] as String?) ?? '';
    final status = (user['status'] as String?) ?? '';

    if (role == 'Pending' || status == 'Pending') {
      return const WorkflowGateResult(
        allowed: false,
        message:
            'Your account is awaiting verification by your university admin. Please wait for approval before continuing.',
      );
    }

    if (role == 'Rejected' || status == 'Rejected') {
      return const WorkflowGateResult(
        allowed: false,
        message:
            'Your account access has been rejected. Contact your university admin for help.',
      );
    }

    if (role != 'Student' || status != 'Active') {
      return const WorkflowGateResult(
        allowed: false,
        message:
            'Your account must be verified and active before you can perform this action.',
      );
    }

    return WorkflowGateResult.allowedResult;
  }

  static WorkflowGateResult checkGroupMembership(
    String uid,
    Map<String, dynamic>? group, {
    required String actionPhrase,
  }) {
    if (group == null) {
      return WorkflowGateResult(
        allowed: false,
        message:
            'You must create a group and have it approved before $actionPhrase.',
      );
    }

    final membersRaw = group['members'];
    if (membersRaw is! Map) {
      return WorkflowGateResult(
        allowed: false,
        message:
            'You must create a group and have it approved before $actionPhrase.',
      );
    }

    final members = Map<String, dynamic>.from(membersRaw);
    if (!members.containsKey(uid)) {
      return WorkflowGateResult(
        allowed: false,
        message:
            'You must create or join a group before $actionPhrase.',
      );
    }

    final memberEntry = members[uid];
    if (memberEntry is Map) {
      final memberStatus = (memberEntry['status'] as String?) ?? 'accepted';
      if (memberStatus != 'accepted') {
        return WorkflowGateResult(
          allowed: false,
          message:
              'You must accept your group invitation and complete group formation before $actionPhrase.',
        );
      }
    }

    final groupStatus = (group['status'] as String?) ?? '';
    if (groupStatus == 'Forming') {
      return WorkflowGateResult(
        allowed: false,
        message:
            'Your group is still being formed. Invite all members and wait for admin approval before $actionPhrase.',
      );
    }

    if (groupStatus == 'Pending') {
      return WorkflowGateResult(
        allowed: false,
        message:
            'Your group is awaiting admin approval. You can continue once the group is approved.',
      );
    }

    if (groupStatus != 'Approved') {
      return WorkflowGateResult(
        allowed: false,
        message:
            'Your group must be approved by the admin before $actionPhrase.',
      );
    }

    return WorkflowGateResult.allowedResult;
  }

  static WorkflowGateResult checkSupervisorAssigned(
    Map<String, dynamic>? group, {
    required String actionPhrase,
  }) {
    final supervisorId = group?['supervisorId'] as String?;
    final supervisorEmail = group?['supervisorEmail'] as String?;
    final hasSupervisor = (supervisorId != null && supervisorId.isNotEmpty) ||
        (supervisorEmail != null && supervisorEmail.isNotEmpty);

    if (!hasSupervisor) {
      return WorkflowGateResult(
        allowed: false,
        message:
            'You must have a supervisor assigned to your group before $actionPhrase.',
      );
    }

    return WorkflowGateResult.allowedResult;
  }

  static WorkflowGateResult forProposal({
    required Map<String, dynamic>? user,
    required Map<String, dynamic>? group,
    required String uid,
  }) {
    for (final check in [
      () => checkAccountVerified(user),
      () => checkGroupMembership(
            uid,
            group,
            actionPhrase: 'submitting a proposal',
          ),
      () => checkSupervisorAssigned(
            group,
            actionPhrase: 'submitting a proposal',
          ),
    ]) {
      final result = check();
      if (!result.allowed) return result;
    }
    return WorkflowGateResult.allowedResult;
  }

  static WorkflowGateResult forMeeting({
    required Map<String, dynamic>? user,
    required Map<String, dynamic>? group,
    required String uid,
  }) {
    for (final check in [
      () => checkAccountVerified(user),
      () => checkGroupMembership(
            uid,
            group,
            actionPhrase: 'scheduling a meeting',
          ),
      () => checkSupervisorAssigned(
            group,
            actionPhrase: 'scheduling a meeting',
          ),
    ]) {
      final result = check();
      if (!result.allowed) return result;
    }
    return WorkflowGateResult.allowedResult;
  }
}
