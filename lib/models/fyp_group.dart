/// Firebase `groups/{code}` summary used in admin approval and capacity views.
class FypGroup {
  const FypGroup({
    required this.code,
    required this.status,
    required this.supervisorEmail,
    required this.memberCount,
    this.university,
    this.supervisorId,
  });

  final String code;
  final String status;
  final String supervisorEmail;
  final int memberCount;
  final String? university;
  final String? supervisorId;

  factory FypGroup.fromMap(String code, Map<String, dynamic> data) {
    final members = data['members'];
    final memberCount = members is Map ? members.length : 0;

    return FypGroup(
      code: code,
      status: (data['status'] as String?) ?? 'Pending',
      supervisorEmail: (data['supervisorEmail'] as String?) ?? '',
      university: data['university'] as String?,
      supervisorId: data['supervisorId'] as String?,
      memberCount: memberCount,
    );
  }

  static List<FypGroup> listFromSnapshot(Object? data) {
    if (data is! Map) {
      return const [];
    }
    final entries = Map<String, dynamic>.from(data);
    return entries.entries
        .map(
          (entry) => FypGroup.fromMap(
            entry.key,
            Map<String, dynamic>.from(entry.value as Map),
          ),
        )
        .toList();
  }
}
