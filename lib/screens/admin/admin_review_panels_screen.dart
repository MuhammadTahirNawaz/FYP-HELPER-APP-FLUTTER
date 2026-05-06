import 'package:flutter/material.dart';

class AdminReviewPanelsScreen extends StatelessWidget {
  const AdminReviewPanelsScreen({super.key});

  static const String routeName = '/admin-review-panels';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Panels'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _PanelTile(panel: 'Panel A', detail: '3 reviewers · 6 proposals'),
          _PanelTile(panel: 'Panel B', detail: '4 reviewers · 5 proposals'),
        ],
      ),
    );
  }
}

class _PanelTile extends StatelessWidget {
  const _PanelTile({required this.panel, required this.detail});

  final String panel;
  final String detail;

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
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8EEF6),
          child: Icon(Icons.fact_check, color: Color(0xFF1B1B1B)),
        ),
        title: Text(panel),
        subtitle: Text(detail),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
