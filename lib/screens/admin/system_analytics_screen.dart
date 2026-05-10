import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'admin_nav_bar.dart';

class SystemAnalyticsScreen extends StatelessWidget {
  const SystemAnalyticsScreen({super.key});

  static const String routeName = '/admin-system-analytics';

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseDatabase.instance.ref('users');
    final groupsRef = FirebaseDatabase.instance.ref('groups');

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: FutureBuilder<List<DataSnapshot>>(
        future: Future.wait([usersRef.get(), groupsRef.get()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final usersSnap = snapshot.data?[0];
          final groupsSnap = snapshot.data?[1];

          // Parse users
          int totalUsers = 0, students = 0, supervisors = 0, committees = 0,
              admins = 0, pending = 0, deactivated = 0;

          if (usersSnap?.value is Map) {
            final all = Map<String, dynamic>.from(usersSnap!.value as Map);
            totalUsers = all.length;
            for (final e in all.values) {
              if (e is! Map) continue;
              final u = Map<String, dynamic>.from(e);
              final role = (u['role'] as String?) ?? '';
              final status = (u['status'] as String?) ?? '';
              switch (role) {
                case 'Student': students++; break;
                case 'Supervisor': supervisors++; break;
                case 'Committee': committees++; break;
                case 'Admin': admins++; break;
                case 'Pending': pending++; break;
              }
              if (status == 'Deactivated') deactivated++;
            }
          }

          // Parse groups
          int totalGroups = 0, assigned = 0, unassigned = 0;
          if (groupsSnap?.value is Map) {
            final all = Map<String, dynamic>.from(groupsSnap!.value as Map);
            totalGroups = all.length;
            for (final e in all.values) {
              if (e is! Map) continue;
              final g = Map<String, dynamic>.from(e);
              final sid = (g['supervisorId'] as String?) ?? '';
              if (sid.isNotEmpty) assigned++; else unassigned++;
            }
          }

          final colorScheme = Theme.of(context).colorScheme;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Live Snapshot',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),

              // Top metrics
              Row(
                children: [
                  _MetricCard(
                      label: 'Total Users',
                      value: '$totalUsers',
                      icon: Icons.group,
                      color: colorScheme.primary),
                  const SizedBox(width: 12),
                  _MetricCard(
                      label: 'Total Groups',
                      value: '$totalGroups',
                      icon: Icons.description,
                      color: colorScheme.secondary),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MetricCard(
                      label: 'Pending Approvals',
                      value: '$pending',
                      icon: Icons.pending_actions,
                      color: const Color(0xFFF59E0B)),
                  const SizedBox(width: 12),
                  _MetricCard(
                      label: 'Deactivated',
                      value: '$deactivated',
                      icon: Icons.block,
                      color: const Color(0xFFDC2626)),
                ],
              ),
              const SizedBox(height: 16),

              // Role breakdown
              Text('Role Breakdown',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              _BreakdownBar(label: 'Students', count: students, total: totalUsers, color: const Color(0xFF2563EB)),
              _BreakdownBar(label: 'Supervisors', count: supervisors, total: totalUsers, color: const Color(0xFF7C3AED)),
              _BreakdownBar(label: 'Committee', count: committees, total: totalUsers, color: const Color(0xFF0891B2)),
              _BreakdownBar(label: 'Admins', count: admins, total: totalUsers, color: const Color(0xFFDC2626)),
              const SizedBox(height: 16),

              // Group assignment stats
              Text('Group Assignment',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              _BreakdownBar(label: 'Assigned', count: assigned, total: totalGroups, color: const Color(0xFF16A34A)),
              _BreakdownBar(label: 'Unassigned', count: unassigned, total: totalGroups, color: const Color(0xFFF59E0B)),
              const SizedBox(height: 16),

              // Status chips
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _TagChip(label: '$totalUsers Total Users'),
                  _TagChip(label: '$totalGroups Projects'),
                  _TagChip(label: '$pending Pending'),
                ],
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const AdminNavBar(selectedIndex: 0),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

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
          border: Border.all(color: const Color(0xFFDDE3EF)),
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
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _BreakdownBar extends StatelessWidget {
  const _BreakdownBar(
      {required this.label,
      required this.count,
      required this.total,
      required this.color});

  final String label;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7A99))),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: const Color(0xFFEDF1F9),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('$count',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF1F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF14375E))),
    );
  }
}
