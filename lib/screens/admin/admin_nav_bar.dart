import 'package:flutter/material.dart';

import 'admin_dashboard_screen.dart';
import 'admin_management_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_settings_screen.dart';

class AdminNavBar extends StatelessWidget {
  const AdminNavBar({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.groups), label: 'Management'),
        NavigationDestination(icon: Icon(Icons.analytics), label: 'Reports'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      onDestinationSelected: (index) {
        if (index == selectedIndex) {
          return;
        }

        final routeName = switch (index) {
          0 => AdminDashboardScreen.routeName,
          1 => AdminManagementScreen.routeName,
          2 => AdminReportsScreen.routeName,
          _ => AdminSettingsScreen.routeName,
        };

        Navigator.of(context).pushReplacementNamed(routeName);
      },
    );
  }
}
