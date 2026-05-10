import 'package:file_selector/file_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/cloudinary_service.dart';
import '../shared/messages_screen.dart';
import 'student_settings_screen.dart';
import 'student_nav_bar.dart';

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
  late _StudentSection _currentSection;
  late String _currentUid;
  late DatabaseReference _groupsRef;
  late DatabaseReference _studentRef;
  late DatabaseReference _adminRef;

  @override
  void initState() {
    super.initState();
    _currentSection = _StudentSection.dashboard;
    _currentUid = FirebaseAuth.instance.currentUser!.uid;
    _groupsRef = FirebaseDatabase.instance.ref('groups');
    _studentRef = FirebaseDatabase.instance.ref('users').child(_currentUid);
    _adminRef = FirebaseDatabase.instance.ref('admin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFF000000),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentSection.label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white),
            ),
            Text(
              'Student workspace',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF000000), Color(0xFF1E293B)],
            ),
          ),
        ),
        actions: [
          StreamBuilder<DatabaseEvent>(
            stream: FirebaseDatabase.instance.ref('users/$_currentUid/notifications').onValue,
            builder: (context, snapshot) {
              final hasUnread = snapshot.hasData && snapshot.data!.snapshot.value != null;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white),
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
                          border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
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
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
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
          groupsRef: _groupsRef,
          studentRef: _studentRef,
          adminRef: _adminRef,
          currentUid: _currentUid,
        ),
      ),
      bottomNavigationBar: const StudentNavBar(selectedIndex: 0),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFFFFFFFF),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.school, color: Color(0xFF3B82F6)),
                ),
                const SizedBox(height: 12),
                Text(
                  'Student Dashboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your FYP journey end to end',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          ..._StudentSection.values.map((section) {
            final isSelected = _currentSection == section;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
                leading: Icon(
                  section.icon,
                  color: isSelected ? const Color(0xFF1E6091) : const Color(0xFF64748B),
                  size: 22,
                ),
                title: Text(
                  section.label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
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
  });

  final _StudentSection section;
  final DatabaseReference groupsRef;
  final DatabaseReference studentRef;
  final DatabaseReference adminRef;
  final String currentUid;

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
            return _StudentDashboardHome(
              groupsRef: widget.groupsRef,
              studentRef: widget.studentRef,
              currentUid: widget.currentUid,
            );
          case _StudentSection.proposal:
            return _SubmitProposalSection(groupsRef: widget.groupsRef, currentUid: widget.currentUid, groupId: myGroupId);
          case _StudentSection.sharedDocuments:
            return const _SharedDocumentsSection();
          case _StudentSection.documents:
            return _UploadDocumentsSection(studentRef: widget.studentRef, currentUid: widget.currentUid, groupsRef: widget.groupsRef, groupId: myGroupId);
          case _StudentSection.tasks:
            return _TasksMilestonesSection(groupsRef: widget.groupsRef, groupId: myGroupId);
          case _StudentSection.progress:
            return _WeeklyProgressSection(groupsRef: widget.groupsRef, groupId: myGroupId);
          case _StudentSection.meetings:
            return _MeetingRequestsSection(groupsRef: widget.groupsRef, groupId: myGroupId);
          case _StudentSection.deadlines:
            return _DeadlinesSection(adminRef: widget.adminRef, groupsRef: widget.groupsRef, groupId: myGroupId);
          case _StudentSection.announcements:
            return _AnnouncementsSection(adminRef: widget.adminRef);
          case _StudentSection.marks:
            return _MarksAndFeedbackSection(groupsRef: widget.groupsRef, groupId: myGroupId);
        }
      },
    );
  }
}

class _StudentDashboardHome extends StatelessWidget {
  const _StudentDashboardHome({
    required this.groupsRef,
    required this.studentRef,
    required this.currentUid,
  });

