import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/sign_in_screen.dart';
import '../committee/committee_dashboard_screen.dart';
import '../student/student_dashboard_screen.dart';
import '../supervisor/supervisor_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

    _controller.forward();

    // Navigate after 5 seconds
    Timer(const Duration(seconds: 5), _handleNavigation);
  }

  Future<void> _handleNavigation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
      }
      return;
    }

    // If user exists, fetch role and navigate accordingly
    try {
      final snap = await FirebaseDatabase.instance.ref('users/${user.uid}').get();
      if (!snap.exists || snap.value == null) {
        if (mounted) Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
        return;
      }

      final data = Map<String, dynamic>.from(snap.value as Map);
      final role = data['role'] as String?;

      if (!mounted) return;

      switch (role) {
        case 'Admin':
          Navigator.of(context).pushReplacementNamed(AdminDashboardScreen.routeName);
          break;
        case 'Student':
          Navigator.of(context).pushReplacementNamed(StudentDashboardScreen.routeName);
          break;
        case 'Supervisor':
          Navigator.of(context).pushReplacementNamed(SupervisorDashboardScreen.routeName);
          break;
        case 'Committee':
          Navigator.of(context).pushReplacementNamed(CommitteeDashboardScreen.routeName);
          break;
        default:
          Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.studentTeal.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.adminPink.withValues(alpha: 0.1),
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.studentTeal.withValues(alpha: 0.2),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png', // We'll need to make sure this exists or use a placeholder
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surface,
                              child: const Icon(
                                Icons.school_rounded,
                                color: AppColors.studentTeal,
                                size: 80,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'FYP HELPER',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 36,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w900,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [AppColors.studentTeal, AppColors.adminPink],
                            ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'PRECISION • COLLABORATION • EXCELLENCE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
                // Premium Loader
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.studentTeal.withValues(alpha: 0.5)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
