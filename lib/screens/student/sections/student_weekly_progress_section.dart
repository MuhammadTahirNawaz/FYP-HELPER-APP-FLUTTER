import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class StudentWeeklyProgressSection extends StatefulWidget {
  const StudentWeeklyProgressSection({
    super.key,
    required this.groupsRef,
    this.groupId,
  });

  final DatabaseReference groupsRef;
  final String? groupId;

  @override
  State<StudentWeeklyProgressSection> createState() =>
      _StudentWeeklyProgressSectionState();
}

class _StudentWeeklyProgressSectionState extends State<StudentWeeklyProgressSection> {
  double _progressValue = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.groupId == null) {
      return const Center(child: Text('Join a group to update progress.'));
    }

    return StreamBuilder(
      stream: widget.groupsRef.child(widget.groupId!).onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.snapshot.value is Map) {
          final groupData = snapshot.data!.snapshot.value as Map;
          _progressValue = (groupData['progressPercentage'] ?? 0).toDouble();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Update Project Progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Slide to update the overall completion percentage of your FYP.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              Text(
                '${_progressValue.toInt()}%',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF38BDF8),
                ),
              ),
              Slider(
                value: _progressValue,
                min: 0,
                max: 100,
                divisions: 100,
                label: '${_progressValue.toInt()}%',
                onChanged: (val) {
                  setState(() => _progressValue = val);
                },
                onChangeEnd: (val) async {
                  await widget.groupsRef.child(widget.groupId!).update({
                    'progressPercentage': val.toInt(),
                    'lastProgressUpdate': DateTime.now().toIso8601String(),
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Progress updated successfully')),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              const Card(
                color: Color(0xFFEEF2FF),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF38BDF8)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This percentage is visible to your supervisor for real-time tracking.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
