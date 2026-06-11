import 'package:flutter/material.dart';

import '../../../models/user_account.dart';
import '../../../theme/app_colors.dart';

class AdminPendingUserCard extends StatelessWidget {
  const AdminPendingUserCard({
    super.key,
    required this.user,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onApprove,
    required this.onReject,
    required this.disabled,
  });

  final UserAccount user;
  final String? selectedRole;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool disabled;

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
        leading: CircleAvatar(
          backgroundColor: AppColors.selectedTile,
          child: Text(user.email.isEmpty ? '?' : user.email[0]),
        ),
        title: Text(user.email.isEmpty ? 'Unknown email' : user.email),
        subtitle: Text(
          user.requestedRole == null
              ? 'Requested: -'
              : 'Requested: ${user.requestedRole}',
        ),
        trailing: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedRole ?? 'Student',
              items: const [
                DropdownMenuItem(value: 'Student', child: Text('Student')),
                DropdownMenuItem(value: 'Supervisor', child: Text('Supervisor')),
                DropdownMenuItem(value: 'Committee', child: Text('Committee')),
              ],
              onChanged: disabled
                  ? null
                  : (value) {
                      if (value != null) onRoleChanged(value);
                    },
            ),
            IconButton(
              icon: const Icon(Icons.check_circle),
              tooltip: 'Approve',
              onPressed: disabled ? null : onApprove,
            ),
            IconButton(
              icon: const Icon(Icons.cancel),
              tooltip: 'Reject',
              onPressed: disabled ? null : onReject,
            ),
          ],
        ),
      ),
    );
  }
}
