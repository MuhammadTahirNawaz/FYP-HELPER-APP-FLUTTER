import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/dashboard_styles.dart';

class DashboardInfoTile extends StatelessWidget {
  const DashboardInfoTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.trailing,
    this.variant = DashboardCardVariant.light,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final Widget? trailing;
  final DashboardCardVariant variant;

  bool get _onNavy => variant == DashboardCardVariant.navy;

  @override
  Widget build(BuildContext context) {
    final valueColor = _onNavy ? AppColors.textOnNavy : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: DashboardStyles.cardDecoration(accent: accent, variant: variant),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: _onNavy ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
