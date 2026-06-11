import 'package:firebase_database/firebase_database.dart';

import '../models/fyp_group.dart';

/// FYP group data access for RTDB `groups/`.
class GroupRepository {
  GroupRepository({FirebaseDatabase? database})
      : _groupsRef = (database ?? FirebaseDatabase.instance).ref('groups');

  final DatabaseReference _groupsRef;

  DatabaseReference get groupsRef => _groupsRef;

  Stream<DatabaseEvent> watchGroups() => _groupsRef.onValue;

  List<FypGroup> listFromSnapshot(Object? data) =>
      FypGroup.listFromSnapshot(data);

  Future<void> approveGroup({
    required String code,
    required String supervisorEmail,
    required String supervisorId,
  }) async {
    await _groupsRef.child(code).update({
      'status': 'Approved',
      'supervisorEmail': supervisorEmail,
      'supervisorId': supervisorId,
      'supervisorName': supervisorEmail.split('@')[0],
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> rejectGroup(String code) async {
    await _groupsRef.child(code).update({
      'status': 'Rejected',
      'updatedAt': ServerValue.timestamp,
    });
  }
}
