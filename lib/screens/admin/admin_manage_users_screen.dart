import 'package:flutter/material.dart';

class AdminManageUsersScreen extends StatelessWidget {
  const AdminManageUsersScreen({super.key});

  static const String routeName = '/admin-manage-users';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _UserTile(name: 'Aisha Khan', role: 'Student', status: 'Active'),
          _UserTile(name: 'Dr. Sana', role: 'Supervisor', status: 'Active'),
          _UserTile(name: 'Omar Farooq', role: 'Committee', status: 'Pending'),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.name,
    required this.role,
    required this.status,
  });

  final String name;
  final String role;
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
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE8EEF6),
          child: Text(name.substring(0, 1)),
        ),
        title: Text(name),
        subtitle: Text(role),
        trailing: Text(status),
        onTap: () {},
      ),
    );
  }
}
