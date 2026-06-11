/// Generic admin-managed content item (announcements, schedule entries, etc.).
class AdminContentItem {
  const AdminContentItem({
    required this.id,
    required this.title,
    required this.details,
    required this.date,
    this.university,
  });

  final String id;
  final String title;
  final String details;
  final String date;
  final String? university;

  factory AdminContentItem.fromMap(String id, Map<String, dynamic> data) {
    return AdminContentItem(
      id: id,
      title: (data['title'] as String?) ?? '',
      details: (data['details'] as String?) ?? '',
      date: (data['date'] as String?) ?? '',
      university: data['university'] as String?,
    );
  }

  static List<AdminContentItem> listFromSnapshot(Object? data) {
    if (data is! Map) {
      return const [];
    }
    final entries = Map<String, dynamic>.from(data);
    return entries.entries
        .map(
          (entry) => AdminContentItem.fromMap(
            entry.key,
            Map<String, dynamic>.from(entry.value as Map),
          ),
        )
        .toList();
  }
}
