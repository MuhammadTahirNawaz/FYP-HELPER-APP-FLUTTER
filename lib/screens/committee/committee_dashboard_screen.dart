import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/dashboard_styles.dart';
import '../../widgets/dashboard/dashboard_kpi_card.dart';
import '../../widgets/dashboard/dashboard_welcome_header.dart';

import '../shared/messages_screen.dart';
import 'committee_nav_bar.dart';

class CommitteeDashboardScreen extends StatefulWidget {
  const CommitteeDashboardScreen({super.key});

  static const String routeName = '/committee-dashboard';

  @override
  State<CommitteeDashboardScreen> createState() =>
      _CommitteeDashboardScreenState();
}

class _CommitteeDashboardScreenState extends State<CommitteeDashboardScreen> {
  final DatabaseReference _groupsRef =
      FirebaseDatabase.instance.ref('groups');
  DatabaseReference get _evaluationRef =>
      FirebaseDatabase.instance.ref('admin/universities/${_university ?? "default"}/evaluationSchedule');
  DatabaseReference get _documentsRef =>
      FirebaseDatabase.instance.ref('admin/universities/${_university ?? "default"}/documents_by_role/Committee');

  _CommitteeSection _currentSection = _CommitteeSection.dashboard;
  String? _university;

  @override
  void initState() {
    super.initState();
    _fetchUniversity();
  }

  Future<void> _fetchUniversity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snap = await FirebaseDatabase.instance.ref('users/${user.uid}').get();
      if (snap.exists && snap.value is Map) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        if (mounted) setState(() => _university = data['university'] as String?);
      }
    }
  }

  void _selectSection(_CommitteeSection section) {
    setState(() => _currentSection = section);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentSection.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              'Committee dashboard',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/committee-settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _CommitteeDrawer(
        selected: _currentSection,
        onSelected: _selectSection,
      ),
      body: PopScope(
        canPop: _currentSection == _CommitteeSection.dashboard,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            setState(() => _currentSection = _CommitteeSection.dashboard);
          }
        },
        child: _CommitteeSectionBody(
          section: _currentSection,
          groupsRef: _groupsRef,
          evaluationRef: _evaluationRef,
          documentsRef: _documentsRef,
          university: _university,
        ),
      ),
      bottomNavigationBar: const CommitteeNavBar(selectedIndex: 0),
    );
  }
}

// ---------------------------------------------------------------------------

class _CommitteeSectionBody extends StatelessWidget {
  const _CommitteeSectionBody({
    required this.section,
    required this.groupsRef,
    required this.evaluationRef,
    required this.documentsRef,
    this.university,
  });

  final _CommitteeSection section;
  final DatabaseReference groupsRef;
  final DatabaseReference evaluationRef;
  final DatabaseReference documentsRef;
  final String? university;

  @override
  Widget build(BuildContext context) {
    switch (section) {
      case _CommitteeSection.dashboard:
        return _CommitteeDashboardHome(
          groupsRef: groupsRef,
          evaluationRef: evaluationRef,
          university: university,
        );
      case _CommitteeSection.groups:
        return _GroupsViewSection(groupsRef: groupsRef, university: university);
      case _CommitteeSection.proposals:
        return _ProposalsViewSection(groupsRef: groupsRef, university: university);
      case _CommitteeSection.reviews:
        return _ProposalReviewSection(
          groupsRef: groupsRef,
          university: university,
        );
      case _CommitteeSection.viva:
        return _VivaSchedulingSection(
          groupsRef: groupsRef,
          evaluationRef: evaluationRef,
          university: university,
        );
      case _CommitteeSection.documents:
        return _DocumentsViewSection(documentsRef: documentsRef, university: university);
      case _CommitteeSection.progress:
        return _GroupProgressSection(groupsRef: groupsRef, university: university);
      case _CommitteeSection.schedule:
        return _EvaluationScheduleSection(groupsRef: groupsRef, university: university);
      case _CommitteeSection.messages:
        return const MessagesScreen(isAdmin: false);
    }
  }
}

// ---------------------------------------------------------------------------

class _CommitteeDrawer extends StatelessWidget {
  const _CommitteeDrawer({
    required this.selected,
    required this.onSelected,
  });

  final _CommitteeSection selected;
  final ValueChanged<_CommitteeSection> onSelected;

