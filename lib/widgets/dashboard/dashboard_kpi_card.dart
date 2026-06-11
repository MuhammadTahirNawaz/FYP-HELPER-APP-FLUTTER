import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/dashboard_styles.dart';

class DashboardKpiCard extends StatelessWidget {
  const DashboardKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.compact = false,
    this.variant = DashboardCardVariant.navy,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final bool compact;
  final DashboardCardVariant variant;

  bool get _onNavy => variant == DashboardCardVariant.navy;

  @override
  Widget build(BuildContext context) {
    final valueColor = _onNavy ? AppColors.textOnNavy : AppColors.textPrimary;
    final labelColor = _onNavy ? AppColors.textOnNavyMuted : AppColors.textSecondary;
    final iconColor = _onNavy ? AppColors.textOnNavy : accent;

    return Container(
      decoration: DashboardStyles.cardDecoration(accent: accent, variant: variant),
      padding: EdgeInsets.all(compact ? 16 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _onNavy
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: compact ? 18 : 20),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up_rounded,
                color: _onNavy
                    ? AppColors.textOnNavyMuted
                    : accent.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
          SizedBox(height: compact ? 14 : 18),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                  fontSize: compact ? 20 : 24,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
