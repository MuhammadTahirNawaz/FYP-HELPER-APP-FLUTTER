import 'package:flutter/material.dart';

import '../../../models/user_account.dart';
import '../../../repositories/user_repository.dart';
import '../widgets/admin_pending_user_card.dart';
import '../widgets/admin_user_card.dart';

class AdminUserManagementSection extends StatefulWidget {
  const AdminUserManagementSection({
    super.key,
    required this.userRepository,
    this.university,
  });

  final UserRepository userRepository;
  final String? university;

  @override
  State<AdminUserManagementSection> createState() =>
      _AdminUserManagementSectionState();
}

class _AdminUserManagementSectionState extends State<AdminUserManagementSection> {
  final Map<String, String> _pendingSelections = {};
  bool _updating = false;

  Future<void> _approveUser(UserAccount user) async {
    if (_updating) return;
    setState(() => _updating = true);
    final role = _pendingSelections[user.uid] ?? user.requestedRole ?? 'Student';
    await widget.userRepository.approveAccount(uid: user.uid, role: role);
    if (mounted) {
      setState(() => _updating = false);
    }
  }

  Future<void> _rejectUser(UserAccount user) async {
    if (_updating) return;
    setState(() => _updating = true);
    await widget.userRepository.rejectAccount(user.uid);
    if (mounted) {
      setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.userRepository.watchAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data?.snapshot.value;
        if (data is! Map) {
          return const Center(child: Text('No users found.'));
        }

        final users = widget.userRepository
            .listFromSnapshot(data)
            .where(
              (user) =>
                  widget.university != null && user.university == widget.university,
            )
            .toList();

        final pending = users.where((user) => user.role == 'Pending').toList();
        final verified = users.where((user) => user.role != 'Pending').toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionHeader(context, 'Pending Users', pending.length),
            const SizedBox(height: 8),
            ...pending.map(
              (user) => AdminPendingUserCard(
                user: user,
                selectedRole: _pendingSelections[user.uid] ?? user.requestedRole,
                onRoleChanged: (value) => setState(() {
                  _pendingSelections[user.uid] = value;
                }),
                onApprove: () => _approveUser(user),
                onReject: () => _rejectUser(user),
                disabled: _updating,
              ),
            ),
            const SizedBox(height: 20),
            _sectionHeader(context, 'Verified Users', verified.length),
            const SizedBox(height: 8),
            ...verified.map((user) => AdminUserCard(user: user)),
          ],
        );
      },
    );
  }

  Widget _sectionHeader(BuildContext context, String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        Text('$count', style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
