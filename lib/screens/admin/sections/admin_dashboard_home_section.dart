import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/dashboard_styles.dart';
import '../../../widgets/dashboard/dashboard_category_chips.dart';
import '../../../widgets/dashboard/dashboard_progress_card.dart';
import '../widgets/admin_dashboard_banner.dart';
import '../widgets/admin_stats_grid.dart';
import '../widgets/admin_system_health_section.dart';
import '../widgets/admin_timed_ad_banner.dart';

class AdminDashboardHomeSection extends StatelessWidget {
  const AdminDashboardHomeSection({
    super.key,
    required this.usersRef,
    required this.adminRef,
    this.university,
    this.displayName,
  });

  final DatabaseReference usersRef;
  final DatabaseReference adminRef;
  final String? university;
  final String? displayName;

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseDatabase.instance.ref('messages/threads');

    return StreamBuilder<DatabaseEvent>(
      stream: usersRef.onValue,
      builder: (context, usersSnapshot) {
        final usersData = usersSnapshot.data?.snapshot.value;
        final allUsers = usersData is Map
            ? Map<String, dynamic>.from(usersData)
            : <String, dynamic>{};

        final usersMap = Map.fromEntries(allUsers.entries.where((e) {
          final userData = e.value as Map;
          return university != null && userData['university'] == university;
        }));

        final totalUsers = usersMap.length;
        final pendingUsers = usersMap.values
            .where((value) => value is Map && (value['role'] as String?) == 'Pending')
            .length;
        final verifiedUsers = totalUsers - pendingUsers;

        return StreamBuilder<DatabaseEvent>(
          stream: adminRef.child('announcements').onValue,
          builder: (context, annSnapshot) {
            final annData = annSnapshot.data?.snapshot.value;
            final annCount =
                annData is Map ? Map<String, dynamic>.from(annData).length : 0;

            return StreamBuilder<DatabaseEvent>(
              stream: messagesRef.onValue,
              builder: (context, msgSnapshot) {
                final msgData = msgSnapshot.data?.snapshot.value;
                final msgCount =
                    msgData is Map ? Map<String, dynamic>.from(msgData).length : 0;

                final verificationRate =
                    totalUsers == 0 ? 0.0 : verifiedUsers / totalUsers;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AdminDashboardBanner(
                        title: 'Welcome back',
                        userName: displayName ?? 'Administrator',
                        subtitle:
                            'Manage the entire platform from one polished control panel.',
                        icon: Icons.admin_panel_settings_rounded,
                      ),
                      const SizedBox(height: 20),
                      const DashboardCategoryChips(
                        labels: ['Overview', 'Users', 'Groups', 'Reports'],
                        accentColor: AppColors.navy,
                        onNavy: false,
                      ),
                      const SizedBox(height: 16),
                      AdminStatsGrid(
                        stats: [
                          AdminStatItem(
                            label: 'Total Users',
                            value: totalUsers.toString(),
                            icon: Icons.group,
                            accent: AppColors.textOnNavy,
                          ),
                          AdminStatItem(
                            label: 'Pending',
                            value: pendingUsers.toString(),
                            icon: Icons.hourglass_top,
                            accent: AppColors.textOnNavy,
                          ),
                          AdminStatItem(
                            label: 'Verified',
                            value: verifiedUsers.toString(),
                            icon: Icons.verified,
                            accent: AppColors.textOnNavy,
                          ),
                          AdminStatItem(
                            label: 'Announcements',
                            value: annCount.toString(),
                            icon: Icons.campaign,
                            accent: AppColors.textOnNavy,
                          ),
                          AdminStatItem(
                            label: 'Messages',
                            value: msgCount.toString(),
                            icon: Icons.message,
                            accent: AppColors.textOnNavy,
                          ),
                        ],
                        variant: DashboardCardVariant.navy,
                      ),
                      const SizedBox(height: 16),
                      DashboardProgressCard(
                        title: 'User Verification',
                        subtitle: '$verifiedUsers of $totalUsers users verified',
                        progress: verificationRate,
                        accent: AppColors.navy,
                        variant: DashboardCardVariant.light,
                      ),
                      const SizedBox(height: 20),
                      const AdminSystemHealthSection(),
                      const SizedBox(height: 20),
                      const AdminTimedAdBanner(),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
