import 'package:flutter/material.dart';

import '../../../theme/dashboard_styles.dart';
import '../../../widgets/dashboard/dashboard_kpi_card.dart';

class AdminStatItem {
  const AdminStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
}

class AdminStatsGrid extends StatelessWidget {
  const AdminStatsGrid({
    super.key,
    required this.stats,
    this.variant = DashboardCardVariant.light,
  });

  final List<AdminStatItem> stats;
  final DashboardCardVariant variant;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15,
      physics: const NeverScrollableScrollPhysics(),
      children: stats
          .map(
            (stat) => DashboardKpiCard(
              label: stat.label,
              value: stat.value,
              icon: stat.icon,
              accent: stat.accent,
              compact: true,
              variant: variant,
            ),
          )
          .toList(),
    );
  }
}
