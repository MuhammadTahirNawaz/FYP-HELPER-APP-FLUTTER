import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/validators.dart';
import '../../services/crypto_service.dart';
import '../../theme/dashboard_styles.dart';
import '../../widgets/dashboard/dashboard_info_tile.dart';
import '../../widgets/dashboard/dashboard_kpi_card.dart';
import '../../widgets/dashboard/dashboard_welcome_header.dart';
import 'supervisor_nav_bar.dart';
import '../../utils/download_helper.dart';
import '../../theme/app_colors.dart';

enum _SupervisorSection {
  dashboard,
  groups,
  proposals,
  tasks,
  documents,
  comments,
  meetings,
  progress,
  marks,
  deadlines,
  sharedDocuments,
}

class SupervisorDashboardScreen extends StatefulWidget {
  const SupervisorDashboardScreen({super.key});

  static const String routeName = '/supervisor-dashboard';

  @override
  State<SupervisorDashboardScreen> createState() =>
      _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends State<SupervisorDashboardScreen> {
  _SupervisorSection _currentSection = _SupervisorSection.dashboard;
  late String _supervisorUid;
  String? _university;
  
  @override
  void initState() {
    super.initState();
    _supervisorUid = FirebaseAuth.instance.currentUser?.uid ?? '';
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

  String _sectionTitle(_SupervisorSection section) {
    switch (section) {
      case _SupervisorSection.dashboard: return 'Dashboard';
      case _SupervisorSection.groups: return 'Groups';
      case _SupervisorSection.proposals: return 'Proposals';
      case _SupervisorSection.tasks: return 'Tasks';
      case _SupervisorSection.documents: return 'Documents';
      case _SupervisorSection.comments: return 'Comments';
      case _SupervisorSection.meetings: return 'Meetings';
      case _SupervisorSection.progress: return 'Progress';
      case _SupervisorSection.marks: return 'Marks';
      case _SupervisorSection.deadlines: return 'Deadlines';
      case _SupervisorSection.sharedDocuments: return 'Shared Documents';
    }
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
            Text(_sectionTitle(_currentSection)),
            Text(
              'Supervisor workspace',
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
            onPressed: () => Navigator.of(context).pushNamed('/supervisor-settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _SupervisorDrawer(
        selected: _currentSection,
        onSelected: (section) {
          setState(() => _currentSection = section);
          Navigator.pop(context);
        },
      ),
      body: PopScope(
        canPop: _currentSection == _SupervisorSection.dashboard,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            setState(() => _currentSection = _SupervisorSection.dashboard);
          }
        },
        child: _buildSectionBody(),
      ),

      bottomNavigationBar: const SupervisorNavBar(selectedIndex: 0),
    );
  }

  Widget _buildSectionBody() {
    final groupsRef = FirebaseDatabase.instance.ref('groups');
    final supervisorRef =
        FirebaseDatabase.instance.ref('supervisor').child(_supervisorUid);

    switch (_currentSection) {
      case _SupervisorSection.dashboard:
        return _SupervisorDashboardHome(
          supervisorUid: _supervisorUid,
          groupsRef: groupsRef,
          supervisorRef: supervisorRef,
          university: _university,
        );
      case _SupervisorSection.groups:
        return _AssignedGroupsSection(
          supervisorUid: _supervisorUid,
          groupsRef: groupsRef,
          university: _university,
        );
      case _SupervisorSection.proposals:
        return _ProposalsReviewSection(
          supervisorUid: _supervisorUid,
          groupsRef: groupsRef,
          university: _university,
        );
      case _SupervisorSection.tasks:
        return _TasksSection(
          supervisorUid: _supervisorUid,
          groupsRef: groupsRef,
          university: _university,
        );
      case _SupervisorSection.documents:
        return _DocumentsReviewSection(
          supervisorUid: _supervisorUid,
          groupsRef: groupsRef,
          university: _university,
        );
      case _SupervisorSection.comments:
        return _CommentsSection(
          supervisorUid: _supervisorUid,
          groupsRef: groupsRef,
          university: _university,
        );
      case _SupervisorSection.meetings:
        return _MeetingRequestsSection(
          supervisorUid: _supervisorUid,
          groupsRef: groupsRef,
          university: _university,
        );
      case _SupervisorSection.progress:
        return _ProgressMonitoringSection(
          supervisorUid: _supervisorUid,
          groupsRef: groupsRef,
          university: _university,
        );
      case _SupervisorSection.marks:
        return _MarksRemarksSection(
          supervisorUid: _supervisorUid,
          groupsRef: groupsRef,
          university: _university,
        );
      case _SupervisorSection.deadlines:
        return _DeadlinesSection(
          supervisorUid: _supervisorUid,
          groupsRef: groupsRef,
          university: _university,
        );
      case _SupervisorSection.sharedDocuments:
        return _SharedDocumentsSection(university: _university);
    }
  }
}

class _SupervisorDrawer extends StatelessWidget {
  const _SupervisorDrawer({
    required this.selected,
    required this.onSelected,
  });

