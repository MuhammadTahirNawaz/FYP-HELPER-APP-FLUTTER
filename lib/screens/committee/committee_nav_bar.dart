import 'package:flutter/material.dart';

import 'committee_dashboard_screen.dart';
import 'committee_proposal_review_screen.dart';
import 'committee_viva_scheduling_screen.dart';

class CommitteeNavBar extends StatelessWidget {
  const CommitteeNavBar({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Dashboard'),
        NavigationDestination(icon: Icon(Icons.fact_check), label: 'Review'),
        NavigationDestination(icon: Icon(Icons.event), label: 'Viva'),
      ],
      onDestinationSelected: (index) {
        if (index == selectedIndex) {
          return;
        }

        final routeName = switch (index) {
          0 => CommitteeDashboardScreen.routeName,
          1 => CommitteeProposalReviewScreen.routeName,
          _ => CommitteeVivaSchedulingScreen.routeName,
        };

        Navigator.of(context).pushReplacementNamed(routeName);
      },
    );
  }
}
