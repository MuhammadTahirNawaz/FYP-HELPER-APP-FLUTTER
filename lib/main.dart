import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_colors.dart';

import 'firebase_options.dart';

import 'screens/admin/add_user_screen.dart';
import 'screens/admin/admin_access_control_screen.dart';
import 'screens/admin/admin_committee_management_screen.dart';
import 'screens/admin/admin_committee_access_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_deactivate_accounts_screen.dart';
import 'screens/admin/admin_manage_users_screen.dart';
import 'screens/admin/admin_management_screen.dart';
import 'screens/admin/admin_notifications_settings_screen.dart';
import 'screens/admin/admin_profile_settings_screen.dart';
import 'screens/admin/admin_group_records_screen.dart';
import 'screens/admin/admin_reports_screen.dart';
import 'screens/admin/admin_settings_screen.dart';
import 'screens/admin/admin_supervisor_load_screen.dart';
import 'screens/admin/admin_supervisor_management_screen.dart';
import 'screens/admin/admin_system_preferences_screen.dart';
import 'screens/admin/admin_user_management_screen.dart';
import 'screens/admin/admin_review_panels_screen.dart';
import 'screens/admin/assign_supervisor_screen.dart';
import 'screens/admin/doc_submissions_screen.dart';
import 'screens/admin/system_analytics_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_out_screen.dart';
import 'screens/committee/committee_dashboard_screen.dart';
import 'screens/committee/committee_proposal_review_screen.dart';
import 'screens/committee/committee_viva_scheduling_screen.dart';
import 'screens/committee/committee_settings_screen.dart';
import 'screens/student/student_dashboard_screen.dart';
import 'screens/student/student_messages_screen.dart';
import 'screens/student/student_groups_screen.dart';
import 'screens/student/student_notifications_settings_screen.dart';
import 'screens/student/student_profile_screen.dart';
import 'screens/student/student_reports_screen.dart';
import 'screens/student/student_security_settings_screen.dart';
import 'screens/student/student_settings_screen.dart';
import 'screens/student/submit_progress_report_screen.dart';
import 'screens/student/submit_proposal_screen.dart';
import 'screens/student/viva_schedule_screen.dart';
import 'screens/supervisor/supervisor_dashboard_screen.dart';
import 'screens/supervisor/supervisor_notifications_settings_screen.dart';
import 'screens/supervisor/supervisor_profile_screen.dart';
import 'screens/supervisor/supervisor_messages_screen.dart';
import 'screens/supervisor/supervisor_progress_reports_screen.dart';
import 'screens/supervisor/supervisor_security_settings_screen.dart';
import 'screens/supervisor/supervisor_settings_screen.dart';
import 'screens/shared/documents_screen.dart';
import 'screens/shared/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebaseIfSupported();
  runApp(const MainApp());
}

Future<void> _initializeFirebaseIfSupported() async {
  if (kIsWeb || defaultTargetPlatform == TargetPlatform.android) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      await _writeFirebaseSmokeTest();
    }
  }
}

