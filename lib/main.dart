import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
import 'screens/student/student_dashboard_screen.dart';
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
import 'screens/supervisor/supervisor_progress_reports_screen.dart';
import 'screens/supervisor/supervisor_requests_screen.dart';
import 'screens/supervisor/supervisor_security_settings_screen.dart';
import 'screens/supervisor/supervisor_settings_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E4E8C),
      surface: const Color(0xFFF7F5F2),
      secondary: const Color(0xFF2F6DA4),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        textTheme: GoogleFonts.spaceGroteskTextTheme(),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F6F2),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF8F6F2),
          foregroundColor: const Color(0xFF1B1B1B),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B1B1B),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFF2F5FA),
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE1E5EA)),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: Color(0xFF1B1B1B),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFFF2F5FA),
          indicatorColor: colorScheme.primary.withOpacity(0.12),
          labelTextStyle: WidgetStateProperty.all(
            GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          iconTheme: WidgetStateProperty.all(
            const IconThemeData(color: Color(0xFF1B1B1B)),
          ),
        ),
      ),
      initialRoute: SignInScreen.routeName,
      routes: {
        SignInScreen.routeName: (_) => const SignInScreen(),
        SignOutScreen.routeName: (_) => const SignOutScreen(),
        AdminDashboardScreen.routeName: (_) => const AdminDashboardScreen(),
        AdminManagementScreen.routeName: (_) => const AdminManagementScreen(),
        AdminReportsScreen.routeName: (_) => const AdminReportsScreen(),
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
        StudentGroupsScreen.routeName: (_) => const StudentGroupsScreen(),
        StudentReportsScreen.routeName: (_) => const StudentReportsScreen(),
        StudentSettingsScreen.routeName: (_) => const StudentSettingsScreen(),
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
        SupervisorDashboardScreen.routeName: (_) =>
            const SupervisorDashboardScreen(),
        SupervisorRequestsScreen.routeName: (_) =>
            const SupervisorRequestsScreen(),
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
