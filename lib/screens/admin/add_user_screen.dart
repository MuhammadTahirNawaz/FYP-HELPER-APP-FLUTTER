import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../data/roles.dart';
import 'admin_nav_bar.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  static const String routeName = '/admin-add-user';

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref('users');
  String _selectedRole = kUserRoles.first;
  bool _isSubmitting = false;

  bool get _canSubmit {
    return !_isSubmitting;
  }

  List<String> get _provisionableRoles {
    return kUserRoles.where((role) => role != 'Admin').toList();
  }

  Future<void> _approveUser(String uid, String role) async {
    if (!_canSubmit) {
      return;
    }
    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await _usersRef.child(uid).update({
        'role': role,
        'status': 'Active',
        'updatedAt': ServerValue.timestamp,
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('User approved.')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Approval failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
          Text(
            'Pending Approvals',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          StreamBuilder<DatabaseEvent>(
            stream: _usersRef.onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snapshot.data?.snapshot.value;
              if (data is! Map) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: const Text('No pending users yet.'),
                );
              }

              final entries = Map<String, dynamic>.from(data);
              final pending = entries.entries
                  .map(
                    (entry) => _PendingUser.fromMap(
                      entry.key,
                      Map<String, dynamic>.from(entry.value as Map),
                    ),
                  )
                  .where((user) => user.role == 'Pending')
                  .toList();

              if (pending.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: const Text('No pending users yet.'),
                );
              }

              return Column(
                children: pending
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
                            backgroundColor: const Color(0xFFEDF1F9),
                            child: Text(user.email.substring(0, 1)),
                          ),
                          title: Text(user.email),
                          subtitle: Text(
                            user.requestedRole == null
                                ? 'Requested: -'
                                : 'Requested: ${user.requestedRole}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButton<String>(
                                value: _selectedRole,
                                items: _provisionableRoles
                                    .map(
                                      (role) => DropdownMenuItem<String>(
                                        value: role,
                                        child: Text(role),
                                      ),
                                    )
                                    .toList(),
                                onChanged: _isSubmitting
                                    ? null
                                    : (value) {
                                        if (value == null) {
                                          return;
                                        }
                                        setState(() => _selectedRole = value);
                                      },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.check_circle),
                                tooltip: 'Approve',
                                onPressed: _isSubmitting
                                    ? null
                                    : () => _approveUser(
                                          user.uid,
                                          _selectedRole,
                                        ),
                              ),
                            ],
                          ),
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

class _PendingUser {
  const _PendingUser({
    required this.uid,
    required this.email,
    required this.role,
    this.requestedRole,
  });

  final String uid;
  final String email;
  final String role;
  final String? requestedRole;

  factory _PendingUser.fromMap(String uid, Map<String, dynamic> data) {
    return _PendingUser(
      uid: uid,
      email: (data['email'] as String?) ?? '',
      role: (data['role'] as String?) ?? '',
      requestedRole: data['requestedRole'] as String?,
    );
  }
}
