import 'package:flutter/material.dart';

import '../../../models/user_account.dart';
import '../../../repositories/group_repository.dart';
import '../../../repositories/user_repository.dart';

class AdminGroupsApprovalSection extends StatefulWidget {
  const AdminGroupsApprovalSection({
    super.key,
    required this.groupRepository,
    required this.userRepository,
    this.university,
  });

  final GroupRepository groupRepository;
  final UserRepository userRepository;
  final String? university;

  @override
  State<AdminGroupsApprovalSection> createState() =>
      _AdminGroupsApprovalSectionState();
}

class _AdminGroupsApprovalSectionState extends State<AdminGroupsApprovalSection> {
  final Map<String, String> _supervisorSelection = {};
  bool _updating = false;

  Future<void> _approveGroup(
    String code,
    String supervisorEmail,
    String supervisorId,
  ) async {
    if (_updating) return;
    setState(() => _updating = true);
    await widget.groupRepository.approveGroup(
      code: code,
      supervisorEmail: supervisorEmail,
      supervisorId: supervisorId,
    );
    if (mounted) {
      setState(() => _updating = false);
    }
  }

  Future<void> _rejectGroup(String code) async {
    if (_updating) return;
    setState(() => _updating = true);
    await widget.groupRepository.rejectGroup(code);
    if (mounted) {
      setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.groupRepository.watchGroups(),
      builder: (context, snapshot) {
        final groups = widget.groupRepository
            .listFromSnapshot(snapshot.data?.snapshot.value)
            .where((group) => group.status == 'Pending')
            .where(
              (group) =>
                  widget.university == null || group.university == widget.university,
            )
            .toList();

        return StreamBuilder(
          stream: widget.userRepository.watchAllUsers(),
          builder: (context, userSnapshot) {
            final supervisors = widget.userRepository
                .listFromSnapshot(userSnapshot.data?.snapshot.value)
                .where((user) => user.role == 'Supervisor')
                .toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Pending Groups',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (supervisors.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Text(
                      'Note: No supervisors available. You can still approve groups, but supervisors should be created first to assign later.',
                      style: TextStyle(color: Colors.amber.shade900, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 12),
                if (groups.isEmpty)
                  const Center(child: Text('No pending groups yet.'))
                else
                  ...groups.map((group) {
                    final selected = _supervisorSelection[group.code] ??
                        (supervisors.isNotEmpty ? supervisors.first.email : '');
                    final selectedSupervisor = supervisors.firstWhere(
                      (sup) => sup.email == selected,
                      orElse: () =>
                          supervisors.isNotEmpty ? supervisors.first : UserAccount.empty,
                    );

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE6E6E6)),
                      ),
                      child: ListTile(
                        title: Text('Group ${group.code}'),
                        subtitle: Text(
                          '${group.memberCount} members · Requested supervisor: ${group.supervisorEmail.isEmpty ? 'Pending' : group.supervisorEmail}',
                        ),
                        trailing: Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            DropdownButton<String>(
                              value: selected,
                              items: supervisors
                                  .map(
                                    (sup) => DropdownMenuItem<String>(
                                      value: sup.email,
                                      child: Text(sup.email),
                                    ),
                                  )
                                  .toList(),
                              isExpanded: false,
                              hint: const Text('No supervisors'),
                              onChanged: _updating
                                  ? null
                                  : (value) {
                                      if (value == null) return;
                                      setState(() {
                                        _supervisorSelection[group.code] = value;
                                      });
                                    },
                            ),
                            IconButton(
                              icon: const Icon(Icons.check_circle),
                              tooltip: 'Approve',
                              onPressed: (_updating || selectedSupervisor.isEmpty)
                                  ? null
                                  : () => _approveGroup(
                                        group.code,
                                        selected,
                                        selectedSupervisor.uid,
                                      ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel),
                              tooltip: 'Reject',
                              onPressed:
                                  _updating ? null : () => _rejectGroup(group.code),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        );
      },
    );
  }
}
