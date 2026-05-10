import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'admin_nav_bar.dart';
import 'admin_dashboard_screen.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  static const String routeName = '/admin-reports';

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final DatabaseReference _reportsRef = FirebaseDatabase.instance.ref('admin/reports');

  Future<void> _showEditor(BuildContext context, {_ReportEntry? entry}) async {
    final titleController = TextEditingController(text: entry?.title ?? '');
    final periodController = TextEditingController(text: entry?.period ?? '');
    final ownerController = TextEditingController(text: entry?.owner ?? '');
    final summaryController = TextEditingController(text: entry?.summary ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(entry == null ? 'Add Report' : 'Edit Report'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: periodController,
                  decoration: const InputDecoration(labelText: 'Period'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ownerController,
                  decoration: const InputDecoration(labelText: 'Owner'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: summaryController,
                  decoration: const InputDecoration(labelText: 'Summary'),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  return;
                }
                final payload = {
                  'title': title,
                  'period': periodController.text.trim(),
                  'owner': ownerController.text.trim(),
                  'summary': summaryController.text.trim(),
                  'updatedAt': ServerValue.timestamp,
                  if (entry == null) 'createdAt': ServerValue.timestamp,
                };
                if (entry == null) {
                  await _reportsRef.push().set(payload);
                } else {
                  await _reportsRef.child(entry.id).update(payload);
                }
                if (!mounted) return;
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(Object? ts) {
    if (ts is int) {
      final date = DateTime.fromMillisecondsSinceEpoch(ts);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '';
  }

  int _toIntTs(Object? ts) => ts is int ? ts : 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(AdminDashboardScreen.routeName);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushReplacementNamed(AdminDashboardScreen.routeName),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showEditor(context),
              tooltip: 'Add Report',
            ),
          ],
        ),
        body: StreamBuilder<DatabaseEvent>(
          stream: _reportsRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final entries = _ReportEntry.fromSnapshot(snapshot.data?.snapshot.value)
              ..sort((a, b) => _toIntTs(b.createdAt).compareTo(_toIntTs(a.createdAt)));

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Firebase Reports',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                if (entries.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    alignment: Alignment.center,
                    child: const Text('No reports available.'),
                  )
                else
                  ...entries.map(
                    (entry) => Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE6E6E6)),
                      ),
                      child: ListTile(
                        title: Text(entry.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            if (entry.period.isNotEmpty)
                              Text('Period: ${entry.period}'),
                            if (entry.owner.isNotEmpty)
                              Text('Owner: ${entry.owner}'),
                            if (entry.summary.isNotEmpty) Text(entry.summary),
                            if (entry.updatedAt != null)
                              Text('Updated: ${_formatTimestamp(entry.updatedAt)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditor(context, entry: entry),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () =>
                                  _reportsRef.child(entry.id).remove(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        bottomNavigationBar: const AdminNavBar(selectedIndex: 2),
      ),
    );
  }
}

class _ReportEntry {
  const _ReportEntry({
    required this.id,
    required this.title,
    required this.period,
    required this.owner,
    required this.summary,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String period;
  final String owner;
  final String summary;
  final Object? createdAt;
  final Object? updatedAt;

  static List<_ReportEntry> fromSnapshot(Object? data) {
    if (data is! Map) {
      return <_ReportEntry>[];
    }
    final entries = Map<String, dynamic>.from(data);
    return entries.entries.map((entry) {
      final value = Map<String, dynamic>.from(entry.value as Map);
      return _ReportEntry(
        id: entry.key,
        title: (value['title'] as String?) ?? '',
        period: (value['period'] as String?) ?? '',
        owner: (value['owner'] as String?) ?? '',
        summary: (value['summary'] as String?) ?? '',
        createdAt: value['createdAt'],
        updatedAt: value['updatedAt'],
      );
    }).toList();
  }
}
