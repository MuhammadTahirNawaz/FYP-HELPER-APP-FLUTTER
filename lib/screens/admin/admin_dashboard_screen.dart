import 'package:file_selector/file_selector.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/system_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/cloudinary_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shared/messages_screen.dart';
import 'admin_nav_bar.dart';
import 'admin_settings_screen.dart';

/// Opens a document URL directly in a new browser tab / OS handler.
void _openDocumentUrl(String url) {
  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  static const String routeName = '/admin-dashboard';

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref('users');
  final DatabaseReference _adminRef =
      FirebaseDatabase.instance.ref('admin');
  _AdminSection _currentSection = _AdminSection.dashboard;
  int _bottomIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName == '/admin-messages') {
      _currentSection = _AdminSection.messages;
    }
  }

  void _selectSection(_AdminSection section) {
    setState(() => _currentSection = section);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFF14375E),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentSection.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              'Admin control center',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () => Navigator.of(context).pushNamed(AdminSettingsScreen.routeName),
          ),
          const SizedBox(width: 8),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF000000), Color(0xFF1E293B)],
            ),
          ),
        ),
      ),
      drawer: _AdminDrawer(
        selected: _currentSection,
        onSelected: _selectSection,
      ),
      body: PopScope(
        canPop: _currentSection == _AdminSection.dashboard,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            setState(() => _currentSection = _AdminSection.dashboard);
          }
        },
        child: _AdminSectionBody(
          section: _currentSection,
          usersRef: _usersRef,
          adminRef: _adminRef,
        ),
      ),
      bottomNavigationBar: AdminNavBar(
        selectedIndex: switch (_currentSection) {
          _AdminSection.dashboard => 0,
          _AdminSection.userManagement => 1,
          _AdminSection.messages => 2,
          _AdminSection.supervisorLimits => 1, // Fallback for related management
          _AdminSection.groupsApproval => 1, // Fallback
          _AdminSection.documents => 1, // Fallback
          _AdminSection.announcements => 0, // Fallback
        },
      ),
    );
  }
}

class _AdminSectionBody extends StatelessWidget {
  const _AdminSectionBody({
    required this.section,
    required this.usersRef,
    required this.adminRef,
  });

  final _AdminSection section;
  final DatabaseReference usersRef;
  final DatabaseReference adminRef;

  @override
  Widget build(BuildContext context) {
    switch (section) {
      case _AdminSection.dashboard:
        return _AdminDashboardHome(
          usersRef: usersRef,
          adminRef: adminRef,
        );
      case _AdminSection.announcements:
        return _CrudSection(
          title: 'Announcements',
          emptyText: 'No announcements yet.',
          dataRef: adminRef.child('announcements'),
          includeDate: false,
        );
      case _AdminSection.messages:
        return const MessagesScreen(isAdmin: true);
      case _AdminSection.userManagement:
        return _UserManagementSection(usersRef: usersRef);
      case _AdminSection.groupsApproval:
        return _GroupsApprovalSection(
          groupsRef: FirebaseDatabase.instance.ref('groups'),
          usersRef: usersRef,
        );
      case _AdminSection.supervisorLimits:
        return _SupervisorLimitsSection(
          usersRef: usersRef,
          groupsRef: FirebaseDatabase.instance.ref('groups'),
          adminRef: adminRef,
        );
      case _AdminSection.documents:
        return _DocumentsSection(documentsRef: adminRef.child('documents'));
    }
  }
}

