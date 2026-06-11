import 'package:flutter/material.dart';

/// Minimal white + charcoal navy palette (car-rental / premium app style).
class AppColors {
  AppColors._();

  // Pure white workspace
  static const Color bg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF3F4F6);

  // Charcoal navy — headers, primary buttons, dark cards
  static const Color navy = Color(0xFF1A1C1E);
  static const Color navyLight = Color(0xFF25282C);
  static const Color navyCard = Color(0xFF1A1C1E);

  // Role accents (monochrome-first; navy drives CTAs)
  static const Color studentTeal = Color(0xFF1A1C1E);
  static const Color adminPink = Color(0xFF1A1C1E);
  static const Color secondaryPink = Color(0xFFEF4444);
  static const Color secondaryCyan = Color(0xFF6B7280);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF1A1C1E);

  // Text on white
  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFFD1D5DB);

  // Text on navy
  static const Color textOnNavy = Color(0xFFFFFFFF);
  static const Color textOnNavyMuted = Color(0xFF9CA3AF);

  // Borders & inputs
  static const Color border = Color(0xFFE5E7EB);
  static const Color inputBg = Color(0xFFF3F4F6);
  static const Color inputBorder = Color(0xFFE5E7EB);

  // Legacy compatibility
  static const Color black = navy;
  static const Color surfaceLight = surfaceMuted;
  static const Color surfaceStrong = navyLight;
  static const Color infoBlue = info;
  static const Color primaryBlue = navy;
  static const Color slateText = textSecondary;
  static const Color selectedTile = surfaceMuted;
  static const Color borderSoft = border;
  static const Color deepBlue = navy;
  static const Color caption = textSecondary;
  static const Color primaryIndigo = navy;
  static const Color chipBg = surfaceMuted;
  static const Color infoIndigo = navy;
  static const Color cardSoft = surface;
  static const Color panelSoft = surfaceMuted;
  static const Color borderLight = border;
  static const Color borderVeryLight = border;
  static const Color borderAdmin = Color(0x331A1C1E);
  static const Color borderStudent = Color(0x331A1C1E);
}
