import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

import 'admin_committee_access_screen.dart';
import 'admin_review_panels_screen.dart';

class AdminCommitteeManagementScreen extends StatelessWidget {
  const AdminCommitteeManagementScreen({super.key});

  static const String routeName = '/admin-committees';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Committees'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ActionTile(
            title: 'Review Member Access',
            subtitle: 'Approve or revoke committee access.',
            icon: Icons.group_work,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AdminCommitteeAccessScreen.routeName),
          ),
          _ActionTile(
            title: 'Assign Review Panels',
            subtitle: 'Create panels for proposal defenses.',
            icon: Icons.fact_check,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AdminReviewPanelsScreen.routeName),
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
