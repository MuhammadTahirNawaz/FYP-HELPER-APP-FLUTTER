import 'package:flutter/material.dart';

import 'supervisor_nav_bar.dart';

class SupervisorProgressReportsScreen extends StatelessWidget {
  const SupervisorProgressReportsScreen({super.key});

  static const String routeName = '/supervisor-progress-reports';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ReportCard(title: 'Group A · Week 4', subtitle: 'Submitted today'),
          _ReportCard(title: 'Group B · Week 3', subtitle: 'Pending review'),
        ],
      ),
      bottomNavigationBar: const SupervisorNavBar(selectedIndex: 2),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

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
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8EEF6),
          child: Icon(Icons.description, color: Color(0xFF1B1B1B)),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
