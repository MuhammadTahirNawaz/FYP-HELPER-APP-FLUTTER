import 'package:flutter/material.dart';

import 'committee_nav_bar.dart';

class CommitteeProposalReviewScreen extends StatelessWidget {
  const CommitteeProposalReviewScreen({super.key});

  static const String routeName = '/committee-proposal-review';

  static const List<_ProposalItem> _proposals = [
    _ProposalItem('Group A', 'Smart Attendance', 'NEW'),
    _ProposalItem('Group B', 'AI Tutor', 'REVIEWED'),
    _ProposalItem('Group C', 'Lab Scheduler', 'NEW'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[LOGO]'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'PROPOSAL REVIEW',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ..._proposals.map((proposal) => _ProposalCard(item: proposal)),
        ],
      ),
      bottomNavigationBar: const CommitteeNavBar(selectedIndex: 1),
    );
  }
}

class _ProposalItem {
  const _ProposalItem(this.group, this.project, this.status);

  final String group;
  final String project;
  final String status;
}

class _ProposalCard extends StatelessWidget {
  const _ProposalCard({required this.item});

  final _ProposalItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE6E6E6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.group.toUpperCase(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Project Title: ${item.project}'),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEF6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(item.status, style: const TextStyle(fontSize: 11)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
