import 'package:flutter/material.dart';

import 'student_nav_bar.dart';
import 'student_profile_screen.dart';
import 'submit_progress_report_screen.dart';
import 'submit_proposal_screen.dart';
import 'viva_schedule_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  static const String routeName = '/student-dashboard';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFE8EEF6),
          child: Icon(Icons.school, color: Color(0xFF1B1B1B)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () =>
                Navigator.of(context).pushNamed(StudentProfileScreen.routeName),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE6E6E6)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatusStep(
                          icon: Icons.check_circle,
                          label: 'Draft',
                          color: colorScheme.primary,
                        ),
                        const Icon(Icons.arrow_right_alt),
                        const _StatusStep(
                          icon: Icons.radio_button_unchecked,
                          label: 'Supervisor',
                          color: Color(0xFF5F6C7B),
                        ),
                        const Icon(Icons.arrow_right_alt),
                        const _StatusStep(
                          icon: Icons.radio_button_unchecked,
                          label: 'Committee',
                          color: Color(0xFF5F6C7B),
                        ),
                      ],
                    ),
                  ],
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
              children: [
                _DashboardTile(
                  icon: Icons.note_add,
                  label: 'Submit Proposal',
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(SubmitProposalScreen.routeName),
                ),
                _DashboardTile(
                  icon: Icons.event_note,
                  label: 'Submit Progress Report',
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(SubmitProgressReportScreen.routeName),
                ),
                _DashboardTile(
                  icon: Icons.schedule,
                  label: 'View Viva Schedule',
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(VivaScheduleScreen.routeName),
                ),
                _DashboardTile(
                  icon: Icons.person_pin,
                  label: 'My Profile',
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(StudentProfileScreen.routeName),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const StudentNavBar(selectedIndex: 0),
    );
  }
}

class _StatusStep extends StatelessWidget {
  const _StatusStep({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFE8EEF6),
              child: Icon(icon, size: 24, color: colorScheme.primary),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
