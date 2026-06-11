import 'package:firebase_database/firebase_database.dart';

/// University-scoped admin configuration and content paths.
class AdminRepository {
  AdminRepository({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  DatabaseReference universityRef(String? university) {
    return _database.ref('admin/universities/${university ?? 'default'}');
  }

  DatabaseReference documentsRef(String? university) {
    return universityRef(university).child('documents');
  }

  DatabaseReference announcementsRef(String? university) {
    return universityRef(university).child('announcements');
  }

  DatabaseReference supervisorLimitsRef(String? university) {
    return universityRef(university).child('supervisorLimits');
  }
}
