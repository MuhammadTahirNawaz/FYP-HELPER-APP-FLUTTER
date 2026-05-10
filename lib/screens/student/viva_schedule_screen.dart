import 'package:flutter/material.dart';

class VivaScheduleScreen extends StatelessWidget {
  const VivaScheduleScreen({super.key});

  static const String routeName = '/student-viva-schedule';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viva Schedule'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ScheduleCard(
            title: 'Proposal Defense',
            subtitle: '12 May 2026 · Room 2.14',
            icon: Icons.event,
          ),
          _ScheduleCard(
            title: 'Final Viva',
            subtitle: '28 Aug 2026 · Room 3.09',
            icon: Icons.event_available,
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
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
          backgroundColor: const Color(0xFFEDF1F9),
          child: Icon(icon, color: const Color(0xFF14375E)),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
