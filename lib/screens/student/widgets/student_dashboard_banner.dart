import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/dashboard/dashboard_welcome_header.dart';

class StudentDashboardBanner extends StatelessWidget {
  const StudentDashboardBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.userName,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? userName;

  @override
  Widget build(BuildContext context) {
    final initial = (userName?.isNotEmpty == true ? userName!.trim()[0] : 'S').toUpperCase();

    return DashboardWelcomeHeader(
      greeting: title,
      name: userName ?? 'Student',
      subtitle: subtitle,
      accentColor: AppColors.navy,
      onLightBackground: true,
      avatar: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.surfaceMuted,
        child: Text(
          initial,
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
