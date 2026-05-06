import 'package:flutter/material.dart';

import 'supervisor_dashboard_screen.dart';
import 'supervisor_progress_reports_screen.dart';
import 'supervisor_requests_screen.dart';
import 'supervisor_settings_screen.dart';

class SupervisorNavBar extends StatelessWidget {
  const SupervisorNavBar({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Dashboard'),
        NavigationDestination(icon: Icon(Icons.groups), label: 'Requests'),
        NavigationDestination(icon: Icon(Icons.article), label: 'Reports'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      onDestinationSelected: (index) {
        if (index == selectedIndex) {
          return;
        }

        final routeName = switch (index) {
          0 => SupervisorDashboardScreen.routeName,
          1 => SupervisorRequestsScreen.routeName,
          2 => SupervisorProgressReportsScreen.routeName,
          _ => SupervisorSettingsScreen.routeName,
        };

        Navigator.of(context).pushReplacementNamed(routeName);
      },
    );
  }
}
