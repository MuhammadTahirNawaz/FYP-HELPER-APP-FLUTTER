import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

import 'admin_nav_bar.dart';

class DocSubmissionsScreen extends StatelessWidget {
  const DocSubmissionsScreen({super.key});

  static const String routeName = '/admin-doc-submissions';

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return const Color(0xFF16A34A);
      case 'pending': return const Color(0xFFF59E0B);
      case 'needs review': return const Color(0xFFDC2626);
      default: return AppColors.slateText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final docsRef = FirebaseDatabase.instance.ref('admin/documents');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doc Submissions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: docsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data?.snapshot.value;
          if (data is! Map) {
            return const Center(child: Text('No submissions found.'));
          }

          final docs = Map<String, dynamic>.from(data);
          final entries = docs.entries
              .where((e) => e.value is Map)
              .toList()
            ..sort((a, b) {
              final aTs = ((a.value as Map)['updatedAt'] as int?) ?? 0;
              final bTs = ((b.value as Map)['updatedAt'] as int?) ?? 0;
              return bTs.compareTo(aTs);
            });

          // Count by status
          final pending = entries.where((e) =>
              ((e.value as Map)['status'] as String?)?.toLowerCase() == 'pending').length;
          final approved = entries.where((e) =>
              ((e.value as Map)['status'] as String?)?.toLowerCase() == 'approved').length;
          final needsReview = entries.where((e) =>
              ((e.value as Map)['status'] as String?)?.toLowerCase() == 'needs review').length;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      if (pending > 0)
                        _StatusChip(label: '$pending Pending', color: const Color(0xFFF59E0B)),
                      if (approved > 0)
                        _StatusChip(label: '$approved Approved', color: const Color(0xFF16A34A)),
                      if (needsReview > 0)
                        _StatusChip(label: '$needsReview Needs Review', color: const Color(0xFFDC2626)),
                    ],
                  ),
                );
              }

              final id = entries[index - 1].key;
              final doc = Map<String, dynamic>.from(entries[index - 1].value as Map);
              final title = (doc['title'] as String?) ?? id;
              final status = (doc['status'] as String?) ?? 'Pending';
              final groupCode = (doc['groupCode'] as String?) ?? '';
              final color = _statusColor(status);

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.selectedTile,
                    child: Icon(Icons.description, color: Color(0xFF14375E)),
                  ),
                  title: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(groupCode.isNotEmpty ? 'Group: $groupCode' : 'No group',
                      style: const TextStyle(fontSize: 12)),
                  trailing: PopupMenuButton<String>(
                    initialValue: status,
                    onSelected: (newStatus) async {
                      await docsRef
                          .child(id)
                          .update({'status': newStatus, 'updatedAt': ServerValue.timestamp});
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'Pending', child: Text('Pending')),
                      const PopupMenuItem(value: 'Approved', child: Text('Approved')),
                      const PopupMenuItem(value: 'Needs Review', child: Text('Needs Review')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(status,
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AdminNavBar(selectedIndex: 0),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

