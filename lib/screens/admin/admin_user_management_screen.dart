import 'package:flutter/material.dart';

import 'admin_deactivate_accounts_screen.dart';
import 'admin_manage_users_screen.dart';

class AdminUserManagementScreen extends StatelessWidget {
  const AdminUserManagementScreen({super.key});

  static const String routeName = '/admin-users';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ActionCard(
            title: 'Add New User',
            subtitle: 'Invite students, supervisors, or committee members.',
            icon: Icons.person_add,
            onTap: () => Navigator.of(context).pushNamed('/admin-add-user'),
          ),
          _ActionCard(
            title: 'Manage Existing Users',
            subtitle: 'Update profiles, roles, and statuses.',
            icon: Icons.manage_accounts,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AdminManageUsersScreen.routeName),
          ),
          _ActionCard(
            title: 'Deactivate Accounts',
            subtitle: 'Disable access for inactive users.',
            icon: Icons.block,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AdminDeactivateAccountsScreen.routeName),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
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
