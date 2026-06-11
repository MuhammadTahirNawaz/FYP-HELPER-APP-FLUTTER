import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

import 'committee_dashboard_screen.dart';
import 'committee_proposal_review_screen.dart';
import 'committee_viva_scheduling_screen.dart';
import 'committee_settings_screen.dart';

class CommitteeNavBar extends StatelessWidget {
  const CommitteeNavBar({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppColors.adminPink.withValues(alpha: 0.12),
          selectedIndex: selectedIndex,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.fact_check_outlined), label: 'Review'),
            NavigationDestination(icon: Icon(Icons.event_outlined), label: 'Viva'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
          ],
          onDestinationSelected: (index) {
            if (index == selectedIndex) return;
            final routeName = switch (index) {
              0 => CommitteeDashboardScreen.routeName,
              1 => CommitteeProposalReviewScreen.routeName,
              2 => CommitteeVivaSchedulingScreen.routeName,
              _ => CommitteeSettingsScreen.routeName,
            };
            Navigator.of(context).pushReplacementNamed(routeName);
          },
        ),
      ),
    );
  }
}
