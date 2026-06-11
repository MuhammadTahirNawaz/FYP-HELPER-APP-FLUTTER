import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../core/validators.dart';
import '../../../models/admin_content_item.dart';
import '../widgets/admin_content_card.dart';

/// Reusable admin CRUD list for announcements and similar content nodes.
class AdminContentCrudSection extends StatelessWidget {
  const AdminContentCrudSection({
    super.key,
    required this.title,
    required this.emptyText,
    required this.dataRef,
    required this.includeDate,
    this.university,
  });

  final String title;
  final String emptyText;
  final DatabaseReference dataRef;
  final bool includeDate;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: dataRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final allItems = AdminContentItem.listFromSnapshot(
          snapshot.data?.snapshot.value,
        );
        final items = university == null
            ? allItems
            : allItems.where((item) => item.university == university).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                FilledButton.icon(
                  onPressed: () => _showEditor(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(emptyText),
                ),
              )
            else
              ...items.map(
                (item) => AdminContentCard(
                  item: item,
                  onEdit: () => _showEditor(context, existing: item),
                  onDelete: () => dataRef.child(item.id).remove(),
                  includeDate: includeDate,
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showEditor(
    BuildContext context, {
    AdminContentItem? existing,
  }) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final detailsController =
        TextEditingController(text: existing?.details ?? '');
    final dateController = TextEditingController(text: existing?.date ?? '');
    final dialogFormKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(existing == null ? 'Add $title' : 'Edit $title'),
          content: SingleChildScrollView(
            child: Form(
              key: dialogFormKey,
              child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  validator: AppValidators.projectTitle,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: detailsController,
                  validator: (v) => AppValidators.description(v, fieldName: 'Details'),
                  style: const TextStyle(fontWeight: FontWeight.normal),
                  decoration: const InputDecoration(labelText: 'Details'),
                  maxLines: 3,
                ),
                if (includeDate) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: dateController,
                    validator: (v) => AppValidators.required(v, fieldName: 'Date'),
                    style: const TextStyle(fontWeight: FontWeight.normal),
                    decoration: const InputDecoration(
                      labelText: 'Date (YYYY-MM-DD)',
                    ),
                  ),
                ],
              ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!(dialogFormKey.currentState?.validate() ?? false)) return;
                final titleText = titleController.text.trim();
                final detailsText = detailsController.text.trim();
                final dateText = dateController.text.trim();

                final payload = <String, dynamic>{
                  'title': titleText,
                  'details': detailsText,
                  'university': university,
                  if (includeDate && dateText.isNotEmpty) 'date': dateText,
                  'updatedAt': ServerValue.timestamp,
                  if (existing == null) 'createdAt': ServerValue.timestamp,
                };
                final navigator = Navigator.of(dialogContext);
                if (existing == null) {
                  await dataRef.push().set(payload);
                } else {
                  await dataRef.child(existing.id).update(payload);
                }
                navigator.pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
