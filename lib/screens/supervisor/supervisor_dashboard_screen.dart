import 'package:flutter/material.dart';

import '../auth/sign_in_screen.dart';
import '../auth/sign_out_screen.dart';
import 'supervisor_nav_bar.dart';
import 'supervisor_profile_screen.dart';
import 'supervisor_progress_reports_screen.dart';
import 'supervisor_requests_screen.dart';

class SupervisorDashboardScreen extends StatelessWidget {
  const SupervisorDashboardScreen({super.key});

  static const String routeName = '/supervisor-dashboard';

  static const List<_GroupInfo> _groups = [
    _GroupInfo('Group A', 'Smart Attendance', 0.65, 5),
    _GroupInfo('Group B', 'AI Tutor', 0.4, 4),
    _GroupInfo('Group C', 'Lab Scheduler', 0.85, 3),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(SignInScreen.routeName, (route) => false),
          tooltip: 'Back to Sign In',
        ),
        title: const Text('LOGO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(SupervisorRequestsScreen.routeName),
            tooltip: 'Requests',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(SupervisorProfileScreen.routeName),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Navigator.of(context).pushNamed(SignOutScreen.routeName),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE6E6E6)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'DASHBOARD',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      const SizedBox(height: 12, child: _WavyDivider()),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.people_alt,
                    label: 'Requests',
                    value: '5',
                    color: colorScheme.primary,
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(SupervisorRequestsScreen.routeName),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.event_available,
                    label: 'Vivas',
                    value: '2',
                    color: colorScheme.secondary,
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(SupervisorProgressReportsScreen.routeName),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ListView.builder(
              itemCount: _groups.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final group = _groups[index];

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE6E6E6)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8EEF6),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(group.project),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.check_circle_outline,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.group, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              group.groupName.toUpperCase(),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _MemberAvatars(count: group.memberCount),
                            const SizedBox(width: 12),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: group.progress,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(999),
                                backgroundColor: const Color(0xFFE8EEF6),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const SupervisorNavBar(selectedIndex: 0),
    );
  }
}

class _GroupInfo {
  const _GroupInfo(
    this.groupName,
    this.project,
    this.progress,
    this.memberCount,
  );

  final String groupName;
  final String project;
  final double progress;
  final int memberCount;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _MemberAvatars extends StatelessWidget {
  const _MemberAvatars({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final items = List<int>.generate(count, (index) => index);

    return SizedBox(
      height: 28,
      width: 28 + (items.length - 1) * 18,
      child: Stack(
        children: [
          for (final index in items)
            Positioned(
              left: index * 18,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFFE8EEF6),
                child: Text(
                  String.fromCharCode(65 + index),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WavyDivider extends StatelessWidget {
  const _WavyDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WavePainter(color: const Color(0xFF5F6C7B)),
      size: const Size(double.infinity, 12),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    final waveHeight = size.height / 2;

    path.moveTo(0, waveHeight);
    for (double x = 0; x <= size.width; x += 12) {
      path.quadraticBezierTo(x + 6, waveHeight - 4, x + 12, waveHeight);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
