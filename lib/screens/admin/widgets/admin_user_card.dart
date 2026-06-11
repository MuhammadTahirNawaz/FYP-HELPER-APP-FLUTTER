import 'package:flutter/material.dart';

import '../../../models/user_account.dart';
import '../../../theme/app_colors.dart';

class AdminUserCard extends StatelessWidget {
  const AdminUserCard({super.key, required this.user});

  final UserAccount user;

  @override
  Widget build(BuildContext context) {
    final roleLabel = user.role.isEmpty ? 'Unknown' : user.role;
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
        subtitle: Text('Role: $roleLabel'),
        trailing: user.requestedRole == null
            ? null
            : Text('Requested: ${user.requestedRole}'),
      ),
    );
  }
}
