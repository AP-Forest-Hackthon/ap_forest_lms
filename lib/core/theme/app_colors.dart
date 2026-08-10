// ─────────────────────────────────────────────────────────────────────────────
// lib/core/theme/app_colors.dart
// Forest-inspired professional color palette.
// All colors are centralized here — change once, applies everywhere.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary Forest Green Palette ──────────────────────────────────────────
  static const Color primary = Color(0xFF1B5E20);       // Deep Forest Green
  static const Color primaryLight = Color(0xFF2E7D32);  // Forest Green
  static const Color primaryLighter = Color(0xFF388E3C); // Mid Green
  static const Color primarySurface = Color(0xFFE8F5E9); // Very light green bg

  // ── Accent Gold ───────────────────────────────────────────────────────────
  static const Color accent = Color(0xFFF9A825);        // Forest Gold
  static const Color accentLight = Color(0xFFFFF8E1);   // Gold tint bg
  static const Color accentDark = Color(0xFFE65100);    // Burnt amber (badges)

  // ── Neutral / Background ──────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F5F0);    // Warm white/cream
  static const Color surface = Color(0xFFFFFFFF);       // Pure white cards
  static const Color surfaceVariant = Color(0xFFF0F4EE); // Light green-grey bg

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A1A);   // Near black
  static const Color textSecondary = Color(0xFF5A5A5A); // Dark grey
  static const Color textHint = Color(0xFF9E9E9E);      // Light grey
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on green
  static const Color textOnAccent = Color(0xFF1A1A1A);  // Dark on gold

  // ── Status Colors ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF9A825);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ── Border & Divider ──────────────────────────────────────────────────────
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // ── Shadow ────────────────────────────────────────────────────────────────
  static const Color shadow = Color(0x1A000000);
  static const Color shadowMedium = Color(0x26000000);

  // ── Priority Badges ───────────────────────────────────────────────────────
  static const Color priorityNormal = Color(0xFF1565C0);
  static const Color priorityImportant = Color(0xFFF9A825);
  static const Color priorityUrgent = Color(0xFFC62828);

  // ── Progress ─────────────────────────────────────────────────────────────
  static const Color progressTrack = Color(0xFFE0E0E0);
  static const Color progressFill = Color(0xFF2E7D32);

  // ── Role Badges ───────────────────────────────────────────────────────────
  static const Color roleTrainee = Color(0xFF1565C0);
  static const Color roleFaculty = Color(0xFF4A148C);
  static const Color roleAdmin = Color(0xFFBF360C);

  // ── Category Colors (for course/resource categories) ─────────────────────
  static const List<Color> categoryColors = [
    Color(0xFF1B5E20), // Forest Management
    Color(0xFF1A237E), // Wildlife Conservation
    Color(0xFFB71C1C), // Forest Protection
    Color(0xFFE65100), // Forest Fire Management
    Color(0xFF4A148C), // Biodiversity
    Color(0xFF006064), // GIS & Remote Sensing
    Color(0xFF1565C0), // Forest Laws
    Color(0xFF33691E), // Silviculture
    Color(0xFF004D40), // Community Forestry
    Color(0xFF37474F), // Field Training
    Color(0xFF3E2723), // General Training
  ];

  // ── Gradient for Hero sections ────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
  );
}
