import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../services/notification_delivery_service.dart';
import '../../theme/app_colors.dart';

import 'committee_nav_bar.dart';
import 'committee_dashboard_screen.dart';

class CommitteeVivaSchedulingScreen extends StatefulWidget {
  const CommitteeVivaSchedulingScreen({super.key});

  static const String routeName = '/committee-viva-scheduling';

  @override
  State<CommitteeVivaSchedulingScreen> createState() =>
      _CommitteeVivaSchedulingScreenState();
}

class _CommitteeVivaSchedulingScreenState
    extends State<CommitteeVivaSchedulingScreen> {
  final DatabaseReference _groupsRef = FirebaseDatabase.instance.ref('groups');

  Future<void> _scheduleViva(String groupCode, DateTime? currentDate) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (picked == null) {
      return;
    }

    try {
      await _groupsRef.child(groupCode).update({
        'vivaDate': picked.toIso8601String(),
        'updatedAt': ServerValue.timestamp,
      });

      await _notifyMembersVivaScheduled(groupCode, picked);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scheduled Viva for group $groupCode')),
        );
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scheduling: $e')),
        );
      }
    }
  }

  Future<void> _notifyMembersVivaScheduled(String groupCode, DateTime date) async {
    final groupSnap = await _groupsRef.child(groupCode).get();
    if (!groupSnap.exists || groupSnap.value == null) {
      return;
    }

    final data = Map<String, dynamic>.from(groupSnap.value as Map);
    final members = data['members'] as Map?;
    if (members == null) {
      return;
    }

    final dateStr = date.toLocal().toString().split(' ').first;
    final body =
        'Your Viva has been scheduled for $dateStr by the Committee.';

    for (final memberUid in members.keys) {
      await NotificationDeliveryService.instance.sendToUser(
        recipientUid: memberUid.toString(),
        title: 'Viva Scheduled',
        message: body,
        type: 'viva',
        extra: {'groupId': groupCode},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(CommitteeDashboardScreen.routeName);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.of(context).pushReplacementNamed(CommitteeDashboardScreen.routeName),
          ),
          title: Text(
            'FYP HELPER',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                  letterSpacing: 1.2,
                ),
          ),
          actions: [
            StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance.ref('committee/notifications').onValue,
              builder: (context, snapshot) {
                final hasUnread = snapshot.hasData && snapshot.data!.snapshot.value != null;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                    ),
                    if (hasUnread)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 8,
                            minHeight: 8,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Viva Scheduling',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.adminPink,
                          shadows: [const Shadow(color: AppColors.adminPink, blurRadius: 15)],
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Manage and coordinate evaluation dates for all groups.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: _groupsRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final data = snapshot.data?.snapshot.value;
                  if (data == null) {
                    return const Center(child: Text('No groups found.'));
                  }

                  final groupsMap = Map<String, dynamic>.from(data as Map);
                  final groupEntries = groupsMap.entries.toList();

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: groupEntries.length,
                    itemBuilder: (context, index) {
                      final groupCode = groupEntries[index].key;
                      final groupData = Map<String, dynamic>.from(groupEntries[index].value as Map);
                      
                      final projectTitle = (groupData['projectTitle'] as String?) ?? 'No Title';
                      final memberCount = (groupData['members'] as Map?)?.length ?? 0;
                      final vivaDateStr = groupData['vivaDate'] as String?;
                      final vivaDate = vivaDateStr != null ? DateTime.parse(vivaDateStr) : null;

                      return _ScheduleCard(
                        groupCode: groupCode,
                        projectTitle: projectTitle,
                        memberCount: memberCount,
                        scheduledDate: vivaDate,
                        onSchedule: () => _scheduleViva(groupCode, vivaDate),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: const CommitteeNavBar(selectedIndex: 2),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.groupCode,
    required this.projectTitle,
    required this.memberCount,
    required this.scheduledDate,
    required this.onSchedule,
  });

  final String groupCode;
  final String projectTitle;
  final int memberCount;
  final DateTime? scheduledDate;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    final isScheduled = scheduledDate != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isScheduled ? AppColors.adminPink.withValues(alpha: 0.4) : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          if (isScheduled)
            BoxShadow(color: AppColors.adminPink.withValues(alpha: 0.1), blurRadius: 15)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: AppColors.surfaceLight.withValues(alpha: 0.5),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.adminPink.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.adminPink.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'GROUP $groupCode',
                      style: const TextStyle(
                        color: AppColors.adminPink,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isScheduled)
                    const Icon(Icons.check_circle, color: AppColors.success, size: 18)
                  else
                    const Icon(Icons.pending, color: AppColors.warning, size: 18),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          projectTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.people_outline, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              '$memberCount Members',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                        if (isScheduled) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: AppColors.adminPink),
                              const SizedBox(width: 6),
                              Text(
                                scheduledDate!.toLocal().toString().split(' ')[0],
                                style: const TextStyle(
                                  color: AppColors.adminPink,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: onSchedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isScheduled ? Colors.transparent : AppColors.adminPink,
                      foregroundColor: isScheduled ? AppColors.adminPink : Colors.white,
                      elevation: 0,
                      side: const BorderSide(color: AppColors.adminPink),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      isScheduled ? 'RESCHEDULE' : 'SCHEDULE',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
