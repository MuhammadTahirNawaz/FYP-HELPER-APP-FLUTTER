import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

import 'student_nav_bar.dart';
import 'student_dashboard_screen.dart';

class StudentReportsScreen extends StatelessWidget {
  const StudentReportsScreen({super.key});

  static const String routeName = '/student-reports';

  DatabaseReference get _reportsRef => FirebaseDatabase.instance.ref('admin/reports');

  int _toTimestamp(Object? value) => value is int ? value : 0;

  String _formatSubtitle(_StudentReportEntry entry) {
    final parts = <String>[];
    if (entry.period.isNotEmpty) {
      parts.add(entry.period);
    }
    if (entry.owner.isNotEmpty) {
      parts.add('By ${entry.owner}');
    }
    return parts.isEmpty ? 'Published by admin' : parts.join(' · ');
  }

  IconData _iconForTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('proposal')) {
      return Icons.description;
    }
    if (lowerTitle.contains('progress')) {
      return Icons.assignment_turned_in;
    }
    return Icons.article;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(StudentDashboardScreen.routeName);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushReplacementNamed(StudentDashboardScreen.routeName),
          ),
        ),
        body: StreamBuilder<DatabaseEvent>(
          stream: _reportsRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final reports = _StudentReportEntry.fromSnapshot(snapshot.data?.snapshot.value)
              ..sort((a, b) => _toTimestamp(b.updatedAt).compareTo(_toTimestamp(a.updatedAt)));

            if (reports.isEmpty) {
              return const Center(
                child: Text('No reports have been published by admin yet.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return _ReportCard(
                  title: report.title,
                  subtitle: _formatSubtitle(report),
                  icon: _iconForTitle(report.title),
                );
              },
            );
          },
        ),
        bottomNavigationBar: const StudentNavBar(selectedIndex: 3),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceMuted,
          child: Icon(icon, color: AppColors.navy),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}

class _StudentReportEntry {
  const _StudentReportEntry({
    required this.id,
    required this.title,
    required this.period,
    required this.owner,
    required this.summary,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String period;
  final String owner;
  final String summary;
  final Object? createdAt;
  final Object? updatedAt;

  static List<_StudentReportEntry> fromSnapshot(Object? data) {
    if (data is! Map) {
      return <_StudentReportEntry>[];
    }

    final entries = Map<String, dynamic>.from(data);
    return entries.entries.map((entry) {
      final value = Map<String, dynamic>.from(entry.value as Map);
      return _StudentReportEntry(
        id: entry.key,
        title: (value['title'] as String?) ?? 'Untitled Report',
        period: (value['period'] as String?) ?? '',
        owner: (value['owner'] as String?) ?? '',
        summary: (value['summary'] as String?) ?? '',
        createdAt: value['createdAt'],
        updatedAt: value['updatedAt'],
      );
    }).toList();
  }
}
