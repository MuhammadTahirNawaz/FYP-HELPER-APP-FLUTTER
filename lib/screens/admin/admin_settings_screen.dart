import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

import 'admin_access_control_screen.dart';
import 'admin_nav_bar.dart';
import 'admin_notifications_settings_screen.dart';
import 'admin_profile_settings_screen.dart';
import 'admin_system_preferences_screen.dart';
import '../../services/system_reset_service.dart';
import '../auth/sign_out_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  static const String routeName = '/admin-settings';

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final SystemResetService _resetService = SystemResetService();
  bool _resetting = false;

  Future<void> _confirmReset() async {
    if (_resetting) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset system data?'),
        content: const Text(
          'This will delete all non-admin Auth users, Realtime Database data, and Storage files. Admin accounts will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _resetting = true);

    try {
      final result = await _resetService.resetAllExceptAdmins();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reset complete. Deleted ${result['deletedAuthUsers'] ?? 0} auth users.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _resetting = false);
      }
    }
  }

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
          title: const Text('Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushReplacementNamed(AdminDashboardScreen.routeName),
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

          const SizedBox(height: 8),
          Text(
            'Danger Zone',
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
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.red.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade50,
                child: Icon(Icons.delete_forever, color: Colors.red.shade700),
              ),
              title: const Text('Reset system data'),
              subtitle: const Text('Deletes all non-admin users, records, and files.'),
              trailing: _resetting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _resetting ? null : _confirmReset,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminNavBar(selectedIndex: 3),
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