  List<_CommitteeSection> get _drawerSections => _CommitteeSection.values
      .where((s) => s != _CommitteeSection.dashboard)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.fact_check_outlined,
                      color: AppColors.navy,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Committee Panel',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Review proposals, documents and progress',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  for (final section in _drawerSections)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        tileColor: section == selected
                            ? AppColors.surfaceMuted
                            : Colors.transparent,
                        leading: Icon(
                          section.icon,
                          color: section == selected
                              ? AppColors.navy
                              : AppColors.textSecondary,
                        ),
                        title: Text(
                          section.title,
                          style: TextStyle(
                            fontWeight: section == selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: section == selected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        selected: section == selected,
                        onTap: () => onSelected(section),
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

// ---------------------------------------------------------------------------

class _CommitteeDashboardHome extends StatelessWidget {
  const _CommitteeDashboardHome({
    required this.groupsRef,
    required this.evaluationRef,
    this.university,
  });

  final DatabaseReference groupsRef;
  final DatabaseReference evaluationRef;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: groupsRef.onValue,
      builder: (context, groupsSnapshot) {
        final groupsData = groupsSnapshot.data?.snapshot.value;
        final allGroups = groupsData is Map
            ? Map<String, dynamic>.from(groupsData)
            : <String, dynamic>{};
            
        // Filter by University
        final groupsMap = university == null 
          ? allGroups 
          : Map.fromEntries(allGroups.entries.where((e) => (e.value as Map)['university'] == university));

        final totalGroups = groupsMap.length;
        final pendingProposals = groupsMap.values
            .where((v) =>
                v is Map &&
                (v['proposalStatus'] as String?) ==
                    'Pending Committee Review')
            .length;
        final approvedProposals = groupsMap.values
            .where((v) =>
                v is Map &&
                (v['proposalStatus'] as String?) == 'Approved')
            .length;
        final delayedGroups = groupsMap.values
            .where(
                (v) => v is Map && (v['status'] as String?) == 'Delayed')
            .length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            DashboardWelcomeHeader(
              greeting: 'Welcome back',
              name: 'Committee',
              subtitle:
                  'Track proposal approvals, group status, and review progress from one place.',
              accentColor: AppColors.navy,
              onLightBackground: true,
              avatar: CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.surfaceMuted,
                child: const Icon(
                  Icons.fact_check_outlined,
                  color: AppColors.navy,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.05,
              children: [
                DashboardKpiCard(
                  label: 'Total Groups',
                  value: totalGroups.toString(),
                  icon: Icons.groups_outlined,
                  accent: AppColors.textOnNavy,
                  compact: true,
                  variant: DashboardCardVariant.navy,
                ),
                DashboardKpiCard(
                  label: 'Pending Proposals',
                  value: pendingProposals.toString(),
                  icon: Icons.pending_actions_outlined,
                  accent: AppColors.textOnNavy,
                  compact: true,
                  variant: DashboardCardVariant.navy,
                ),
                DashboardKpiCard(
                  label: 'Approved Proposals',
                  value: approvedProposals.toString(),
                  icon: Icons.check_circle_outline,
                  accent: AppColors.textOnNavy,
                  compact: true,
                  variant: DashboardCardVariant.navy,
                ),
                DashboardKpiCard(
                  label: 'Delayed Groups',
                  value: delayedGroups.toString(),
                  icon: Icons.warning_amber_outlined,
                  accent: AppColors.textOnNavy,
                  compact: true,
                  variant: DashboardCardVariant.navy,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _ActionPill(
                          label: 'Review Proposals',
                          icon: Icons.fact_check,
                          onTap: () {},
                        ),
                        _ActionPill(
                          label: 'View Groups',
                          icon: Icons.groups,
                          onTap: () {},
                        ),
                        _ActionPill(
                          label: 'Documents',
                          icon: Icons.folder,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SectionHint(
              text:
                  'Everything below is live from Firebase and updates in real time.',
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _SectionHint extends StatelessWidget {
  const _SectionHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _GroupsViewSection extends StatelessWidget {
  const _GroupsViewSection({required this.groupsRef, this.university});

  final DatabaseReference groupsRef;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: groupsRef.onValue,
      builder: (context, snapshot) {
        final data = snapshot.data?.snapshot.value;
        if (data is! Map) {
          return const Center(child: Text('No groups found.'));
        }

        final entries = Map<String, dynamic>.from(data);
        final groups = entries.entries.map((entry) {
          final value = Map<String, dynamic>.from(entry.value as Map);
          return _GroupRowData(
            code: entry.key,
            status: (value['status'] as String?) ?? 'Unknown',
            memberCount: ((value['members'] as Map?)?.length ?? 0),
            proposalStatus:
                (value['proposalStatus'] as String?) ?? 'Not Submitted',
            supervisorEmail:
                (value['supervisorEmail'] as String?) ?? '',
          );
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'All Groups in Session',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (groups.isEmpty)
              const Center(child: Text('No groups found.'))
            else
              ...groups.map(
                (group) => Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE6E6E6)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.selectedTile,
                      child: Text(group.code[0]),
                    ),
                    title: Text('Group ${group.code}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Members: ${group.memberCount}'),
                        Text('Proposal: ${group.proposalStatus}'),
                        Text('Status: ${group.status}'),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _ProposalsViewSection extends StatelessWidget {
  const _ProposalsViewSection({required this.groupsRef, this.university});

  final DatabaseReference groupsRef;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: groupsRef.onValue,
      builder: (context, snapshot) {
        final data = snapshot.data?.snapshot.value;
        if (data is! Map) {
          return const Center(child: Text('No proposals found.'));
        }

        final entries = Map<String, dynamic>.from(data);
        final proposals = entries.entries
            .map((entry) {
              final value =
                  Map<String, dynamic>.from(entry.value as Map);
              return _ProposalRowData(
                groupCode: entry.key,
                title:
                    (value['projectTitle'] as String?) ?? 'Untitled',
                status: (value['proposalStatus'] as String?) ??
                    'Not Submitted',
                supervisorApproved:
                    (value['supervisorApproved'] as bool?) ?? false,
              );
            })
            .where((p) => p.status == 'Pending Committee Review')
            .toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Proposals Pending Committee Review',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (proposals.isEmpty)
              const Center(child: Text('No pending proposals.'))
            else
              ...proposals.map(
                (proposal) => Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE6E6E6)),
                  ),
                  child: ListTile(
                    title: Text(proposal.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Group: ${proposal.groupCode}'),
                        Text(
                          'Supervisor Approved: ${proposal.supervisorApproved ? 'Yes' : 'No'}',
                        ),
                      ],
                    ),
                    trailing: FilledButton(
                      onPressed: () {},
                      child: const Text('Review'),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _DocumentsViewSection extends StatefulWidget {
  const _DocumentsViewSection({required this.documentsRef, this.university});

  final DatabaseReference documentsRef;
  final String? university;

  @override
  State<_DocumentsViewSection> createState() => _DocumentsViewSectionState();
}

class _DocumentsViewSectionState extends State<_DocumentsViewSection> {
  final DatabaseReference _byRoleRef = FirebaseDatabase.instance.ref('documents_by_role');
  String _role = 'Committee';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await FirebaseDatabase.instance.ref('users').child(user.uid).get();
    if (snap.exists && snap.value is Map) {
      final data = Map<String, dynamic>.from(snap.value as Map);
      if (mounted) setState(() => _role = (data['role'] as String?) ?? 'Committee');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: _byRoleRef.child(_role).onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data?.snapshot.value;
        if (data == null || data is! Map) {
          return const Center(child: Text('No shared documents available for your role.'));
        }

        final docs = Map<String, dynamic>.from(data).entries.map((e) {
          final val = Map<String, dynamic>.from(e.value as Map);
          return {
            'title': val['title'] ?? 'Untitled',
            'description': val['description'] ?? '',
            'fileName': val['fileName'] ?? '',
            'fileUrl': val['fileUrl'] ?? val['downloadUrl'] ?? '',
          };
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE6E6E6)),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.selectedTile,
                  child: Icon(Icons.description, color: AppColors.deepBlue),
                ),
                title: Text(doc['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(doc['description'].isNotEmpty ? doc['description'] : doc['fileName']),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new, color: AppColors.primaryBlue),
                  onPressed: () async {
                    if (doc['fileUrl'].isNotEmpty) {
                      final url = Uri.parse(doc['fileUrl']);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open document')),
                        );
                      }
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _EvaluationScheduleSection extends StatelessWidget {
  const _EvaluationScheduleSection({required this.groupsRef, this.university});

  final DatabaseReference groupsRef;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/committee-viva-scheduling'),
            icon: const Icon(Icons.add_task),
            label: const Text('Manage Viva Schedule'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<DatabaseEvent>(
            stream: groupsRef.onValue,
            builder: (context, snapshot) {
              final data = snapshot.data?.snapshot.value;
              if (data == null) {
                return const Center(child: Text('No groups found.'));
              }

              final groupsMap = Map<String, dynamic>.from(data as Map);
              final scheduledGroups = groupsMap.entries.where((e) {
                final val = e.value as Map;
                return val['vivaDate'] != null;
              }).toList();

              if (scheduledGroups.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No evaluation schedule found.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Text(
                    'Upcoming Evaluations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...scheduledGroups.map((entry) {
                    final groupData = Map<String, dynamic>.from(entry.value as Map);
                    final vivaDate = DateTime.parse(groupData['vivaDate'] as String);
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE6E6E6)),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.selectedTile,
                          child: Icon(Icons.event, color: AppColors.primaryBlue),
                        ),
                        title: Text('Group ${entry.key} - ${groupData['projectTitle'] ?? 'Untitled'}'),
                        subtitle: Text(
                          'Date: ${vivaDate.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepBlue),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _GroupProgressSection extends StatelessWidget {
  const _GroupProgressSection({required this.groupsRef, this.university});

  final DatabaseReference groupsRef;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: groupsRef.onValue,
      builder: (context, snapshot) {
        final data = snapshot.data?.snapshot.value;
        if (data is! Map) {
          return const Center(child: Text('No groups found.'));
        }

        final entries = Map<String, dynamic>.from(data);
        final allGroups = entries.entries.map((entry) {
          final value =
              Map<String, dynamic>.from(entry.value as Map);
          return _GroupProgressData(
            code: entry.key,
            projectTitle:
                (value['projectTitle'] as String?) ?? 'Untitled',
            status: (value['status'] as String?) ?? 'Unknown',
            proposalStatus: (value['proposalStatus'] as String?) ??
                'Not Submitted',
            memberCount: ((value['members'] as Map?)?.length ?? 0),
            isDelayed:
                (value['status'] as String?) == 'Delayed',
          );
        }).toList();

        final delayedGroups =
            allGroups.where((g) => g.isDelayed).toList();
        final activeGroups =
            allGroups.where((g) => !g.isDelayed).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Group Progress Tracking',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (delayedGroups.isNotEmpty) ...[
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE6E6E6)),
                ),
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Delayed Groups (${delayedGroups.length})',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.red[600],
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...delayedGroups.map(
                        (group) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Colors.red[100],
                              child: Text(group.code[0]),
                            ),
                            title: Text('Group ${group.code}'),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(group.projectTitle),
                                Text('Members: ${group.memberCount}'),
                              ],
                            ),
                            trailing: Chip(
                              label: const Text('Delayed'),
                              backgroundColor: Colors.red[100],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              'All Groups Progress',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            if (activeGroups.isEmpty && delayedGroups.isEmpty)
              const Center(child: Text('No groups found.'))
            else
              ...activeGroups.map(
                (group) => Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE6E6E6)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.selectedTile,
                      child: Text(group.code[0]),
                    ),
                    title: Text('Group ${group.code}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(group.projectTitle),
                        Text('Members: ${group.memberCount}'),
                        Row(
                          children: [
                            Chip(
                              label: Text(group.status),
                              backgroundColor: AppColors.selectedTile,
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(group.proposalStatus),
                              backgroundColor: AppColors.selectedTile,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

class _GroupRowData {
  const _GroupRowData({
    required this.code,
    required this.status,
    required this.memberCount,
    required this.proposalStatus,
    required this.supervisorEmail,
  });

  final String code;
  final String status;
  final int memberCount;
  final String proposalStatus;
  final String supervisorEmail;
}

class _ProposalRowData {
  const _ProposalRowData({
    required this.groupCode,
    required this.title,
    required this.status,
    required this.supervisorApproved,
  });

  final String groupCode;
  final String title;
  final String status;
  final bool supervisorApproved;
}

class _GroupProgressData {
  const _GroupProgressData({
    required this.code,
    required this.projectTitle,
    required this.status,
    required this.proposalStatus,
    required this.memberCount,
    required this.isDelayed,
  });

  final String code;
  final String projectTitle;
  final String status;
  final String proposalStatus;
  final int memberCount;
  final bool isDelayed;
}

// ---------------------------------------------------------------------------

enum _CommitteeSection {
  dashboard('Dashboard', Icons.dashboard),
  groups('All Groups', Icons.groups),
  proposals('Proposals', Icons.fact_check),
  reviews('Proposal Reviews', Icons.rate_review),
  viva('Viva Scheduling', Icons.event_available),
  documents('Documents', Icons.folder),
  progress('Progress', Icons.trending_up),
  schedule('Schedule', Icons.event),
  messages('Messages', Icons.message);

  const _CommitteeSection(this.title, this.icon);

  final String title;
  final IconData icon;
}

class _ProposalReviewSection extends StatelessWidget {
  const _ProposalReviewSection({required this.groupsRef, this.university});
  final DatabaseReference groupsRef;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Proposal Review Module (Scoped by University)', style: TextStyle(color: AppColors.textSecondary)));
  }
}

class _VivaSchedulingSection extends StatelessWidget {
  const _VivaSchedulingSection({required this.groupsRef, required this.evaluationRef, this.university});
  final DatabaseReference groupsRef;
  final DatabaseReference evaluationRef;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Viva Scheduling Module (Scoped by University)', style: TextStyle(color: AppColors.textSecondary)));
  }
}