  final _SupervisorSection selected;
  final Function(_SupervisorSection) onSelected;

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
                      Icons.supervisor_account_outlined,
                      color: AppColors.navy,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Supervisor Portal',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Requests, approvals, tasks and feedback',
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
                  _drawerItem(context, Icons.dashboard_outlined, 'Dashboard',
                      _SupervisorSection.dashboard),
                  _drawerItem(
                      context, Icons.group_outlined, 'Groups', _SupervisorSection.groups),
                  _drawerItem(context, Icons.assignment_outlined, 'Proposals',
                      _SupervisorSection.proposals),
                  _drawerItem(
                      context, Icons.task_alt_outlined, 'Tasks', _SupervisorSection.tasks),
                  _drawerItem(context, Icons.description_outlined, 'Documents',
                      _SupervisorSection.documents),
                  _drawerItem(context, Icons.comment_outlined, 'Comments',
                      _SupervisorSection.comments),
                  _drawerItem(
                      context, Icons.event_outlined, 'Meetings', _SupervisorSection.meetings),
                  _drawerItem(context, Icons.trending_up, 'Progress',
                      _SupervisorSection.progress),
                  _drawerItem(context, Icons.grade_outlined, 'Marks', _SupervisorSection.marks),
                  _drawerItem(context, Icons.calendar_today_outlined, 'Deadlines',
                      _SupervisorSection.deadlines),
                  _drawerItem(context, Icons.folder_shared_outlined, 'Shared Documents',
                      _SupervisorSection.sharedDocuments),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label,
      _SupervisorSection section) {
    final isSelected = selected == section;
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      tileColor:
          isSelected ? AppColors.selectedTile : Colors.transparent,
      leading: Icon(icon,
          color: isSelected ? AppColors.navy : AppColors.textSecondary),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onTap: () => onSelected(section),
    );
  }
}

class _SupervisorDashboardHome extends StatelessWidget {
  const _SupervisorDashboardHome({
    required this.supervisorUid,
    required this.groupsRef,
    required this.supervisorRef,
    this.university,
  });

