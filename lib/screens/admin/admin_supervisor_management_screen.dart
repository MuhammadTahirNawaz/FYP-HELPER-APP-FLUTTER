import 'package:flutter/material.dart';

import 'admin_supervisor_load_screen.dart';
import 'assign_supervisor_screen.dart';

class AdminSupervisorManagementScreen extends StatelessWidget {
  const AdminSupervisorManagementScreen({super.key});

  static const String routeName = '/admin-supervisors';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisors'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ActionTile(
            title: 'Assign Supervisor',
            subtitle: 'Link supervisors to students and projects.',
            icon: Icons.school,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AssignSupervisorScreen(),
              ),
            ),
          ),
          _ActionTile(
            title: 'Review Supervisor Load',
            subtitle: 'See active projects per supervisor.',
            icon: Icons.bar_chart,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AdminSupervisorLoadScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

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
          backgroundColor: const Color(0xFFEDF1F9),
          child: Icon(icon, color: const Color(0xFF14375E)),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