  final DatabaseReference groupsRef;
  final DatabaseReference studentRef;
  final String currentUid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: groupsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.snapshot.value is Map) {
          final groups = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          
          final myGroupEntry = groups.entries.where((e) {
            final members = e.value['members'] is Map ? Map<String, dynamic>.from(e.value['members'] as Map) : {};
            return members.containsKey(currentUid);
          }).firstOrNull;

          if (myGroupEntry != null) {
            final myGroup = Map<String, dynamic>.from(myGroupEntry.value as Map);
            final proposalStatus = myGroup['proposalStatus'] as String? ?? 'Not Submitted';
            final supervisorName = myGroup['supervisorName'] as String? ?? 'Not Assigned Yet';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DashboardBanner(
                    title: 'Welcome Back!',
                    subtitle: 'Track your FYP journey and collaborate with your supervisor.',
                    icon: Icons.waving_hand,
                  ),
                  const SizedBox(height: 20),
                  
                  // Supervisor Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFEDF1F9),
                          child: Icon(Icons.supervisor_account, color: Color(0xFF14375E)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('YOUR SUPERVISOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1)),
                              Text(supervisorName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF14375E))),
                            ],
                          ),
                        ),
                        if (myGroup['supervisorId'] != null)
                          const Icon(Icons.verified, color: Colors.blue, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85, // Adjust for taller content
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _StatCard(
                        title: 'Group Code',
                        value: myGroupEntry.key,
                        icon: Icons.tag,
                        color: const Color(0xFF1E6091),
                      ),
                      _StatCard(
                        title: 'Proposal Status',
                        value: proposalStatus,
                        icon: Icons.description,
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: _StatCard(
                      title: 'Project Title',
                      value: myGroup['projectTitle'] ?? 'No Title Set',
                      icon: Icons.lightbulb_outline,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (myGroup['vivaDate'] != null) ...[
                    Builder(
                      builder: (context) {
                        final vivaDate = DateTime.parse(myGroup['vivaDate']);
                        final now = DateTime.now();
                        // Only show if the viva date hasn't passed yet
                        if (vivaDate.isBefore(now.subtract(const Duration(days: 1)))) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.1)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.stars, color: Colors.white, size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        'OFFICIAL VIVA SCHEDULED',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F3FF),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Icon(Icons.calendar_month, color: Color(0xFF8B5CF6)),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vivaDate.toLocal().toString().split(' ')[0],
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            const Text(
                                              'Set by FYP Committee',
                                              style: TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFCBD5E1)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          }
        }

        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_add, size: 64, color: Color(0xFFCBD5E1)),
                SizedBox(height: 16),
                Text('No Group Assigned', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                Text('Join or create a group to start your FYP.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.08), color.withOpacity(0.02)],
        ),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF14375E),
                    fontSize: 28,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14375E), Color(0xFF1E6091)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14375E).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withOpacity(0.12),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        height: 1.5,
                        fontSize: 13,
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


class _SupervisorsListSection extends StatefulWidget {
  const _SupervisorsListSection({
    required this.groupsRef,
    required this.studentRef,
    required this.currentUid,
    this.groupId,
  });

  final DatabaseReference groupsRef;
  final DatabaseReference studentRef;
  final String currentUid;
  final String? groupId;

  @override
  State<_SupervisorsListSection> createState() => _SupervisorsListSectionState();
}

