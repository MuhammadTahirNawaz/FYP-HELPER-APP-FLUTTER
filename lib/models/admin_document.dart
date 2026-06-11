/// Admin-uploaded document metadata stored under `admin/universities/{uni}/documents`.
class AdminDocument {
  const AdminDocument({
    required this.id,
    required this.title,
    required this.description,
    required this.fileName,
    required this.fileUrl,
    required this.storagePath,
    required this.sizeBytes,
    required this.roles,
    required this.uploadedBy,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String fileName;
  final String fileUrl;
  final String storagePath;
  final int sizeBytes;
  final List<String> roles;
  final String uploadedBy;
  final Object? createdAt;

  factory AdminDocument.fromMap(String id, Map<String, dynamic> data) {
    final rolesData = data['roles'];
    final roles = <String>[];
    if (rolesData is Map) {
      roles.addAll(
        rolesData.entries
            .where((entry) => entry.value == true)
            .map((entry) => entry.key.toString()),
      );
    } else if (rolesData is List) {
      roles.addAll(rolesData.map((role) => role.toString()));
    }

    return AdminDocument(
      id: id,
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      fileName: (data['fileName'] as String?) ?? '',
      fileUrl: (data['fileUrl'] as String?) ?? '',
      storagePath: (data['storagePath'] as String?) ?? '',
      sizeBytes: (data['sizeBytes'] as int?) ?? 0,
      roles: roles,
      createdAt: data['createdAt'],
      uploadedBy: (data['uploadedBy'] as String?) ?? '',
    );
  }

  static List<AdminDocument> listFromSnapshot(Object? data) {
    if (data is! Map) {
      return const [];
    }
    final entries = Map<String, dynamic>.from(data);
    return entries.entries
        .map(
          (entry) => AdminDocument.fromMap(
            entry.key,
            Map<String, dynamic>.from(entry.value as Map),
          ),
        )
        .toList();
  }
}
