import 'package:flutter/material.dart';

import 'committee_nav_bar.dart';

class CommitteeDashboardScreen extends StatelessWidget {
  const CommitteeDashboardScreen({super.key});

  static const String routeName = '/committee-dashboard';

  static const List<_DashboardStat> _stats = [
    _DashboardStat('Pending Proposals', '3', Icons.pending_actions),
    _DashboardStat('Vivas to Schedule', '5', Icons.event_available),
    _DashboardStat('Completed Reviews', '5', Icons.check_circle),
    _DashboardStat('Total Groups', '5', Icons.groups),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[LOGO]'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'COMMITTEE PANEL',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _stats.map((stat) => _StatCard(stat: stat)).toList(),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE6E6E6)),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8EEF6),
                child: Icon(Icons.lightbulb, color: Color(0xFF1B1B1B)),
              ),
              title: const Text('Panel Summary'),
              subtitle: const Text(
                'Pending proposals: 3 · Vivas to schedule: 5 · Total groups: 5',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CommitteeNavBar(selectedIndex: 0),
    );
  }
}

class _DashboardStat {
  const _DashboardStat(this.title, this.value, this.icon);

  final String title;
  final String value;
  final IconData icon;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final _DashboardStat stat;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE6E6E6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primary.withOpacity(0.12),
              child: Icon(stat.icon, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              stat.value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              stat.title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
