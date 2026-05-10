import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminReviewPanelsScreen extends StatefulWidget {
  const AdminReviewPanelsScreen({super.key});

  static const String routeName = '/admin-review-panels';

  @override
  State<AdminReviewPanelsScreen> createState() =>
      _AdminReviewPanelsScreenState();
}

class _AdminReviewPanelsScreenState extends State<AdminReviewPanelsScreen> {
  final DatabaseReference _panelsRef =
      FirebaseDatabase.instance.ref('admin/reviewPanels');

  Future<void> _showCreatePanel(BuildContext context,
      {String? panelId, Map<String, dynamic>? existing}) async {
    final nameCtrl =
        TextEditingController(text: existing?['name'] as String? ?? '');
    final notesCtrl =
        TextEditingController(text: existing?['notes'] as String? ?? '');

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Create Panel' : 'Edit Panel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Panel Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration:
                  const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final payload = {
                'name': name,
                'notes': notesCtrl.text.trim(),
                'updatedAt': ServerValue.timestamp,
                if (existing == null) 'createdAt': ServerValue.timestamp,
              };
              if (existing == null) {
                await _panelsRef.push().set(payload);
              } else {
                await _panelsRef.child(panelId!).update(payload);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Panels'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Panel',
            onPressed: () => _showCreatePanel(context),
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _panelsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data?.snapshot.value;
          if (data is! Map) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fact_check_outlined,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('No review panels yet.'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showCreatePanel(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create First Panel'),
                  ),
                ],
              ),
            );
          }

          final panels = Map<String, dynamic>.from(data);
          final entries = panels.entries.toList()
            ..sort((a, b) {
              final aTs = (a.value is Map
                      ? (a.value as Map)['createdAt'] as int?
                      : null) ??
                  0;
              final bTs = (b.value is Map
                      ? (b.value as Map)['createdAt'] as int?
                      : null) ??
                  0;
              return bTs.compareTo(aTs);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final id = entries[index].key;
              final panel =
                  Map<String, dynamic>.from(entries[index].value as Map);
              final name = (panel['name'] as String?) ?? id;
              final notes = (panel['notes'] as String?) ?? '';

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEDF1F9),
                    child:
                        Icon(Icons.fact_check, color: Color(0xFF14375E)),
                  ),
                  title: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: notes.isNotEmpty ? Text(notes) : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showCreatePanel(context,
                            panelId: id, existing: panel),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 20, color: Color(0xFFDC2626)),
                        onPressed: () =>
                            _panelsRef.child(id).remove(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
