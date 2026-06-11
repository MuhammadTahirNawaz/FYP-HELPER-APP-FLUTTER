import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

import 'student_dashboard_screen.dart';
import 'student_groups_screen.dart';
import 'student_messages_screen.dart';
import 'student_settings_screen.dart';

class StudentNavBar extends StatelessWidget {
  const StudentNavBar({super.key, required this.selectedIndex});

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
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Groups'),
            NavigationDestination(icon: Icon(Icons.message_outlined), label: 'Chat'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
          onDestinationSelected: (index) {
            if (index == selectedIndex) return;
            final routeName = switch (index) {
              0 => StudentDashboardScreen.routeName,
              1 => StudentGroupsScreen.routeName,
              2 => StudentMessagesScreen.routeName,
              _ => StudentSettingsScreen.routeName,
            };
            Navigator.of(context).pushReplacementNamed(routeName);
          },
        ),
      ),
    );
  }
}
