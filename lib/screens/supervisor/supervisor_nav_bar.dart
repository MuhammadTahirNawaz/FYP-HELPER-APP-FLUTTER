import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

import 'supervisor_dashboard_screen.dart';
import 'supervisor_progress_reports_screen.dart';
import 'supervisor_messages_screen.dart';
import 'supervisor_settings_screen.dart';

class SupervisorNavBar extends StatelessWidget {
  const SupervisorNavBar({super.key, required this.selectedIndex});

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
          indicatorColor: AppColors.studentTeal.withValues(alpha: 0.12),
          selectedIndex: selectedIndex,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.message_outlined), label: 'Chat'),
            NavigationDestination(icon: Icon(Icons.article_outlined), label: 'Reports'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
          ],
          onDestinationSelected: (index) {
            if (index == selectedIndex) return;
            final routeName = switch (index) {
              0 => SupervisorDashboardScreen.routeName,
              1 => SupervisorMessagesScreen.routeName,
              2 => SupervisorProgressReportsScreen.routeName,
              _ => SupervisorSettingsScreen.routeName,
            };
            Navigator.of(context).pushReplacementNamed(routeName);
          },
        ),
      ),
    );
  }
}
