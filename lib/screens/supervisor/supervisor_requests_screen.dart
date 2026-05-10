import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'supervisor_nav_bar.dart';
import 'supervisor_profile_screen.dart';
import 'supervisor_dashboard_screen.dart';

class SupervisorRequestsScreen extends StatefulWidget {
  const SupervisorRequestsScreen({super.key});

  static const String routeName = '/supervisor-requests';

  @override
  State<SupervisorRequestsScreen> createState() => _SupervisorRequestsScreenState();
}

class _SupervisorRequestsScreenState extends State<SupervisorRequestsScreen> {
  late String _supervisorUid;
  final DatabaseReference _groupsRef = FirebaseDatabase.instance.ref('groups');

  @override
  void initState() {
    super.initState();
    _supervisorUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final supervisorRef = FirebaseDatabase.instance.ref('supervisor').child(_supervisorUid);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(SupervisorDashboardScreen.routeName);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushReplacementNamed(SupervisorDashboardScreen.routeName),
            tooltip: 'Back to Dashboard',
          ),
          title: const Text('FYP Portal'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => Navigator.of(context).pushNamed(SupervisorProfileScreen.routeName),
              tooltip: 'Profile',
            ),
          ],
        ),
        body: StreamBuilder<DatabaseEvent>(
          stream: supervisorRef.child('requests').onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data?.snapshot.value;
            final requestsMap = data is Map ? Map<String, dynamic>.from(data) : {};
            final pendingRequests = requestsMap.entries
                .where((e) => e.value['status'] == 'Pending')
                .toList();

            return Padding(
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
                            '${pendingRequests.length} PENDING REQUESTS',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (pendingRequests.isEmpty)
                    const Expanded(child: Center(child: Text('No pending requests found.')))
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: pendingRequests.length,
                        itemBuilder: (context, index) {
                          final entry = pendingRequests[index];
                          final requestData = Map<String, dynamic>.from(entry.value as Map);
                          return _RequestCard(
                            requestId: entry.key,
                            requestData: requestData,
                            supervisorRef: supervisorRef,
                            groupsRef: _groupsRef,
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: const SupervisorNavBar(selectedIndex: 1),
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  const _RequestCard({
    required this.requestId,
    required this.requestData,
    required this.supervisorRef,
    required this.groupsRef,
  });

  final String requestId;
  final Map<String, dynamic> requestData;
  final DatabaseReference supervisorRef;
  final DatabaseReference groupsRef;

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _processing = false;

  Future<void> _handleAction(bool accept) async {
    setState(() => _processing = true);
    try {
      final status = accept ? 'Accepted' : 'Rejected';
      final studentId = widget.requestData['studentId'];
      final groupCode = widget.requestData['groupCode'];

      // 1. Update request status
      await widget.supervisorRef.child('requests').child(widget.requestId).update({
        'status': status,
        'respondedAt': ServerValue.timestamp,
      });

      // 2. If accepted, link supervisor to group and vice versa
      if (accept && groupCode != null) {
        await widget.groupsRef.child(groupCode).update({
          'supervisorId': FirebaseAuth.instance.currentUser?.uid,
          'supervisorName': FirebaseAuth.instance.currentUser?.displayName ?? 'Supervisor',
          'status': 'Under Supervision',
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request $status')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupName = widget.requestData['groupName'] ?? 'No Group Name';
    final projectName = widget.requestData['projectName'] ?? 'No Project Title';
    final timestamp = widget.requestData['timestamp'];
    final students = widget.requestData['studentName'] != null 
        ? [widget.requestData['studentName'] as String] 
        : ['Unknown Student'];

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
                  groupName.toUpperCase(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (timestamp != null)
                  Text(
                    'Recent', // Ideally format timestamp
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B7A99),
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              projectName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: students.map((name) => _StudentAvatar(name: name)).toList(),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _processing ? null : () => _handleAction(true),
                    icon: _processing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
                    label: const Text('ACCEPT'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _processing ? null : () => _handleAction(false),
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
          backgroundColor: const Color(0xFFEDF1F9),
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
      painter: _WavePainter(color: const Color(0xFF6B7A99)),
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
