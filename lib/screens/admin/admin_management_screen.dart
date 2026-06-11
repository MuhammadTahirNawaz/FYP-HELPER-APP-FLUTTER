import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

import 'admin_committee_management_screen.dart';
import 'admin_group_records_screen.dart';
import 'admin_nav_bar.dart';
import 'admin_supervisor_management_screen.dart';
import 'admin_user_management_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminManagementScreen extends StatelessWidget {
  const AdminManagementScreen({super.key});

  static const String routeName = '/admin-management';

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
          title: const Text('Management'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushReplacementNamed(AdminDashboardScreen.routeName),
          ),
        ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _ManagementCard(
            title: 'Users',
            subtitle: 'Create, update, and deactivate accounts.',
            icon: Icons.person,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AdminUserManagementScreen.routeName),
          ),
          _ManagementCard(
            title: 'Supervisors',
            subtitle: 'Manage supervisor assignments and limits.',
            icon: Icons.school,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AdminSupervisorManagementScreen.routeName),
          ),
          _ManagementCard(
            title: 'Committees',
            subtitle: 'Review member access and approvals.',
            icon: Icons.group_work,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AdminCommitteeManagementScreen.routeName),
          ),
          _ManagementCard(
            title: 'Group Records',
            subtitle: 'View detailed group info and export PDF.',
            icon: Icons.assignment,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AdminGroupRecordsScreen.routeName),
          ),
        ],
      ),
      bottomNavigationBar: const AdminNavBar(selectedIndex: 1),
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  const _ManagementCard({
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
          backgroundColor: AppColors.surfaceMuted,
          child: Icon(icon, color: AppColors.navy),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
