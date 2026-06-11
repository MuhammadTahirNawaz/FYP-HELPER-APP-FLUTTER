import 'package:flutter/material.dart';

import '../../../models/admin_content_item.dart';

class AdminContentCard extends StatelessWidget {
  const AdminContentCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.includeDate,
  });

  final AdminContentItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool includeDate;

  @override
  Widget build(BuildContext context) {
    final details = item.details.isEmpty ? 'No details' : item.details;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE6E6E6)),
      ),
      child: ListTile(
        title: Text(item.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(details),
            if (includeDate && item.date.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Date: ${item.date}'),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
