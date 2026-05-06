import 'package:flutter/material.dart';

import 'supervisor_nav_bar.dart';
import 'supervisor_profile_screen.dart';

class SupervisorRequestsScreen extends StatelessWidget {
  const SupervisorRequestsScreen({super.key});

  static const String routeName = '/supervisor-requests';

  static const List<_RequestGroup> _requests = [
    _RequestGroup(
      groupName: 'Group Delta',
      projectName: 'Smart Attendance',
      sentLabel: 'Sent 2 hrs ago',
      students: ['Student 1', 'Student 2', 'Student 3', 'Student 4'],
    ),
    _RequestGroup(
      groupName: 'Group Alpha',
      projectName: 'AI Tutor',
      sentLabel: 'Sent 1 hr ago',
      students: ['Student 1', 'Student 2', 'Student 3'],
    ),
    _RequestGroup(
      groupName: 'Group Gamma',
      projectName: 'Lab Scheduler',
      sentLabel: 'Sent 30 mins ago',
      students: [
        'Student 1',
        'Student 2',
        'Student 3',
        'Student 4',
        'Student 5',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
          tooltip: 'Notifications',
        ),
        title: const Text('FYP Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(SupervisorProfileScreen.routeName),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Padding(
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
                child: Column(
                  children: [
                    Text(
                      'SUPERVISION REQUESTS',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 12, child: _WavyDivider()),
                    const SizedBox(height: 6),
                    Text(
                      '${_requests.length} PENDING REQUESTS',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  final request = _requests[index];
                  return _RequestCard(request: request);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const SupervisorNavBar(selectedIndex: 1),
    );
  }
}

class _RequestGroup {
  const _RequestGroup({
    required this.groupName,
    required this.projectName,
    required this.sentLabel,
    required this.students,
  });

  final String groupName;
  final String projectName;
  final String sentLabel;
  final List<String> students;
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final _RequestGroup request;

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  request.groupName.toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  request.sentLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5F6C7B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              request.projectName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: request.students
                  .map((student) => _StudentAvatar(name: student))
                  .toList(),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Accepted ${request.groupName}'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('ACCEPT'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Rejected ${request.groupName}'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('REJECT'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  const _StudentAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFE8EEF6),
          child: Text(
            name.substring(0, 1),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: Theme.of(context).textTheme.bodySmall),
      ],
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
