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
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
              indicatorColor: Colors.white.withOpacity(0.1),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: Colors.white, size: 26);
                }
                return const IconThemeData(color: Colors.white60, size: 24);
              }),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold);
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
              NavigationDestination(icon: Icon(Icons.dashboard_customize_outlined, color: Colors.white), label: 'Manage'),
              NavigationDestination(icon: Icon(Icons.message_outlined, color: Colors.white), label: 'Chat'),
              NavigationDestination(icon: Icon(Icons.settings_outlined, color: Colors.white), label: 'System'),
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
      ),
    );
  }
}
