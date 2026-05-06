import 'package:flutter/material.dart';

import '../../data/admin_mock_store.dart';
import 'add_user_screen.dart';
import 'admin_nav_bar.dart';
import 'assign_supervisor_screen.dart';
import 'doc_submissions_screen.dart';
import 'system_analytics_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const String routeName = '/admin-dashboard';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFE8EEF6),
          child: Icon(Icons.admin_panel_settings, color: Color(0xFF1B1B1B)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/admin-settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE6E6E6)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Overview',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<List<AdminUser>>(
                      valueListenable: AdminMockStore.instance.users,
                      builder: (context, users, _) {
                        return ValueListenableBuilder<List<String>>(
                          valueListenable: AdminMockStore.instance.projects,
                          builder: (context, projects, __) {
                            final userCount = users.length;
                            final projectCount = projects.length;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatBlock(
                                  icon: Icons.group,
                                  label: 'Users',
                                  value: userCount.toString(),
                                  color: colorScheme.primary,
                                ),
                                _StatBlock(
                                  icon: Icons.description,
                                  label: 'Projects',
                                  value: projectCount.toString(),
                                  color: colorScheme.secondary,
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _DashboardTile(
                    icon: Icons.person_add,
                    label: 'Add User',
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AddUserScreen.routeName),
                  ),
                  _DashboardTile(
                    icon: Icons.school,
                    label: 'Assign Supervisor',
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AssignSupervisorScreen.routeName),
                  ),
                  _DashboardTile(
                    icon: Icons.bar_chart,
                    label: 'System Analytics',
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(SystemAnalyticsScreen.routeName),
                  ),
                  _DashboardTile(
                    icon: Icons.assignment_turned_in,
                    label: 'Doc Submissions',
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(DocSubmissionsScreen.routeName),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminNavBar(selectedIndex: 0),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFE8EEF6),
              child: Icon(icon, size: 24, color: colorScheme.primary),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 10),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
