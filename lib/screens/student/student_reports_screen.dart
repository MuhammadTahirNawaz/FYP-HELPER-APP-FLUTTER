import 'package:flutter/material.dart';

import 'student_nav_bar.dart';

class StudentReportsScreen extends StatelessWidget {
  const StudentReportsScreen({super.key});

  static const String routeName = '/student-reports';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ReportCard(
            title: 'Proposal Submission',
            subtitle: 'Draft · Due in 10 days',
            icon: Icons.description,
          ),
          _ReportCard(
            title: 'Progress Report 1',
            subtitle: 'Not started · Due in 21 days',
            icon: Icons.assignment_turned_in,
          ),
        ],
      ),
      bottomNavigationBar: const StudentNavBar(selectedIndex: 2),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE6E6E6)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE8EEF6),
          child: Icon(icon, color: const Color(0xFF1B1B1B)),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
