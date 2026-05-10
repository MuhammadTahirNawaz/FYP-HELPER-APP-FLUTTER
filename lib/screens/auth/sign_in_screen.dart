import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../data/roles.dart';
import '../../services/auth_service.dart';
import '../../services/user_profile_service.dart';
import '../../services/system_service.dart';
import '../admin/admin_dashboard_screen.dart';
import '../committee/committee_dashboard_screen.dart';
import '../student/student_dashboard_screen.dart';
import '../supervisor/supervisor_dashboard_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const String routeName = '/sign-in';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String _selectedRole = kUserRoles.first;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  final UserProfileService _profileService = UserProfileService();
  bool _isSubmitting = false;
  bool _isSignUpMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _isEmailValid {
    final email = _emailController.text.trim().toLowerCase();
    final atIndex = email.indexOf('@');
    if (atIndex <= 0) {
      return false;
    }
    final dotIndex = email.indexOf('.', atIndex + 1);
    return dotIndex > atIndex + 1;
  }

  bool get _canSubmit {
    return _isEmailValid &&
        _passwordController.text.trim().length >= 6 &&
        !_isSubmitting;
  }

  Future<void> _handleSignIn() async {
    if (!_canSubmit) {
      return;
    }
    await SystemService.requestPermissions();
    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    try {
      final credential = await _authService.signIn(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw StateError('User is not available after sign-in.');
      }

      var profile = await _profileService.fetchProfile(user.uid);
      if (_selectedRole == 'Admin') {
        await _authService.reloadUser(user);
        final refreshedUser = FirebaseAuth.instance.currentUser;
        if (refreshedUser == null || !refreshedUser.emailVerified) {
          await _authService.sendEmailVerification(user);
          await _authService.signOut();
          throw StateError(
            'Admin access requires verified email. We sent a verification link to $email.',
          );
        }

        if (profile == null) {
          await _profileService.createProfile(
            uid: user.uid,
            email: email,
            role: 'Admin',
          );
        } else if (profile.role != 'Admin') {
          await _authService.signOut();
          throw StateError(
            'Your account is assigned as ${profile.role}. Admin access is not allowed.',
          );
        }
      } else {
        if (profile == null) {
          await _profileService.createProfile(
            uid: user.uid,
            email: email,
            role: _selectedRole,
            status: 'Active',
          );
          profile = await _profileService.fetchProfile(user.uid);
        }
        final role = profile?.role ?? _selectedRole;
        if (role == 'Pending') {
          await _authService.signOut();
          throw StateError('Your account is awaiting admin approval.');
        }
        if (role == 'Rejected') {
          await _authService.signOut();
          throw StateError('Your account request was rejected.');
        }
      }

      await _profileService.touchProfile(user.uid);
      if (!mounted) {
        return;
      }
      _navigateForRole(profile?.role ?? _selectedRole);
    } on StateError catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } on Exception catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Sign-in failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleSignUp() async {
    if (!_canSubmit) {
      return;
    }
    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      print('DEBUG SIGNUP: Validating name');
      if (_fullNameController.text.trim().isEmpty) {
        throw StateError('Full Name is required for sign-up.');
      }

      print('DEBUG SIGNUP: Registering user in Firebase Auth');
      final credential = await _authService.register(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw StateError('User is not available after sign-up.');
      }

      print('DEBUG SIGNUP: Checking Student ID uniqueness');
      if (_selectedRole == 'Student') {
        final studentId = _studentIdController.text.trim();
        if (studentId.isEmpty) {
          await user.delete();
          throw StateError('Student ID is required for sign-up.');
        }
        
        try {
          final existingIdQuery = await FirebaseDatabase.instance
              .ref('users')
              .orderByChild('studentId')
              .equalTo(studentId)
              .get();

          if (existingIdQuery.exists) {
            print('DEBUG SIGNUP: Duplicate Student ID found: $studentId');
            await user.delete();
            throw StateError('This Student ID ($studentId) is already registered. Please use your own ID.');
          }
        } catch (e) {
          print('DEBUG SIGNUP: Uniqueness check failed: $e');
          await user.delete(); // Safety first: don't create account if we can't verify uniqueness
          if (e.toString().contains('permission-denied')) {
            throw StateError('Database Permission Error: The system cannot verify your Student ID uniqueness. Please ensure Firebase Rules allow authenticated users to read the "users" node.');
          }
          throw StateError('System error during ID verification: $e');
        }
      }
      
      print('DEBUG SIGNUP: Creating user profile in RTDB');
      if (_selectedRole == 'Admin') {
        await _authService.sendEmailVerification(user);
        await _authService.signOut();
        print('DEBUG SIGNUP: Admin signup complete (verification sent)');
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Verification link sent to $email. Please verify before signing in.',
            ),
          ),
        );
      } else {
        await _profileService.createProfile(
          uid: user.uid,
          email: email,
          fullName: _fullNameController.text.trim(),
          studentId: _selectedRole == 'Student' ? _studentIdController.text.trim() : null,
          phoneEncrypted: _authService.encryptPhone(_phoneController.text.trim()),
          role: 'Pending',
          requestedRole: _selectedRole,
          status: 'Pending',
        );
        print('DEBUG SIGNUP: Profile created successfully');
        await _authService.signOut();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Sign-up received. Await admin approval to login.'),
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        messenger.showSnackBar(
          const SnackBar(content: Text('Account already exists. Please sign in.')),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text('Sign-up failed: ${error.message}')),
        );
      }
    } on StateError catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('An unexpected error occurred: $error')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _navigateForRole(String role) {
    if (role == 'Admin') {
      Navigator.of(context).pushReplacementNamed(
        AdminDashboardScreen.routeName,
      );
      return;
    }
    if (role == 'Student') {
      Navigator.of(context).pushReplacementNamed(
        StudentDashboardScreen.routeName,
      );
      return;
    }
    if (role == 'Supervisor') {
      Navigator.of(context).pushReplacementNamed(
        SupervisorDashboardScreen.routeName,
      );
      return;
    }
    if (role == 'Committee') {
      Navigator.of(context).pushReplacementNamed(
        CommitteeDashboardScreen.routeName,
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Only admins, students, supervisors, or committee can access dashboards.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'FYP Portal',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: -1,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUpMode
                          ? 'Create your account'
                          : 'Sign in to manage your FYP journey',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _AuthModeChip(
                              label: 'Sign In',
                              isSelected: !_isSignUpMode,
                              onTap: () => setState(() => _isSignUpMode = false),
                            ),
                            _AuthModeChip(
                              label: 'Sign Up',
                              isSelected: _isSignUpMode,
                              onTap: () => setState(() => _isSignUpMode = true),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Role',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              items: kUserRoles
                                  .map(
                                    (role) => DropdownMenuItem<String>(
                                      value: role,
                                      child: Text(role),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() => _selectedRole = value);
                              },
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _selectedRole == 'Admin'
                                    ? 'Admins must verify email before access.'
                                    : 'Sign-ups require admin approval before login.',
                                style: const TextStyle(color: Color(0xFF4B5563)),
                              ),
                            ),
                            if (_isSignUpMode) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Full Name',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _fullNameController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your full name',
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Phone Number',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. +92 300 1234567',
                                ),
                              ),
                              if (_selectedRole == 'Student') ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Student ID',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _studentIdController,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. 2021-CS-123',
                                  ),
                                ),
                              ],
                            ],
                            const SizedBox(height: 16),
                            Text(
                              'Email',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'you@university.edu',
                                errorText:
                                    _emailController.text.isEmpty ||
                                        _isEmailValid
                                    ? null
                                    : 'Enter a valid email',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Password',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                errorText:
                                    _passwordController.text.isEmpty ||
                                        _passwordController.text
                                                .trim()
                                                .length >=
                                            6
                                    ? null
                                    : 'Use at least 6 characters',
                              ),
                            ),
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: _canSubmit
                                  ? (_isSignUpMode ? _handleSignUp : _handleSignIn)
                                  : null,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: colorScheme.primary,
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(_isSignUpMode ? 'Sign Up' : 'Sign In'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      _isSignUpMode
                          ? 'Choose your role to request access.'
                          : 'Roles are assigned by the committee. Choose your role to continue.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7A99),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthModeChip extends StatelessWidget {
  const _AuthModeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6B7A99),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
