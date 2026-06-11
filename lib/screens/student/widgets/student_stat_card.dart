import 'package:flutter/material.dart';

import '../../../theme/dashboard_styles.dart';
import '../../../widgets/dashboard/dashboard_kpi_card.dart';

class StudentStatCard extends StatelessWidget {
  const StudentStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.compact = false,
    this.variant = DashboardCardVariant.navy,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool compact;
  final DashboardCardVariant variant;

  @override
  Widget build(BuildContext context) {
    return DashboardKpiCard(
      label: title,
      value: value,
      icon: icon,
      accent: color,
      compact: compact,
      variant: variant,
    );
  }
}
