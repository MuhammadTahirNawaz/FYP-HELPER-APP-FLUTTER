/// Firebase `users/{uid}` record used for admin listing and approval flows.
class UserAccount {
  const UserAccount({
    required this.uid,
    required this.email,
    required this.role,
    this.university,
    this.requestedRole,
    this.status,
  });

  final String uid;
  final String email;
  final String role;
  final String? university;
  final String? requestedRole;
  final String? status;

  static const empty = UserAccount(uid: '', email: '', role: '');

  bool get isEmpty => uid.isEmpty;

  factory UserAccount.fromMap(String uid, Map<String, dynamic> data) {
    return UserAccount(
      uid: uid,
      email: (data['email'] as String?) ?? '',
      role: (data['role'] as String?) ?? '',
      university: data['university'] as String?,
      requestedRole: data['requestedRole'] as String?,
      status: data['status'] as String?,
    );
  }

  static List<UserAccount> listFromSnapshot(Object? data) {
    if (data is! Map) {
      return const [];
    }
    final entries = Map<String, dynamic>.from(data);
    return entries.entries
        .map(
          (entry) => UserAccount.fromMap(
            entry.key,
            Map<String, dynamic>.from(entry.value as Map),
          ),
        )
        .toList();
  }
}
