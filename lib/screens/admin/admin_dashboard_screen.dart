import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repositories/admin_repository.dart';
import '../../repositories/group_repository.dart';
import '../../repositories/user_repository.dart';
import '../../state/session_provider.dart';
import '../../theme/app_colors.dart';
import '../auth/sign_out_screen.dart';
import '../shared/messages_screen.dart';
import 'admin_nav_bar.dart';
import 'admin_settings_screen.dart';
import 'sections/admin_content_crud_section.dart';
import 'sections/admin_dashboard_home_section.dart';
import 'sections/admin_documents_section.dart';
import 'sections/admin_groups_approval_section.dart';
import 'sections/admin_supervisor_limits_section.dart';
import 'sections/admin_user_management_section.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  static const String routeName = '/admin-dashboard';

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  _AdminSection _currentSection = _AdminSection.dashboard;

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
    final session = context.watch<SessionProvider>();
    if (session.isLoading && session.profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final university = session.university;
    final displayName = session.profile?.fullName;
    final userRepository = context.read<UserRepository>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_currentSection.title),
            Text(
              'Admin control center',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        actions: [
          StreamBuilder<DatabaseEvent>(
            stream: userRepository.watchAllUsers(),
            builder: (context, snapshot) {
              int pendingCount = 0;
              if (snapshot.hasData && snapshot.data?.snapshot.value is Map) {
                final users =
                    Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
                pendingCount = users.values
                    .where(
                      (u) =>
                          u is Map &&
                          u['role'] == 'Pending' &&
                          u['university'] == university,
                    )
                    .length;
              }
              return Badge(
                label: Text(pendingCount.toString()),
                isLabelVisible: pendingCount > 0,
                backgroundColor: AppColors.adminPink,
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.adminPink),
                  onPressed: () =>
                      setState(() => _currentSection = _AdminSection.userManagement),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(AdminSettingsScreen.routeName),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surfaceMuted,
                child: Text(
                  (displayName?.isNotEmpty == true
                          ? displayName!.trim()[0]
                          : 'A')
                      .toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
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
          university: university,
        ),
      ),
      bottomNavigationBar: AdminNavBar(
        selectedIndex: switch (_currentSection) {
          _AdminSection.dashboard => 0,
          _AdminSection.userManagement => 1,
          _AdminSection.messages => 2,
          _AdminSection.supervisorLimits => 1,
          _AdminSection.groupsApproval => 1,
          _AdminSection.documents => 1,
          _AdminSection.announcements => 0,
        },
      ),
    );
  }
}

class _AdminSectionBody extends StatelessWidget {
  const _AdminSectionBody({
    required this.section,
    this.university,
  });

  final _AdminSection section;
  final String? university;

  @override
  Widget build(BuildContext context) {
    final userRepository = context.read<UserRepository>();
    final groupRepository = context.read<GroupRepository>();
    final adminRepository = context.read<AdminRepository>();
    final adminRef = adminRepository.universityRef(university);

    switch (section) {
      case _AdminSection.dashboard:
        return AdminDashboardHomeSection(
          usersRef: userRepository.usersRef,
          adminRef: adminRef,
          university: university,
          displayName: context.read<SessionProvider>().profile?.fullName,
        );
      case _AdminSection.announcements:
        return AdminContentCrudSection(
          title: 'Announcements',
          emptyText: 'No announcements yet.',
          dataRef: adminRepository.announcementsRef(university),
          includeDate: false,
          university: university,
        );
      case _AdminSection.messages:
        return const MessagesScreen(isAdmin: true);
      case _AdminSection.userManagement:
        return AdminUserManagementSection(
          userRepository: userRepository,
          university: university,
        );
      case _AdminSection.groupsApproval:
        return AdminGroupsApprovalSection(
          groupRepository: groupRepository,
          userRepository: userRepository,
          university: university,
        );
      case _AdminSection.supervisorLimits:
        return AdminSupervisorLimitsSection(
          usersRef: userRepository.usersRef,
          groupsRef: groupRepository.groupsRef,
          adminRef: adminRef,
          university: university,
        );
      case _AdminSection.documents:
        return AdminDocumentsSection(
          documentsRef: adminRepository.documentsRef(university),
          university: university,
        );
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
      backgroundColor: AppColors.bg,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.adminPink.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.adminPink.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.adminPink.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: AppColors.adminPink,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Admin Panel',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Text(
                    'Management Terminal',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.adminPink,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  for (final section in _drawerSections)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        tileColor: section == selected
                            ? AppColors.adminPink.withValues(alpha: 0.1)
                            : Colors.transparent,
                        leading: Icon(
                          section.icon,
                          color: section == selected
                              ? AppColors.adminPink
                              : AppColors.textSecondary,
                        ),
                        title: Text(
                          section.title,
                          style: TextStyle(
                            color: section == selected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight:
                                section == selected ? FontWeight.w900 : FontWeight.w600,
                          ),
                        ),
                        onTap: () => onSelected(section),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(SignOutScreen.routeName),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.adminPink,
                        radius: 18,
                        child: Icon(Icons.logout, color: Colors.black, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Logout Session',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
