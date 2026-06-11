import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

enum FeedbackKind { error, success, info }

class FeedbackBanner extends StatelessWidget {
  const FeedbackBanner({
    super.key,
    required this.message,
    required this.kind,
    this.onDismiss,
  });

  final String message;
  final FeedbackKind kind;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final palette = switch (kind) {
      FeedbackKind.error => _BannerPalette(
          background: const Color(0xFFFEF2F2),
          border: AppColors.error.withValues(alpha: 0.25),
          icon: Icons.error_outline_rounded,
          iconColor: AppColors.error,
          textColor: const Color(0xFF991B1B),
        ),
      FeedbackKind.success => _BannerPalette(
          background: const Color(0xFFF0FDF4),
          border: AppColors.success.withValues(alpha: 0.25),
          icon: Icons.check_circle_outline_rounded,
          iconColor: AppColors.success,
          textColor: const Color(0xFF166534),
        ),
      FeedbackKind.info => _BannerPalette(
          background: AppColors.surfaceMuted,
          border: AppColors.border,
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.navy,
          textColor: AppColors.textPrimary,
        ),
    };

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(palette.icon, color: palette.iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.outfit(
                  color: palette.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
            if (onDismiss != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: Icon(Icons.close_rounded, size: 18, color: palette.textColor.withValues(alpha: 0.7)),
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );
  }
}

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    FeedbackKind kind = FeedbackKind.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final palette = switch (kind) {
      FeedbackKind.error => (bg: AppColors.navy, fg: Colors.white, icon: Icons.error_outline_rounded),
      FeedbackKind.success => (bg: AppColors.success, fg: Colors.white, icon: Icons.check_circle_outline_rounded),
      FeedbackKind.info => (bg: AppColors.navy, fg: Colors.white, icon: Icons.info_outline_rounded),
    };

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: palette.bg,
        duration: duration,
        content: Row(
          children: [
            Icon(palette.icon, color: palette.fg, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.outfit(
                  color: palette.fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerPalette {
  const _BannerPalette({
    required this.background,
    required this.border,
    required this.icon,
    required this.iconColor,
    required this.textColor,
  });

  final Color background;
  final Color border;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
}
