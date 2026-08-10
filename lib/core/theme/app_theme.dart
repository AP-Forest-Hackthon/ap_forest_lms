// ─────────────────────────────────────────────────────────────────────────────
// lib/core/theme/app_theme.dart
// Material 3 theme using forest color palette and Inter font.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.primarySurface,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.accent,
      onSecondary: AppColors.textOnAccent,
      secondaryContainer: AppColors.accentLight,
      onSecondaryContainer: AppColors.accentDark,
      tertiary: AppColors.primaryLighter,
      onTertiary: AppColors.textOnPrimary,
      tertiaryContainer: AppColors.surfaceVariant,
      onTertiaryContainer: AppColors.primary,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
      errorContainer: AppColors.errorLight,
      onErrorContainer: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
      shadow: AppColors.shadow,
      scrim: Colors.black,
      inverseSurface: AppColors.textPrimary,
      onInverseSurface: AppColors.surface,
      inversePrimary: AppColors.primaryLighter,
    );

    final textTheme = GoogleFonts.interTextTheme(
      TextTheme(
        // Display
        displayLarge: const TextStyle(
          fontSize: 57, fontWeight: FontWeight.w700, letterSpacing: -0.25,
          color: AppColors.textPrimary,
        ),
        displayMedium: const TextStyle(
          fontSize: 45, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displaySmall: const TextStyle(
          fontSize: 36, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        // Headline
        headlineLarge: const TextStyle(
          fontSize: 32, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: const TextStyle(
          fontSize: 28, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: const TextStyle(
          fontSize: 24, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        // Title
        titleLarge: const TextStyle(
          fontSize: 22, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15,
          color: AppColors.textPrimary,
        ),
        titleSmall: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1,
          color: AppColors.textPrimary,
        ),
        // Body
        bodyLarge: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5,
          color: AppColors.textPrimary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25,
          color: AppColors.textPrimary,
        ),
        bodySmall: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4,
          color: AppColors.textSecondary,
        ),
        // Label
        labelLarge: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1,
          color: AppColors.textPrimary,
        ),
        labelMedium: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5,
          color: AppColors.textSecondary,
        ),
        labelSmall: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5,
          color: AppColors.textHint,
        ),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: AppColors.primary, fontSize: 12),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primarySurface,
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Drawer
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textHint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primarySurface;
          return AppColors.border;
        }),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.progressTrack,
      ),

      // List Tile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: Colors.transparent,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.inter(
          color: AppColors.surface,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
    );
  }
}
