import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/dashboard_styles.dart';

class DashboardCategoryChips extends StatelessWidget {
  const DashboardCategoryChips({
    super.key,
    required this.labels,
    required this.accentColor,
    this.highlightIndex = 0,
    this.onNavy = false,
  });

  final List<String> labels;
  final Color accentColor;
  final int highlightIndex;
  final bool onNavy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = index == highlightIndex;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? (onNavy ? accentColor.withValues(alpha: 0.2) : accentColor)
                  : (onNavy ? AppColors.navyCard : AppColors.surfaceMuted),
              borderRadius: BorderRadius.circular(DashboardStyles.chipRadius),
              border: Border.all(
                color: selected
                    ? accentColor
                    : (onNavy ? AppColors.navyLight : AppColors.border),
              ),
            ),
            child: Text(
              labels[index],
              style: TextStyle(
                color: selected
                    ? (onNavy ? AppColors.textOnNavy : AppColors.textOnNavy)
                    : (onNavy ? AppColors.textOnNavyMuted : AppColors.textSecondary),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          );
        },
      ),
    );
  }
}
