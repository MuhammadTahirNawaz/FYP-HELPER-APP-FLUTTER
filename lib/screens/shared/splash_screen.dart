import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/session_provider.dart';
import '../../theme/app_colors.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/sign_in_screen.dart';
import '../committee/committee_dashboard_screen.dart';
import '../student/student_dashboard_screen.dart';
import '../supervisor/supervisor_dashboard_screen.dart';
import '../../core/app_logger.dart';
import '../../services/ad_service.dart';
import '../../services/system_service.dart';

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
  Future<void>? _startupFuture;

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

    _startupFuture = _requestStartupPermissions();

    // Navigate after 5 seconds
    Timer(const Duration(seconds: 5), _handleNavigation);
  }

  /// Runtime permission prompts fire immediately while the splash animation plays.
  Future<void> _requestStartupPermissions() async {
    final permissionResult = await SystemService.requestPermissionsAtStartup();
    AppLogger.debug(permissionResult.summary, tag: 'STARTUP');
  }

  Future<void> _handleNavigation() async {
    if (!mounted) return;

    await _startupFuture;

    final session = context.read<SessionProvider>();
    await session.bootstrap();

    if (!session.isSignedIn || session.role == null) {
      _navigateWithAd(SignInScreen.routeName);
      return;
    }

    try {
      if (!mounted) return;

      switch (session.role) {
        case 'Admin':
          _navigateWithAd(AdminDashboardScreen.routeName);
          break;
        case 'Student':
          _navigateWithAd(StudentDashboardScreen.routeName);
          break;
        case 'Supervisor':
          _navigateWithAd(SupervisorDashboardScreen.routeName);
          break;
        case 'Committee':
          _navigateWithAd(CommitteeDashboardScreen.routeName);
          break;
        default:
          _navigateWithAd(SignInScreen.routeName);
      }
    } catch (e) {
      if (mounted) _navigateWithAd(SignInScreen.routeName);
    }
  }

  void _navigateWithAd(String routeName) {
    if (!mounted) return;
    AdService.showLaunchAdIfAvailable(
      onAdComplete: () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(routeName);
        }
      },
    );
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
