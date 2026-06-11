import 'package:flutter/material.dart';

import 'app_colors.dart';

enum DashboardCardVariant { light, navy }

/// White workspace + charcoal navy accent cards.
class DashboardStyles {
  DashboardStyles._();

  static const double cardRadius = 24;
  static const double chipRadius = 28;
  static const double navRadius = 32;
  static const double buttonRadius = 28;

  static const Color chartTrackLight = Color(0xFFE5E7EB);
  static const Color chartTrackNavy = Color(0xFF374151);

  /// White card — soft premium shadow.
  static BoxDecoration lightCardDecoration({Color? accent}) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(cardRadius),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  /// Charcoal card on white background (payment-card style).
  static BoxDecoration navyCardDecoration({Color? accent}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A1C1E), Color(0xFF25282C)],
      ),
      borderRadius: BorderRadius.circular(cardRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.18),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  static BoxDecoration cardDecoration({
    Color? accent,
    bool elevated = false,
    DashboardCardVariant variant = DashboardCardVariant.light,
  }) {
    if (variant == DashboardCardVariant.navy) {
      return navyCardDecoration(accent: accent);
    }
    return lightCardDecoration(accent: accent);
  }
}
