import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class StudentMarksAndFeedbackSection extends StatelessWidget {
  const StudentMarksAndFeedbackSection({
    super.key,
    required this.groupsRef,
    this.groupId,
  });

  final DatabaseReference groupsRef;
  final String? groupId;

  @override
  Widget build(BuildContext context) {
    if (groupId == null) {
      return const Center(child: Text('Join a group to see marks.'));
    }

    return StreamBuilder(
      stream: groupsRef.child(groupId!).onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('No marks assigned yet'));
        }

        final groupData = snapshot.data!.snapshot.value as Map;
        final marks = groupData['marks'];
        final remarks = groupData['remarks'];

        if (marks == null) {
          return const Center(
            child: Text('Supervisor has not graded your project yet.'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.borderSoft),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Project Grade',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.studentTeal,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$marks/100',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF38BDF8),
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: marks / 100,
                      minHeight: 10,
                      backgroundColor: AppColors.borderSoft,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        marks >= 50 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Supervisor Feedback:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    remarks ?? 'No comments provided.',
                    style: const TextStyle(color: Color(0xFF64748B), height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
