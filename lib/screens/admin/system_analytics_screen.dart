import 'package:flutter/material.dart';

import 'admin_nav_bar.dart';

class SystemAnalyticsScreen extends StatelessWidget {
  const SystemAnalyticsScreen({super.key});

  static const String routeName = '/admin-system-analytics';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Live Snapshot',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetricCard(
                label: 'Active Users',
                value: '256',
                icon: Icons.group,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 16),
              _MetricCard(
                label: 'Open Projects',
                value: '87',
                icon: Icons.description,
                color: colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFE8EEF6), Color(0xFFF7F5F2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0xFFE6E6E6)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.show_chart, size: 40, color: Color(0xFF5F6C7B)),
                SizedBox(height: 8),
                Text('Engagement trend preview'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _TagChip(label: 'Uptime 98%'),
              _TagChip(label: 'Latency 120ms'),
              _TagChip(label: 'Incidents 0'),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE6E6E6)),
            ),
            child: ListTile(
              leading: const Icon(Icons.timeline),
              title: const Text('Weekly Health Snapshot'),
              subtitle: const Text('All services operational with 98% uptime.'),
              trailing: Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminNavBar(selectedIndex: 0),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
