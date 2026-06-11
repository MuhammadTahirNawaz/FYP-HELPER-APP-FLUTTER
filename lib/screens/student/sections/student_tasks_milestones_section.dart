import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../core/validators.dart';
import '../../../theme/app_colors.dart';
import '../utils/student_deadline_utils.dart';

class StudentTasksMilestonesSection extends StatelessWidget {
  const StudentTasksMilestonesSection({
    super.key,
    required this.groupsRef,
    this.groupId,
  });

  final DatabaseReference groupsRef;
  final String? groupId;

  @override
  Widget build(BuildContext context) {
    if (groupId == null) {
      return const Center(child: Text('Join a group to see tasks.'));
    }

    return StreamBuilder(
      stream: groupsRef.child(groupId!).child('tasks').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('No tasks assigned by supervisor yet'));
        }

        final tasks = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
        final tasksList = tasks.entries.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasksList.length,
          itemBuilder: (context, index) {
            final taskId = tasksList[index].key;
            final task = Map<String, dynamic>.from(tasksList[index].value);
            final status = task['status'] ?? 'Pending';
            final isCompleted = status == 'Completed';
            final isVerified = status == 'Verified';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.borderSoft),
              ),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: isVerified
                      ? Colors.green[50]
                      : (isCompleted ? Colors.orange[50] : const Color(0xFFFEF3C7)),
                  child: Icon(
                    isVerified
                        ? Icons.check_circle
                        : (isCompleted ? Icons.pending : Icons.assignment),
                    color: isVerified
                        ? Colors.green
                        : (isCompleted ? Colors.orange : const Color(0xFFB45309)),
                  ),
                ),
                title: Text(
                  task['title'] ?? 'Task ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.studentTeal,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deadline: ${task['deadline'] ?? 'No'} ${task['deadlineTime'] ?? ''}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: isVerified ? 1.0 : (isCompleted ? 0.75 : 0.25),
                        backgroundColor: AppColors.borderSoft,
                        color: isVerified
                            ? Colors.green
                            : (isCompleted ? Colors.orange : AppColors.infoBlue),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['description'] ?? 'No description provided.',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const Divider(height: 24),
                        if (isVerified) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.grade, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  'Your Marks: ${((task['memberMarks'] as Map?)?[FirebaseAuth.instance.currentUser?.uid] ?? 0)} / 100',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (isCompleted) ...[
                          const Text(
                            'Waiting for supervisor verification...',
                            style: TextStyle(
                              color: Colors.orange,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Your Submission:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Enter your work link or submission text...',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            maxLines: 2,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (v) => AppValidators.description(v, fieldName: 'Submission'),
                            onFieldSubmitted: (val) {
                              if (AppValidators.description(val, fieldName: 'Submission') == null) {
                                _submitTask(taskId, val);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          if (isStudentDeadlinePassed(
                            task['deadline'],
                            task['deadlineTime'],
                          ))
                            const Text(
                              'Deadline passed. Submissions are closed.',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => _showSubmitDialog(context, taskId),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.studentTeal,
                                ),
                                child: const Text('Submit Task'),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitTask(String taskId, String submission) async {
    await groupsRef.child(groupId!).child('tasks').child(taskId).update({
      'submission': submission,
      'status': 'Completed',
      'submittedAt': DateTime.now().toIso8601String(),
    });
  }

  void _showSubmitDialog(BuildContext context, String taskId) {
    final controller = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Task'),
        content: Form(
          key: dialogFormKey,
          child: TextFormField(
            controller: controller,
            maxLines: 4,
            validator: (v) => AppValidators.description(v, fieldName: 'Submission'),
            decoration: const InputDecoration(
              hintText: 'Enter document link or description of your work...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!(dialogFormKey.currentState?.validate() ?? false)) return;
              _submitTask(taskId, controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
