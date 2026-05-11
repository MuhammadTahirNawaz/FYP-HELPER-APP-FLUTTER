import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core background & surfaces - Lightened to match user preference
  static const Color bg = Color(0xFF1E293B); 
  static const Color surface = Color(0xFF334155);
  static const Color surfaceLight = Color(0xFF475569);

  // Brand Accents (Identity Colors)
  static const Color adminPink = Color(0xFFFF007F);  // Vibrant Neon Pink
  static const Color studentTeal = Color(0xFF00E5FF); // Vibrant Neon Cyan
  static const Color secondaryPink = Color(0xFFFF00FF); 
  static const Color secondaryCyan = Color(0xFF00BFA5);

  // Status & Utility
  static const Color success = Color(0xFF00FF9D);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF3D00);
  static const Color info = Color(0xFF2979FF);

  // Typography
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Borders & Glows
  static const Color border = Color(0xFF334155);
  static const Color borderAdmin = Color(0x66FF005C);
  static const Color borderStudent = Color(0x6600E5FF);
  static const Color inputBg = Color(0xFFF0F4F8); // White/Light blue background for inputs

  // Legacy compatibility
  static const Color black = bg;
  static const Color surfaceStrong = surfaceLight;
  static const Color infoBlue = info;
  static const Color primaryBlue = studentTeal;
  static const Color slateText = textSecondary;
  static const Color selectedTile = surfaceLight;
  static const Color borderSoft = border;
  static const Color deepBlue = bg;
  static const Color caption = textMuted;
  static const Color primaryIndigo = info;
  static const Color chipBg = surface;
  static const Color infoIndigo = info;
  static const Color cardSoft = surface;
  static const Color panelSoft = surface;
  static const Color borderLight = border;
  static const Color borderVeryLight = border;
}
