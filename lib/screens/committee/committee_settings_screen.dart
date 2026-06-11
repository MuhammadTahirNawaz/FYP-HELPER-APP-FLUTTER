import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/change_password_widget.dart';
import '../auth/sign_out_screen.dart';
import 'committee_nav_bar.dart';
import 'committee_dashboard_screen.dart';

class CommitteeSettingsScreen extends StatelessWidget {
  const CommitteeSettingsScreen({super.key});

  static const String routeName = '/committee-settings';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(CommitteeDashboardScreen.routeName);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushReplacementNamed(CommitteeDashboardScreen.routeName),
          ),
        ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsTile(
            title: 'Security',
            subtitle: 'Update your password.',
            icon: Icons.lock_outline,
            onTap: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 8,
                ),
                child: const SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 8),
                      ChangePasswordWidget(),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
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
      bottomNavigationBar: const CommitteeNavBar(selectedIndex: 3),
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