  final String supervisorUid;
  final DatabaseReference groupsRef;
  final DatabaseReference supervisorRef;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: groupsRef.onValue,
      builder: (context, groupsSnapshot) {
        final allGroups = groupsSnapshot.data?.snapshot.value is Map
            ? Map<String, dynamic>.from(groupsSnapshot.data!.snapshot.value as Map)
            : {};
            
        // Filter by University
        final filteredGroups = university == null 
          ? allGroups 
          : Map.fromEntries(allGroups.entries.where((e) => (e.value as Map)['university'] == university));

        final myGroups = filteredGroups.values.where((g) => g is Map && g['supervisorId'] == supervisorUid).toList();
        final assignedGroupsCount = myGroups.length;

        return StreamBuilder<DatabaseEvent>(
          stream: supervisorRef.child('requests').onValue,
          builder: (context, requestsSnapshot) {
            final requests = requestsSnapshot.data?.snapshot.value is Map
                ? Map<String, dynamic>.from(requestsSnapshot.data!.snapshot.value as Map)
                : {};
            final pendingRequestsCount = requests.values.where((r) => r is Map && r['status'] == 'Pending').length;

            int activeTasksCount = 0;
            int pendingGradesCount = 0;
            for (final g in myGroups) {
              if (g is Map) {
                if (g['tasks'] is Map) {
                  activeTasksCount += (g['tasks'] as Map).length;
                }
                if (g['marks'] == null) {
                  pendingGradesCount++;
                }
              }
            }

            final scheduledVivas = myGroups.where((g) => g is Map && g['vivaDate'] != null).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                DashboardWelcomeHeader(
                  greeting: 'Welcome back',
                  name: 'Supervisor',
                  subtitle:
                      'Keep requests, proposals, tasks, and marks under control in real time.',
                  accentColor: AppColors.navy,
                  onLightBackground: true,
                  avatar: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.surfaceMuted,
                    child: const Icon(
                      Icons.supervisor_account_outlined,
                      color: AppColors.navy,
                      size: 28,
                    ),
                  ),
                ),
                if (scheduledVivas.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'UPCOMING VIVAS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...scheduledVivas.map((group) {
                    final groupData = Map<String, dynamic>.from(group as Map);
                    final vivaDate = DateTime.parse(groupData['vivaDate'] as String);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DashboardInfoTile(
                        label: groupData['projectTitle'] ?? 'Untitled',
                        value: vivaDate.toLocal().toString().split(' ')[0],
                        icon: Icons.event_outlined,
                        accent: AppColors.navy,
                        variant: DashboardCardVariant.light,
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                  children: [
                    DashboardKpiCard(
                      label: 'Assigned Groups',
                      value: assignedGroupsCount.toString(),
                      icon: Icons.groups_outlined,
                      accent: AppColors.textOnNavy,
                      compact: true,
                      variant: DashboardCardVariant.navy,
                    ),
                    DashboardKpiCard(
                      label: 'Pending Requests',
                      value: pendingRequestsCount.toString(),
                      icon: Icons.pending_actions_outlined,
                      accent: AppColors.textOnNavy,
                      compact: true,
                      variant: DashboardCardVariant.navy,
                    ),
                    DashboardKpiCard(
                      label: 'Active Tasks',
                      value: activeTasksCount.toString(),
                      icon: Icons.assignment_turned_in_outlined,
                      accent: AppColors.textOnNavy,
                      compact: true,
                      variant: DashboardCardVariant.navy,
                    ),
                    DashboardKpiCard(
                      label: 'Pending Grades',
                      value: pendingGradesCount.toString(),
                      icon: Icons.grade_outlined,
                      accent: AppColors.textOnNavy,
                      compact: true,
                      variant: DashboardCardVariant.navy,
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AssignedGroupsSection extends StatelessWidget {
  const _AssignedGroupsSection(
      {required this.supervisorUid, required this.groupsRef, this.university});

  final String supervisorUid;
  final DatabaseReference groupsRef;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: groupsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data?.snapshot.value;
        if (data is! Map) {
          return const Center(child: Text('No groups assigned.'));
        }
        final allEntries = Map<String, dynamic>.from(data);
        
        // Filter by University
        final entries = university == null 
          ? allEntries 
          : Map.fromEntries(allEntries.entries.where((e) => (e.value as Map)['university'] == university));

        final assignedGroups = entries.entries
            .where((e) =>
                e.value is Map &&
                ((e.value as Map)['supervisorId'] == supervisorUid))
            .map((e) {
              final groupData = Map<String, dynamic>.from(e.value as Map);
              final membersMap = groupData['members'] is Map ? Map<String, dynamic>.from(groupData['members'] as Map) : {};

              return _GroupItem(
                code: e.key,
                projectTitle: groupData['projectTitle'] ?? 'No Title',
                status: groupData['status'] ?? 'Active',
                memberCount: membersMap.length,
                memberUids: membersMap.keys.cast<String>().toList(),
              );
            })
            .toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Assigned Groups',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...assignedGroups.map((g) => _GroupItemCard(group: g)),
          ],
        );
      },
    );
  }
}

class _GroupItem {
  _GroupItem({
    required this.code,
    required this.projectTitle,
    required this.status,
    required this.memberCount,
    required this.memberUids,
  });

  final String code;
  final String projectTitle;
  final String status;
  final int memberCount;
  final List<String> memberUids;
}

class _GroupItemCard extends StatelessWidget {
  const _GroupItemCard({required this.group});

  final _GroupItem group;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showGroupDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.projectTitle, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Code: ${group.code}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Chip(
                    label: Text(group.status, style: const TextStyle(fontSize: 10)),
                    backgroundColor: AppColors.chipBg,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Members: ${group.memberCount}', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  void _showGroupDetails(BuildContext context) {
    final usersRef = FirebaseDatabase.instance.ref('users');
    final crypto = CryptoService();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.projectTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('Group Code: ${group.code}', style: const TextStyle(color: AppColors.infoBlue, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.chipBg, borderRadius: BorderRadius.circular(20)),
                    child: Text(group.status, style: const TextStyle(color: AppColors.infoIndigo, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Divider(height: 40),
              const Text('Group Members', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              ...group.memberUids.map((uid) => FutureBuilder<DataSnapshot>(
                    future: usersRef.child(uid).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: LinearProgressIndicator(),
                        );
                      }
                      final data = snapshot.data?.value as Map?;
                      if (data == null) {
                        return const ListTile(title: Text('Unknown User'), leading: Icon(Icons.error_outline));
                      }

                      final name = data['fullName'] ?? 'No Name';
                      final studentId = data['studentId'] ?? 'No ID';
                      final encryptedPhone = data['phoneEncrypted'] as String?;
                      String? phone;
                      if (encryptedPhone != null) {
                        try {
                          phone = crypto.decryptText(encryptedPhone);
                        } catch (_) {
                          phone = 'Encryption Error';
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.cardSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSoft),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.infoBlue,
                            child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ID: $studentId', style: const TextStyle(fontSize: 12)),
                              if (phone != null)
                                Text('Phone: $phone', style: const TextStyle(fontSize: 12, color: AppColors.infoBlue, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          trailing: phone != null
                              ? IconButton(
                                  icon: const Icon(Icons.phone_outlined, size: 20),
                                  onPressed: () async {
                                    final url = Uri.parse('tel:$phone');
                                    if (await canLaunchUrl(url)) await launchUrl(url);
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  )),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProposalsReviewSection extends StatelessWidget {
  const _ProposalsReviewSection(
      {required this.supervisorUid, required this.groupsRef, this.university});

  final String supervisorUid;
  final DatabaseReference groupsRef;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: groupsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data?.snapshot.value;
        if (data is! Map) {
          return const Center(child: Text('No proposals found.'));
        }
        final allEntries = Map<String, dynamic>.from(data);
        
        // Filter by University
        final entries = university == null 
          ? allEntries 
          : Map.fromEntries(allEntries.entries.where((e) => (e.value as Map)['university'] == university));

        final proposals = entries.entries
            .where((e) =>
                e.value is Map &&
                ((e.value as Map)['supervisorId'] == supervisorUid))
            .map((e) => _ProposalItem(
                  groupCode: e.key,
                  projectTitle: (e.value is Map
                      ? ((e.value as Map)['projectTitle'] as String?) ?? ''
                      : ''),
                  description: (e.value is Map
                      ? ((e.value as Map)['description'] as String?) ?? ''
                      : ''),
                  proposalStatus: (e.value is Map
                      ? ((e.value as Map)['proposalStatus'] as String?) ?? ''
                      : ''),
                  proposalUrl: (e.value is Map
                      ? ((e.value as Map)['proposalUrl'] as String?)
                      : null),
                  marks: (e.value is Map
                      ? (e.value as Map)['marks']
                      : null),
                  remarks: (e.value is Map
                      ? (e.value as Map)['remarks']
                      : null),
                ))
            .toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Proposals Review',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...proposals.map(
              (p) => _ProposalCard(proposal: p, groupsRef: groupsRef),
            ),
          ],
        );
      },
    );
  }
}

class _ProposalItem {
  _ProposalItem({
    required this.groupCode,
    required this.projectTitle,
    required this.description,
    required this.proposalStatus,
    this.proposalUrl,
    this.marks,
    this.remarks,
  });

  final String groupCode;
  final String projectTitle;
  final String description;
  final String proposalStatus;
  final String? proposalUrl;
  final dynamic marks;
  final String? remarks;
}

class _ProposalCard extends StatefulWidget {
  const _ProposalCard({required this.proposal, required this.groupsRef});

  final _ProposalItem proposal;
  final DatabaseReference groupsRef;

  @override
  State<_ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends State<_ProposalCard> {
  final _formKey = GlobalKey<FormState>();
  bool _isUpdating = false;
  late TextEditingController _marksController;
  late TextEditingController _remarksController;
  @override
  void initState() {
    super.initState();
    _marksController = TextEditingController(text: widget.proposal.marks?.toString() ?? '');
    _remarksController = TextEditingController(text: widget.proposal.remarks ?? '');
  }

  @override
  void didUpdateWidget(_ProposalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.proposal.marks != oldWidget.proposal.marks) {
      _marksController.text = widget.proposal.marks?.toString() ?? '';
    }
    if (widget.proposal.remarks != oldWidget.proposal.remarks) {
      _remarksController.text = widget.proposal.remarks ?? '';
    }
  }

  @override
  void dispose() {
    _marksController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _viewDocument() async {
    if (widget.proposal.proposalUrl != null) {
      final url = Uri.parse(widget.proposal.proposalUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open proposal document.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSubmitted = widget.proposal.proposalStatus == 'Submitted';
    final bool isApproved = widget.proposal.proposalStatus == 'Approved by Supervisor';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(widget.proposal.projectTitle.isEmpty ? 'Untitled Project' : widget.proposal.projectTitle),
        subtitle: Chip(
          label: Text(widget.proposal.proposalStatus),
          backgroundColor: _getStatusColor(),
          labelStyle:
              const TextStyle(color: Colors.white, fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.proposal.proposalUrl != null) ...[
                  ElevatedButton.icon(
                    onPressed: _viewDocument,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('View Proposal Document'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text('Description:',
                    style: Theme.of(context).textTheme.titleSmall),
                Text(widget.proposal.description.isEmpty ? 'No description provided.' : widget.proposal.description,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                TextFormField(
                  controller: _marksController,
                  keyboardType: TextInputType.number,
                  validator: (v) => AppValidators.required(v, fieldName: 'Marks'),
                  decoration: const InputDecoration(
                    labelText: 'Proposal Marks (0-100)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.grade),
                  ),
                ),
                TextFormField(
                  controller: _remarksController,
                  maxLines: 2,
                  validator: (v) => AppValidators.description(v, fieldName: 'Feedback'),
                  decoration: const InputDecoration(
                    labelText: 'Feedback / Remarks',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.comment),
                  ),
                ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (isSubmitted)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isUpdating
                              ? null
                              : () => _updateProposal(
                                  'Rejected by Supervisor'),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: _isUpdating
                              ? null
                              : () => _updateProposal(
                                  'Approved by Supervisor'),
                          child: _isUpdating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))
                              : const Text('Approve'),
                        ),
                      ),
                    ],
                  )
                else if (isApproved)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isUpdating ? null : () => _updateProposal('Approved by Supervisor'),
                      icon: const Icon(Icons.save),
                      label: const Text('Update Marks'),
                      style: FilledButton.styleFrom(backgroundColor: Colors.green[700]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.proposal.proposalStatus) {
      case 'Submitted':
        return Colors.orange;
      case 'Approved by Supervisor':
        return Colors.green;
      case 'Rejected by Supervisor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateProposal(String status) async {
    if (!mounted) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isUpdating = true);
    try {
      final marks = int.tryParse(_marksController.text) ?? 0;
      await widget.groupsRef
          .child(widget.proposal.groupCode)
          .update({
        'proposalStatus': status,
        'supervisorApproved': status == 'Approved by Supervisor',
        'marks': status == 'Approved by Supervisor' ? marks : widget.proposal.marks,
        'remarks': _remarksController.text.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Proposal $status')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }
}

class _TasksSection extends StatelessWidget {
  const _TasksSection({required this.supervisorUid, required this.groupsRef, this.university});

  final String supervisorUid;
  final DatabaseReference groupsRef;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: groupsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data?.snapshot.value;
        if (data is! Map) return const Center(child: Text('No groups found.'));

        final allEntries = Map<String, dynamic>.from(data);
        
        // Filter by University
        final entries = university == null 
          ? allEntries 
          : Map.fromEntries(allEntries.entries.where((e) => (e.value as Map)['university'] == university));

        final myGroups = entries.entries.where((e) {
          final val = e.value;
          return val is Map && val['supervisorId'] == supervisorUid;
        }).toList();

        final allTasks = <_TaskItem>[];
        for (final group in myGroups) {
          final groupData = group.value as Map;
          if (groupData['tasks'] is Map) {
            final tasks = Map<String, dynamic>.from(groupData['tasks']);
            tasks.forEach((id, val) {
              if (val is Map) {
                allTasks.add(_TaskItem(
                  id: id,
                  groupCode: group.key,
                  title: val['title'] ?? '',
                  description: val['description'] ?? '',
                  deadline: val['deadline'] ?? '',
                  deadlineTime: val['deadlineTime'] ?? '',
                  status: val['status'] ?? 'Pending',
                  submission: val['submission'],
                  memberMarks: val['memberMarks'] is Map ? Map<String, dynamic>.from(val['memberMarks'] as Map) : null,
                ));
              }
            });
          }
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tasks & Milestones', style: Theme.of(context).textTheme.titleMedium),
                if (myGroups.isNotEmpty)
                  FilledButton.icon(
                    onPressed: () => _showCreateTaskDialog(context, myGroups),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (allTasks.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No tasks created yet.'))),
            ...allTasks.map((t) => _TaskCard(task: t, groupsRef: groupsRef)),
          ],
        );
      },
    );
  }

  void _showCreateTaskDialog(BuildContext context, List<MapEntry<String, dynamic>> groups) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final deadlineController = TextEditingController();
    final timeController = TextEditingController();
    String? selectedGroup = groups.first.key;
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Group Task'),
          content: SingleChildScrollView(
            child: Form(
              key: dialogFormKey,
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedGroup,
                  items: groups.map((g) => DropdownMenuItem(value: g.key, child: Text(g.key))).toList(),
                  onChanged: (v) => setDialogState(() => selectedGroup = v),
                  decoration: const InputDecoration(labelText: 'Target Group'),
                ),
                TextFormField(controller: titleController, validator: AppValidators.projectTitle, style: const TextStyle(fontWeight: FontWeight.normal), decoration: const InputDecoration(labelText: 'Task Title')),
                TextFormField(controller: descController, validator: AppValidators.description, style: const TextStyle(fontWeight: FontWeight.normal), decoration: const InputDecoration(labelText: 'Description')),
                TextFormField(
                  controller: deadlineController,
                  validator: (v) => AppValidators.required(v, fieldName: 'Deadline date'),
                  style: const TextStyle(fontWeight: FontWeight.normal),
                  decoration: const InputDecoration(labelText: 'Deadline Date', hintText: 'YYYY-MM-DD'),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) {
                      setDialogState(() => deadlineController.text = date.toString().split(' ')[0]);
                    }
                  },
                ),
                TextFormField(
                  controller: timeController,
                  validator: (v) => AppValidators.required(v, fieldName: 'Deadline time'),
                  style: const TextStyle(fontWeight: FontWeight.normal),
                  decoration: const InputDecoration(labelText: 'Deadline Time', hintText: 'HH:MM'),
                  readOnly: true,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      if (context.mounted) {
                        setDialogState(() => timeController.text = time.format(context));
                      }
                    }
                  },
                ),
              ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (!(dialogFormKey.currentState?.validate() ?? false)) return;
                if (selectedGroup == null) return;
                await groupsRef.child(selectedGroup!).child('tasks').push().set({
                  'title': titleController.text,
                  'description': descController.text,
                  'deadline': deadlineController.text,
                  'deadlineTime': timeController.text,
                  'status': 'Pending',
                  'createdAt': DateTime.now().toIso8601String(),
                });
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskItem {
  _TaskItem({
    required this.id,
    required this.groupCode,
    required this.title,
    required this.description,
    required this.deadline,
    required this.deadlineTime,
    required this.status,
    this.submission,
    this.memberMarks,
  });

  final String id;
  final String groupCode;
  final String title;
  final String description;
  final String deadline;
  final String deadlineTime;
  final String status;
  final String? submission;
  final Map<String, dynamic>? memberMarks;
}

class _TaskCard extends StatefulWidget {
  const _TaskCard({required this.task, required this.groupsRef});

  final _TaskItem task;
  final DatabaseReference groupsRef;

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task.status == 'Completed';
    final isVerified = widget.task.status == 'Verified';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isVerified ? Colors.green[50] : (isCompleted ? Colors.orange[50] : Colors.grey[50]),
          child: Icon(
            isVerified ? Icons.check_circle : (isCompleted ? Icons.pending : Icons.assignment_outlined),
            color: isVerified ? Colors.green : (isCompleted ? Colors.orange : Colors.grey),
          ),
        ),
        title: Text(widget.task.title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.black)),
        subtitle: Text('Group: ${widget.task.groupCode} • Due: ${widget.task.deadline} ${widget.task.deadlineTime}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(widget.task.description, style: const TextStyle(fontSize: 13)),
                const Divider(height: 24),
                if (widget.task.submission != null) ...[
                  const Text('Group Submission:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.panelSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          widget.task.submission!,
                          style: const TextStyle(fontSize: 13, color: Colors.black),
                        ),
                        if (widget.task.submission!.trim().toLowerCase().startsWith('http')) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final url = Uri.parse(widget.task.submission!.trim());
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                }
                              },
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text('Open Submission Link'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.black),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                const Text('Individual Grading:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                FutureBuilder<DataSnapshot>(
                  future: widget.groupsRef.child(widget.task.groupCode).child('members').get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    final members = snapshot.data?.value as Map?;
                    if (members == null) return const Text('No members found.');

                    final memberUids = members.keys.cast<String>().toList();
                    final usersRef = FirebaseDatabase.instance.ref('users');

                    return Column(
                      children: memberUids.map((uid) {
                        if (!_controllers.containsKey(uid)) {
                          _controllers[uid] = TextEditingController(text: widget.task.memberMarks?[uid]?.toString() ?? '');
                        }
                        return FutureBuilder<DataSnapshot>(
                          future: usersRef.child(uid).get(),
                          builder: (context, userSnap) {
                            String displayName = 'Loading...';
                            String studentId = '...';
                            if (userSnap.hasData && userSnap.data!.value is Map) {
                              final userData = userSnap.data!.value as Map;
                              displayName = userData['fullName'] ?? 'No Name';
                              studentId = userData['studentId'] ?? 'No ID';
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                        Text('ID: $studentId', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: _controllers[uid],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        hintText: '0-100',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (isCompleted || isVerified)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _updateTaskStatus('Verified'),
                      style: FilledButton.styleFrom(backgroundColor: Colors.green),
                      child: Text(isVerified ? 'Update All Marks' : 'Verify & Mark All'),
                    ),
                  )
                else
                  Text('Status: ${widget.task.status}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateTaskStatus(String status) async {
    final Map<String, int> marksMap = {};
    _controllers.forEach((uid, controller) {
      if (controller.text.isNotEmpty) {
        marksMap[uid] = int.tryParse(controller.text) ?? 0;
      }
    });

    await widget.groupsRef.child(widget.task.groupCode).child('tasks').child(widget.task.id).update({
      'status': status,
      'memberMarks': marksMap,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marks updated successfully')));
    }
  }
}

class _DocumentsReviewSection extends StatelessWidget {
  const _DocumentsReviewSection({required this.supervisorUid, required this.groupsRef, this.university});

  final String supervisorUid;
  final DatabaseReference groupsRef;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: groupsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data?.snapshot.value;
        if (data is! Map) return const Center(child: Text('No documents found.'));

        final allEntries = Map<String, dynamic>.from(data);
        
        // Filter by University
        final entries = university == null 
          ? allEntries 
          : Map.fromEntries(allEntries.entries.where((e) => (e.value as Map)['university'] == university));

        final myGroups = entries.entries.where((e) {
          final val = e.value;
          return val is Map && val['supervisorId'] == supervisorUid;
        }).toList();

        final allDocs = <_DocItem>[];
        for (final group in myGroups) {
          final groupData = group.value as Map;
          if (groupData['documents'] is Map) {
            final docs = Map<String, dynamic>.from(groupData['documents']);
            docs.forEach((id, val) {
              if (val is Map) {
                allDocs.add(_DocItem(
                  id: id,
                  groupCode: group.key,
                  title: val['title'] ?? 'Untitled',
                  description: val['description'] ?? '',
                  type: val['type'] ?? 'File',
                  downloadUrl: val['downloadUrl'],
                ));
              }
            });
          }
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Documents Review', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            if (allDocs.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No documents uploaded by groups yet.'))),
            ...allDocs.map((d) => _DocCard(doc: d)),
          ],
        );
      },
    );
  }
}

class _DocItem {
  _DocItem({
    required this.id,
    required this.groupCode,
    required this.title,
    required this.description,
    required this.type,
    this.downloadUrl,
  });

  final String id;
  final String groupCode;
  final String title;
  final String description;
  final String type;
  final String? downloadUrl;
}

class _DocCard extends StatelessWidget {
  const _DocCard({required this.doc});

  final _DocItem doc;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(doc.title),
        subtitle: Text('${doc.groupCode} • ${doc.type}'),
        trailing: doc.downloadUrl != null
            ? IconButton(
                icon: Icon(Icons.download, color: Theme.of(context).colorScheme.primary),
                onPressed: () async {
                  final uri = Uri.parse(doc.downloadUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open document')),
                    );
                  }
                },
              )
            : null,
      ),
    );
  }
}

class _CommentsSection extends StatelessWidget {
  const _CommentsSection({required this.supervisorUid, required this.groupsRef, this.university});

