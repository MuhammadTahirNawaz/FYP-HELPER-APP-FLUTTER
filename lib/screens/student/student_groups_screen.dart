import 'package:flutter/material.dart';

import 'student_nav_bar.dart';

class StudentGroupsScreen extends StatelessWidget {
  const StudentGroupsScreen({super.key});

  static const String routeName = '/student-groups';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _GroupCard(
            title: 'FYP Team Alpha',
            subtitle: '4 members · Supervisor pending',
            icon: Icons.groups,
          ),
          _GroupCard(
            title: 'FYP Team Beta',
            subtitle: '3 members · Supervisor assigned',
            icon: Icons.groups,
          ),
        ],
      ),
      bottomNavigationBar: const StudentNavBar(selectedIndex: 1),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
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
