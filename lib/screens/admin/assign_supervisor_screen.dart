import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

import 'admin_nav_bar.dart';

class AssignSupervisorScreen extends StatefulWidget {
  const AssignSupervisorScreen({super.key});

  static const String routeName = '/admin-assign-supervisor';

  @override
  State<AssignSupervisorScreen> createState() => _AssignSupervisorScreenState();
}

class _AssignSupervisorScreenState extends State<AssignSupervisorScreen> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  final DatabaseReference _groupsRef = FirebaseDatabase.instance.ref('groups');

  String? _selectedGroupId;
  String? _selectedSupervisorUid;
  bool _isAssigning = false;

  // Parsed data from Firebase
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _supervisors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final usersSnap = await _usersRef.get();
      final groupsSnap = await _groupsRef.get();

      final supervisors = <Map<String, dynamic>>[];
      if (usersSnap.value is Map) {
        final usersMap = Map<String, dynamic>.from(usersSnap.value as Map);
        for (final entry in usersMap.entries) {
          if (entry.value is! Map) continue;
          final user = Map<String, dynamic>.from(entry.value as Map);
          if (user['role'] == 'Supervisor') {
            supervisors.add({
              'uid': entry.key,
              'name': (user['displayName'] as String?) ?? (user['email'] as String?) ?? entry.key,
              'email': (user['email'] as String?) ?? '',
            });
          }
        }
      }

      final groups = <Map<String, dynamic>>[];
      if (groupsSnap.value is Map) {
        final groupsMap = Map<String, dynamic>.from(groupsSnap.value as Map);
        for (final entry in groupsMap.entries) {
          if (entry.value is! Map) continue;
          final group = Map<String, dynamic>.from(entry.value as Map);
          // Only show groups without a supervisor or with unassigned supervisor
          final hasSupervisor = (group['supervisorId'] as String?)?.isNotEmpty == true;
          groups.add({
            'id': entry.key,
            'projectTitle': (group['projectTitle'] as String?) ?? entry.key,
            'hasSupervisor': hasSupervisor,
            'supervisorId': group['supervisorId'],
          });
        }
      }

      if (mounted) {
        setState(() {
          _supervisors = supervisors;
          _groups = groups;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  bool get _canAssign =>
      _selectedGroupId != null && _selectedSupervisorUid != null && !_isAssigning;

  Future<void> _assign() async {
    if (!_canAssign) return;
    setState(() => _isAssigning = true);
    try {
      await _groupsRef.child(_selectedGroupId!).update({
        'supervisorId': _selectedSupervisorUid,
        'updatedAt': ServerValue.timestamp,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supervisor assigned successfully!')),
      );
      // Reload data
      setState(() {
        _selectedGroupId = null;
        _selectedSupervisorUid = null;
        _loading = true;
      });
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to assign: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAssigning = false);
    }
  }

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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Group picker
                  Text(
                    'Select Group',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (_groups.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No groups found in Firebase.'),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: _groups.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final group = _groups[index];
                          final id = group['id'] as String;
                          final title = group['projectTitle'] as String;
                          final hasSupervisor = group['hasSupervisor'] as bool;
                          final isSelected = id == _selectedGroupId;

                          return ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.navy
                                    : const Color(0xFFDDE3EF),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.surfaceMuted,
                              child: Text(
                                title.isNotEmpty ? title[0].toUpperCase() : 'G',
                                style: const TextStyle(
                                    color: AppColors.navy,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            title: Text(title,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              hasSupervisor ? '⚠ Already has supervisor' : 'Unassigned',
                              style: TextStyle(
                                fontSize: 11,
                                color: hasSupervisor
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF16A34A),
                              ),
                            ),
                            trailing: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? AppColors.navy
                                  : const Color(0xFF6B7A99),
                            ),
                            onTap: () => setState(() => _selectedGroupId = id),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Supervisor dropdown
                  Text(
                    'Select Supervisor',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (_supervisors.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No supervisors registered yet.'),
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: _selectedSupervisorUid,
                      hint: const Text('Choose a supervisor'),
                      items: _supervisors.map((s) {
                        return DropdownMenuItem<String>(
                          value: s['uid'] as String,
                          child: Text(s['name'] as String),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedSupervisorUid = v),
                      decoration: const InputDecoration(labelText: 'Supervisor'),
                    ),

                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _canAssign ? _assign : null,
                    child: _isAssigning
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Assign Supervisor'),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const AdminNavBar(selectedIndex: 0),
    );
  }
}
