import 'package:flutter/material.dart';

import 'student_dashboard_screen.dart';
import 'student_groups_screen.dart';
import 'student_reports_screen.dart';
import 'student_settings_screen.dart';

class StudentNavBar extends StatelessWidget {
  const StudentNavBar({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.groups), label: 'Groups'),
        NavigationDestination(icon: Icon(Icons.analytics), label: 'Reports'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      onDestinationSelected: (index) {
        if (index == selectedIndex) {
          return;
        }

        final routeName = switch (index) {
          0 => StudentDashboardScreen.routeName,
          1 => StudentGroupsScreen.routeName,
          2 => StudentReportsScreen.routeName,
          _ => StudentSettingsScreen.routeName,
        };

        Navigator.of(context).pushReplacementNamed(routeName);
      },
    );
  }
}
