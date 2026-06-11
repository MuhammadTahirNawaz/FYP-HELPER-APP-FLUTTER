import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

import 'admin_dashboard_screen.dart';
import 'admin_management_screen.dart';
import 'admin_settings_screen.dart';

class AdminNavBar extends StatelessWidget {
  const AdminNavBar({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppColors.adminPink.withValues(alpha: 0.12),
          selectedIndex: selectedIndex,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.manage_accounts_outlined), label: 'Manage'),
            NavigationDestination(icon: Icon(Icons.message_outlined), label: 'Messages'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
          ],
          onDestinationSelected: (index) {
            if (index == selectedIndex) return;
            final routeName = switch (index) {
              0 => AdminDashboardScreen.routeName,
              1 => AdminManagementScreen.routeName,
              2 => '/admin-messages',
              _ => AdminSettingsScreen.routeName,
            };
            Navigator.of(context).pushReplacementNamed(routeName);
          },
        ),
      ),
    );
  }
}
