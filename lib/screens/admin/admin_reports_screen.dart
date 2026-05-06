import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'admin_nav_bar.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  static const String routeName = '/admin-reports';

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const List<_ReportFile> _reports = [
    _ReportFile(
      title: 'Submission Summary',
      period: 'Last 7 days',
      fileName: 'submission_summary_week_17.pdf',
      size: '1.2 MB',
      downloadUrl: 'https://example.com/reports/submission_summary_week_17.pdf',
      icon: Icons.assignment_turned_in,
    ),
    _ReportFile(
      title: 'Supervisor Load',
      period: 'Current semester',
      fileName: 'supervisor_load_semester_1.xlsx',
      size: '740 KB',
      downloadUrl:
          'https://example.com/reports/supervisor_load_semester_1.xlsx',
      icon: Icons.bar_chart,
    ),
    _ReportFile(
      title: 'Committee Reviews',
      period: 'This month',
      fileName: 'committee_reviews_april.pdf',
      size: '560 KB',
      downloadUrl: 'https://example.com/reports/committee_reviews_april.pdf',
      icon: Icons.fact_check,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ReportFile> _filterReports() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _reports;
    }

    return _reports.where((report) {
      return report.title.toLowerCase().contains(query) ||
          report.period.toLowerCase().contains(query) ||
          report.fileName.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _handleDownload(_ReportFile report) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Download Options',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                report.fileName,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(report.downloadUrl);
                  final launched = await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                  if (!mounted) {
                    return;
                  }
                  Navigator.of(context).pop();
                  _showSnack(
                    launched
                        ? 'Opening ${report.fileName} in browser.'
                        : 'Unable to open download link.',
                  );
                },
                icon: const Icon(Icons.link),
                label: const Text('Open Download Link'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final saveLocation = await getSaveLocation(
                    suggestedName: report.fileName,
                  );
                  if (!mounted) {
                    return;
                  }
                  Navigator.of(context).pop();
                  if (saveLocation == null) {
                    _showSnack('Download canceled.');
                    return;
                  }
                  _showSnack('Saved to ${saveLocation.path}');
                },
                icon: const Icon(Icons.save_alt),
                label: const Text('Choose Save Location'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = _filterReports();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Overview',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _StatChip(label: '3 Reports Available', icon: Icons.folder),
              _StatChip(label: 'Last updated today', icon: Icons.schedule),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search reports by title or file name',
            ),
          ),
          const SizedBox(height: 12),
          if (filteredReports.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              child: const Text('No reports match your search.'),
            )
          else
            ...filteredReports.map(
              (report) => _ReportCard(
                report: report,
                onDownload: () => _handleDownload(report),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const AdminNavBar(selectedIndex: 2),
    );
  }
}

class _ReportFile {
  const _ReportFile({
    required this.title,
    required this.period,
    required this.fileName,
    required this.size,
    required this.downloadUrl,
    required this.icon,
  });

  final String title;
  final String period;
  final String fileName;
  final String size;
  final String downloadUrl;
  final IconData icon;
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.onDownload});

  final _ReportFile report;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE6E6E6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFE8EEF6),
                  child: Icon(report.icon, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(report.period),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(report.fileName, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              report.size,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF5F6C7B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1B1B1B)),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
