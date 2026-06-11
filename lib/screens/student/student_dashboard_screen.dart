import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repositories/admin_repository.dart';
import '../../repositories/group_repository.dart';
import '../../repositories/user_repository.dart';
import '../../state/session_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/banner_ad_widget.dart';
import '../auth/sign_out_screen.dart';
import 'sections/student_announcements_section.dart';
import 'sections/student_dashboard_home_section.dart';
import 'sections/student_deadlines_section.dart';
import 'sections/student_marks_feedback_section.dart';
import 'sections/student_meeting_requests_section.dart';
import 'sections/student_shared_documents_section.dart';
import 'sections/student_submit_proposal_section.dart';
import 'sections/student_tasks_milestones_section.dart';
import 'sections/student_upload_documents_section.dart';
import 'sections/student_weekly_progress_section.dart';
import 'student_nav_bar.dart';
import 'student_settings_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  static const String routeName = '/student-dashboard';

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

enum _StudentSection {
  dashboard('Dashboard', Icons.dashboard),
  proposal('Submit Proposal', Icons.description),
  sharedDocuments('Shared Documents', Icons.folder_shared),
  documents('Upload Documents', Icons.cloud_upload),
  tasks('Tasks/Milestones', Icons.assignment),
  progress('Weekly Progress', Icons.trending_up),
  meetings('Request Meetings', Icons.event),
  deadlines('Deadlines', Icons.calendar_today),
  announcements('Announcements', Icons.notifications),
  marks('Marks & Feedback', Icons.grade);

  const _StudentSection(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  _StudentSection _currentSection = _StudentSection.dashboard;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    if (session.isLoading && session.profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentUid = session.uid;
    if (currentUid == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in again.')),
      );
    }

    final userRepository = context.read<UserRepository>();
    final groupRepository = context.read<GroupRepository>();
    final adminRepository = context.read<AdminRepository>();
    final university = session.university;

    final displayName = session.profile?.fullName;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_currentSection.label),
            Text(
              'Student workspace',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        actions: [
          StreamBuilder<DatabaseEvent>(
            stream: userRepository.usersRef.child('$currentUid/notifications').onValue,
            builder: (context, snapshot) {
              final hasUnread = snapshot.hasData && snapshot.data!.snapshot.value != null;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {
                      setState(() => _currentSection = _StudentSection.announcements);
                    },
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.infoBlue, width: 1.5),
                        ),
                        constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(StudentSettingsScreen.routeName);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surfaceMuted,
                child: Text(
                  (displayName?.isNotEmpty == true
                          ? displayName!.trim()[0]
                          : 'S')
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
      drawer: _buildDrawer(),
      body: PopScope(
        canPop: _currentSection == _StudentSection.dashboard,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            setState(() => _currentSection = _StudentSection.dashboard);
          }
        },
        child: _StudentSectionBody(
          section: _currentSection,
          groupsRef: groupRepository.groupsRef,
          studentRef: userRepository.usersRef.child(currentUid),
          adminRef: adminRepository.universityRef(university),
          currentUid: currentUid,
          university: university,
        ),
      ),
      bottomNavigationBar: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BannerAdWidget(),
          StudentNavBar(selectedIndex: 0),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
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
                    child: const Icon(Icons.school_outlined, color: AppColors.navy, size: 30),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Student Portal',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Academic Workspace',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  ..._StudentSection.values.map((section) {
                    final isSelected = _currentSection == section;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        tileColor: isSelected ? AppColors.surfaceMuted : Colors.transparent,
                        leading: Icon(
                          section.icon,
                          color: isSelected ? AppColors.navy : AppColors.textSecondary,
                        ),
                        title: Text(
                          section.label,
                          style: TextStyle(
                            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          setState(() => _currentSection = section);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }),
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
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.navy,
                        radius: 18,
                        child: const Icon(Icons.logout, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Logout Session',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
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

class _StudentSectionBody extends StatefulWidget {
  const _StudentSectionBody({
    required this.section,
    required this.groupsRef,
    required this.studentRef,
    required this.adminRef,
    required this.currentUid,
    this.university,
  });

  final _StudentSection section;
  final DatabaseReference groupsRef;
  final DatabaseReference studentRef;
  final DatabaseReference adminRef;
  final String currentUid;
  final String? university;

  @override
  State<_StudentSectionBody> createState() => _StudentSectionBodyState();
}

class _StudentSectionBodyState extends State<_StudentSectionBody> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: widget.groupsRef.onValue,
      builder: (context, snapshot) {
        String? myGroupId;
        if (snapshot.hasData && snapshot.data!.snapshot.value is Map) {
          final groups = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          for (final entry in groups.entries) {
            final members = entry.value['members'] is Map ? Map<String, dynamic>.from(entry.value['members'] as Map) : {};
            if (members.containsKey(widget.currentUid)) {
              myGroupId = entry.key;
              break;
            }
          }
        }

        switch (widget.section) {
          case _StudentSection.dashboard:
            return StudentDashboardHomeSection(
              groupsRef: widget.groupsRef,
              currentUid: widget.currentUid,
              displayName: context.read<SessionProvider>().profile?.fullName,
            );
          case _StudentSection.proposal:
            return StudentSubmitProposalSection(
              groupsRef: widget.groupsRef,
              currentUid: widget.currentUid,
              groupId: myGroupId,
            );
          case _StudentSection.sharedDocuments:
            return StudentSharedDocumentsSection(university: widget.university);
          case _StudentSection.documents:
            return StudentUploadDocumentsSection(
              studentRef: widget.studentRef,
              currentUid: widget.currentUid,
              groupsRef: widget.groupsRef,
              groupId: myGroupId,
            );
          case _StudentSection.tasks:
            return StudentTasksMilestonesSection(
              groupsRef: widget.groupsRef,
              groupId: myGroupId,
            );
          case _StudentSection.progress:
            return StudentWeeklyProgressSection(
              groupsRef: widget.groupsRef,
              groupId: myGroupId,
            );
          case _StudentSection.meetings:
            return StudentMeetingRequestsSection(
              groupsRef: widget.groupsRef,
              groupId: myGroupId,
              currentUid: widget.currentUid,
            );
          case _StudentSection.deadlines:
            return StudentDeadlinesSection(
              adminRef: widget.adminRef,
              groupsRef: widget.groupsRef,
              groupId: myGroupId,
            );
          case _StudentSection.announcements:
            return StudentAnnouncementsSection(adminRef: widget.adminRef);
          case _StudentSection.marks:
            return StudentMarksAndFeedbackSection(
              groupsRef: widget.groupsRef,
              groupId: myGroupId,
            );
        }
      },
    );
  }
}
