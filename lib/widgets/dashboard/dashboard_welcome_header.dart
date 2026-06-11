import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class DashboardWelcomeHeader extends StatelessWidget {
  const DashboardWelcomeHeader({
    super.key,
    required this.greeting,
    required this.name,
    required this.subtitle,
    required this.accentColor,
    this.avatar,
    this.trailing,
    this.onLightBackground = true,
  });

  final String greeting;
  final String name;
  final String subtitle;
  final Color accentColor;
  final Widget? avatar;
  final Widget? trailing;
  final bool onLightBackground;

  @override
  Widget build(BuildContext context) {
    if (onLightBackground) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          avatar ??
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.surfaceMuted,
                child: Icon(Icons.person, color: accentColor, size: 28),
              ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1C1E), Color(0xFF25282C)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: AppColors.textOnNavyMuted,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textOnNavy,
                    fontSize: 22,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textOnNavyMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
          if (trailing == null && avatar != null) ...[
            const SizedBox(width: 12),
            avatar!,
          ],
        ],
      ),
    );
  }
}