  final String supervisorUid;
  final DatabaseReference groupsRef;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: groupsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data?.snapshot.value;
        if (data is! Map) return const Center(child: Text('No feedback found.'));

        final myGroupsFeedback = <Map<String, dynamic>>[];
        final allEntries = Map<String, dynamic>.from(data);
        
        // Filter by University
        final entries = university == null 
          ? allEntries 
          : Map.fromEntries(allEntries.entries.where((e) => (e.value as Map)['university'] == university));
        
        entries.forEach((groupCode, groupData) {
          if (groupData is Map && groupData['supervisorId'] == supervisorUid) {
            final title = groupData['projectTitle'] ?? 'Untitled Project';
            // Add proposal remarks if exist
            if (groupData['remarks'] != null && groupData['remarks'].toString().isNotEmpty) {
              myGroupsFeedback.add({
                'source': 'Proposal',
                'projectTitle': title,
                'content': groupData['remarks'],
                'groupCode': groupCode,
              });
            }
          }
        });

        if (myGroupsFeedback.isEmpty) {
          return const Center(child: Text('No feedback or remarks have been sent yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: myGroupsFeedback.length,
          itemBuilder: (context, index) {
            final fb = myGroupsFeedback[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.selectedTile,
                  child: Icon(fb['source'] == 'Proposal' ? Icons.description : Icons.assignment, size: 20),
                ),
                title: Text(fb['projectTitle'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(fb['content'], style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text('Type: ${fb['source']} | Group: ${fb['groupCode']}', style: const TextStyle(fontSize: 11)),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}

class _MeetingRequestsSection extends StatelessWidget {
  const _MeetingRequestsSection({required this.supervisorUid, required this.groupsRef, this.university});

  final String supervisorUid;
  final DatabaseReference groupsRef;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: groupsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data?.snapshot.value;
        if (data is! Map) return const Center(child: Text('No groups found.'));

        final allEntries = Map<String, dynamic>.from(data);
        
        // Filter by University
        final entries = university == null 
          ? allEntries 
          : Map.fromEntries(allEntries.entries.where((e) => (e.value as Map)['university'] == university));

        final myGroups = entries.entries.where((e) {
          final val = e.value;
          return val is Map && val['supervisorId'] == supervisorUid;
        }).toList();

        final allMeetings = <_MeetingItem>[];
        for (final group in myGroups) {
          final groupData = group.value as Map;
          if (groupData['meetings'] is Map) {
            final meetings = Map<String, dynamic>.from(groupData['meetings']);
            meetings.forEach((id, val) {
              if (val is Map) {
                allMeetings.add(_MeetingItem(
                  id: id,
                  groupCode: group.key,
                  requestedDate: val['requestedDate'] ?? '',
                  requestedTime: val['requestedTime'] ?? '',
                  duration: val['duration'] ?? '',
                  status: val['status'] ?? 'Pending',
                  meetingLink: val['meetingLink'] ?? 'https://meet.google.com/new',
                ));
              }
            });
          }
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Meeting Requests', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            if (allMeetings.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No meeting requests yet.'))),
            ...allMeetings.map((m) => _MeetingCard(meeting: m, groupsRef: groupsRef)),
          ],
        );
      },
    );
  }
}

class _MeetingItem {
  _MeetingItem({
    required this.id,
    required this.groupCode,
    required this.requestedDate,
    required this.requestedTime,
    required this.duration,
    required this.status,
    required this.meetingLink,
  });

