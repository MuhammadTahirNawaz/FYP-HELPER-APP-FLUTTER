import 'package:flutter/material.dart';

class AdminDeactivateAccountsScreen extends StatelessWidget {
  const AdminDeactivateAccountsScreen({super.key});

  static const String routeName = '/admin-deactivate-accounts';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deactivate Accounts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _DeactivateTile(name: 'Bilal Ahmed', role: 'Student'),
          _DeactivateTile(name: 'Dr. Rehan', role: 'Supervisor'),
        ],
      ),
    );
  }
}

class _DeactivateTile extends StatelessWidget {
  const _DeactivateTile({required this.name, required this.role});

  final String name;
  final String role;

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
        trailing: const Text('Deactivate'),
        onTap: () {},
      ),
    );
  }
}