Future<void> _writeFirebaseSmokeTest() async {
  try {
    await FirebaseDatabase.instance.ref('healthcheck').set({
      'status': 'ok',
      'checkedAt': ServerValue.timestamp,
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
    });
  } catch (error) {
    debugPrint('Firebase RTDB smoke test failed: $error');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Design tokens ──────────────────────────────────────────────────────────
    // Neon Cyberpunk Palette
    const Color bgColor          = AppColors.bg;
    const Color surfaceColor     = AppColors.surface;
    const Color adminColor       = AppColors.adminPink;
    const Color studentColor     = AppColors.studentTeal;
    const Color textPrimary      = AppColors.textPrimary;
    const Color textSecondary    = AppColors.textSecondary;
    const Color borderColor      = AppColors.border;

    final colorScheme = ColorScheme.dark(
      primary:         studentColor, // Default to student teal
      secondary:       adminColor,   // Admin pink
      surface:         surfaceColor,
      onPrimary:       bgColor,
      onSurface:       textPrimary,
      outline:         borderColor,
      error:           AppColors.error,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgColor,
        fontFamily: GoogleFonts.outfit().fontFamily, // Switched to Outfit for a more modern tech look
        textTheme: GoogleFonts.outfitTextTheme().copyWith(
          displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: textPrimary, letterSpacing: -1),
          titleLarge:   GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.5),
          titleMedium:  GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
          titleSmall:   GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
          bodyLarge:    GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
          bodyMedium:   GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: textSecondary),
          bodySmall:    GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
          iconTheme: const IconThemeData(color: textPrimary),
        ),
        cardTheme: CardThemeData(
          color: surfaceColor.withValues(alpha: 0.7),
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: borderColor, width: 1.5),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceLight.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: studentColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintStyle: GoogleFonts.outfit(color: textSecondary.withValues(alpha: 0.5), fontSize: 14),
          labelStyle: GoogleFonts.outfit(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
          floatingLabelStyle: GoogleFonts.outfit(color: studentColor, fontSize: 12, fontWeight: FontWeight.w700),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: studentColor,
            foregroundColor: bgColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: textPrimary,
            side: const BorderSide(color: borderColor, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surfaceColor.withValues(alpha: 0.95),
          elevation: 10,
          indicatorColor: studentColor.withValues(alpha: 0.1),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected ? studentColor : textSecondary,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? studentColor : textSecondary,
              size: 24,
              shadows: selected ? [Shadow(color: studentColor, blurRadius: 10)] : null,
            );
          }),
        ),
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        SignInScreen.routeName: (_) => const SignInScreen(),
        SignOutScreen.routeName: (_) => const SignOutScreen(),
        AdminDashboardScreen.routeName: (_) => const AdminDashboardScreen(),
        AdminManagementScreen.routeName: (_) => const AdminManagementScreen(),
        AdminReportsScreen.routeName: (_) => const AdminReportsScreen(),
        '/admin-messages': (_) => const AdminDashboardScreen(),
        AdminGroupRecordsScreen.routeName: (_) => const AdminGroupRecordsScreen(),
        AdminSettingsScreen.routeName: (_) => const AdminSettingsScreen(),
        AdminProfileSettingsScreen.routeName: (_) =>
            const AdminProfileSettingsScreen(),
        AdminAccessControlScreen.routeName: (_) =>
            const AdminAccessControlScreen(),
        AdminNotificationsSettingsScreen.routeName: (_) =>
            const AdminNotificationsSettingsScreen(),
        AdminSystemPreferencesScreen.routeName: (_) =>
            const AdminSystemPreferencesScreen(),
        AdminUserManagementScreen.routeName: (_) =>
            const AdminUserManagementScreen(),
        AdminSupervisorManagementScreen.routeName: (_) =>
            const AdminSupervisorManagementScreen(),
        AdminCommitteeManagementScreen.routeName: (_) =>
            const AdminCommitteeManagementScreen(),
        AdminCommitteeAccessScreen.routeName: (_) =>
            const AdminCommitteeAccessScreen(),
        AdminReviewPanelsScreen.routeName: (_) =>
            const AdminReviewPanelsScreen(),
        AdminManageUsersScreen.routeName: (_) => const AdminManageUsersScreen(),
        AdminDeactivateAccountsScreen.routeName: (_) =>
            const AdminDeactivateAccountsScreen(),
        AddUserScreen.routeName: (_) => const AddUserScreen(),
        AssignSupervisorScreen.routeName: (_) => const AssignSupervisorScreen(),
        AdminSupervisorLoadScreen.routeName: (_) =>
            const AdminSupervisorLoadScreen(),
        SystemAnalyticsScreen.routeName: (_) => const SystemAnalyticsScreen(),
        DocSubmissionsScreen.routeName: (_) => const DocSubmissionsScreen(),
        StudentDashboardScreen.routeName: (_) => const StudentDashboardScreen(),
        StudentMessagesScreen.routeName: (_) => const StudentMessagesScreen(),
        StudentGroupsScreen.routeName: (_) => const StudentGroupsScreen(),
        StudentReportsScreen.routeName: (_) => const StudentReportsScreen(),
        StudentSettingsScreen.routeName: (_) => const StudentSettingsScreen(),
        DocumentsScreen.routeName: (_) => const DocumentsScreen(),
        StudentProfileScreen.routeName: (_) => const StudentProfileScreen(),
        StudentNotificationsSettingsScreen.routeName: (_) =>
            const StudentNotificationsSettingsScreen(),
        StudentSecuritySettingsScreen.routeName: (_) =>
            const StudentSecuritySettingsScreen(),
        SubmitProposalScreen.routeName: (_) => const SubmitProposalScreen(),
        SubmitProgressReportScreen.routeName: (_) =>
            const SubmitProgressReportScreen(),
        VivaScheduleScreen.routeName: (_) => const VivaScheduleScreen(),
        CommitteeDashboardScreen.routeName: (_) =>
            const CommitteeDashboardScreen(),
        CommitteeProposalReviewScreen.routeName: (_) =>
            const CommitteeProposalReviewScreen(),
        CommitteeVivaSchedulingScreen.routeName: (_) =>
            const CommitteeVivaSchedulingScreen(),
        CommitteeSettingsScreen.routeName: (_) =>
            const CommitteeSettingsScreen(),
        SupervisorDashboardScreen.routeName: (_) => const SupervisorDashboardScreen(),
        SupervisorMessagesScreen.routeName: (_) => const SupervisorMessagesScreen(),
        SupervisorProgressReportsScreen.routeName: (_) =>
            const SupervisorProgressReportsScreen(),
        SupervisorSettingsScreen.routeName: (_) =>
            const SupervisorSettingsScreen(),
        SupervisorNotificationsSettingsScreen.routeName: (_) =>
            const SupervisorNotificationsSettingsScreen(),
        SupervisorSecuritySettingsScreen.routeName: (_) =>
            const SupervisorSecuritySettingsScreen(),
        SupervisorProfileScreen.routeName: (_) =>
            const SupervisorProfileScreen(),
      },
    );
  }
}
