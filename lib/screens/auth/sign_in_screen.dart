import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../theme/app_colors.dart';
import '../../data/roles.dart';
import '../../services/auth_service.dart';
import '../../services/user_profile_service.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _universityController = TextEditingController(); // For "Other" university

  final _authService = AuthService();
  final _profileService = UserProfileService();

  bool _isLoading = false;
  bool _isSignUpMode = false;
  bool _obscurePassword = true;
  String _signupRole = 'Student';
  String _selectedUniversity = 'UET';

  final List<String> _universities = [
    'UET', 'PU', 'UAF', 'UET KSK', 'UET TEXILA', 
    'TAHIR FARAN', 'FAST', 'NUST', 'GCU', 'MEDICAL', 'Other'
  ];

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
    setState(() => _isLoading = true);
    try {
      if (_isSignUpMode) {
        await _handleSignUp();
      } else {
        await _handleSignIn();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      throw 'Please fill in all fields';
    }

    final userCredential = await _authService.signIn(email: email, password: password);
    final user = userCredential.user;
    
    if (user != null) {
      var profile = await _profileService.fetchProfile(user.uid);
      if (profile == null) {
        throw 'User profile not found. Please contact admin.';
      }
      
      final role = profile.role;

      // Special check for Admins: Must be email verified
      if (role == 'Admin') {
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          await _authService.signOut();
          throw 'Please verify your email before logging in. A new verification link has been sent.';
        }
      } else if (role == 'Pending') {
        await _authService.signOut();
        throw 'Your account is awaiting approval from your University Admin.';
      }
      
      if (!mounted) return;
      _navigateForRole(role);
    }
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty || password.isEmpty || fullName.isEmpty || phone.isEmpty) {
      throw 'Please fill in all fields';
    }

    final university = _selectedUniversity == 'Other' ? _universityController.text.trim() : _selectedUniversity;
    if (university.isEmpty) throw 'Please select or enter your University';

    final userCredential = await _authService.register(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      // If Admin, they start with 'Admin' role but need email verification
      // Others start with 'Pending' and need Admin approval
      final initialRole = _signupRole == 'Admin' ? 'Admin' : 'Pending';
      
      await _profileService.createProfile(
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! Please verify your email to activate Admin account.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful! Awaiting approval from $_selectedUniversity Admin.')),
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
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address first.')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent! Please check your inbox.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Access denied. Role not recognized.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.studentTeal;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  // Logo/Header
                  Icon(Icons.school_rounded, size: 80, color: accentColor),
                  const SizedBox(height: 16),
                  const Text(
                    'FYP Helper System',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    'University Final Year Project Portal',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  const SizedBox(height: 40),

                  _buildAuthForm(accentColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthForm(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isSignUpMode ? 'Create Account' : 'Login Session',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          if (_isSignUpMode) ...[
            _buildRoleSelector(accentColor),
            const SizedBox(height: 20),
            _buildTextField('Full Name', _fullNameController, Icons.person_outline, color: accentColor),
            const SizedBox(height: 20),
            if (_signupRole == 'Student') ...[
              _buildTextField('Student ID', _studentIdController, Icons.numbers_outlined, hint: 'e.g. 2021-CS-123', color: accentColor),
              const SizedBox(height: 20),
            ],
            _buildTextField('Phone Number', _phoneController, Icons.phone_outlined, hint: '+92...', color: accentColor),
            const SizedBox(height: 20),
            _buildUniversitySelector(accentColor),
            const SizedBox(height: 20),
          ],

          _buildTextField('Email Address', _emailController, Icons.email_outlined, color: accentColor),
          const SizedBox(height: 20),
          _buildTextField(
            'Password', 
            _passwordController, 
            Icons.lock_outline, 
            isPassword: true, 
            color: accentColor,
            obscureText: _obscurePassword,
            onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          
          const SizedBox(height: 32),
          
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: FilledButton(
              onPressed: _isLoading ? null : _handleAuth,
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isSignUpMode ? Icons.person_add_rounded : Icons.login_rounded, size: 20),
                      const SizedBox(width: 12),
                      Text(_isSignUpMode ? 'Register Now' : 'Login', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
            ),
          ),
          
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: _handleForgotPassword,
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.border)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('New to the system?', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ),
              const Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 24),
          
          Center(
            child: TextButton(
              onPressed: () => setState(() => _isSignUpMode = !_isSignUpMode),
              child: Text(
                _isSignUpMode ? 'Already have an account? Sign In' : 'Need an account? Sign Up',
                style: TextStyle(color: accentColor, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector(Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Requested Role', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ['Student', 'Admin', 'Supervisor', 'Committee'].map((role) {
                final isSelected = _signupRole == role;
                final roleColor = (role == 'Admin' || role == 'Committee') ? AppColors.adminPink : AppColors.studentTeal;
                return GestureDetector(
                  onTap: () => setState(() => _signupRole = role),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: itemWidth,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? roleColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? roleColor : roleColor.withValues(alpha: 0.4),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(color: roleColor.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: -2)
                      ] : null,
                    ),
                    child: Center(
                      child: Text(
                        role,
                        style: TextStyle(
                          color: isSelected ? Colors.black : roleColor,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
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

  Widget _buildUniversitySelector(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_city, size: 16, color: color),
            const SizedBox(width: 8),
            Text('University', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedUniversity,
              dropdownColor: AppColors.surface,
              icon: Icon(Icons.arrow_drop_down, color: color),
              isExpanded: true,
              style: const TextStyle(color: Colors.black, fontSize: 15),
              items: _universities.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: Colors.black)),
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
          _buildTextField('Specify University', _universityController, Icons.edit_note, color: color),
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
    Color color = Colors.white,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 20,
              )
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? obscureText : false,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 15), // Clean non-bold font
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black38),
              filled: true,
              fillColor: AppColors.inputBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2.5),
              ),
              suffixIcon: isPassword 
                ? IconButton(
                    icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, size: 20, color: color),
                    onPressed: onToggleVisibility,
                  ) 
                : null,
            ),
          ),
        ),
      ],
    );
  }
}