class _SupervisorsListSectionState extends State<_SupervisorsListSection> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');

  Future<void> _sendRequest(String supervisorUid, String supervisorName) async {
    if (widget.groupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be in a group to request a supervisor.')),
      );
      return;
    }

    try {
      // 1. Get student and group info
      final studentSnap = await widget.studentRef.get();
      final groupSnap = await widget.groupsRef.child(widget.groupId!).get();
      
      final studentData = studentSnap.value is Map ? Map<String, dynamic>.from(studentSnap.value as Map) : {};
      final groupData = groupSnap.value is Map ? Map<String, dynamic>.from(groupSnap.value as Map) : {};
      
      final studentName = studentData['name'] ?? 'Unknown Student';
      final groupName = groupData['groupName'] ?? 'No Group Name';
      final projectName = groupData['projectTitle'] ?? 'No Project Title';

      // 2. Send request to supervisor
      final requestRef = FirebaseDatabase.instance.ref('supervisor').child(supervisorUid).child('requests').push();
      await requestRef.set({
        'studentId': widget.currentUid,
        'studentName': studentName,
        'groupId': widget.groupId,
        'groupCode': widget.groupId, // Using groupId as code for simplicity
        'groupName': groupName,
        'projectName': projectName,
        'status': 'Pending',
        'timestamp': ServerValue.timestamp,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request sent to $supervisorName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: _usersRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final supervisors = <Map<String, dynamic>>[];
        if (snapshot.hasData && snapshot.data!.snapshot.value is Map) {
          final allUsers = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          allUsers.forEach((uid, data) {
            if (data is Map && data['role'] == 'supervisor') {
              supervisors.add({
                'uid': uid,
                'name': data['name'] ?? 'Supervisor',
                'dept': data['department'] ?? 'General',
              });
            }
          });
        }

        if (supervisors.isEmpty) {
          return const Center(child: Text('No supervisors found in the system.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: supervisors.length,
          itemBuilder: (context, index) {
            final supervisor = supervisors[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: const Icon(Icons.supervisor_account, color: Color(0xFF1E6091), size: 22),
                ),
                title: Text(
                  supervisor['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF14375E)),
                ),
                subtitle: Text(supervisor['dept']),
                trailing: FilledButton.icon(
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Request'),
                  onPressed: () => _sendRequest(supervisor['uid'], supervisor['name']),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SubmitProposalSection extends StatefulWidget {
  const _SubmitProposalSection({required this.groupsRef, required this.currentUid, this.groupId});

  final DatabaseReference groupsRef;
  final String currentUid;
  final String? groupId;

  @override
  State<_SubmitProposalSection> createState() => _SubmitProposalSectionState();
}

class _SubmitProposalSectionState extends State<_SubmitProposalSection> {
  bool _uploading = false;
  double _progress = 0;
  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    if (widget.groupId == null) return;
    final snap = await widget.groupsRef.child(widget.groupId!).get();
    if (snap.exists && snap.value is Map) {
      final data = Map<String, dynamic>.from(snap.value as Map);
      if (mounted) {
        setState(() {
          _titleController.text = data['projectTitle'] ?? '';
          _descController.text = data['description'] ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _uploadProposal() async {
    if (widget.groupId == null) return;

    final typeGroup = XTypeGroup(label: 'PDFs', extensions: ['pdf']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    
    if (file == null) return;

    setState(() {
      _uploading = true;
      _progress = 0;
    });

    try {
      final bytes = await file.readAsBytes();
      final url = await CloudinaryService.uploadFile(
        fileBytes: bytes,
        fileName: file.name,
        folder: 'proposals/${widget.groupId}',
        onProgress: (p) => setState(() => _progress = p),
      );

      if (url != null) {
        await widget.groupsRef.child(widget.groupId!).update({
          'projectTitle': _titleController.text.trim(),
          'description': _descController.text.trim(),
          'proposalUrl': url,
          'proposalStatus': 'Submitted',
          'proposalSubmittedAt': ServerValue.timestamp,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proposal submitted successfully!')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.groupId == null) return const Center(child: Text('Join a group to submit proposals.'));

    return StreamBuilder(
      stream: widget.groupsRef.child(widget.groupId!).onValue,
      builder: (context, snapshot) {
        final groupData = snapshot.data?.snapshot.value is Map ? Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map) : {};
        final proposalUrl = groupData['proposalUrl'];
        final status = groupData['proposalStatus'] ?? 'Not Submitted';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DashboardBanner(
                title: 'FYP Proposal',
                subtitle: 'Current Status: $status',
                icon: Icons.assignment_turned_in,
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Proposal Details',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Project Title',
                          hintText: 'Enter your project title',
                          prefixIcon: Icon(Icons.title),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Project Summary',
                          hintText: 'Briefly describe your project',
                          prefixIcon: Icon(Icons.description),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Center(child: Icon(Icons.picture_as_pdf, size: 48, color: Color(0xFF1E6091))),
                      const SizedBox(height: 12),
                      if (proposalUrl != null)
                        Center(
                          child: Text(
                            'Current Document: Submitted',
                            style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      const SizedBox(height: 20),
                      if (_uploading)
                        Column(
                          children: [
                            LinearProgressIndicator(value: _progress),
                            const SizedBox(height: 8),
                            Text('${(_progress * 100).toInt()}% uploaded'),
                          ],
                        )
                      else
                        FilledButton.icon(
                          onPressed: _uploadProposal,
                          icon: const Icon(Icons.cloud_upload),
                          label: Text(proposalUrl == null ? 'Submit Proposal (PDF)' : 'Update & Resubmit'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF000000),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProposalStatusSection extends StatelessWidget {
  const _ProposalStatusSection({required this.groupsRef, required this.currentUid});

  final DatabaseReference groupsRef;
  final String currentUid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: groupsRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('No proposal submitted yet'));
        }

        final groups = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
        final myGroup = groups.values.whereType<Map>().firstWhere(
          (group) {
            final members = group['members'] is Map ? Map<String, dynamic>.from(group['members'] as Map) : {};
            return members.containsKey(currentUid);
          },
          orElse: () => {},
        );

        if (myGroup.isEmpty) {
          return const Center(child: Text('You are not part of any group'));
        }

        final status = myGroup['proposalStatus'] ?? 'Not Submitted';
        final statusColor = status == 'Approved' ? Colors.green : status == 'Pending' ? Colors.orange : Colors.red;

        return Center(
          child: Card(
            margin: const EdgeInsets.all(16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: statusColor.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.pending_actions, size: 48, color: statusColor),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Proposal Status',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Chip(
                    label: Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    backgroundColor: statusColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UploadDocumentsSection extends StatefulWidget {
  const _UploadDocumentsSection({required this.studentRef, required this.currentUid, required this.groupsRef, this.groupId});

  final DatabaseReference studentRef;
  final String currentUid;
  final DatabaseReference groupsRef;
  final String? groupId;

  @override
  State<_UploadDocumentsSection> createState() => _UploadDocumentsSectionState();
}

class _UploadDocumentsSectionState extends State<_UploadDocumentsSection> {
  bool _uploading = false;
  double _uploadProgress = 0;
  String _uploadLabel = '';

  Future<void> _pickAndUploadFile() async {
    try {
      final file = await openFile();
      if (file == null) return;

      final titleController = TextEditingController(text: file.name);
      final descriptionController = TextEditingController();

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          bool isUploading = false;
          double dialogProgress = 0;
          String? dialogError;

          Future<void> startUpload(StateSetter setDialogState) async {
            final title = titleController.text.trim();
            if (title.isEmpty) {
              setDialogState(() {
                dialogError = 'Please enter a title';
              });
              return;
            }

            setDialogState(() {
              isUploading = true;
              dialogError = null;
            });

            final success = await _uploadFile(
              file,
              title,
              descriptionController.text.trim(),
              onProgress: (progress) {
                if (!mounted) return;
                setDialogState(() {
                  dialogProgress = progress;
                });
              },
            );

            if (!mounted) {
              return;
            }

            if (success) {
              Navigator.of(dialogContext).pop();
            } else {
              setDialogState(() {
                isUploading = false;
                dialogProgress = 0;
              });
            }
          }

          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Upload Document'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: titleController,
                        enabled: !isUploading,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        enabled: !isUploading,
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      Text('File: ${file.name}'),
                      const SizedBox(height: 16),
                      if (isUploading) ...[
                        LinearProgressIndicator(value: dialogProgress.toDouble()),
                        const SizedBox(height: 8),
                        Text('Uploading... ${(dialogProgress * 100).toStringAsFixed(0)}%'),
                      ],
                      if (dialogError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          dialogError!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isUploading ? null : () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: isUploading ? null : () => startUpload(setDialogState),
                    child: Text(isUploading ? 'Uploading' : 'Upload'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<bool> _uploadFile(
    XFile file,
    String title,
    String description, {
    required ValueChanged<double> onProgress,
  }) async {
    try {
      setState(() {
        _uploading = true;
        _uploadLabel = file.name;
        _uploadProgress = 0;
      });

      final bytes = await file.readAsBytes();
      final docId = widget.studentRef.child('documents').push().key;
      if (docId == null) throw Exception('Failed to generate document ID');

      final downloadUrl = await CloudinaryService.uploadFile(
        fileBytes: bytes,
        fileName: file.name,
        folder: 'student_documents/${widget.currentUid}/$docId',
        onProgress: (progress) {
          onProgress(progress);
          if (mounted) {
            setState(() {
              _uploadProgress = progress;
            });
          }
        },
      );

      if (downloadUrl == null) {
        throw Exception('Failed to get download URL from Cloudinary');
      }

      // Save metadata to database (Student private list)
      await widget.studentRef.child('documents').child(docId).set({
        'title': title,
        'description': description,
        'fileName': file.name,
        'fileSize': bytes.length,
        'downloadUrl': downloadUrl,
        'uploadedAt': DateTime.now().toIso8601String(),
        'uploadedBy': FirebaseAuth.instance.currentUser?.email ?? '',
      });

      // Also save to Group node if student is in a group (so Supervisor can see it)
      if (widget.groupId != null) {
        await widget.groupsRef.child(widget.groupId!).child('documents').child(docId).set({
          'title': title,
          'description': description,
          'fileName': file.name,
          'downloadUrl': downloadUrl,
          'type': 'Group Doc',
          'uploadedAt': DateTime.now().toIso8601String(),
          'uploadedBy': FirebaseAuth.instance.currentUser?.email ?? '',
        });
      }

      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully')),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: $e')),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Upload Documents',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: const Color(0xFF14375E),
            ),
          ),
          const SizedBox(height: 20),
          if (_uploading) ...[
            Text(
              'Uploading $_uploadLabel',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF14375E)),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _uploadProgress.toDouble(),
                minHeight: 8,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E6091)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_uploadProgress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
          ],
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.cloud_upload, size: 48, color: Color(0xFF1E6091)),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Choose Document'),
                    onPressed: _uploading ? null : _pickAndUploadFile,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Documents',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: const Color(0xFF14375E),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<DatabaseEvent>(
            stream: widget.studentRef.child('documents').onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data?.snapshot.value;
              if (data == null) {
                return const Center(child: Text('No documents uploaded yet'));
              }

              if (data is! Map) {
                return const Center(child: Text('No documents uploaded yet'));
              }

              final docs = (data as Map).entries.toList();
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = Map<String, dynamic>.from(docs[index].value as Map);
                  final title = doc['title'] ?? 'Untitled';
                  final fileName = doc['fileName'] ?? 'File';
                  final uploadedAt = doc['uploadedAt'] ?? '';

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFEEF2FF),
                        child: const Icon(Icons.description, color: Color(0xFF1E6091)),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF14375E)),
                      ),
                      subtitle: Text(
                        fileName,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new, color: Color(0xFF1E6091)),
                        onPressed: () async {
                          final downloadUrl = doc['downloadUrl'];
                          if (downloadUrl != null) {
                            final uri = Uri.parse(downloadUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Could not open document')),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TasksMilestonesSection extends StatelessWidget {
  const _TasksMilestonesSection({required this.groupsRef, this.groupId});

  final DatabaseReference groupsRef;
  final String? groupId;

  @override
  Widget build(BuildContext context) {
    if (groupId == null) return const Center(child: Text('Join a group to see tasks.'));

    return StreamBuilder(
      stream: groupsRef.child(groupId!).child('tasks').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('No tasks assigned by supervisor yet'));
        }

        final tasks = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
        final tasksList = tasks.entries.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasksList.length,
          itemBuilder: (context, index) {
            final taskId = tasksList[index].key;
            final task = Map<String, dynamic>.from(tasksList[index].value);
            final status = task['status'] ?? 'Pending';
            final isCompleted = status == 'Completed';
            final isVerified = status == 'Verified';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: isVerified ? Colors.green[50] : (isCompleted ? Colors.orange[50] : const Color(0xFFFEF3C7)),
                  child: Icon(
                    isVerified ? Icons.check_circle : (isCompleted ? Icons.pending : Icons.assignment),
                    color: isVerified ? Colors.green : (isCompleted ? Colors.orange : const Color(0xFFB45309)),
                  ),
                ),
                title: Text(
                  task['title'] ?? 'Task ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF14375E)),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deadline: ${task['deadline'] ?? 'No'} ${task['deadlineTime'] ?? ''}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: isVerified ? 1.0 : (isCompleted ? 0.75 : 0.25),
                        backgroundColor: const Color(0xFFE2E8F0),
                        color: isVerified ? Colors.green : (isCompleted ? Colors.orange : const Color(0xFF3B82F6)),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task['description'] ?? 'No description provided.', style: const TextStyle(fontSize: 13)),
                        const Divider(height: 24),
                        if (isVerified) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                const Icon(Icons.grade, color: Colors.green),
                                const SizedBox(width: 8),
                                Text('Your Marks: ${((task['memberMarks'] as Map?)?[FirebaseAuth.instance.currentUser?.uid] ?? 0)} / 100', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              ],
                            ),
                          ),
                        ] else if (isCompleted) ...[
                          const Text('Waiting for supervisor verification...', style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic)),
                        ] else ...[
                          const Text('Your Submission:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            decoration: const InputDecoration(
                              hintText: 'Enter your work link or submission text...',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            maxLines: 2,
                            onSubmitted: (val) => _submitTask(taskId, val),
                          ),
                          const SizedBox(height: 12),
                          if (_isDeadlinePassed(task['deadline'], task['deadlineTime']))
                            const Text('Deadline passed. Submissions are closed.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                          else
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => _showSubmitDialog(context, taskId),
                                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF14375E)),
                                child: const Text('Submit Task'),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _submitTask(String taskId, String submission) async {
    await groupsRef.child(groupId!).child('tasks').child(taskId).update({
      'submission': submission,
      'status': 'Completed',
      'submittedAt': DateTime.now().toIso8601String(),
    });
  }

  void _showSubmitDialog(BuildContext context, String taskId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Task'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter document link or description of your work...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _submitTask(taskId, controller.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

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
    final buffer = (timeStr != null && timeStr.contains(':')) ? const Duration(hours: 2) : Duration.zero;
    return DateTime.now().isAfter(deadline.add(buffer));
  } catch (e) {
    return false;
  }
}

class _WeeklyProgressSection extends StatefulWidget {
  const _WeeklyProgressSection({required this.groupsRef, this.groupId});

  final DatabaseReference groupsRef;
  final String? groupId;

  @override
  State<_WeeklyProgressSection> createState() => _WeeklyProgressSectionState();
}

class _WeeklyProgressSectionState extends State<_WeeklyProgressSection> {
  double _progressValue = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.groupId == null) return const Center(child: Text('Join a group to update progress.'));

    return StreamBuilder(
      stream: widget.groupsRef.child(widget.groupId!).onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.snapshot.value is Map) {
          final groupData = snapshot.data!.snapshot.value as Map;
          _progressValue = (groupData['progressPercentage'] ?? 0).toDouble();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Update Project Progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text('Slide to update the overall completion percentage of your FYP.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              Text(
                '${_progressValue.toInt()}%',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Color(0xFF1E6091)),
              ),
              Slider(
                value: _progressValue,
                min: 0,
                max: 100,
                divisions: 100,
                label: '${_progressValue.toInt()}%',
                onChanged: (val) {
                  setState(() => _progressValue = val);
                },
                onChangeEnd: (val) async {
                  await widget.groupsRef.child(widget.groupId!).update({
                    'progressPercentage': val.toInt(),
                    'lastProgressUpdate': DateTime.now().toIso8601String(),
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progress updated successfully')));
                  }
                },
              ),
              const SizedBox(height: 20),
              const Card(
                color: Color(0xFFEEF2FF),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF1E6091)),
                      SizedBox(width: 12),
                      Expanded(child: Text('This percentage is visible to your supervisor for real-time tracking.', style: TextStyle(fontSize: 12))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MeetingRequestsSection extends StatefulWidget {
  const _MeetingRequestsSection({required this.groupsRef, this.groupId});

  final DatabaseReference groupsRef;
  final String? groupId;

  @override
  State<_MeetingRequestsSection> createState() => _MeetingRequestsSectionState();
}

class _MeetingRequestsSectionState extends State<_MeetingRequestsSection> {
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  String _selectedDuration = '15 min';

  final List<String> _durations = ['5 min', '10 min', '15 min', '30 min', '60 min'];

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _timeController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.groupId == null) return const Center(child: Text('Join a group to request meetings.'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _DashboardBanner(
            title: 'Schedule Meeting',
            subtitle: 'Request an online video session with your supervisor.',
            icon: Icons.video_call,
          ),
          const SizedBox(height: 24),
          
          TextField(
            controller: _dateController,
            decoration: InputDecoration(
              labelText: 'Select Date',
              hintText: 'YYYY-MM-DD',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date != null) {
                _dateController.text = date.toString().split(' ')[0];
              }
            },
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _timeController,
            decoration: InputDecoration(
              labelText: 'Select Time',
              hintText: 'HH:MM',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.access_time),
            ),
            readOnly: true,
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                _timeController.text = time.format(context);
              }
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedDuration,
            decoration: InputDecoration(
              labelText: 'Duration',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.timer_outlined),
            ),
            items: _durations.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedDuration = val);
            },
          ),
          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: () async {
              if (_dateController.text.isNotEmpty && _timeController.text.isNotEmpty) {
                await widget.groupsRef.child(widget.groupId!).child('meetings').push().set({
                  'requestedDate': _dateController.text,
                  'requestedTime': _timeController.text,
                  'duration': _selectedDuration,
                  'status': 'Pending',
                  'meetingLink': 'https://meet.google.com/new', // Dummy for now
                  'timestamp': DateTime.now().toIso8601String(),
                });
                _dateController.clear();
                _timeController.clear();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meeting request sent!')));
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select date and time.')));
              }
            },
            icon: const Icon(Icons.send),
            label: const Text('Request Meeting'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF000000),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 40),
          
          Text('Your Meeting Requests', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          StreamBuilder(
            stream: widget.groupsRef.child(widget.groupId!).child('meetings').onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No meeting requests yet.')));
              }
              final meetings = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
              final sortedMeetings = meetings.entries.toList()..sort((a, b) => (b.value['timestamp'] as String).compareTo(a.value['timestamp'] as String));

              return Column(
                children: sortedMeetings.map((entry) {
                  final m = entry.value as Map;
                  final status = m['status'] ?? 'Pending';
                  final isApproved = status == 'Approved';

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: isApproved ? Colors.green.withOpacity(0.3) : const Color(0xFFE2E8F0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isApproved ? Colors.green[50] : const Color(0xFFEDF1F9),
                              child: Icon(Icons.video_call, color: isApproved ? Colors.green : const Color(0xFF14375E)),
                            ),
                            title: Text('${m['requestedDate']} at ${m['requestedTime'] ?? 'N/A'}'),
                            subtitle: Text('Duration: ${m['duration'] ?? 'N/A'}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isApproved ? Colors.green[100] : (status == 'Rejected' ? Colors.red[50] : Colors.orange[50]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isApproved ? Colors.green[700] : (status == 'Rejected' ? Colors.red[700] : Colors.orange[700]))),
                            ),
                          ),
                          if (isApproved) ...[
                            const Divider(height: 24),
                            if (_isDeadlinePassed(m['requestedDate'], m['requestedTime']))
                              const Text('Meeting link expired.', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold))
                            else
                              FilledButton.icon(
                                onPressed: () async {
                                  final url = Uri.parse(m['meetingLink'] ?? 'https://meet.google.com/new');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                                icon: const Icon(Icons.play_arrow, size: 18),
                                label: const Text('Join Video Meeting'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  minimumSize: const Size(double.infinity, 40),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DeadlinesSection extends StatelessWidget {
  const _DeadlinesSection({required this.adminRef, required this.groupsRef, this.groupId});

  final DatabaseReference adminRef;
  final DatabaseReference groupsRef;
  final String? groupId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Global Deadlines', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          StreamBuilder(
            stream: adminRef.child('evaluationSchedule').onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) return const Center(child: Text('No global deadlines.'));
              final schedule = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
              return Column(
                children: schedule.values.map((event) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today, color: Colors.orange),
                    title: Text(event['eventName'] ?? 'Event'),
                    subtitle: Text(event['date'] ?? 'TBD'),
                  ),
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Group-Specific Deadlines', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (groupId == null)
            const Text('Join a group to see supervisor-set deadlines.')
          else
            StreamBuilder(
              stream: groupsRef.child(groupId!).onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) return const Text('No group deadlines.');
                final groupData = snapshot.data!.snapshot.value as Map;
                final deadline = groupData['proposalDeadline'];
                if (deadline == null) return const Text('No custom deadline set by supervisor yet.');
                return Card(
                  color: const Color(0xFFF0FDF4),
                  child: ListTile(
                    leading: const Icon(Icons.description, color: Colors.green),
                    title: const Text('Proposal Submission Deadline'),
                    subtitle: Text(deadline, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _AnnouncementsSection extends StatelessWidget {
  const _AnnouncementsSection({required this.adminRef});

  final DatabaseReference adminRef;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: adminRef.child('announcements').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('No announcements'));
        }

        final announcements = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
        final announcementsList = announcements.entries.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: announcementsList.length,
          itemBuilder: (context, index) {
            final announcement = Map<String, dynamic>.from(announcementsList[index].value);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: const Icon(Icons.notifications, color: Color(0xFF1E6091)),
                ),
                title: Text(
                  announcement['title'] ?? 'Announcement',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF14375E)),
                ),
                subtitle: Text(
                  announcement['content'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MarksAndFeedbackSection extends StatelessWidget {
  const _MarksAndFeedbackSection({required this.groupsRef, this.groupId});

  final DatabaseReference groupsRef;
  final String? groupId;

  @override
  Widget build(BuildContext context) {
    if (groupId == null) return const Center(child: Text('Join a group to see marks.'));

    return StreamBuilder(
      stream: groupsRef.child(groupId!).onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('No marks assigned yet'));
        }

        final groupData = snapshot.data!.snapshot.value as Map;
        final marks = groupData['marks'];
        final remarks = groupData['remarks'];

        if (marks == null) return const Center(child: Text('Supervisor has not graded your project yet.'));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Project Grade',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF14375E)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
                        child: Text('$marks/100', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E6091), fontSize: 18)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: marks / 100,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(marks >= 50 ? Colors.green : Colors.red),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Supervisor Feedback:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(remarks ?? 'No comments provided.', style: const TextStyle(color: Color(0xFF64748B), height: 1.6)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SharedDocumentsSection extends StatefulWidget {
  const _SharedDocumentsSection({super.key});

  @override
  State<_SharedDocumentsSection> createState() => _SharedDocumentsSectionState();
}

class _SharedDocumentsSectionState extends State<_SharedDocumentsSection> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  final DatabaseReference _byRoleRef = FirebaseDatabase.instance.ref('documents_by_role');
  String _role = 'Student';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await _usersRef.child(user.uid).get();
    if (snap.exists && snap.value is Map) {
      final data = Map<String, dynamic>.from(snap.value as Map);
      if (mounted) setState(() => _role = (data['role'] as String?) ?? 'Student');
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
            'fileUrl': val['fileUrl'] ?? '',
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
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEDF1F9),
                  child: Icon(Icons.description, color: Color(0xFF14375E)),
                ),
                title: Text(doc['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(doc['description'].isNotEmpty ? doc['description'] : 'File: ${doc['fileName']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.download, color: Color(0xFF1E6091)),
                  onPressed: () async {
                    final url = Uri.parse(doc['fileUrl']);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
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
