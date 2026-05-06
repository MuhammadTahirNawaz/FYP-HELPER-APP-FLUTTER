import 'package:flutter/material.dart';

import 'admin_access_control_screen.dart';
import 'admin_nav_bar.dart';
import 'admin_notifications_settings_screen.dart';
import 'admin_profile_settings_screen.dart';
import 'admin_system_preferences_screen.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  static const String routeName = '/admin-settings';

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
          Text(
            'Preferences',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            title: 'Profile',
            subtitle: 'Update admin profile and password.',
            icon: Icons.account_circle,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AdminProfileSettingsScreen.routeName),
          ),
          _SettingsTile(
            title: 'Access Control',
            subtitle: 'Manage roles and permissions.',
            icon: Icons.lock_outline,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AdminAccessControlScreen.routeName),
          ),
          _SettingsTile(
            title: 'Notifications',
            subtitle: 'Configure email and app alerts.',
            icon: Icons.notifications_none,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AdminNotificationsSettingsScreen.routeName),
          ),
          _SettingsTile(
            title: 'System Preferences',
            subtitle: 'Adjust academic year and deadlines.',
            icon: Icons.tune,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AdminSystemPreferencesScreen.routeName),
          ),
        ],
      ),
      bottomNavigationBar: const AdminNavBar(selectedIndex: 3),
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
