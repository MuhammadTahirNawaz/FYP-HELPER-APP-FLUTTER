import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AdminDeactivateAccountsScreen extends StatelessWidget {
  const AdminDeactivateAccountsScreen({super.key});

  static const String routeName = '/admin-deactivate-accounts';

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseDatabase.instance.ref('users');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deactivate Accounts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: usersRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data?.snapshot.value;
          if (data is! Map) {
            return const Center(child: Text('No users found.'));
          }
          final allUsers = Map<String, dynamic>.from(data);
          // Show only active (non-admin, non-deactivated) users
          final active = allUsers.entries.where((e) {
            if (e.value is! Map) return false;
            final u = Map<String, dynamic>.from(e.value as Map);
            final status = (u['status'] as String?) ?? 'Active';
            final role = (u['role'] as String?) ?? '';
            return status != 'Deactivated' && role != 'Admin' && role != 'Pending';
          }).toList();

          if (active.isEmpty) {
            return const Center(child: Text('No active accounts to deactivate.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: active.length,
            itemBuilder: (context, index) {
              final uid = active[index].key;
              final user = Map<String, dynamic>.from(active[index].value as Map);
              final name = (user['displayName'] as String?) ??
                  (user['email'] as String?) ?? uid;
              final role = (user['role'] as String?) ?? '';
              final email = (user['email'] as String?) ?? '';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceMuted,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: AppColors.navy, fontWeight: FontWeight.w700),
                    ),
                  ),
                  title: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(email.isNotEmpty ? '$role · $email' : role,
                      style: const TextStyle(fontSize: 12)),
                  trailing: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                    ),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Deactivate Account?'),
                          content:
                              Text('This will block $name from signing in.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFDC2626)),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Deactivate'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await usersRef
                            .child(uid)
                            .update({'status': 'Deactivated'});
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$name deactivated.')),
                          );
                        }
                      }
                    },
                    child: const Text('Deactivate'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
