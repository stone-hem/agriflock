import 'package:flutter/material.dart';

// ─── Color Palette ─────────────────────────────────────────────────────────────

// --- Dark Colors ---
class AppColorsDark {
  // Background layers
  static const bg = Color(0xFF0D0D0F);
  static const surface = Color(0xFF141417);
  static const surfaceElevated = Color(0xFF1C1C21);
  static const surfaceHighlight = Color(0xFF242429);
  static const border = Color(0xFF2A2A32);
  static const borderBright = Color(0xFF3D3D4A);

  // Text
  static const textPrimary = Color(0xFFF0F0F5);
  static const textSecondary = Color(0xFF8E8E9E);
  static const textMuted = Color(0xFF4A4A5A);

  // Accents
  static const primary = Color(0xFF15562E); // deep green
  static const primaryMuted = Color(0xFF0E3B1F);
  static const accentOrange = Color(0xFFCA652F);
  static const accentMaroon = Color(0xFF6C2E2D);
  static const accentGold = Color(0xFFF1C04C);
  static const accentGreen = Color(0xFF3DD68C);

  // Priority colors
  static const priorityLow = Color(0xFF3DD68C);
  static const priorityMedium = Color(0xFFF1C04C);
  static const priorityHigh = Color(0xFFCA652F);
  static const priorityUrgent = Color(0xFF6C2E2D);
}

// --- Light Colors ---
class AppColorsLight {
  // Background layers
  static const bg = Color(0xFFF5F5F0);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFF0EDE8);
  static const surfaceHighlight = Color(0xFFE8E4DD);
  static const border = Color(0xFFD6D1C9);
  static const borderBright = Color(0xFFBFB9AE);

  // Text
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF5C5C5C);
  static const textMuted = Color(0xFF9E9E9E);

  // Accents
  static const primary = Color(0xFF15562E); // deep green
  static const primaryMuted = Color(0xFFCDE6D5);
  static const accentOrange = Color(0xFFCA652F);
  static const accentMaroon = Color(0xFF6C2E2D);
  static const accentGold = Color(0xFFF1C04C);
  static const accentGreen = Color(0xFF2AB86E);

  // Priority colors
  static const priorityLow = Color(0xFF2AB86E);
  static const priorityMedium = Color(0xFFF1C04C);
  static const priorityHigh = Color(0xFFCA652F);
  static const priorityUrgent = Color(0xFF6C2E2D);
}

// Active palette — switch here to swap between light / dark
typedef AppColors = AppColorsLight;

// ─── Typography ────────────────────────────────────────────────────────────────
class AppTextStyles {
  static const _base =
      TextStyle(fontFamily: 'DMSans', color: AppColors.textPrimary);

  static final displayLarge = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.1,
  );

  static final displayMedium = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static final headingLarge = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static final headingMedium = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static final bodyLarge = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textSecondary,
  );

  static final bodyMedium = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static final label = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textMuted,
  );

  static final mono = _base.copyWith(
    fontFamily: 'monospace',
    fontSize: 13,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );
}

// ─── Theme ─────────────────────────────────────────────────────────────────────
class AppTheme {
  // ── Light theme ──────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColorsLight.bg,
        fontFamily: 'DMSans',
        colorScheme: const ColorScheme.light(
          primary: AppColorsLight.primary,
          secondary: AppColorsLight.accentOrange,
          surface: AppColorsLight.surface,
          onPrimary: Colors.white,
          onSurface: AppColorsLight.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColorsLight.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColorsLight.textPrimary,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(color: AppColorsLight.textSecondary),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColorsLight.surface,
          indicatorColor: AppColorsLight.primaryMuted,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColorsLight.primary);
            }
            return const IconThemeData(color: AppColorsLight.textMuted);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.label
                  .copyWith(color: AppColorsLight.primary);
            }
            return AppTextStyles.label;
          }),
          height: 68,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColorsLight.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColorsLight.border),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColorsLight.surfaceElevated,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColorsLight.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColorsLight.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColorsLight.primary, width: 1.5),
          ),
          labelStyle: AppTextStyles.bodyMedium,
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColorsLight.textMuted),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColorsLight.primary,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColorsLight.border,
          thickness: 1,
          space: 1,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColorsLight.surfaceElevated,
          selectedColor: AppColorsLight.primaryMuted,
          labelStyle: AppTextStyles.bodyMedium
              .copyWith(fontSize: 12, color: AppColorsLight.textSecondary),
          side: const BorderSide(color: AppColorsLight.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),
      );

  // ── Dark theme ───────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColorsDark.bg,
        fontFamily: 'DMSans',
        colorScheme: const ColorScheme.dark(
          primary: AppColorsDark.primary,
          secondary: AppColorsDark.accentOrange,
          surface: AppColorsDark.surface,
          onPrimary: Colors.white,
          onSurface: AppColorsDark.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColorsDark.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColorsDark.textPrimary,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(color: AppColorsDark.textSecondary),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColorsDark.surface,
          indicatorColor: AppColorsDark.primaryMuted,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColorsDark.primary);
            }
            return const IconThemeData(color: AppColorsDark.textMuted);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.label
                  .copyWith(color: AppColorsDark.primary);
            }
            return AppTextStyles.label;
          }),
          height: 68,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColorsDark.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColorsDark.border),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColorsDark.surfaceElevated,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColorsDark.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColorsDark.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColorsDark.primary, width: 1.5),
          ),
          labelStyle: AppTextStyles.bodyMedium,
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColorsDark.textMuted),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColorsDark.primary,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColorsDark.border,
          thickness: 1,
          space: 1,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColorsDark.surfaceElevated,
          selectedColor: AppColorsDark.primaryMuted,
          labelStyle: AppTextStyles.bodyMedium
              .copyWith(fontSize: 12, color: AppColorsDark.textSecondary),
          side: const BorderSide(color: AppColorsDark.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),
      );
}
