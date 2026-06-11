import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

import '../../theme/app_colors.dart';

import 'supervisor_nav_bar.dart';
import 'supervisor_dashboard_screen.dart';

class SupervisorProgressReportsScreen extends StatefulWidget {
  const SupervisorProgressReportsScreen({super.key});

  static const String routeName = '/supervisor-progress-reports';

  @override
  State<SupervisorProgressReportsScreen> createState() => _SupervisorProgressReportsScreenState();
}

class _SupervisorProgressReportsScreenState extends State<SupervisorProgressReportsScreen> {
  late String _supervisorUid;
  final DatabaseReference _groupsRef = FirebaseDatabase.instance.ref('groups');

  @override
  void initState() {
    super.initState();
    _supervisorUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(SupervisorDashboardScreen.routeName);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: const Text('Progress Reports'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushReplacementNamed(SupervisorDashboardScreen.routeName),
          ),
        ),
        body: StreamBuilder<DatabaseEvent>(
          stream: _groupsRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data?.snapshot.value;
            if (data is! Map) {
              return const Center(child: Text('No groups assigned yet.'));
            }

            final allGroups = Map<String, dynamic>.from(data);
            final myGroups = allGroups.entries
                .where((e) => e.value['supervisorId'] == _supervisorUid)
                .toList();

            if (myGroups.isEmpty) {
              return const Center(child: Text('No groups under your supervision.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myGroups.length,
              itemBuilder: (context, index) {
                final group = myGroups[index];
                final groupData = Map<String, dynamic>.from(group.value as Map);
                final title = groupData['projectTitle'] ?? 'No Title';
                final progress = groupData['progressPercentage'] ?? 0;
                final lastUpdate =
                    groupData['lastProgressUpdate'] ?? 'No updates yet';

                return _ReportCard(
                  title: title,
                  subtitle: 'Overall Progress: $progress% · $lastUpdate',
                  progress: progress.toDouble(),
                );
              },
            );
          },
        ),
        bottomNavigationBar: const SupervisorNavBar(selectedIndex: 2),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.subtitle,
    required this.progress,
  });

  final String title;
  final String subtitle;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: const CircleAvatar(
              backgroundColor: AppColors.surfaceMuted,
              child: Icon(Icons.analytics, color: AppColors.navy),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Potential detail view
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 8,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 80 ? Colors.green : (progress > 40 ? Colors.blue : Colors.orange),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
