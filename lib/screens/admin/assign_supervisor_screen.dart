import 'package:flutter/material.dart';

import 'admin_nav_bar.dart';

class AssignSupervisorScreen extends StatefulWidget {
  const AssignSupervisorScreen({super.key});

  static const String routeName = '/admin-assign-supervisor';

  @override
  State<AssignSupervisorScreen> createState() => _AssignSupervisorScreenState();
}

class _AssignSupervisorScreenState extends State<AssignSupervisorScreen> {
  final List<String> _students = [
    'Aisha Khan',
    'Bilal Ahmed',
    'Maha Saeed',
    'Noor Siddiqui',
  ];
  final List<String> _supervisors = [
    'Dr. Malik',
    'Dr. Sana',
    'Dr. Rehan',
    'Dr. Iqra',
  ];

  String? _selectedStudent;
  String? _selectedSupervisor;

  bool get _canAssign =>
      _selectedStudent != null && _selectedSupervisor != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Supervisor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select a student',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _students.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final student = _students[index];
                  final isSelected = student == _selectedStudent;

                  return ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFE6E6E6)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE8EEF6),
                      child: Text(student.substring(0, 1)),
                    ),
                    title: Text(student),
                    subtitle: const Text('BS Computer Science'),
                    trailing: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFF5F6C7B),
                    ),
                    onTap: () => setState(() => _selectedStudent = student),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select supervisor',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedSupervisor,
              items: _supervisors
                  .map(
                    (supervisor) => DropdownMenuItem<String>(
                      value: supervisor,
                      child: Text(supervisor),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedSupervisor = value),
              decoration: const InputDecoration(labelText: 'Select Supervisor'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _canAssign ? () {} : null,
              child: const Text('Assign Supervisor'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminNavBar(selectedIndex: 0),
    );
  }
}
