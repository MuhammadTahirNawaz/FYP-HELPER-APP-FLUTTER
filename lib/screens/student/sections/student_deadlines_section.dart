import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class StudentDeadlinesSection extends StatelessWidget {
  const StudentDeadlinesSection({
    super.key,
    required this.adminRef,
    required this.groupsRef,
    this.groupId,
  });

  final DatabaseReference adminRef;
  final DatabaseReference groupsRef;
  final String? groupId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Global Deadlines',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          StreamBuilder(
            stream: adminRef.child('evaluationSchedule').onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return const Center(child: Text('No global deadlines.'));
              }
              final schedule = Map<String, dynamic>.from(
                snapshot.data!.snapshot.value as Map,
              );
              return Column(
                children: schedule.values
                    .map(
                      (event) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today, color: Colors.orange),
                          title: Text(event['eventName'] ?? 'Event'),
                          subtitle: Text(event['date'] ?? 'TBD'),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Group-Specific Deadlines',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (groupId == null)
            const Text('Join a group to see supervisor-set deadlines.')
          else
            StreamBuilder(
              stream: groupsRef.child(groupId!).onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Text('No group deadlines.');
                }
                final groupData = snapshot.data!.snapshot.value as Map;
                final deadline = groupData['proposalDeadline'];
                if (deadline == null) {
                  return const Text('No custom deadline set by supervisor yet.');
                }
                return Card(
                  color: const Color(0xFFF0FDF4),
                  child: ListTile(
                    leading: const Icon(Icons.description, color: Colors.green),
                    title: const Text('Proposal Submission Deadline'),
                    subtitle: Text(
                      deadline,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
