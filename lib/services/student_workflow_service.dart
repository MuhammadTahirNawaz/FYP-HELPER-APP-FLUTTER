import 'package:firebase_database/firebase_database.dart';

import '../core/student_workflow_gate.dart';
import '../repositories/group_repository.dart';

/// Validates student workflow order and performs gated group writes.
class StudentWorkflowService {
  StudentWorkflowService({
    FirebaseDatabase? database,
    GroupRepository? groupRepository,
  })  : _usersRef = (database ?? FirebaseDatabase.instance).ref('users'),
        _groupRepository = groupRepository ?? GroupRepository(database: database);

  final DatabaseReference _usersRef;
  final GroupRepository _groupRepository;

  Future<Map<String, dynamic>?> _loadUser(String uid) async {
    final snap = await _usersRef.child(uid).get();
    if (!snap.exists || snap.value is! Map) return null;
    return Map<String, dynamic>.from(snap.value as Map);
  }

  Future<Map<String, dynamic>?> _loadGroup(String? groupId) async {
    if (groupId == null) return null;
    final snap = await _groupRepository.groupsRef.child(groupId).get();
    if (!snap.exists || snap.value is! Map) return null;
    return Map<String, dynamic>.from(snap.value as Map);
  }

  Future<WorkflowGateResult> evaluateProposalGate(
    String uid,
    String? groupId,
  ) async {
    final user = await _loadUser(uid);
    final group = await _loadGroup(groupId);
    return StudentWorkflowGate.forProposal(user: user, group: group, uid: uid);
  }

  Future<WorkflowGateResult> evaluateMeetingGate(
    String uid,
    String? groupId,
  ) async {
    final user = await _loadUser(uid);
    final group = await _loadGroup(groupId);
    return StudentWorkflowGate.forMeeting(user: user, group: group, uid: uid);
  }

  Future<void> submitProposal({
    required String uid,
    required String groupId,
    required String projectTitle,
    required String description,
    required String proposalUrl,
  }) async {
    final gate = await evaluateProposalGate(uid, groupId);
    if (!gate.allowed) {
      throw WorkflowGateException(gate.message);
    }

    await _groupRepository.groupsRef.child(groupId).update({
      'projectTitle': projectTitle,
      'description': description,
      'proposalUrl': proposalUrl,
      'proposalStatus': 'Submitted',
      'proposalSubmittedAt': ServerValue.timestamp,
    });
  }

  Future<void> requestMeeting({
    required String uid,
    required String groupId,
    required String requestedDate,
    required String requestedTime,
    required String duration,
  }) async {
    final gate = await evaluateMeetingGate(uid, groupId);
    if (!gate.allowed) {
      throw WorkflowGateException(gate.message);
    }

    await _groupRepository.groupsRef.child(groupId).child('meetings').push().set({
      'requestedDate': requestedDate,
      'requestedTime': requestedTime,
      'duration': duration,
      'status': 'Pending',
      'meetingLink': 'https://meet.google.com/new',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
