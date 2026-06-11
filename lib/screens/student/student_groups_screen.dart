import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../core/app_logger.dart';
import '../../core/validators.dart';
import 'student_dashboard_screen.dart';
import 'student_nav_bar.dart';

class StudentGroupsScreen extends StatefulWidget {
  const StudentGroupsScreen({super.key});

  static const String routeName = '/student-groups';

  @override
  State<StudentGroupsScreen> createState() => _StudentGroupsScreenState();
}

class _StudentGroupsScreenState extends State<StudentGroupsScreen> {
  final _createGroupFormKey = GlobalKey<FormState>();
  final _inviteFormKey = GlobalKey<FormState>();
  final DatabaseReference _groupsRef = FirebaseDatabase.instance.ref('groups');
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');

  final TextEditingController _groupCodeController = TextEditingController();
  final List<TextEditingController> _memberControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final TextEditingController _newMemberController = TextEditingController();

  int _requiredSize = 3;
  bool _isLoading = false;

  @override
  void dispose() {
    _groupCodeController.dispose();
    _newMemberController.dispose();
    for (final c in _memberControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _setLoading(bool value) {
    if (mounted) setState(() => _isLoading = value);
  }

  // ---------------- 1. CREATE GROUP & SEND INVITES ----------------

  Future<String> _generateGroupCode() async {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    while (true) {
      final code = List.generate(
        6,
        (i) => chars[(DateTime.now().microsecondsSinceEpoch + i) % chars.length],
      ).join();

      final snap = await _groupsRef.child(code).get();
      if (!snap.exists) return code;
    }
  }

  Future<void> _createGroupAndInvite() async {
    if (!(_createGroupFormKey.currentState?.validate() ?? false)) return;

    final user = FirebaseAuth.instance.currentUser!;
    
    // Fetch user university
    final userSnap = await _usersRef.child(user.uid).get();
    String? userUniversity;
    if (userSnap.exists && userSnap.value is Map) {
      userUniversity = (userSnap.value as Map)['university'] as String?;
    }

    final inviteEmails = _memberControllers
        .map((c) => c.text.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Total members will be Leader (1) + Invites
    if (inviteEmails.length != _requiredSize - 1) {
      _showSnackBar('You must invite exactly ${_requiredSize - 1} members.');
      return;
    }

    _setLoading(true);

    try {
      final groupCode = await _generateGroupCode();
      final groupUpdates = <String, dynamic>{
        'code': groupCode,
        'status': 'Forming',
        'requiredSize': _requiredSize,
        'supervisorEmail': '',
        'leaderUid': user.uid,
        'university': userUniversity,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        // The creator is automatically added as an accepted member
        'members/${user.uid}': {
          'email': user.email,
          'status': 'accepted',
        },
      };

      final Map<String, String> resolvedUids = {};
      
      // Process Invites
      for (final email in inviteEmails) {
        if (email == user.email) continue; // Prevent inviting oneself

        final query = await _usersRef.orderByChild('email').equalTo(email).get();

        if (!query.exists) {
          _showSnackBar('User not found: $email. Group creation aborted.');
          _setLoading(false);
          return; 
        }

        final data = Map<String, dynamic>.from(query.value as Map);
        final inviteeUid = data.keys.first;
        final inviteeData = data[inviteeUid] as Map;

        if (inviteeData['role'] == 'Pending') {
          _showSnackBar('User $email is not verified by admin yet. Group creation aborted.');
          _setLoading(false);
          return;
        }

        resolvedUids[email] = inviteeUid;

        // Add to group as pending
        groupUpdates['members/$inviteeUid'] = {
          'email': email,
          'status': 'pending',
        };
      }

      // Execute updates separately to avoid root multi-path rule issues
      await _groupsRef.child(groupCode).update(groupUpdates);
      
      // Send invitations using deep .set() to pass security rules
      int invitesSent = 0;
      for (final email in resolvedUids.keys) {
        final inviteeUid = resolvedUids[email]!;
        AppLogger.debug(
          'Attempting to send invite to $email (UID: $inviteeUid) for group $groupCode',
          tag: 'GROUPS',
        );
        try {
          await _usersRef.child(inviteeUid).child('invitations').child(groupCode).set({
            'leaderEmail': user.email,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
          AppLogger.debug('Successfully wrote invite for $email', tag: 'GROUPS');
          invitesSent++;
        } catch (e) {
          AppLogger.error(
            'Failed to write invite for $email',
            tag: 'GROUPS',
            error: e,
          );
          _showSnackBar('Failed to send invite to $email: $e');
        }
      }
      
      // Update the leader's group ID
      await _usersRef.child(user.uid).update({'groupId': groupCode});

      _showSnackBar('Group created! $invitesSent invitations sent.');
      
      // Clear fields
      for (var c in _memberControllers) { c.clear(); }
      
    } catch (e) {
      _showSnackBar('Error creating group: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ---------------- 2. HANDLE INVITATIONS ----------------

  Future<void> _respondToInvite(String groupCode, String leaderEmail, bool accept) async {
    final user = FirebaseAuth.instance.currentUser!;
    _setLoading(true);

    try {
      // Remove the invitation from the user's profile regardless of choice
      await _usersRef.child(user.uid).child('invitations/$groupCode').remove();

      if (accept) {
        final groupSnap = await _groupsRef.child(groupCode).get();
        if (groupSnap.exists) {
          final groupData = Map<String, dynamic>.from(groupSnap.value as Map);
          final requiredSize = groupData['requiredSize'] ?? 3;
          final members = (groupData['members'] as Map?) ?? {};
          int acceptedCount = 1; // Current user accepting
          members.forEach((key, val) {
            if ((val as Map)['status'] == 'accepted') acceptedCount++;
          });
          
          final groupUpdates = <String, dynamic>{
            'members/${user.uid}/status': 'accepted',
          };
          if (acceptedCount >= requiredSize) {
            groupUpdates['status'] = 'Pending';
          }
          await _groupsRef.child(groupCode).update(groupUpdates);
          await _usersRef.child(user.uid).update({'groupId': groupCode});
        }
        _showSnackBar('You joined the group!');
      } else {
        final groupSnap = await _groupsRef.child(groupCode).get();
        if (groupSnap.exists) {
          final groupData = Map<String, dynamic>.from(groupSnap.value as Map);
          final leaderUid = groupData['leaderUid'];
          if (leaderUid != null) {
            final notifId = _usersRef.child(leaderUid).child('group_notifications').push().key;
            if (notifId != null) {
              await _usersRef.child(leaderUid).child('group_notifications/$notifId').set({
                'message': '${user.email} declined your invitation to join the group.',
                'timestamp': DateTime.now().millisecondsSinceEpoch,
              });
            }
          }
        }
        await _groupsRef.child(groupCode).child('members/${user.uid}').update({'status': 'rejected'});
        _showSnackBar('Invitation declined.');
      }
    } catch (e) {
      _showSnackBar('Error responding to invite: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ---------------- 3. LEADER MANAGEMENT ----------------

  Future<void> _removeMember(String groupCode, String targetUid) async {
    final updates = <String, dynamic>{
      'members/$targetUid': null,
    };
    await _groupsRef.child(groupCode).update(updates);
    await _usersRef.child(targetUid).update({'groupId': null});
    _showSnackBar('Member removed slot opened.');
  }

  Future<void> _inviteNewMember(String groupCode) async {
    if (!(_inviteFormKey.currentState?.validate() ?? false)) return;

    final email = _newMemberController.text.trim();

    final user = FirebaseAuth.instance.currentUser!;
    if (email == user.email) {
      _showSnackBar('Cannot invite yourself.');
      return;
    }

    _setLoading(true);
    try {
      final query = await _usersRef.orderByChild('email').equalTo(email).get();
      if (!query.exists) {
        _showSnackBar('User not found: $email.');
        return;
      }

      final data = Map<String, dynamic>.from(query.value as Map);
      final inviteeUid = data.keys.first;
      final inviteeData = data[inviteeUid] as Map;

      if (inviteeData['role'] == 'Pending') {
        _showSnackBar('User $email is not verified by admin yet.');
        return;
      }

      final groupSnap = await _groupsRef.child(groupCode).child('members').child(inviteeUid).get();
      if (groupSnap.exists) {
        _showSnackBar('User is already invited or in the group.');
        return;
      }

      await _groupsRef.child(groupCode).child('members/$inviteeUid').set({
        'email': email,
        'status': 'pending',
      });

      try {
        await _usersRef.child(inviteeUid).child('invitations').child(groupCode).set({
          'leaderEmail': user.email,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        _showSnackBar('Invitation sent to $email');
      } catch (e) {
        _showSnackBar('Error sending invite to $email: $e');
      }
      
      _newMemberController.clear();
    } catch (e) {
      _showSnackBar('Error processing invite: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _cancelGroup(String groupCode) async {
    _setLoading(true);
    try {
      final groupSnap = await _groupsRef.child(groupCode).get();
      if (groupSnap.exists) {
        final groupData = Map<String, dynamic>.from(groupSnap.value as Map);
        final members = Map<String, dynamic>.from(groupData['members'] as Map? ?? {});
        
        // Remove invitations and group IDs from all members
        for (final uid in members.keys) {
          await _usersRef.child(uid).child('groupId').remove();
          await _usersRef.child(uid).child('invitations/$groupCode').remove();
        }
        
        // Delete the group
        await _groupsRef.child(groupCode).remove();
        _showSnackBar('Group cancelled successfully.');
      }
    } catch (e) {
      _showSnackBar('Error cancelling group: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ---------------- UI BUILDERS ----------------

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(StudentDashboardScreen.routeName);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FYP Groups'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushReplacementNamed(StudentDashboardScreen.routeName),
          ),
        ),
      body: user == null
          ? const Center(child: Text('Please sign in.'))
          : StreamBuilder<DatabaseEvent>(
              stream: _usersRef.child(user.uid).onValue,
              builder: (context, userSnapshot) {
                if (userSnapshot.hasError) return const Center(child: Text('Error loading data.'));
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userData = userSnapshot.data?.snapshot.value as Map?;
                final groupId = userData?['groupId'] as String?;
                final notifications = userData?['group_notifications'] as Map?;
                final invitations = userData?['invitations'] as Map?;
                AppLogger.debug(
                  'uid=${user.uid} email=${user.email} groupId=$groupId invitations=$invitations',
                  tag: 'GROUPS',
                );

                // 1. If already in a group, show group details
                if (groupId != null && groupId.isNotEmpty) {
                  return _buildGroupDetails(groupId, user.uid, notifications);
                }

                // 2. If not in a group, check their profile for pending invitations
                if (invitations != null && invitations.isNotEmpty) {
                  final pendingInvitations = <Map<String, dynamic>>[];
                  
                  invitations.forEach((code, data) {
                    final inviteData = data as Map;
                    pendingInvitations.add({
                      'groupCode': code.toString(),
                      'leaderEmail': inviteData['leaderEmail'] ?? 'Unknown',
                    });
                  });
                  
                  return _buildInvitationScreen(pendingInvitations, user.email);
                }

                // 3. No group, no invites — show the Create Group UI
                return _buildNoGroupUI(user.email);
              },
            ),
      bottomNavigationBar: const StudentNavBar(selectedIndex: 1),
      ),
    );
  }


  // Dedicated invitation screen - shown when user has pending invitations
  Widget _buildInvitationScreen(List<Map<String, dynamic>> invitations, String? currentUserEmail) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.mail, size: 64, color: Colors.blue),
        const SizedBox(height: 16),
        const Text(
          'You have a Group Invitation!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Logged in as: $currentUserEmail',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ...invitations.map((invite) {
          final groupCode = invite['groupCode'] as String;
          // leaderEmail is pre-computed and stored in the invite map
          final leaderEmail = invite['leaderEmail'] as String? ?? 'Unknown';
          return Card(
            color: Colors.blue.shade50,
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invitation from: $leaderEmail',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Group Code: $groupCode', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _respondToInvite(groupCode, leaderEmail, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          icon: const Icon(Icons.check),
                          label: const Text('Accept'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : () => _respondToInvite(groupCode, leaderEmail, false),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          icon: const Icon(Icons.close),
                          label: const Text('Decline'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  // UI when user is not in a group — only shows the Create form
  Widget _buildNoGroupUI(String? currentUserEmail) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Logged in as: $currentUserEmail', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),

        const Text('Create a New Group', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Select group size and invite members.'),
        const SizedBox(height: 16),

        Form(
          key: _createGroupFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
        DropdownButtonFormField<int>(
          value: _requiredSize,
          decoration: const InputDecoration(labelText: 'Total Group Size', border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 3, child: Text('3 Members')),
            DropdownMenuItem(value: 4, child: Text('4 Members')),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _requiredSize = val;
                // Adjust controllers length
                int requiredFields = _requiredSize - 1;
                while (_memberControllers.length < requiredFields) {
                  _memberControllers.add(TextEditingController());
                }
                while (_memberControllers.length > requiredFields) {
                  _memberControllers.last.dispose();
                  _memberControllers.removeLast();
                }
              });
            }
          },
        ),
        const SizedBox(height: 16),

        ..._memberControllers.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: entry.value,
                    keyboardType: TextInputType.emailAddress,
                    validator: AppValidators.email,
                    decoration: InputDecoration(labelText: 'Invite Member ${entry.key + 2} Email'),
                  ),
                ),
              ],
            ),
          ),
        ),
          
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _isLoading ? null : _createGroupAndInvite,
          child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
            : const Text('Send Invitations & Create Group'),
        ),
            ],
          ),
        ),
      ],
    );
  }

  // UI when user is inside a group
  Widget _buildGroupDetails(String groupId, String currentUserId, Map? notifications) {
    return StreamBuilder<DatabaseEvent>(
      stream: _groupsRef.child(groupId).onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        final data = snapshot.data?.snapshot.value as Map?;
        if (data == null) return const Center(child: Text('Group no longer exists.'));

        final members = (data['members'] as Map?) ?? {};
        final leaderUid = data['leaderUid'];
        final isLeader = currentUserId == leaderUid;
        final requiredSize = data['requiredSize'] ?? 3;
        final status = data['status'] ?? 'Forming';

        int acceptedCount = members.values.where((m) => (m as Map)['status'] == 'accepted').length;
        int activeInvites = members.values.where((m) {
          final s = (m as Map)['status'];
          return s == 'accepted' || s == 'pending';
        }).length;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (isLeader && notifications != null && notifications.isNotEmpty)
              ...notifications.entries.map((entry) => Card(
                color: Colors.red.shade50,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: Text((entry.value as Map)['message'] ?? 'Notification'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _usersRef.child(currentUserId).child('group_notifications').child(entry.key).remove();
                    },
                  ),
                ),
              )),
            Card(
              child: ListTile(
                title: const Text('Group Status'),
                subtitle: Text(status == 'Pending' ? 'Pending Admin Approval' : (status == 'Approved' ? 'Approved' : 'Awaiting Members ($acceptedCount/$requiredSize)')),
                trailing: status == 'Approved' 
                    ? const Icon(Icons.verified, color: Colors.blue) 
                    : (status == 'Pending' ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.hourglass_empty, color: Colors.orange)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Committee Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...members.entries.map((entry) {
              final uid = entry.key;
              final memberData = entry.value as Map;
              final status = memberData['status'];
              
              Color statusColor = Colors.grey;
              IconData statusIcon = Icons.help;
              if (status == 'accepted') { statusColor = Colors.green; statusIcon = Icons.check_circle; }
              if (status == 'pending') { statusColor = Colors.orange; statusIcon = Icons.access_time; }
              if (status == 'rejected') { statusColor = Colors.red; statusIcon = Icons.cancel; }

              return ListTile(
                leading: Icon(statusIcon, color: statusColor),
                title: Text(memberData['email']),
                subtitle: Text(status.toString().toUpperCase()),
                trailing: (isLeader && status == 'rejected') 
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Remove declined invite to free up a slot',
                      onPressed: () => _removeMember(groupId, uid),
                    )
                  : null,
              );
            }),
            if (isLeader && status == 'Forming' && activeInvites < requiredSize) ...[
              const SizedBox(height: 24),
              const Text('Invite Missing Member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Form(
                key: _inviteFormKey,
                child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _newMemberController,
                      keyboardType: TextInputType.emailAddress,
                      validator: AppValidators.email,
                      decoration: const InputDecoration(labelText: 'Member Email', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _inviteNewMember(groupId),
                    child: const Text('Invite'),
                  ),
                ],
                ),
              ),
            ],
            
            if (isLeader && status == 'Forming') ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _cancelGroup(groupId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Cancel & Delete Group'),
              ),
            ],
          ],
        );
      },
    );
  }
}