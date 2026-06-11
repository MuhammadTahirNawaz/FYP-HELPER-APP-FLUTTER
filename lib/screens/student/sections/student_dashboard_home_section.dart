import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/dashboard_styles.dart';
import '../../../widgets/dashboard/dashboard_category_chips.dart';
import '../../../widgets/dashboard/dashboard_info_tile.dart';
import '../../../widgets/dashboard/dashboard_progress_card.dart';
import '../widgets/student_dashboard_banner.dart';
import '../widgets/student_stat_card.dart';

class StudentDashboardHomeSection extends StatelessWidget {
  const StudentDashboardHomeSection({
    super.key,
    required this.groupsRef,
    required this.currentUid,
    this.displayName,
  });

  final DatabaseReference groupsRef;
  final String currentUid;
  final String? displayName;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: groupsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.snapshot.value is Map) {
          final groups =
              Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

          final myGroupEntry = groups.entries.where((e) {
            final members = e.value['members'] is Map
                ? Map<String, dynamic>.from(e.value['members'] as Map)
                : {};
            return members.containsKey(currentUid);
          }).firstOrNull;

          if (myGroupEntry != null) {
            final myGroup = Map<String, dynamic>.from(myGroupEntry.value as Map);
            final proposalStatus =
                myGroup['proposalStatus'] as String? ?? 'Not Submitted';
            final supervisorName =
                myGroup['supervisorName'] as String? ?? 'Not Assigned Yet';
            final progress = proposalStatusProgress(proposalStatus);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StudentDashboardBanner(
                    title: 'Welcome back',
                    userName: displayName ?? 'Student',
                    subtitle:
                        'Track your FYP journey and collaborate with your supervisor.',
                    icon: Icons.waving_hand_rounded,
                  ),
                  const SizedBox(height: 20),
                  const DashboardCategoryChips(
                    labels: ['Overview', 'Proposals', 'Tasks', 'Meetings'],
                    accentColor: AppColors.navy,
                    onNavy: false,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StudentStatCard(
                          title: 'Group Code',
                          value: myGroupEntry.key,
                          icon: Icons.tag_rounded,
                          color: AppColors.textOnNavy,
                          compact: true,
                          variant: DashboardCardVariant.navy,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StudentStatCard(
                          title: 'Proposal',
                          value: proposalStatus,
                          icon: Icons.description_outlined,
                          color: AppColors.textOnNavy,
                          compact: true,
                          variant: DashboardCardVariant.navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DashboardProgressCard(
                    title: 'FYP Progress',
                    subtitle: 'Based on your current proposal status',
                    progress: progress,
                    accent: AppColors.navy,
                    variant: DashboardCardVariant.light,
                  ),
                  const SizedBox(height: 12),
                  DashboardInfoTile(
                    label: 'Supervisor',
                    value: supervisorName,
                    icon: Icons.supervisor_account_outlined,
                    accent: AppColors.navy,
                    variant: DashboardCardVariant.light,
                    trailing: myGroup['supervisorId'] != null
                        ? const Icon(Icons.verified_user, color: AppColors.navy, size: 22)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  StudentStatCard(
                    title: 'Project Title',
                    value: myGroup['projectTitle'] ?? 'No Title Set',
                    icon: Icons.lightbulb_outline_rounded,
                    color: AppColors.navy,
                    variant: DashboardCardVariant.light,
                  ),
                  if (myGroup['vivaDate'] != null) ...[
                    const SizedBox(height: 12),
                    _VivaCard(vivaDateStr: myGroup['vivaDate'] as String),
                  ],
                ],
              ),
            );
          }
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: DashboardStyles.lightCardDecoration(),
                  child: const Icon(
                    Icons.group_add_rounded,
                    size: 56,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No Group Assigned',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join or create a group to start your FYP.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('/student-groups'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Join or Create Group'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DashboardStyles.buttonRadius),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VivaCard extends StatelessWidget {
  const _VivaCard({required this.vivaDateStr});

  final String vivaDateStr;

  @override
  Widget build(BuildContext context) {
    final vivaDate = DateTime.parse(vivaDateStr);
    final now = DateTime.now();
    if (vivaDate.isBefore(now.subtract(const Duration(days: 1)))) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: DashboardStyles.lightCardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppColors.navy,
            child: const Row(
              children: [
                Icon(Icons.stars_rounded, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'OFFICIAL VIVA SCHEDULED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: AppColors.navy),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vivaDate.toLocal().toString().split(' ')[0],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'Set by FYP Committee',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
