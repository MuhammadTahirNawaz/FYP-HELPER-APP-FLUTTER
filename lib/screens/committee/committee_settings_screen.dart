import 'package:flutter/material.dart';

import 'committee_nav_bar.dart';

class CommitteeSettingsScreen extends StatelessWidget {
  const CommitteeSettingsScreen({super.key});

  static const String routeName = '/committee-settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsTile(
            title: 'Profile',
            subtitle: 'Update committee member details.',
            icon: Icons.person,
            onTap: () {},
          ),
          _SettingsTile(
            title: 'Notifications',
            subtitle: 'Manage review and viva alerts.',
            icon: Icons.notifications_none,
            onTap: () {},
          ),
          _SettingsTile(
            title: 'Security',
            subtitle: 'Update your password.',
            icon: Icons.lock_outline,
            onTap: () {},
          ),
        ],
      ),
      bottomNavigationBar: const CommitteeNavBar(selectedIndex: 0),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
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
          backgroundColor: const Color(0xFFE8EEF6),
          child: Icon(icon, color: const Color(0xFF1B1B1B)),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
