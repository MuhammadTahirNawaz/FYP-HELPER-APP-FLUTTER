import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme/app_colors.dart';

class StudentSharedDocumentsSection extends StatelessWidget {
  const StudentSharedDocumentsSection({
    super.key,
    this.university,
  });

  final String? university;

  @override
  Widget build(BuildContext context) {
    final uniPath = university ?? 'default';
    final docsRef = FirebaseDatabase.instance.ref(
      'admin/universities/$uniPath/documents_by_role/Student',
    );

    return StreamBuilder<DatabaseEvent>(
      stream: docsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data?.snapshot.value;
        if (data == null || data is! Map) {
          return const Center(
            child: Text('No shared documents available for your role.'),
          );
        }

        final docs = Map<String, dynamic>.from(data).entries.map((e) {
          final val = Map<String, dynamic>.from(e.value as Map);
          return {
            'title': val['title'] ?? 'Untitled',
            'description': val['description'] ?? '',
            'fileName': val['fileName'] ?? '',
            'fileUrl': val['fileUrl'] ?? '',
          };
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.borderSoft),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.selectedTile,
                  child: Icon(Icons.description, color: AppColors.studentTeal),
                ),
                title: Text(
                  doc['title']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  doc['description']!.isNotEmpty
                      ? doc['description']!
                      : 'File: ${doc['fileName']}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new, color: Color(0xFF38BDF8)),
                  onPressed: () async {
                    if (doc['fileUrl']!.isNotEmpty) {
                      final url = Uri.parse(doc['fileUrl']!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