  final String id;
  final String groupCode;
  final String requestedDate;
  final String requestedTime;
  final String duration;
  final String status;
  final String meetingLink;
}

class _MeetingCard extends StatelessWidget {
  const _MeetingCard({required this.meeting, required this.groupsRef});

  final _MeetingItem meeting;
  final DatabaseReference groupsRef;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Group: ${meeting.groupCode}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.black)),
                      const SizedBox(height: 4),
                      Text('${meeting.requestedDate} at ${meeting.requestedTime}', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                      Text('Duration: ${meeting.duration}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: meeting.status == 'Pending' ? Colors.orange[50] : (meeting.status == 'Approved' ? Colors.green[50] : Colors.red[50]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    meeting.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: meeting.status == 'Pending' ? Colors.orange[700] : (meeting.status == 'Approved' ? Colors.green[700] : Colors.red[700]),
                    ),
                  ),
                ),
              ],
            ),
            if (meeting.status == 'Pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(context, 'Rejected'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _updateStatus(context, 'Approved'),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
            if (meeting.status == 'Approved') ...[
              const Divider(height: 32),
              if (_isDeadlinePassed(meeting.requestedDate, meeting.requestedTime))
                const Center(child: Text('Meeting link expired.', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)))
              else
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(meeting.meetingLink);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    icon: const Icon(Icons.videocam),
                    label: const Text('Join Video Meeting'),
                    style: FilledButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isDeadlinePassed(String? dateStr, String? timeStr) {
    if (dateStr == null || dateStr.isEmpty) return false;
    try {
      final date = DateTime.parse(dateStr);
      int hour = 23;
      int minute = 59;

      if (timeStr != null && timeStr.isNotEmpty) {
        final parts = timeStr.trim().split(' ');
        final timeParts = parts[0].split(':');
        hour = int.parse(timeParts[0]);
        minute = int.parse(timeParts[1]);
        if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour < 12) {
          hour += 12;
        } else if (parts.length > 1 && parts[1].toUpperCase() == 'AM' && hour == 12) {
          hour = 0;
        }
      }

      final deadline = DateTime(date.year, date.month, date.day, hour, minute);
      // 2 hours buffer for meetings
      return DateTime.now().isAfter(deadline.add(const Duration(hours: 2)));
    } catch (e) {
      return false;
    }
  }

  void _updateStatus(BuildContext context, String status) async {
    await groupsRef.child(meeting.groupCode).child('meetings').child(meeting.id).update({
      'status': status,
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Meeting $status')));
    }
  }
}

