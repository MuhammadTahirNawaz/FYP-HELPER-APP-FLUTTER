import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'committee_nav_bar.dart';
import 'committee_dashboard_screen.dart';

class CommitteeProposalReviewScreen extends StatefulWidget {
  const CommitteeProposalReviewScreen({super.key});

  static const String routeName = '/committee-proposal-review';

  @override
  State<CommitteeProposalReviewScreen> createState() =>
      _CommitteeProposalReviewScreenState();
}

class _CommitteeProposalReviewScreenState
    extends State<CommitteeProposalReviewScreen> {
  final DatabaseReference _groupsRef =
      FirebaseDatabase.instance.ref('groups');

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
        appBar: AppBar(
          title: const Text('Proposal Review'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushReplacementNamed(CommitteeDashboardScreen.routeName),
          ),
        ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _groupsRef.onValue,
        builder: (context, snapshot) {
          final data = snapshot.data?.snapshot.value;
          if (data is! Map) {
            return const Center(child: Text('No proposals found.'));
          }

          final entries = Map<String, dynamic>.from(data);
          final proposals = entries.entries
              .map((entry) {
                final value = Map<String, dynamic>.from(entry.value as Map);
                return _ProposalItem(
                  groupCode: entry.key,
                  projectTitle: (value['projectTitle'] as String?) ?? 'Untitled',
                  description: (value['projectDescription'] as String?) ?? '',
                  proposalStatus:
                      (value['proposalStatus'] as String?) ?? 'Not Submitted',
                  supervisorApproved:
                      (value['supervisorApproved'] as bool?) ?? false,
                  committeeApproved:
                      (value['committeeApproved'] as bool?) ?? false,
                );
              })
              .where((p) => p.proposalStatus == 'Pending Committee Review')
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Proposals Pending Review',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (proposals.isEmpty)
                const Center(child: Text('No pending proposals.'))
              else
                ...proposals.map(
                  (proposal) => _ProposalCard(
                    item: proposal,
                    groupsRef: _groupsRef,
                    onStatusChanged: () => setState(() {}),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: const CommitteeNavBar(selectedIndex: 1),
      ),
    );
  }
}

class _ProposalItem {
  const _ProposalItem({
    required this.groupCode,
    required this.projectTitle,
    required this.description,
    required this.proposalStatus,
    required this.supervisorApproved,
    required this.committeeApproved,
  });

  final String groupCode;
  final String projectTitle;
  final String description;
  final String proposalStatus;
  final bool supervisorApproved;
  final bool committeeApproved;
}

class _ProposalCard extends StatefulWidget {
  const _ProposalCard({
    required this.item,
    required this.groupsRef,
    required this.onStatusChanged,
  });

  final _ProposalItem item;
  final DatabaseReference groupsRef;
  final VoidCallback onStatusChanged;

  @override
  State<_ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends State<_ProposalCard> {
  bool _isUpdating = false;

  Future<void> _approveProposal() async {
    setState(() => _isUpdating = true);
    try {
      await widget.groupsRef.child(widget.item.groupCode).update({
        'committeeApproved': true,
        'proposalStatus': 'Approved',
        'updatedAt': ServerValue.timestamp,
      });
      widget.onStatusChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proposal approved successfully')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _rejectProposal() async {
    setState(() => _isUpdating = true);
    try {
      await widget.groupsRef.child(widget.item.groupCode).update({
        'committeeApproved': false,
        'proposalStatus': 'Rejected by Committee',
        'updatedAt': ServerValue.timestamp,
      });
      widget.onStatusChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proposal rejected')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.item.committeeApproved
        ? Colors.green
        : widget.item.proposalStatus == 'Rejected by Committee'
            ? Colors.red
            : Colors.orange;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE6E6E6)),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEDF1F9),
          child: Text(widget.item.groupCode[0]),
        ),
        title: Text('Group ${widget.item.groupCode}'),
        subtitle: Text(widget.item.projectTitle),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project Description',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.item.description.isEmpty
                      ? 'No description provided'
                      : widget.item.description,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        'Supervisor: ${widget.item.supervisorApproved ? 'Approved' : 'Not Approved'}',
                      ),
                      backgroundColor:
                          widget.item.supervisorApproved ? Colors.green[100] : Colors.grey[100],
                    ),
                    Chip(
                      label: Text(
                        'Committee: ${widget.item.committeeApproved ? 'Approved' : 'Pending'}',
                      ),
                      backgroundColor: statusColor.withOpacity(0.2),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton.tonal(
                      onPressed: _isUpdating ? null : _rejectProposal,
                      child: const Text('Reject'),
                    ),
                    FilledButton(
                      onPressed: _isUpdating ? null : _approveProposal,
                      child: _isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Approve'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
