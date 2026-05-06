import 'package:flutter/material.dart';

import '../../data/roles.dart';
import '../admin/admin_dashboard_screen.dart';
import '../committee/committee_dashboard_screen.dart';
import '../student/student_dashboard_screen.dart';
import '../supervisor/supervisor_dashboard_screen.dart';
import 'sign_out_screen.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isEmailValid {
    final email = _emailController.text.trim();
    final atIndex = email.indexOf('@');
    if (atIndex <= 0) {
      return false;
    }
    final dotIndex = email.indexOf('.', atIndex + 1);
    return dotIndex > atIndex + 1;
  }

  bool get _canSubmit {
    return _isEmailValid && _passwordController.text.trim().length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F5F2), Color(0xFFE8EEF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B1B1B),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to manage your FYP journey',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF5F6C7B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(color: Color(0xFFE6E6E6)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Role',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: const Color(0xFF1B1B1B)),
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
                            Text(
                              'Email',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: const Color(0xFF1B1B1B)),
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
                                  ?.copyWith(color: const Color(0xFF1B1B1B)),
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
                                  ? () {
                                      if (_selectedRole == 'Admin') {
                                        Navigator.of(context).pushNamed(
                                          AdminDashboardScreen.routeName,
                                        );
                                        return;
                                      }
                                      if (_selectedRole == 'Student') {
                                        Navigator.of(context).pushNamed(
                                          StudentDashboardScreen.routeName,
                                        );
                                        return;
                                      }
                                      if (_selectedRole == 'Supervisor') {
                                        Navigator.of(context).pushNamed(
                                          SupervisorDashboardScreen.routeName,
                                        );
                                        return;
                                      }
                                      if (_selectedRole == 'Committee') {
                                        Navigator.of(context).pushNamed(
                                          CommitteeDashboardScreen.routeName,
                                        );
                                        return;
                                      }
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Only admins, students, supervisors, or committee can access dashboards.',
                                          ),
                                        ),
                                      );
                                    }
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
                              child: const Text('Sign In'),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pushNamed(SignOutScreen.routeName);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Go to Sign Out'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Roles are assigned by the committee. Choose your role to continue.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF5F6C7B),
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