class _ProgressMonitoringSection extends StatelessWidget {
  const _ProgressMonitoringSection({required this.supervisorUid, required this.groupsRef, this.university});

  final String supervisorUid;
  final DatabaseReference groupsRef;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: groupsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data?.snapshot.value;
        if (data is! Map) return const Center(child: Text('No groups found.'));

        final allEntries = Map<String, dynamic>.from(data);
        
        // Filter by University
        final entries = university == null 
          ? allEntries 
          : Map.fromEntries(allEntries.entries.where((e) => (e.value as Map)['university'] == university));

        final myGroups = entries.entries.where((e) {
          final val = e.value;
          return val is Map && val['supervisorId'] == supervisorUid;
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Progress Monitoring', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            if (myGroups.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No assigned groups.'))),
            ...myGroups.map((g) {
              final groupData = g.value as Map;
              final progress = groupData['progressPercentage'] ?? 0;
              return _ProgressCard(
                groupCode: g.key,
                projectTitle: groupData['projectTitle'] ?? 'No Title',
                percentage: progress is int ? progress : 0,
              );
            }),
          ],
        );
      },
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.groupCode, required this.projectTitle, required this.percentage});

  final String groupCode;
  final String projectTitle;
  final int percentage;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(projectTitle, style: Theme.of(context).textTheme.titleSmall),
            Text('Group: $groupCode', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text('$percentage% Complete', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MarksRemarksSection extends StatefulWidget {
  const _MarksRemarksSection({required this.supervisorUid, required this.groupsRef, this.university});

  final String supervisorUid;
  final DatabaseReference groupsRef;
  final String? university;

  @override
  State<_MarksRemarksSection> createState() => _MarksRemarksSectionState();
}

class _MarksRemarksSectionState extends State<_MarksRemarksSection> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: widget.groupsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data?.snapshot.value;
        if (data is! Map) return const Center(child: Text('No groups found.'));

        final allEntries = Map<String, dynamic>.from(data);
        
        // Filter by University
        final entries = widget.university == null 
          ? allEntries 
          : Map.fromEntries(allEntries.entries.where((e) => (e.value as Map)['university'] == widget.university));

        final myGroups = entries.entries.where((e) {
          final val = e.value;
          return val is Map && val['supervisorId'] == widget.supervisorUid;
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(child: Text('Marks & Remarks', style: Theme.of(context).textTheme.titleMedium)),
                IconButton(
                  tooltip: 'Download marks CSV',
                  icon: Icon(Icons.download, color: Theme.of(context).colorScheme.primary),
                  onPressed: () async {
                    await _downloadCsv(data as Map?);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (myGroups.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No assigned groups.'))),
            ...myGroups.map((g) {
              final groupData = g.value as Map;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(groupData['projectTitle'] ?? 'No Title', style: Theme.of(context).textTheme.titleSmall),
                                Text('Group: ${g.key}', style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                            onPressed: () => _showMarkDialog(context, g.key, groupData['marks'], groupData['remarks']),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Current Marks: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${groupData['marks'] ?? 'Not set'}/100'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Remarks:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(groupData['remarks'] ?? 'No remarks yet.'),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  void _showMarkDialog(BuildContext context, String groupCode, dynamic currentMarks, dynamic currentRemarks) {
    final marksController = TextEditingController(text: currentMarks?.toString() ?? '');
    final remarksController = TextEditingController(text: currentRemarks?.toString() ?? '');
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Grade Group: $groupCode'),
        content: SingleChildScrollView(
          child: Form(
            key: dialogFormKey,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: marksController,
                validator: (v) => AppValidators.required(v, fieldName: 'Marks'),
                style: const TextStyle(fontWeight: FontWeight.normal),
                decoration: const InputDecoration(labelText: 'Marks (0-100)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: remarksController,
                validator: (v) => AppValidators.description(v, fieldName: 'Remarks'),
                style: const TextStyle(fontWeight: FontWeight.normal),
                decoration: const InputDecoration(labelText: 'Remarks'),
                maxLines: 3,
              ),
            ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!(dialogFormKey.currentState?.validate() ?? false)) return;
              await widget.groupsRef.child(groupCode).update({
                'marks': int.tryParse(marksController.text) ?? 0,
                'remarks': remarksController.text,
              });
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadCsv(Map? allGroupsData) async {
    // Lazy import of helper to avoid unused import warnings
    // Build CSV only for groups supervised by current user
    if (allGroupsData == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No groups data available')));
      return;
    }

    final myGroups = Map<String, dynamic>.from(allGroupsData).entries.where((e) {
      final val = e.value;
      return val is Map && val['supervisorId'] == widget.supervisorUid;
    }).toList();

    final rows = <List<String>>[];
    rows.add(['GroupCode', 'ProjectTitle', 'MemberNames', 'MemberMarks', 'Marks', 'Remarks']);

    // gather all member UIDs across the groups so we can fetch their names in batch
    final usersRef = FirebaseDatabase.instance.ref('users');
    final allMemberUids = <String>{};
    for (final g in myGroups) {
      final data = g.value as Map;
      if (data['members'] is Map) {
        allMemberUids.addAll((data['members'] as Map).keys.cast<String>());
      }
      if (data['memberMarks'] is Map) {
        allMemberUids.addAll((data['memberMarks'] as Map).keys.cast<String>());
      }
    }

    // fetch names for each uid
    final Map<String, String> uidToName = {};
    for (final uid in allMemberUids) {
      try {
        final snap = await usersRef.child(uid).get();
        if (snap.exists && snap.value is Map) {
          final m = Map<String, dynamic>.from(snap.value as Map);
          uidToName[uid] = (m['fullName'] ?? uid).toString();
        } else {
          uidToName[uid] = uid;
        }
      } catch (_) {
        uidToName[uid] = uid;
      }
    }

    for (final g in myGroups) {
      final key = g.key;
      final data = Map<String, dynamic>.from(g.value as Map);
      final title = (data['projectTitle'] ?? '').toString().replaceAll('\n', ' ');
      final marks = data['marks']?.toString() ?? '';
      final remarks = data['remarks']?.toString() ?? '';

      final membersMap = data['members'] is Map ? Map<String, dynamic>.from(data['members'] as Map) : {};
      final memberMarksMap = data['memberMarks'] is Map ? Map<String, dynamic>.from(data['memberMarks'] as Map) : {};

      final memberUids = membersMap.keys.cast<String>().toList();

      final memberNames = memberUids.map((uid) {
        final name = uidToName[uid] ?? uid;
        final sid = membersMap[uid] is Map ? (membersMap[uid]['studentId'] ?? '') : '';
        return sid != '' ? '$name ($sid)' : name;
      }).join(';');

      final memberMarks = memberUids.map((uid) {
        final name = uidToName[uid] ?? uid;
        final mark = memberMarksMap[uid]?.toString() ?? '';
        return '$name:$mark';
      }).join(';');

      rows.add([key, title, memberNames, memberMarks, marks, remarks]);
    }

    final csv = StringBuffer();
    for (final r in rows) {
      final escaped = r.map((c) {
        final needs = c.contains(',') || c.contains('"') || c.contains('\n');
        var col = c.replaceAll('"', '""');
        if (needs) col = '"$col"';
        return col;
      }).join(',');
      csv.writeln(escaped);
    }

    final filename = 'marks_${DateTime.now().toIso8601String().replaceAll(':', '-')}.csv';
    try {
      await saveFile(filename, csv.toString(), mime: 'text/csv');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download started')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save file: $e')));
    }
  }
}

class _DeadlinesSection extends StatelessWidget {
  const _DeadlinesSection({required this.supervisorUid, required this.groupsRef, this.university});

  final String supervisorUid;
  final DatabaseReference groupsRef;
  final String? university;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: groupsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data?.snapshot.value;
        if (data is! Map) return const Center(child: Text('No groups found.'));

        final allEntries = Map<String, dynamic>.from(data);
        
        // Filter by University
        final entries = university == null 
          ? allEntries 
          : Map.fromEntries(allEntries.entries.where((e) => (e.value as Map)['university'] == university));

        final myGroups = entries.entries.where((e) {
          final val = e.value;
          return val is Map && val['supervisorId'] == supervisorUid;
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Project Deadlines', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            if (myGroups.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No assigned groups.'))),
            ...myGroups.map((g) {
              final groupData = g.value as Map;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(groupData['projectTitle'] ?? 'No Title'),
                  subtitle: Text('Proposal Deadline: ${groupData['proposalDeadline'] ?? 'Not set'}'),
                  trailing: IconButton(
                    icon: Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
                    onPressed: () => _showDeadlineDialog(context, g.key),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  void _showDeadlineDialog(BuildContext context, String groupCode) {
    final dateController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set Proposal Deadline for $groupCode'),
        content: Form(
          key: dialogFormKey,
          child: TextFormField(
          controller: dateController,
          validator: (v) => AppValidators.required(v, fieldName: 'Deadline'),
          style: const TextStyle(fontWeight: FontWeight.normal),
          decoration: const InputDecoration(labelText: 'Deadline (YYYY-MM-DD)'),
          readOnly: true,
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 180)),
            );
            if (d != null) dateController.text = d.toString().split(' ')[0];
          },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!(dialogFormKey.currentState?.validate() ?? false)) return;
              await groupsRef.child(groupCode).update({
                'proposalDeadline': dateController.text,
              });
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Set Deadline'),
          ),
        ],
      ),
    );
  }
}

class _SharedDocumentsSection extends StatelessWidget {
  const _SharedDocumentsSection({this.university});
  final String? university;

  @override
  Widget build(BuildContext context) {
    final uniPath = university ?? 'default';
    final docsRef = FirebaseDatabase.instance.ref('admin/universities/$uniPath/documents_by_role/Supervisor');
    return StreamBuilder<DatabaseEvent>(
      stream: docsRef.onValue,
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
            'fileName': val['fileName'] ?? '',
            'fileUrl': val['fileUrl'] ?? val['downloadUrl'] ?? '',
            'description': val['description'] ?? '',
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
                side: const BorderSide(color: AppColors.borderVeryLight),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.selectedTile,
                  child: Icon(Icons.description, color: AppColors.black),
                ),
                title: Text(doc['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(doc['description'].isNotEmpty ? doc['description'] : doc['fileName']),
                trailing: IconButton(
                  icon: Icon(Icons.open_in_new, color: Theme.of(context).colorScheme.primary),
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
