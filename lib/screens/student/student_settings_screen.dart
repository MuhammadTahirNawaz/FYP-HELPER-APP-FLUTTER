import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

import 'student_nav_bar.dart';
import 'student_notifications_settings_screen.dart';
import 'student_profile_screen.dart';
import 'student_security_settings_screen.dart';
import '../auth/sign_out_screen.dart';
import 'student_dashboard_screen.dart';

class StudentSettingsScreen extends StatelessWidget {
  const StudentSettingsScreen({super.key});

  static const String routeName = '/student-settings';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(StudentDashboardScreen.routeName);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushReplacementNamed(StudentDashboardScreen.routeName),
          ),
        ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsTile(
            title: 'Profile Settings',
            subtitle: 'Update your profile and contact details.',
            icon: Icons.person,
            onTap: () =>
                Navigator.of(context).pushNamed(StudentProfileScreen.routeName),
          ),
          _SettingsTile(
            title: 'Notifications',
            subtitle: 'Manage report reminders and alerts.',
            icon: Icons.notifications_none,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(StudentNotificationsSettingsScreen.routeName),
          ),
          _SettingsTile(
            title: 'Security',
            subtitle: 'Change password and login preferences.',
            icon: Icons.lock_outline,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(StudentSecuritySettingsScreen.routeName),
          ),
          const SizedBox(height: 8),
          Text(
            'Account Management',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            title: 'Sign Out or Delete Account',
            subtitle: 'Sign out of your session or permanently delete your data.',
            icon: Icons.logout,
            onTap: () =>
                Navigator.of(context).pushNamed(SignOutScreen.routeName),
          ),
        ],
      ),
      bottomNavigationBar: const StudentNavBar(selectedIndex: 3),
      ),
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
          backgroundColor: AppColors.selectedTile,
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