class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer({
    required this.selected,
    required this.onSelected,
  });

  final _AdminSection selected;
  final ValueChanged<_AdminSection> onSelected;

  List<_AdminSection> get _drawerSections {
    return _AdminSection.values
        .where(
          (section) =>
              section != _AdminSection.dashboard &&
              section != _AdminSection.announcements &&
              section != _AdminSection.messages,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF000000), Color(0xFF1E293B)],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.admin_panel_settings, color: Color(0xFF14375E)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Admin Panel',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Users, sessions, approvals, analytics',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            for (final section in _drawerSections)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  tileColor: section == selected ? const Color(0xFFEDF1F9) : Colors.transparent,
                  leading: Icon(
                    section.icon,
                    color: section == selected ? const Color(0xFF1E6091) : const Color(0xFF6B7A99),
                  ),
                  title: Text(
                    section.title,
                    style: TextStyle(
                      color: section == selected ? const Color(0xFF14375E) : const Color(0xFF6B7A99),
                      fontWeight: section == selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  selected: section == selected,
                  onTap: () => onSelected(section),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AdminDashboardHome extends StatelessWidget {
  const _AdminDashboardHome({
    required this.usersRef,
    required this.adminRef,
  });

  final DatabaseReference usersRef;
  final DatabaseReference adminRef;

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseDatabase.instance.ref('messages/threads');

    return StreamBuilder<DatabaseEvent>(
      stream: usersRef.onValue,
      builder: (context, usersSnapshot) {
        final usersData = usersSnapshot.data?.snapshot.value;
        final usersMap = usersData is Map
            ? Map<String, dynamic>.from(usersData)
            : <String, dynamic>{};
        final totalUsers = usersMap.length;
        final pendingUsers = usersMap.values
            .where((value) =>
                value is Map && (value['role'] as String?) == 'Pending')
            .length;
        final verifiedUsers = totalUsers - pendingUsers;

        return StreamBuilder<DatabaseEvent>(
          stream: adminRef.child('announcements').onValue,
          builder: (context, annSnapshot) {
            final annData = annSnapshot.data?.snapshot.value;
            final annCount = annData is Map
                ? Map<String, dynamic>.from(annData).length
                : 0;

            return StreamBuilder<DatabaseEvent>(
              stream: messagesRef.onValue,
              builder: (context, msgSnapshot) {
                final msgData = msgSnapshot.data?.snapshot.value;
                final msgCount = msgData is Map
                    ? Map<String, dynamic>.from(msgData).length
                    : 0;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _DashboardBanner(
                      title: 'Admin Overview',
                      subtitle: 'Manage the entire platform from one polished control panel.',
                      icon: Icons.admin_panel_settings,
                    ),
                    const SizedBox(height: 16),
                    _StatsGrid(
                      stats: [
                        _StatItem(
                          label: 'Total Users',
                          value: totalUsers.toString(),
                          icon: Icons.group,
                          accent: const Color(0xFF1E6091),
                        ),
                        _StatItem(
                          label: 'Pending',
                          value: pendingUsers.toString(),
                          icon: Icons.hourglass_top,
                          accent: const Color(0xFFF59E0B),
                        ),
                        _StatItem(
                          label: 'Verified',
                          value: verifiedUsers.toString(),
                          icon: Icons.verified,
                          accent: const Color(0xFF16A34A),
                        ),
                        _StatItem(
                          label: 'Announcements',
                          value: annCount.toString(),
                          icon: Icons.campaign,
                          accent: const Color(0xFF8B5CF6),
                        ),
                        _StatItem(
                          label: 'Messages',
                          value: msgCount.toString(),
                          icon: Icons.message,
                          accent: const Color(0xFF0EA5E9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SystemHealthSection(),
                    const SizedBox(height: 20),
                    const _TimedAdBanner(),
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

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<_StatItem> stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: stats
          .map(
            (stat) => Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: stat.accent.withOpacity(0.12)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [stat.accent.withOpacity(0.16), Colors.white],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: stat.accent.withOpacity(0.14),
                        child: Icon(stat.icon, color: stat.accent),
                      ),
                      const Spacer(),
                      Text(
                        stat.value,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF14375E),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stat.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7A99),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: const Color(0xFFEFF6FF),
      side: const BorderSide(color: Color(0xFFBFDBFE)),
      labelStyle: const TextStyle(
        color: Color(0xFF1E6091),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _DashboardBanner extends StatelessWidget {
  const _DashboardBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14375E), Color(0xFF1E6091)],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.16),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserManagementSection extends StatefulWidget {
  const _UserManagementSection({required this.usersRef});

  final DatabaseReference usersRef;

  @override
  State<_UserManagementSection> createState() =>
      _UserManagementSectionState();
}

class _UserManagementSectionState extends State<_UserManagementSection> {
  final Map<String, String> _pendingSelections = {};
  bool _updating = false;

  Future<void> _approveUser(_UserRow user) async {
    if (_updating) {
      return;
    }
    setState(() => _updating = true);
    final role =
        _pendingSelections[user.uid] ?? user.requestedRole ?? 'Student';
    await widget.usersRef.child(user.uid).update({
      'role': role,
      'status': 'Active',
      'updatedAt': ServerValue.timestamp,
    });
    if (mounted) {
      setState(() => _updating = false);
    }
  }

  Future<void> _rejectUser(_UserRow user) async {
    if (_updating) {
      return;
    }
    setState(() => _updating = true);
    await widget.usersRef.child(user.uid).update({
      'role': 'Rejected',
      'status': 'Rejected',
      'updatedAt': ServerValue.timestamp,
    });
    if (mounted) {
      setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: widget.usersRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data?.snapshot.value;
        if (data is! Map) {
          return _emptyState();
        }
        final entries = Map<String, dynamic>.from(data);
        final users = entries.entries
            .map(
              (entry) => _UserRow.fromMap(
                entry.key,
                Map<String, dynamic>.from(entry.value as Map),
              ),
            )
            .toList();

        final pending = users.where((user) => user.role == 'Pending').toList();
        final verified =
            users.where((user) => user.role != 'Pending').toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionHeader(context, 'Pending Users', pending.length),
            const SizedBox(height: 8),
            ...pending.map((user) => _PendingUserCard(
                  user: user,
                  selectedRole:
                      _pendingSelections[user.uid] ?? user.requestedRole,
                  onRoleChanged: (value) => setState(() {
                    _pendingSelections[user.uid] = value;
                  }),
                  onApprove: () => _approveUser(user),
                  onReject: () => _rejectUser(user),
                  disabled: _updating,
                )),
            const SizedBox(height: 20),
            _sectionHeader(context, 'Verified Users', verified.length),
            const SizedBox(height: 8),
            ...verified.map((user) => _UserCard(user: user)),
          ],
        );
      },
    );
  }

  Widget _emptyState() {
    return const Center(child: Text('No users found.'));
  }

  Widget _sectionHeader(BuildContext context, String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        Text('$count', style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}

class _PendingUserCard extends StatelessWidget {
  const _PendingUserCard({
    required this.user,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onApprove,
    required this.onReject,
    required this.disabled,
  });

  final _UserRow user;
  final String? selectedRole;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE6E6E6)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEDF1F9),
          child: Text(user.email.isEmpty ? '?' : user.email[0]),
        ),
        title: Text(user.email.isEmpty ? 'Unknown email' : user.email),
        subtitle: Text(
          user.requestedRole == null
              ? 'Requested: -'
              : 'Requested: ${user.requestedRole}',
        ),
        trailing: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedRole ?? 'Student',
              items: const [
                DropdownMenuItem(value: 'Student', child: Text('Student')),
                DropdownMenuItem(value: 'Supervisor', child: Text('Supervisor')),
                DropdownMenuItem(value: 'Committee', child: Text('Committee')),
              ],
              onChanged: disabled
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }
                      onRoleChanged(value);
                    },
            ),
            IconButton(
              icon: const Icon(Icons.check_circle),
              tooltip: 'Approve',
              onPressed: disabled ? null : onApprove,
            ),
            IconButton(
              icon: const Icon(Icons.cancel),
              tooltip: 'Reject',
              onPressed: disabled ? null : onReject,
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupsApprovalSection extends StatefulWidget {
  const _GroupsApprovalSection({
    required this.groupsRef,
    required this.usersRef,
  });

  final DatabaseReference groupsRef;
  final DatabaseReference usersRef;

  @override
  State<_GroupsApprovalSection> createState() => _GroupsApprovalSectionState();
}

class _GroupsApprovalSectionState extends State<_GroupsApprovalSection> {
  final Map<String, String> _supervisorSelection = {};
  bool _updating = false;

  Future<void> _approveGroup(
      String code, String supervisorEmail, String supervisorId) async {
    if (_updating) {
      return;
    }
    setState(() => _updating = true);
    await widget.groupsRef.child(code).update({
      'status': 'Approved',
      'supervisorEmail': supervisorEmail,
      'supervisorId': supervisorId,
      'supervisorName': supervisorEmail.split('@')[0],
      'updatedAt': ServerValue.timestamp,
    });
    if (mounted) {
      setState(() => _updating = false);
    }
  }

  Future<void> _rejectGroup(String code) async {
    if (_updating) {
      return;
    }
    setState(() => _updating = true);
    await widget.groupsRef.child(code).update({
      'status': 'Rejected',
      'updatedAt': ServerValue.timestamp,
    });
    if (mounted) {
      setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: widget.groupsRef.onValue,
      builder: (context, snapshot) {
        final groupsData = snapshot.data?.snapshot.value;
        final groups = _GroupRow.fromSnapshot(groupsData)
            .where((group) => group.status == 'Pending')
            .toList();

        return StreamBuilder<DatabaseEvent>(
          stream: widget.usersRef.onValue,
          builder: (context, userSnapshot) {
            final usersData = userSnapshot.data?.snapshot.value;
            final supervisors = _UserRow.fromSnapshot(usersData)
                .where((user) => user.role == 'Supervisor')
                .toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Pending Groups',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                 if (supervisors.isEmpty)
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: Colors.amber.shade50,
                       borderRadius: BorderRadius.circular(8),
                       border: Border.all(color: Colors.amber.shade300),
                     ),
                     child: Text(
                       'Note: No supervisors available. You can still approve groups, but supervisors should be created first to assign later.',
                       style: TextStyle(color: Colors.amber.shade900, fontSize: 12),
                     ),
                   ),
                 const SizedBox(height: 12),
                if (groups.isEmpty)
                  const Center(child: Text('No pending groups yet.'))
                else
                  ...groups.map(
                    (group) {
                      final selected = _supervisorSelection[group.code] ??
                          (supervisors.isNotEmpty
                              ? supervisors.first.email
                              : '');
                      final selectedSupervisor = supervisors
                          .firstWhere((sup) => sup.email == selected,
                              orElse: () => supervisors.isNotEmpty ? supervisors.first : null as _UserRow);
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFE6E6E6)),
                        ),
                        child: ListTile(
                          title: Text('Group ${group.code}'),
                          subtitle: Text(
                            '${group.memberCount} members · Requested supervisor: ${group.supervisorEmail.isEmpty ? 'Pending' : group.supervisorEmail}',
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              DropdownButton<String>(
                                value: selected,
                                items: supervisors
                                    .map(
                                      (sup) => DropdownMenuItem<String>(
                                        value: sup.email,
                                        child: Text(sup.email),
                                      ),
                                    )
                                    .toList(),
                                 isExpanded: false,
                                 hint: const Text('No supervisors'),
                                onChanged: _updating
                                    ? null
                                    : (value) {
                                        if (value == null) {
                                          return;
                                        }
                                        setState(() {
                                          _supervisorSelection[group.code] =
                                              value;
                                        });
                                      },
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_circle),
                                tooltip: 'Approve',
                                 onPressed: (selectedSupervisor == null || _updating)
                                    ? null
                                    : () => _approveGroup(
                                          group.code,
                                          selected,
                                          selectedSupervisor.uid,
                                        ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel),
                                tooltip: 'Reject',
                                onPressed: _updating
                                    ? null
                                    : () => _rejectGroup(group.code),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SupervisorLimitsSection extends StatefulWidget {
  const _SupervisorLimitsSection({
    required this.usersRef,
    required this.groupsRef,
    required this.adminRef,
  });

  final DatabaseReference usersRef;
  final DatabaseReference groupsRef;
  final DatabaseReference adminRef;

  @override
  State<_SupervisorLimitsSection> createState() =>
      _SupervisorLimitsSectionState();
}

class _SupervisorLimitsSectionState extends State<_SupervisorLimitsSection> {
  bool _updating = false;

  Future<void> _updateLimit(String supervisorId, int newLimit) async {
    if (_updating) return;
    setState(() => _updating = true);
    try {
      await widget.adminRef
          .child('supervisorLimits')
          .child(supervisorId)
          .update({
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
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Supervisor Limit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Supervisor: $supervisorEmail'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Max Groups',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value != null && value > 0) {
                  Navigator.pop(dialogContext);
                  _updateLimit(supervisorId, value);
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid number greater than 0'),
                    ),
                  );
                }
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
        final usersData = userSnapshot.data?.snapshot.value;
        final supervisors = _UserRow.fromSnapshot(usersData)
            .where((user) => user.role == 'Supervisor')
            .toList();

        return StreamBuilder<DatabaseEvent>(
          stream: widget.adminRef.child('supervisorLimits').onValue,
          builder: (context, limitsSnapshot) {
            final limitsData = limitsSnapshot.data?.snapshot.value;
            final limits = limitsData is Map
                ? Map<String, dynamic>.from(limitsData as Map)
                : {};

            return StreamBuilder<DatabaseEvent>(
              stream: widget.groupsRef.onValue,
              builder: (context, groupsSnapshot) {
                final groupsData = groupsSnapshot.data?.snapshot.value;
                final groups = _GroupRow.fromSnapshot(groupsData);

                final supervisorCapacity = <String, int>{};
                for (var group in groups) {
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
                      const Center(
                        child: Text('No supervisors registered yet.'),
                      )
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
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

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final _UserRow user;

  @override
  Widget build(BuildContext context) {
    final roleLabel = user.role.isEmpty ? 'Unknown' : user.role;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE6E6E6)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEDF1F9),
          child: Text(user.email.isEmpty ? '?' : user.email[0]),
        ),
        title: Text(user.email.isEmpty ? 'Unknown email' : user.email),
        subtitle: Text('Role: $roleLabel'),
        trailing: user.requestedRole == null
            ? null
            : Text('Requested: ${user.requestedRole}'),
      ),
    );
  }
}

String _formatBytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var size = bytes.toDouble();
  var unitIndex = 0;
  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex += 1;
  }
  final decimals = size < 10 && unitIndex > 0 ? 1 : 0;
  return '${size.toStringAsFixed(decimals)} ${units[unitIndex]}';
}

String _formatTimestamp(Object? value) {
  if (value is! int) {
    return 'Unknown';
  }
  final date = DateTime.fromMillisecondsSinceEpoch(value).toLocal();
  final yyyy = date.year.toString().padLeft(4, '0');
  final mm = date.month.toString().padLeft(2, '0');
  final dd = date.day.toString().padLeft(2, '0');
  final hh = date.hour.toString().padLeft(2, '0');
  final min = date.minute.toString().padLeft(2, '0');
  return '$yyyy-$mm-$dd $hh:$min';
}

int _toIntTs(Object? value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    final i = int.tryParse(value);
    if (i != null) return i;
    final d = double.tryParse(value);
    if (d != null) return d.toInt();
  }
  return 0;
}

class _DocumentsSection extends StatefulWidget {
  const _DocumentsSection({required this.documentsRef});

  final DatabaseReference documentsRef;

  @override
  State<_DocumentsSection> createState() => _DocumentsSectionState();
}

class _DocumentsSectionState extends State<_DocumentsSection> {
  bool _uploading = false;
  double _uploadProgress = 0;
  String _uploadLabel = '';

  Future<void> _showDocumentEditor(
    BuildContext context, {
    _DocumentRow? existing,
  }) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descriptionController =
        TextEditingController(text: existing?.description ?? '');
    final roles = <String>['Admin', 'Supervisor', 'Committee', 'Student'];
    final selectedRoles = <String>{
      ...?existing?.roles,
      if (existing == null) ...roles,
    };
    XFile? selectedFile;
    var saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'Upload Document' : 'Edit Document'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Access Roles',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: roles
                          .map(
                            (role) => FilterChip(
                              label: Text(role),
                              selected: selectedRoles.contains(role),
                              onSelected: (selected) {
                                setDialogState(() {
                                  if (selected) {
                                    selectedRoles.add(role);
                                  } else {
                                    selectedRoles.remove(role);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    if (existing != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('File: ${existing.fileName}'),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () async {
                          final file = await openFile();
                          if (file == null) {
                            return;
                          }
                          setDialogState(() {
                            selectedFile = file;
                          });
                        },
                        icon: const Icon(Icons.attach_file),
                        label: Text(
                          selectedFile == null
                              ? 'Pick file'
                              : selectedFile!.name,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          if (title.isEmpty) {
                            return;
                          }
                          if (existing == null && selectedFile == null) {
                            return;
                          }
                          setDialogState(() => saving = true);
                          try {
                            final rolesMap = {
                              for (final role in selectedRoles) role: true,
                            };
                            final rootRef = FirebaseDatabase.instance.ref();
                            if (existing == null) {
                              final docId = widget.documentsRef.push().key;
                              if (docId == null) {
                                return;
                              }
                              final file = selectedFile!;
                              final storagePath = 'documents/$docId/${file.name}';
                              final bytes = await file.readAsBytes();

                              final downloadUrl = await CloudinaryService.uploadFile(
                                fileBytes: bytes,
                                fileName: file.name,
                                folder: 'documents/$docId',
                                onProgress: (progress) {
                                  if (!mounted) return;
                                  setState(() {
                                    _uploading = true;
                                    _uploadLabel = file.name;
                                    _uploadProgress = progress;
                                  });
                                },
                              );

                              if (downloadUrl == null) {
                                throw Exception('Failed to upload to Cloudinary');
                              }
                              final sizeBytes = await file.length();
                              final uploaderEmail =
                                  FirebaseAuth.instance.currentUser?.email ?? '';
                              final payload = <String, Object?>{
                                'title': title,
                                'description': descriptionController.text.trim(),
                                'fileName': file.name,
                                'fileUrl': downloadUrl,
                                'storagePath': storagePath,
                                'sizeBytes': sizeBytes,
                                'roles': rolesMap,
                                'uploadedBy': uploaderEmail,
                                'createdAt': ServerValue.timestamp,
                                'updatedAt': ServerValue.timestamp,
                              };
                              final updates = <String, Object?>{
                                'admin/documents/$docId': payload,
                              };
                              for (final role in selectedRoles) {
                                updates['documents_by_role/$role/$docId'] =
                                    payload;
                              }
                              await rootRef.update(updates);
                              if (mounted) {
                                setState(() {
                                  _uploading = false;
                                  _uploadProgress = 0;
                                  _uploadLabel = '';
                                });
                              }
                            } else {
                              final payload = <String, Object?>{
                                'title': title,
                                'description': descriptionController.text.trim(),
                                'fileName': existing.fileName,
                                'fileUrl': existing.fileUrl,
                                'storagePath': existing.storagePath,
                                'sizeBytes': existing.sizeBytes,
                                'roles': rolesMap,
                                'uploadedBy': existing.uploadedBy,
                                'createdAt': existing.createdAt ??
                                    ServerValue.timestamp,
                                'updatedAt': ServerValue.timestamp,
                              };
                              // Note: Cloudinary unsigned API does not support updating metadata from client.
                              // Roles are primarily managed via the Realtime Database nodes anyway.
                              final updates = <String, Object?>{
                                'admin/documents/${existing.id}': payload,
                              };
                              final existingRoles = existing.roles.toSet();
                              for (final role in existingRoles) {
                                if (!selectedRoles.contains(role)) {
                                  updates[
                                      'documents_by_role/$role/${existing.id}'] =
                                      null;
                                }
                              }
                              for (final role in selectedRoles) {
                                updates['documents_by_role/$role/${existing.id}'] =
                                    payload;
                              }
                              await rootRef.update(updates);
                            }
                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          } catch (error) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Upload failed: $error'),
                                ),
                              );
                              setState(() {
                                _uploading = false;
                                _uploadProgress = 0;
                                _uploadLabel = '';
                              });
                            }
                          } finally {
                            if (mounted) {
                              setDialogState(() => saving = false);
                            }
                          }
                        },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteDocument(_DocumentRow doc) async {
    // Note: Cloudinary unsigned API does not support deletions from client app.
    // The files will become orphaned in Cloudinary. To delete them physically, a backend is required.
    final rootRef = FirebaseDatabase.instance.ref();
    final updates = <String, Object?>{
      'admin/documents/${doc.id}': null,
    };
    for (final role in doc.roles) {
      updates['documents_by_role/$role/${doc.id}'] = null;
    }
    await rootRef.update(updates);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: widget.documentsRef.onValue,
      builder: (context, snapshot) {
        final docsData = snapshot.data?.snapshot.value;
        final documents = _DocumentRow.fromSnapshot(docsData)
          ..sort((a, b) => _toIntTs(b.createdAt).compareTo(_toIntTs(a.createdAt)));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Documents', style: Theme.of(context).textTheme.titleMedium),
                FilledButton.icon(
                  onPressed: () => _showDocumentEditor(context),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload'),
                ),
              ],
            ),
            if (_uploading) ...[
              const SizedBox(height: 12),
              Text('Uploading $_uploadLabel'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _uploadProgress),
            ],
            const SizedBox(height: 12),
            if (documents.isEmpty)
              const Center(child: Text('No documents yet.'))
            else
              ...documents.map(
                (doc) => Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE6E6E6)),
                  ),
                  child: ListTile(
                    title: Text(doc.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(doc.description.isEmpty
                            ? 'No description'
                            : doc.description),
                        const SizedBox(height: 6),
                        Text('File: ${doc.fileName}'),
                        Text('Size: ${_formatBytes(doc.sizeBytes)}'),
                        if (doc.roles.isNotEmpty)
                          Text('Roles: ${doc.roles.join(', ')}'),
                        if (doc.createdAt != null)
                          Text('Uploaded: ${_formatTimestamp(doc.createdAt)}'),
                      ],
                    ),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_new),
                          tooltip: 'Open',
                          onPressed: doc.fileUrl.isEmpty
                              ? null
                              : () => _openDocumentUrl(doc.fileUrl),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit',
                          onPressed: () =>
                              _showDocumentEditor(context, existing: doc),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete',
                          onPressed: () => _deleteDocument(doc),
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

class _CrudSection extends StatelessWidget {
  const _CrudSection({
    required this.title,
    required this.emptyText,
    required this.dataRef,
    required this.includeDate,
  });

  final String title;
  final String emptyText;
  final DatabaseReference dataRef;
  final bool includeDate;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: dataRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data?.snapshot.value;
        final items = _CrudItem.fromSnapshot(data);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                FilledButton.icon(
                  onPressed: () => _showEditor(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(emptyText),
                ),
              )
            else
              ...items.map((item) => _CrudCard(
                    item: item,
                    onEdit: () => _showEditor(context, existing: item),
                    onDelete: () => dataRef.child(item.id).remove(),
                    includeDate: includeDate,
                  )),
          ],
        );
      },
    );
  }

  Future<void> _showEditor(BuildContext context, {_CrudItem? existing}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final detailsController =
        TextEditingController(text: existing?.details ?? '');
    final dateController =
        TextEditingController(text: existing?.date ?? '');
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(existing == null ? 'Add $title' : 'Edit $title'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: detailsController,
                  decoration: const InputDecoration(labelText: 'Details'),
                  maxLines: 3,
                ),
                if (includeDate) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date (YYYY-MM-DD)',
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final titleText = titleController.text.trim();
                final detailsText = detailsController.text.trim();
                final dateText = dateController.text.trim();
                if (titleText.isEmpty) {
                  return;
                }
                final payload = <String, dynamic>{
                  'title': titleText,
                  'details': detailsText,
                  if (includeDate && dateText.isNotEmpty) 'date': dateText,
                  'updatedAt': ServerValue.timestamp,
                  if (existing == null) 'createdAt': ServerValue.timestamp,
                };
                final navigator = Navigator.of(dialogContext);
                if (existing == null) {
                  await dataRef.push().set(payload);
                } else {
                  await dataRef.child(existing.id).update(payload);
                }
                navigator.pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _CrudCard extends StatelessWidget {
  const _CrudCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.includeDate,
  });

  final _CrudItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool includeDate;

  @override
  Widget build(BuildContext context) {
    final details = item.details.isEmpty ? 'No details' : item.details;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE6E6E6)),
      ),
      child: ListTile(
        title: Text(item.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(details),
            if (includeDate && item.date.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Date: ${item.date}'),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _UserRow {
  const _UserRow({
    required this.uid,
    required this.email,
    required this.role,
    this.requestedRole,
  });

  final String uid;
  final String email;
  final String role;
  final String? requestedRole;

  factory _UserRow.fromMap(String uid, Map<String, dynamic> data) {
    return _UserRow(
      uid: uid,
      email: (data['email'] as String?) ?? '',
      role: (data['role'] as String?) ?? '',
      requestedRole: data['requestedRole'] as String?,
    );
  }

  static List<_UserRow> fromSnapshot(Object? data) {
    if (data is! Map) {
      return <_UserRow>[];
    }
    final entries = Map<String, dynamic>.from(data);
    return entries.entries
        .map(
          (entry) => _UserRow.fromMap(
            entry.key,
            Map<String, dynamic>.from(entry.value as Map),
          ),
        )
        .toList();
  }
}

class _GroupRow {
  const _GroupRow({
    required this.code,
    required this.status,
    required this.supervisorEmail,
    required this.memberCount,
  });

  final String code;
  final String status;
  final String supervisorEmail;
  final int memberCount;

  static List<_GroupRow> fromSnapshot(Object? data) {
    if (data is! Map) {
      return <_GroupRow>[];
    }
    final entries = Map<String, dynamic>.from(data);
    return entries.entries.map((entry) {
      final value = Map<String, dynamic>.from(entry.value as Map);
      final members = value['members'] as Map?;
      return _GroupRow(
        code: entry.key,
        status: (value['status'] as String?) ?? 'Pending',
        supervisorEmail: (value['supervisorEmail'] as String?) ?? '',
        memberCount: members?.length ?? 0,
      );
    }).toList();
  }
}

class _DocumentRow {
  const _DocumentRow({
    required this.id,
    required this.title,
    required this.description,
    required this.fileName,
    required this.fileUrl,
    required this.storagePath,
    required this.sizeBytes,
    required this.roles,
    required this.createdAt,
    required this.uploadedBy,
  });

  final String id;
  final String title;
  final String description;
  final String fileName;
  final String fileUrl;
  final String storagePath;
  final int sizeBytes;
  final List<String> roles;
  final Object? createdAt;
  final String uploadedBy;

  static List<_DocumentRow> fromSnapshot(Object? data) {
    if (data is! Map) {
      return <_DocumentRow>[];
    }
    final entries = Map<String, dynamic>.from(data);
    return entries.entries.map((entry) {
      final value = Map<String, dynamic>.from(entry.value as Map);
      final rolesData = value['roles'];
      final roles = <String>[];
      if (rolesData is Map) {
        roles.addAll(
          rolesData.entries
              .where((entry) => entry.value == true)
              .map((entry) => entry.key.toString()),
        );
      } else if (rolesData is List) {
        roles.addAll(rolesData.map((role) => role.toString()));
      }
      return _DocumentRow(
        id: entry.key,
        title: (value['title'] as String?) ?? '',
        description: (value['description'] as String?) ?? '',
        fileName: (value['fileName'] as String?) ?? '',
        fileUrl: (value['fileUrl'] as String?) ?? '',
        storagePath: (value['storagePath'] as String?) ?? '',
        sizeBytes: (value['sizeBytes'] as int?) ?? 0,
        roles: roles,
        createdAt: value['createdAt'],
        uploadedBy: (value['uploadedBy'] as String?) ?? '',
      );
    }).toList();
  }
}




class _CrudItem {
  const _CrudItem({
    required this.id,
    required this.title,
    required this.details,
    required this.date,
  });

  final String id;
  final String title;
  final String details;
  final String date;

  static List<_CrudItem> fromSnapshot(Object? data) {
    if (data is! Map) {
      return <_CrudItem>[];
    }
    final entries = Map<String, dynamic>.from(data);
    return entries.entries.map((entry) {
      final value = Map<String, dynamic>.from(entry.value as Map);
      return _CrudItem(
        id: entry.key,
        title: (value['title'] as String?) ?? '',
        details: (value['details'] as String?) ?? '',
        date: (value['date'] as String?) ?? '',
      );
    }).toList();
  }
}

enum _AdminSection {
  dashboard('Dashboard', Icons.dashboard),
  userManagement('User Management', Icons.group),
  groupsApproval('Groups Approval', Icons.how_to_reg),
  supervisorLimits('Supervisor Limits', Icons.rule),
  documents('Documents', Icons.folder_copy),
  announcements('Announcements', Icons.campaign),
  messages('Messages', Icons.message);

  const _AdminSection(this.title, this.icon);

  final String title;
  final IconData icon;
}

class _TimedAdBanner extends StatefulWidget {
  const _TimedAdBanner();

  @override
  State<_TimedAdBanner> createState() => _TimedAdBannerState();
}

class _TimedAdBannerState extends State<_TimedAdBanner> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => _visible = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shadowColor: const Color(0xFF1E6091).withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF14375E), Color(0xFF1E6091), Color(0xFF14375E)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'PROMO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF14375E),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'FYP Helper Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'Upgrade your experience now.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _visible = false),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _SystemHealthSection extends StatelessWidget {
  const _SystemHealthSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF334155)),
      ),
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hub, color: Color(0xFF3B82F6)),
                const SizedBox(width: 12),
                Text(
                  'System Health & Services',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _HealthRow(
              label: 'Background Services',
              status: 'Active',
              icon: Icons.settings_input_component,
              color: Colors.green,
            ),
            _HealthRow(
              label: 'Database Connector',
              status: 'Synchronized',
              icon: Icons.cloud_done,
              color: Colors.green,
            ),
            const Divider(height: 32, color: Color(0xFF334155)),
            Text(
              'Active Permissions',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF94A3B8),
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _PermissionChip(label: 'Microphone', icon: Icons.mic),
                _PermissionChip(label: 'Camera', icon: Icons.videocam),
                _PermissionChip(label: 'Phone', icon: Icons.phone),
                _PermissionChip(label: 'Storage', icon: Icons.folder),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({
    required this.label,
    required this.status,
    required this.icon,
    required this.color,
  });

  final String label;
  final String status;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionChip extends StatelessWidget {
  const _PermissionChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF3B82F6)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

