import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/validators.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';
import '../../state/session_provider.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  static const String routeName = '/student-profile';

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final authRepository = context.read<AuthRepository>();
    final userRepository = context.read<UserRepository>();
    final user = authRepository.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Please sign in to load your profile.';
        _isLoading = false;
      });
      return;
    }

    try {
      final profile = await userRepository.fetchProfile(user.uid);
      _fullNameController.text = profile?.fullName ?? '';
      _emailController.text = profile?.email.isNotEmpty == true
          ? profile!.email
          : (user.email ?? '');
      _studentIdController.text = profile?.studentId ?? '';
      _phoneController.text = profile?.phoneNumber ?? '';
    } catch (error) {
      _errorMessage = 'Failed to load profile: $error';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_isSaving) {
      return;
    }
    final authRepository = context.read<AuthRepository>();
    final userRepository = context.read<UserRepository>();
    final session = context.read<SessionProvider>();
    final uid = authRepository.currentUid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await userRepository.updateProfile(
        uid: uid,
        fullName: _fullNameController.text.trim(),
        studentId: _studentIdController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );
      await session.refreshProfile();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_errorMessage != null)
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE6E6E6)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE6E6E6)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Profile',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _fullNameController,
                          validator: AppValidators.fullName,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Enter name',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _studentIdController,
                          validator: (v) => AppValidators.required(v, fieldName: 'Student ID'),
                          decoration: const InputDecoration(
                            labelText: 'Student ID',
                            hintText: '2022-CS-001',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: AppValidators.pakistaniPhone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number (encrypted at rest)',
                            hintText: '03xx-xxxxxxx',
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save Changes'),
                        ),
                      ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
