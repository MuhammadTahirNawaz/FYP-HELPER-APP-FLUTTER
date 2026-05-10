import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../widgets/change_password_widget.dart';

class AdminProfileSettingsScreen extends StatefulWidget {
  const AdminProfileSettingsScreen({super.key});

  static const String routeName = '/admin-profile-settings';

  @override
  State<AdminProfileSettingsScreen> createState() =>
      _AdminProfileSettingsScreenState();
}

class _AdminProfileSettingsScreenState
    extends State<AdminProfileSettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  bool _saving = false;
  bool _loaded = false;

  late final String _uid;
  late final String _email;
  late final DatabaseReference _userRef;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    _uid = user.uid;
    _email = user.email ?? '';
    _userRef = FirebaseDatabase.instance.ref('users/$_uid');
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final snap = await _userRef.get();
      if (snap.value is Map) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        _nameCtrl.text = (data['displayName'] as String?) ?? '';
        _deptCtrl.text = (data['department'] as String?) ?? '';
      }
    } catch (_) {}
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await _userRef.update({
        'displayName': _nameCtrl.text.trim(),
        'department': _deptCtrl.text.trim(),
        'updatedAt': ServerValue.timestamp,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _deptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.account_circle,
                                  color: Color(0xFF14375E)),
                              const SizedBox(width: 10),
                              Text(
                                'Admin Profile',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Full Name',
                                hintText: 'Enter your name'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: _email,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'Email address',
                              helperText: 'Email cannot be changed here.',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _deptCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Department',
                                hintText: 'e.g. Computer Science'),
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: _saving ? null : _saveProfile,
                            child: _saving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Save Changes'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Password change
                  const ChangePasswordWidget(),
                ],
              ),
            ),
    );
  }
}
