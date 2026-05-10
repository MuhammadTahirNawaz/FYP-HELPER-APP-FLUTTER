import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    // Minimalist Sleek Light Theme (Inspired by User Image)
    const Color bgColor      = Color(0xFFF8F9FA); // Soft off-white
    const Color surfaceColor = Color(0xFFFFFFFF); // Pure white cards
    const Color primaryDark  = Color(0xFF000000); // Bold black titles
    const Color primaryMid   = Color(0xFF111827); // Deep slate grey
    const Color accentColor  = Color(0xFF000000); // Pitch black accents
    const Color labelGrey    = Color(0xFF6B7280); // Muted grey text
    const Color borderColor  = Color(0xFFE5E7EB); // Subtle borders

    final colorScheme = ColorScheme.light(
      primary:         accentColor,
      secondary:       primaryMid,
      surface:         surfaceColor,
      onPrimary:       Colors.white,
      onSurface:       primaryDark,
      outline:         borderColor,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: bgColor,
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: GoogleFonts.interTextTheme().copyWith(
          displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: primaryDark),
          titleLarge:   GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: primaryDark),
          titleMedium:  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: primaryDark),
          titleSmall:   GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: primaryDark),
          bodyLarge:    GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: const Color(0xFFF1F5F9)),
          bodyMedium:   GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: labelGrey),
          bodySmall:    GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: labelGrey),
          labelLarge:   GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: primaryMid),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: bgColor,
          foregroundColor: primaryDark,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: primaryDark,
          ),
          iconTheme: const IconThemeData(color: primaryDark),
        ),
        cardTheme: CardThemeData(
          color: surfaceColor,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: borderColor, width: 1),
          ),
          shadowColor: const Color(0x18143758),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: primaryDark,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          tileColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryMid, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: GoogleFonts.inter(color: labelGrey, fontSize: 14),
          labelStyle: GoogleFonts.inter(color: labelGrey, fontSize: 14),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
            elevation: 0,
          ).copyWith(
            overlayColor: WidgetStateProperty.all(Colors.white12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryDark,
            side: const BorderSide(color: primaryDark, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryMid,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFE8EEF8),
          labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: primaryDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),
        dividerTheme: const DividerThemeData(
          color: borderColor,
          thickness: 1,
          space: 24,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surfaceColor,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: const Color(0x22000000),
          indicatorColor: primaryMid.withOpacity(0.2),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? primaryMid : labelGrey,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? primaryMid : labelGrey,
              size: 22,
            );
          }),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: surfaceColor,
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: primaryDark,
          contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 13),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          elevation: 0,
        ),
      ),
      initialRoute: SignInScreen.routeName,
      routes: {
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
