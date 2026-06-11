import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../core/validators.dart';
import '../../../models/fyp_group.dart';
import '../../../models/user_account.dart';

class AdminSupervisorLimitsSection extends StatefulWidget {
  const AdminSupervisorLimitsSection({
    super.key,
    required this.usersRef,
    required this.groupsRef,
    required this.adminRef,
    this.university,
  });

  final DatabaseReference usersRef;
  final DatabaseReference groupsRef;
  final DatabaseReference adminRef;
  final String? university;

  @override
  State<AdminSupervisorLimitsSection> createState() =>
      _AdminSupervisorLimitsSectionState();
}

class _AdminSupervisorLimitsSectionState extends State<AdminSupervisorLimitsSection> {
  bool _updating = false;

  Future<void> _updateLimit(String supervisorId, int newLimit) async {
    if (_updating) return;
    setState(() => _updating = true);
    try {
      await widget.adminRef.child('supervisorLimits').child(supervisorId).update({
        'maxGroups': newLimit,
        'updatedAt': ServerValue.timestamp,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Limit updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  Future<void> _showEditLimitDialog(
    String supervisorId,
    String supervisorEmail,
    int currentLimit,
  ) async {
    final controller = TextEditingController(text: currentLimit.toString());
    final dialogFormKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Supervisor Limit'),
          content: Form(
            key: dialogFormKey,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Supervisor: $supervisorEmail'),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final requiredError = AppValidators.required(v, fieldName: 'Max groups');
                  if (requiredError != null) return requiredError;
                  final value = int.tryParse(v!.trim());
                  if (value == null || value <= 0) {
                    return 'Enter a valid number greater than 0';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Max Groups',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (!(dialogFormKey.currentState?.validate() ?? false)) return;
                final value = int.tryParse(controller.text.trim())!;
                Navigator.pop(dialogContext);
                _updateLimit(supervisorId, value);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: widget.usersRef.onValue,
      builder: (context, userSnapshot) {
        final supervisors = UserAccount.listFromSnapshot(
          userSnapshot.data?.snapshot.value,
        )
            .where((user) => user.role == 'Supervisor')
            .where(
              (user) =>
                  widget.university == null || user.university == widget.university,
            )
            .toList();

        return StreamBuilder<DatabaseEvent>(
          stream: widget.adminRef.child('supervisorLimits').onValue,
          builder: (context, limitsSnapshot) {
            final limitsData = limitsSnapshot.data?.snapshot.value;
            final limits =
                limitsData is Map ? Map<String, dynamic>.from(limitsData) : {};

            return StreamBuilder<DatabaseEvent>(
              stream: widget.groupsRef.onValue,
              builder: (context, groupsSnapshot) {
                final groups = FypGroup.listFromSnapshot(
                  groupsSnapshot.data?.snapshot.value,
                ).where(
                  (group) =>
                      widget.university == null ||
                      group.university == widget.university,
                ).toList();

                final supervisorCapacity = <String, int>{};
                for (final group in groups) {
                  if (group.supervisorEmail.isNotEmpty) {
                    supervisorCapacity[group.supervisorEmail] =
                        (supervisorCapacity[group.supervisorEmail] ?? 0) + 1;
                  }
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Supervisor Capacity Management',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set the maximum number of groups each supervisor can manage',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (supervisors.isEmpty)
                      const Center(child: Text('No supervisors registered yet.'))
                    else
                      ...supervisors.map((supervisor) {
                        final limitData = limits[supervisor.uid];
                        final maxGroups = limitData is Map
                            ? (limitData['maxGroups'] as num?)?.toInt() ?? 5
                            : 5;
                        final currentCapacity =
                            supervisorCapacity[supervisor.email] ?? 0;
                        final usagePercentage =
                            (currentCapacity / maxGroups * 100).clamp(0, 100);

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFFE6E6E6)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            supervisor.email,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Capacity: $currentCapacity / $maxGroups groups',
                                            style:
                                                Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Edit limit',
                                      onPressed: _updating
                                          ? null
                                          : () => _showEditLimitDialog(
                                                supervisor.uid,
                                                supervisor.email,
                                                maxGroups,
                                              ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: usagePercentage / 100,
                                    minHeight: 6,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      usagePercentage > 80
                                          ? const Color(0xFFEF4444)
                                          : usagePercentage > 60
                                              ? const Color(0xFFF59E0B)
                                              : const Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${usagePercentage.toStringAsFixed(0)}% capacity used',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: usagePercentage > 80
                                            ? const Color(0xFFEF4444)
                                            : usagePercentage > 60
                                                ? const Color(0xFFF59E0B)
                                                : const Color(0xFF10B981),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
