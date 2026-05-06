import 'package:flutter/material.dart';

class AdminSupervisorLoadScreen extends StatelessWidget {
  const AdminSupervisorLoadScreen({super.key});

  static const String routeName = '/admin-supervisor-load';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisor Load'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _LoadTile(name: 'Dr. Malik', load: '4 projects'),
          _LoadTile(name: 'Dr. Sana', load: '3 projects'),
          _LoadTile(name: 'Dr. Iqra', load: '5 projects'),
        ],
      ),
    );
  }
}

class _LoadTile extends StatelessWidget {
  const _LoadTile({required this.name, required this.load});

  final String name;
  final String load;

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
          child: Icon(Icons.school, color: Color(0xFF1B1B1B)),
        ),
        title: Text(name),
        subtitle: Text(load),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
