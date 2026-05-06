import 'package:flutter/material.dart';

import 'admin_nav_bar.dart';

class DocSubmissionsScreen extends StatelessWidget {
  const DocSubmissionsScreen({super.key});

  static const String routeName = '/admin-doc-submissions';

  @override
  Widget build(BuildContext context) {
    final submissions = [
      _Submission('Proposal - Group A', 'Pending', Colors.orange),
      _Submission('Report - Group B', 'Approved', Colors.green),
      _Submission('SRS - Group C', 'Needs Review', Colors.redAccent),
      _Submission('Demo Video - Group D', 'Approved', Colors.green),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doc Submissions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: submissions.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _SummaryChip(label: '4 Pending'),
                _SummaryChip(label: '2 Approved'),
                _SummaryChip(label: '1 Needs Review'),
              ],
            );
          }

          final submission = submissions[index - 1];

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE6E6E6)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8EEF6),
                child: Icon(Icons.description, color: Color(0xFF1B1B1B)),
              ),
              title: Text(submission.title),
              subtitle: const Text('Updated today'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: submission.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  submission.status,
                  style: TextStyle(color: submission.color),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AdminNavBar(selectedIndex: 0),
    );
  }
}

class _Submission {
  const _Submission(this.title, this.status, this.color);

  final String title;
  final String status;
  final Color color;
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
