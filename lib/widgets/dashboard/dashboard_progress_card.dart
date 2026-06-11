import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/dashboard_styles.dart';

class DashboardProgressCard extends StatelessWidget {
  const DashboardProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.accent,
    this.bars,
    this.variant = DashboardCardVariant.light,
  });

  final String title;
  final String subtitle;
  final double progress;
  final Color accent;
  final List<double>? bars;
  final DashboardCardVariant variant;

  bool get _onNavy => variant == DashboardCardVariant.navy;

  @override
  Widget build(BuildContext context) {
    final chartBars = bars ??
        List<double>.generate(
          7,
          (i) => (0.35 + (progress * 0.55) * ((i % 3) + 1) / 3).clamp(0.2, 1.0),
        );

    final titleColor = _onNavy ? AppColors.textOnNavy : AppColors.textPrimary;
    final subtitleColor = _onNavy ? AppColors.textOnNavyMuted : AppColors.textSecondary;
    final trackColor = _onNavy ? DashboardStyles.chartTrackNavy : DashboardStyles.chartTrackLight;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DashboardStyles.cardDecoration(accent: accent, variant: variant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: subtitleColor,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: trackColor,
              color: accent,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 72,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final height in chartBars) ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        height: 72 * height,
                        decoration: BoxDecoration(
                          color: accent.withValues(
                            alpha: _onNavy
                                ? 0.25 + (height * 0.45)
                                : 0.15 + (height * 0.35),
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

double proposalStatusProgress(String? status) {
  switch (status) {
    case 'Approved by Supervisor':
    case 'Approved':
      return 1.0;
    case 'Submitted':
      return 0.55;
    case 'Rejected by Supervisor':
    case 'Rejected':
      return 0.25;
    default:
      return 0.12;
  }
}
