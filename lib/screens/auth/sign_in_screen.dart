import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth_error_messages.dart';
import '../../core/validators.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';
import '../../state/session_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/dashboard_styles.dart';
import '../../widgets/app_feedback.dart';
import '../student/student_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../supervisor/supervisor_dashboard_screen.dart';
import '../committee/committee_dashboard_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const String routeName = '/sign-in';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _universityController = TextEditingController();

  bool _isLoading = false;
  bool _isSignUpMode = false;
  bool _obscurePassword = true;
  String _signupRole = 'Student';
  String _selectedUniversity = 'UET';
  String? _feedbackMessage;
  FeedbackKind _feedbackKind = FeedbackKind.error;

  final List<String> _universities = [
    'UET', 'PU', 'UAF', 'UET KSK', 'UET TEXILA',
    'TAHIR FARAN', 'FAST', 'NUST', 'GCU', 'MEDICAL', 'Other'
  ];

  static const Color _accent = AppColors.navy;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _emailController,
      _passwordController,
      _fullNameController,
      _studentIdController,
      _phoneController,
      _universityController,
    ]) {
      controller.addListener(_clearFeedback);
    }
  }

  void _clearFeedback() {
    if (_feedbackMessage == null) return;
    setState(() => _feedbackMessage = null);
  }

  void _showFeedback(String message, FeedbackKind kind) {
    setState(() {
      _feedbackMessage = message;
      _feedbackKind = kind;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    _universityController.dispose();
    super.dispose();
  }

  void _handleAuth() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);
    _clearFeedback();
    try {
      if (_isSignUpMode) {
        await _handleSignUp();
      } else {
        await _handleSignIn();
      }
    } catch (e) {
      if (mounted) {
        _showFeedback(AuthErrorMessages.from(e), FeedbackKind.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final authRepository = context.read<AuthRepository>();
    final userRepository = context.read<UserRepository>();
    final session = context.read<SessionProvider>();

    final userCredential = await authRepository.signIn(email: email, password: password);
    final user = userCredential.user;

    if (user != null) {
      final profile = await userRepository.fetchProfile(user.uid);
      if (profile == null) {
        throw 'User profile not found. Please contact admin.';
      }

      final role = profile.role;

      if (role == 'Admin') {
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          await authRepository.signOut();
          session.endSession();
          throw 'Please verify your email before logging in. A new verification link has been sent.';
        }
      } else if (role == 'Pending') {
        await authRepository.signOut();
        session.endSession();
        throw 'Your account is awaiting approval from your University Admin.';
      }

      session.establishSession(profile);

      if (!mounted) return;
      _navigateForRole(role);
    }
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();

    final university = _selectedUniversity == 'Other' ? _universityController.text.trim() : _selectedUniversity;

    final authRepository = context.read<AuthRepository>();
    final userRepository = context.read<UserRepository>();

    final userCredential = await authRepository.register(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      final initialRole = _signupRole == 'Admin' ? 'Admin' : 'Pending';

      await userRepository.createProfile(
        uid: user.uid,
        email: email,
        role: initialRole,
        requestedRole: _signupRole,
        fullName: fullName,
        phoneNumber: phone,
        university: university,
        studentId: _signupRole == 'Student' ? _studentIdController.text.trim() : null,
      );

      if (_signupRole == 'Admin') {
        await user.sendEmailVerification();
        if (mounted) {
          AppSnackBar.show(
            context,
            message: 'Registration successful! Please verify your email to activate your admin account.',
            kind: FeedbackKind.success,
          );
        }
      } else {
        if (mounted) {
          AppSnackBar.show(
            context,
            message: 'Registration successful! Awaiting approval from $_selectedUniversity admin.',
            kind: FeedbackKind.success,
          );
        }
      }

      if (mounted) {
        setState(() {
          _isSignUpMode = false;
          _passwordController.clear();
        });
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final emailError = AppValidators.email(_emailController.text);
    if (emailError != null) {
      _showFeedback(emailError, FeedbackKind.error);
      return;
    }
    final email = _emailController.text.trim();

    setState(() => _isLoading = true);
    _clearFeedback();
    try {
      await context.read<AuthRepository>().sendPasswordResetEmail(email);
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Password reset link sent. Check your inbox.',
          kind: FeedbackKind.success,
        );
      }
    } catch (e) {
      if (mounted) {
        _showFeedback(AuthErrorMessages.from(e), FeedbackKind.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateForRole(String role) {
    if (role == 'Admin') {
      Navigator.of(context).pushReplacementNamed(AdminDashboardScreen.routeName);
    } else if (role == 'Student') {
      Navigator.of(context).pushReplacementNamed(StudentDashboardScreen.routeName);
    } else if (role == 'Supervisor') {
      Navigator.of(context).pushReplacementNamed(SupervisorDashboardScreen.routeName);
    } else if (role == 'Committee') {
      Navigator.of(context).pushReplacementNamed(CommitteeDashboardScreen.routeName);
    } else {
      _showFeedback('Access denied. Role not recognized.', FeedbackKind.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.school_rounded, size: 44, color: AppColors.navy),
                ),
                const SizedBox(height: 16),
                const Text(
                  'FYP Helper System',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'University Final Year Project Portal',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: _buildAuthForm(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthForm() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: DashboardStyles.lightCardDecoration(accent: _accent),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                color: AppColors.navy,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSignUpMode ? 'Create Account' : 'Welcome Back',
                      style: const TextStyle(
                        color: AppColors.textOnNavy,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isSignUpMode
                          ? 'Register for the FYP portal'
                          : 'Sign in to your workspace',
                      style: const TextStyle(
                        color: AppColors.textOnNavyMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              if (_isSignUpMode) ...[
                _buildRoleSelector(),
                const SizedBox(height: 20),
                _buildTextField(
                  'Full Name',
                  _fullNameController,
                  Icons.person_outline,
                  validator: AppValidators.fullName,
                ),
                const SizedBox(height: 16),
                if (_signupRole == 'Student') ...[
                  _buildTextField(
                    'Student ID',
                    _studentIdController,
                    Icons.numbers_outlined,
                    hint: 'e.g. 2021-CS-123',
                    validator: (v) => AppValidators.required(v, fieldName: 'Student ID'),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildTextField(
                  'Phone Number',
                  _phoneController,
                  Icons.phone_outlined,
                  hint: '03XX XXXXXXX',
                  keyboardType: TextInputType.phone,
                  validator: AppValidators.pakistaniPhone,
                ),
                const SizedBox(height: 16),
                _buildUniversitySelector(),
                const SizedBox(height: 16),
              ],
              _buildTextField(
                'Email Address',
                _emailController,
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: AppValidators.email,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Password',
                _passwordController,
                Icons.lock_outline,
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                validator: AppValidators.password,
              ),
              if (_feedbackMessage != null) ...[
                const SizedBox(height: 16),
                FeedbackBanner(
                  message: _feedbackMessage!,
                  kind: _feedbackKind,
                  onDismiss: _clearFeedback,
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isSignUpMode ? Icons.person_add_rounded : Icons.login_rounded,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _isSignUpMode ? 'Register Now' : 'Login',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _handleForgotPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.border.withValues(alpha: 0.8))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'New to the system?',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.border.withValues(alpha: 0.8))),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _isSignUpMode = !_isSignUpMode;
                    _clearFeedback();
                  }),
                  child: Text(
                    _isSignUpMode ? 'Already have an account? Sign In' : 'Need an account? Sign Up',
                    style: const TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Requested Role',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ['Student', 'Admin', 'Supervisor', 'Committee'].map((role) {
                final isSelected = _signupRole == role;
                final roleColor = AppColors.navy;
                return GestureDetector(
                  onTap: () => setState(() => _signupRole = role),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: itemWidth,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? roleColor.withValues(alpha: 0.12) : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? roleColor : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        role,
                        style: TextStyle(
                          color: isSelected ? AppColors.navy : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUniversitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.location_city, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 8),
            Text(
              'University',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedUniversity,
              dropdownColor: AppColors.surface,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              isExpanded: true,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
              items: _universities.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() => _selectedUniversity = newValue!);
              },
            ),
          ),
        ),
        if (_selectedUniversity == 'Other') ...[
          const SizedBox(height: 12),
          _buildTextField(
            'Specify University',
            _universityController,
            Icons.edit_note,
            validator: (v) => AppValidators.required(v, fieldName: 'University'),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    String? hint,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.inputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
