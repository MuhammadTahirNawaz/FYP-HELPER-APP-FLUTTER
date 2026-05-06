import 'package:flutter/material.dart';

class AdminCommitteeAccessScreen extends StatelessWidget {
  const AdminCommitteeAccessScreen({super.key});

  static const String routeName = '/admin-committee-access';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Access'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _AccessTile(name: 'Dr. Nida', status: 'Approved'),
          _AccessTile(name: 'Dr. Usman', status: 'Pending'),
          _AccessTile(name: 'Dr. Zara', status: 'Review'),
        ],
      ),
    );
  }
}

class _AccessTile extends StatelessWidget {
  const _AccessTile({required this.name, required this.status});

  final String name;
  final String status;

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
          child: Icon(Icons.group_work, color: Color(0xFF1B1B1B)),
        ),
        title: Text(name),
        subtitle: Text('Status: $status'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
