import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// A reusable widget that handles the full change-password flow using
/// Firebase Auth (re-authenticate → updatePassword).
/// Drop it into any settings screen.
class ChangePasswordWidget extends StatefulWidget {
  const ChangePasswordWidget({super.key});

  @override
  State<ChangePasswordWidget> createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _currentVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      _showMessage('No signed-in user found.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Step 1: Re-authenticate with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentCtrl.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);

      // Step 2: Update to new password
      await user.updatePassword(_newCtrl.text.trim());

      if (!mounted) return;
      _showMessage('Password changed successfully!', isError: false);

      // Clear fields on success
      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          msg = 'Current password is incorrect.';
          break;
        case 'weak-password':
          msg = 'New password is too weak (min 6 characters).';
          break;
        case 'requires-recent-login':
          msg = 'Session expired. Please sign out and sign in again.';
          break;
        case 'too-many-requests':
          msg = 'Too many attempts. Try again later.';
          break;
        default:
          msg = e.message ?? 'An error occurred. Please try again.';
      }
      if (mounted) _showMessage(msg, isError: true);
    } catch (e) {
      if (mounted) _showMessage('Unexpected error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
      ),
    );
  }

  InputDecoration _inputDeco(
    String label,
    bool visible,
    VoidCallback toggleVisible,
  ) {
    return InputDecoration(
      labelText: label,
      suffixIcon: IconButton(
        icon: Icon(visible ? Icons.visibility_off : Icons.visibility, size: 20),
        onPressed: toggleVisible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock_outline, color: Color(0xFF14375E)),
                  const SizedBox(width: 10),
                  Text(
                    'Change Password',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Current password
              TextFormField(
                controller: _currentCtrl,
                obscureText: !_currentVisible,
                decoration: _inputDeco(
                  'Current Password',
                  _currentVisible,
                  () => setState(() => _currentVisible = !_currentVisible),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // New password
              TextFormField(
                controller: _newCtrl,
                obscureText: !_newVisible,
                decoration: _inputDeco(
                  'New Password',
                  _newVisible,
                  () => setState(() => _newVisible = !_newVisible),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter a new password';
                  }
                  if (v.trim().length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  if (v.trim() == _currentCtrl.text.trim()) {
                    return 'New password must differ from current';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm password
              TextFormField(
                controller: _confirmCtrl,
                obscureText: !_confirmVisible,
                decoration: _inputDeco(
                  'Confirm New Password',
                  _confirmVisible,
                  () => setState(() => _confirmVisible = !_confirmVisible),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Confirm your new password';
                  }
                  if (v.trim() != _newCtrl.text.trim()) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Update Password'),
              ),

              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user?.email == null) return;
                          setState(() => _isLoading = true);
                          try {
                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(email: user!.email!);
                            if (mounted) {
                              _showMessage(
                                'Reset link sent to ${user.email}',
                                isError: false,
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              _showMessage('Could not send reset email: $e',
                                  isError: true);
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                  icon: const Icon(Icons.mail_outline, size: 16),
                  label: const Text('Send reset link to email instead'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
