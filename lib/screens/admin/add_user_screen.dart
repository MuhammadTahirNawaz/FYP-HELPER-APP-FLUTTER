import 'package:flutter/material.dart';

import '../../data/admin_mock_store.dart';
import '../../data/roles.dart';
import 'admin_nav_bar.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  static const String routeName = '/admin-add-user';

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedRole = kUserRoles.first;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool get _isEmailValid {
    final email = _emailController.text.trim();
    final atIndex = email.indexOf('@');
    if (atIndex <= 0) {
      return false;
    }
    final dotIndex = email.indexOf('.', atIndex + 1);
    return dotIndex > atIndex + 1;
  }

  bool get _canSubmit {
    return _nameController.text.trim().isNotEmpty && _isEmailValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'User Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter full name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'name@university.edu',
                      errorText: _emailController.text.isEmpty || _isEmailValid
                          ? null
                          : 'Enter a valid email',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    items: kUserRoles
                        .map(
                          (role) => DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _selectedRole = value);
                    },
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _canSubmit
                        ? () {
                            final trimmedName = _nameController.text.trim();
                            final trimmedEmail = _emailController.text.trim();

                            AdminMockStore.instance.addUser(
                              AdminUser(
                                name: trimmedName,
                                role: _selectedRole,
                                status: 'Invited',
                              ),
                            );

                            _nameController.clear();
                            _emailController.clear();
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Invite sent to $trimmedEmail'),
                              ),
                            );
                          }
                        : null,
                    child: const Text('Create User'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Recent Adds',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<List<AdminUser>>(
            valueListenable: AdminMockStore.instance.users,
            builder: (context, users, _) {
              if (users.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: const Text('No users added yet.'),
                );
              }

              return Column(
                children: users
                    .map(
                      (user) => Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFE6E6E6)),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE8EEF6),
                            child: Text(user.name.substring(0, 1)),
                          ),
                          title: Text(user.name),
                          subtitle: Text(user.role),
                          trailing: _StatusChip(label: user.status),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const AdminNavBar(selectedIndex: 0),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = colorScheme.primary.withOpacity(0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: colorScheme.primary)),
    );
  }
}
