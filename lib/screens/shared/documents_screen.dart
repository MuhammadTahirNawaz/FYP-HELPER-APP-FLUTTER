import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a document URL directly in a new browser tab / OS handler.
void _openDocumentUrl(String url) {
  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  static const String routeName = '/documents';

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  final DatabaseReference _byRoleRef =
      FirebaseDatabase.instance.ref('documents_by_role');
  final DatabaseReference _adminDocsRef =
      FirebaseDatabase.instance.ref('admin/documents');

  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await _usersRef.child(user.uid).get();
    if (!snap.exists || snap.value == null) return;
    final data = Map<String, dynamic>.from(snap.value as Map);
    setState(() => _role = (data['role'] as String?) ?? 'Student');
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _role == 'Admin';
    final ref = isAdmin ? _adminDocsRef : _byRoleRef.child(_role);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          final data = snapshot.data?.snapshot.value;
          if (data == null) {
            return const Center(child: Text('No documents available.'));
          }
          if (data is! Map) {
            return const Center(child: Text('No documents available.'));
          }
          final entries = Map<String, dynamic>.from(data);
          final docs = entries.entries.map((entry) {
            final value = Map<String, dynamic>.from(entry.value as Map);
            return _DocRow(
              id: entry.key,
              title: (value['title'] as String?) ?? '',
              description: (value['description'] as String?) ?? '',
              fileName: (value['fileName'] as String?) ?? '',
              fileUrl: (value['fileUrl'] as String?) ?? '',
              sizeBytes: (value['sizeBytes'] as int?) ?? 0,
              createdAt: value['createdAt'],
            );
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text('No documents available.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: docs.map((doc) {
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE6E6E6)),
                ),
                child: ListTile(
                  title: Text(doc.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      if (doc.description.isNotEmpty) Text(doc.description),
                      const SizedBox(height: 6),
                      Text('File: ${doc.fileName}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: doc.fileUrl.isEmpty
                        ? null
                    : () => _openDocumentUrl(doc.fileUrl),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _DocRow {
  _DocRow({
    required this.id,
    required this.title,
    required this.description,
    required this.fileName,
    required this.fileUrl,
    required this.sizeBytes,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String fileName;
  final String fileUrl;
  final int sizeBytes;
  final Object? createdAt;
}
