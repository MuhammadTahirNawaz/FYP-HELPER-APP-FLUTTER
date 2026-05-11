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
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              indicatorColor: AppColors.studentTeal.withValues(alpha: 0.15),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(color: AppColors.studentTeal, size: 28);
                }
                return const IconThemeData(color: Colors.white60, size: 24);
              }),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(color: AppColors.studentTeal, fontSize: 13, fontWeight: FontWeight.w900);
                }
                return const TextStyle(color: Colors.white60, fontSize: 11);
              }),
            ),
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: Colors.transparent,
            selectedIndex: selectedIndex,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined, color: Colors.white), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.groups_outlined, color: Colors.white), label: 'Groups'),
              NavigationDestination(icon: Icon(Icons.message_outlined, color: Colors.white), label: 'Chat'),
              NavigationDestination(icon: Icon(Icons.person_outline, color: Colors.white), label: 'Profile'),
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
      ),
    );
  }
}
