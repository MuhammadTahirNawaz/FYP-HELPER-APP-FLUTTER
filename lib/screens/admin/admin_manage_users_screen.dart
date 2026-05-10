import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminManageUsersScreen extends StatefulWidget {
  const AdminManageUsersScreen({super.key});

  static const String routeName = '/admin-manage-users';

  @override
  State<AdminManageUsersScreen> createState() => _AdminManageUsersScreenState();
}

class _AdminManageUsersScreenState extends State<AdminManageUsersScreen> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  String _filterRole = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const _roles = ['All', 'Student', 'Supervisor', 'Committee', 'Admin', 'Pending'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return const Color(0xFF16A34A);
      case 'pending': return const Color(0xFFF59E0B);
      case 'rejected': return const Color(0xFFDC2626);
      default: return const Color(0xFF6B7A99);
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Student': return const Color(0xFF2563EB);
      case 'Supervisor': return const Color(0xFF7C3AED);
      case 'Committee': return const Color(0xFF0891B2);
      case 'Admin': return const Color(0xFFDC2626);
      default: return const Color(0xFF6B7A99);
    }
  }

  void _showUserDialog(BuildContext context, String uid, Map<String, dynamic> user) {
    final name = (user['displayName'] as String?) ?? (user['email'] as String?) ?? uid;
    final role = (user['role'] as String?) ?? 'Pending';
    final email = (user['email'] as String?) ?? '';
    final status = (user['status'] as String?) ?? 'Active';

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (email.isNotEmpty) _InfoRow(label: 'Email', value: email),
            _InfoRow(label: 'Role', value: role),
            _InfoRow(label: 'Status', value: status),
            if (user['requestedRole'] != null)
              _InfoRow(label: 'Requested Role', value: user['requestedRole'].toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          if (role == 'Pending') ...[
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
              onPressed: () async {
                await _usersRef.child(uid).update({'role': 'Rejected', 'status': 'Rejected'});
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Reject'),
            ),
            FilledButton(
              onPressed: () async {
                final requestedRole = (user['requestedRole'] as String?) ?? 'Student';
                await _usersRef.child(uid).update({'role': requestedRole, 'status': 'Active'});
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Approve'),
            ),
          ],
          if (role != 'Pending')
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: ctx,
                  builder: (c) => AlertDialog(
                    title: const Text('Delete User?'),
                    content: Text('Remove $name from the system?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                        onPressed: () => Navigator.of(c).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await _usersRef.child(uid).remove();
                  if (ctx.mounted) Navigator.of(ctx).pop();
                }
              },
              child: const Text('Delete'),
            ),
        ],
      ),
    );
  }

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
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by name or email…',
              ),
            ),
          ),
          // Role filter chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _roles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final role = _roles[i];
                final selected = _filterRole == role;
                return FilterChip(
                  label: Text(role),
                  selected: selected,
                  onSelected: (_) => setState(() => _filterRole = role),
                  selectedColor: const Color(0xFF14375E),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF14375E),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // User list from Firebase
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _usersRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data?.snapshot.value;
                if (data is! Map) {
                  return const Center(
                    child: Text(
                      'No users found.',
                      style: TextStyle(color: Color(0xFF6B7A99)),
                    ),
                  );
                }

                final allUsers = Map<String, dynamic>.from(data);
                final filtered = allUsers.entries.where((e) {
                  if (e.value is! Map) return false;
                  final user = Map<String, dynamic>.from(e.value as Map);
                  final role = (user['role'] as String?) ?? '';
                  final name = ((user['displayName'] as String?) ?? '').toLowerCase();
                  final email = ((user['email'] as String?) ?? '').toLowerCase();

                  final roleMatch = _filterRole == 'All' || role == _filterRole;
                  final searchMatch = _searchQuery.isEmpty ||
                      name.contains(_searchQuery) ||
                      email.contains(_searchQuery);
                  return roleMatch && searchMatch;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No users match this filter.',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final uid = filtered[index].key;
                    final user = Map<String, dynamic>.from(filtered[index].value as Map);
                    final name = (user['fullName'] as String?) ??
                        (user['displayName'] as String?) ??
                        (user['email'] as String?) ??
                        uid;
                    final role = (user['role'] as String?) ?? 'Unknown';
                    final status = (user['status'] as String?) ?? 'Active';
                    final email = (user['email'] as String?) ?? '';
                    final studentId = user['studentId'] as String?;
                    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

                    return Card(
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: _roleColor(role).withOpacity(0.12),
                          child: Text(
                            initial,
                            style: TextStyle(
                              color: _roleColor(role),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (email.isNotEmpty)
                              Text(
                                email,
                                style: const TextStyle(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (studentId != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  'ID: $studentId',
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF1E6091), fontWeight: FontWeight.bold),
                                ),
                              ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _roleColor(role).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    role,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _roleColor(role),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _statusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _statusColor(status),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => _showUserDialog(context, uid, user),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF6B7A99),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Color(0xFF14375E)),
            ),
          ),
        ],
      ),
    );
  }
}
