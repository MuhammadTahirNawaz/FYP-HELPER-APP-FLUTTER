import 'package:flutter/material.dart';

import '../screens/admin/add_user_screen.dart';
import '../screens/admin/admin_access_control_screen.dart';
import '../screens/admin/admin_committee_access_screen.dart';
import '../screens/admin/admin_committee_management_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_deactivate_accounts_screen.dart';
import '../screens/admin/admin_group_records_screen.dart';
import '../screens/admin/admin_manage_users_screen.dart';
import '../screens/admin/admin_management_screen.dart';
import '../screens/admin/admin_notifications_settings_screen.dart';
import '../screens/admin/admin_profile_settings_screen.dart';
import '../screens/admin/admin_reports_screen.dart';
import '../screens/admin/admin_review_panels_screen.dart';
import '../screens/admin/admin_settings_screen.dart';
import '../screens/admin/admin_supervisor_load_screen.dart';
import '../screens/admin/admin_supervisor_management_screen.dart';
import '../screens/admin/admin_system_preferences_screen.dart';
import '../screens/admin/admin_user_management_screen.dart';
import '../screens/admin/assign_supervisor_screen.dart';
import '../screens/admin/doc_submissions_screen.dart';
import '../screens/admin/system_analytics_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_out_screen.dart';
import '../screens/committee/committee_dashboard_screen.dart';
import '../screens/committee/committee_proposal_review_screen.dart';
import '../screens/committee/committee_settings_screen.dart';
import '../screens/committee/committee_viva_scheduling_screen.dart';
import '../screens/shared/documents_screen.dart';
import '../screens/shared/splash_screen.dart';
import '../screens/student/student_dashboard_screen.dart';
import '../screens/student/student_groups_screen.dart';
import '../screens/student/student_messages_screen.dart';
import '../screens/student/student_notifications_settings_screen.dart';
import '../screens/student/student_profile_screen.dart';
import '../screens/student/student_reports_screen.dart';
import '../screens/student/student_security_settings_screen.dart';
import '../screens/student/student_settings_screen.dart';
import '../screens/student/submit_progress_report_screen.dart';
import '../screens/student/submit_proposal_screen.dart';
import '../screens/student/viva_schedule_screen.dart';
import '../screens/supervisor/supervisor_dashboard_screen.dart';
import '../screens/supervisor/supervisor_messages_screen.dart';
import '../screens/supervisor/supervisor_notifications_settings_screen.dart';
import '../screens/supervisor/supervisor_profile_screen.dart';
import '../screens/supervisor/supervisor_progress_reports_screen.dart';
import '../screens/supervisor/supervisor_security_settings_screen.dart';
import '../screens/supervisor/supervisor_settings_screen.dart';

class AppRouter {
  AppRouter._();

  static const String initialRoute = SplashScreen.routeName;

  static Map<String, WidgetBuilder> get routes => {
        SplashScreen.routeName: (_) => const SplashScreen(),
        SignInScreen.routeName: (_) => const SignInScreen(),
        SignOutScreen.routeName: (_) => const SignOutScreen(),
        AdminDashboardScreen.routeName: (_) => const AdminDashboardScreen(),
        AdminManagementScreen.routeName: (_) => const AdminManagementScreen(),
        AdminReportsScreen.routeName: (_) => const AdminReportsScreen(),
        '/admin-messages': (_) => const AdminDashboardScreen(),
        AdminGroupRecordsScreen.routeName: (_) =>
            const AdminGroupRecordsScreen(),
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
        SupervisorDashboardScreen.routeName: (_) =>
            const SupervisorDashboardScreen(),
        SupervisorMessagesScreen.routeName: (_) =>
            const SupervisorMessagesScreen(),
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
      };
}
