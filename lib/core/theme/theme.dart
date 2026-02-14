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

// ─── Shared Radius / Spacing Constants ────────────────────────────────────────
class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 28.0;
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

// ─── Theme ─────────────────────────────────────────────────────────────────────
class AppTheme {
  // ── Light theme ──────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColorsLight.bg,
    fontFamily: 'DMSans',

    // ── Color Scheme ─────────────────────────────────────────────────
    colorScheme: const ColorScheme.light(
      primary: AppColorsLight.primary,
      primaryContainer: AppColorsLight.primaryMuted,
      secondary: AppColorsLight.accentOrange,
      secondaryContainer: Color(0xFFFFE8D9),
      surface: AppColorsLight.surface,
      surfaceContainerHighest: AppColorsLight.surfaceHighlight,
      onPrimary: Colors.white,
      onPrimaryContainer: AppColorsLight.primary,
      onSurface: AppColorsLight.textPrimary,
      onSurfaceVariant: AppColorsLight.textSecondary,
      outline: AppColorsLight.border,
      outlineVariant: AppColorsLight.borderBright,
      error: Color(0xFFB00020),
      onError: Colors.white,
    ),

    // ── AppBar ───────────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColorsLight.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColorsLight.textPrimary,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: AppColorsLight.textSecondary),
      actionsIconTheme: IconThemeData(color: AppColorsLight.textSecondary),
    ),

    // ── Navigation Bar (bottom) ───────────────────────────────────────
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
          return AppTextStyles.label.copyWith(color: AppColorsLight.primary);
        }
        return AppTextStyles.label;
      }),
      height: 68,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(
        AppColorsLight.primary.withOpacity(0.06),
      ),
    ),

    // ── Navigation Rail ───────────────────────────────────────────────
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColorsLight.surface,
      indicatorColor: AppColorsLight.primaryMuted,
      selectedIconTheme:
      const IconThemeData(color: AppColorsLight.primary),
      unselectedIconTheme:
      const IconThemeData(color: AppColorsLight.textMuted),
      selectedLabelTextStyle: AppTextStyles.label.copyWith(
        color: AppColorsLight.primary,
      ),
      unselectedLabelTextStyle: AppTextStyles.label,
      elevation: 0,
      useIndicator: true,
    ),

    // ── Drawer ───────────────────────────────────────────────────────
    drawerTheme: DrawerThemeData(
      backgroundColor: AppColorsLight.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(AppRadius.xl),
        ),
      ),
      width: 280,
    ),

    // ── Card ─────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: AppColorsLight.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColorsLight.border),
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),

    // ── Bottom Sheet ─────────────────────────────────────────────────
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColorsLight.surface,
      modalBackgroundColor: AppColorsLight.surface,
      elevation: 0,
      modalElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      dragHandleColor: AppColorsLight.borderBright,
      dragHandleSize: Size(40, 4),
      showDragHandle: true,
    ),

    // ── Dialog ───────────────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: AppColorsLight.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      titleTextStyle: AppTextStyles.headingLarge.copyWith(
        color: AppColorsLight.textPrimary,
      ),
      contentTextStyle: AppTextStyles.bodyLarge.copyWith(
        color: AppColorsLight.textSecondary,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
    ),

    // ── Snack Bar ────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColorsLight.surfaceHighlight,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColorsLight.textPrimary,
      ),
      actionTextColor: AppColorsLight.accentGreen,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColorsLight.border),
      ),
      insetPadding: const EdgeInsets.all(AppSpacing.md),
    ),

    // ── Buttons ───────────────────────────────────────────────────────

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsLight.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColorsLight.border,
        disabledForegroundColor: AppColorsLight.textMuted,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        textStyle: AppTextStyles.headingMedium.copyWith(
          color: Colors.white,
        ),
        minimumSize: const Size(64, 48),
      ),
    ),

    // Filled Button
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.border,
        disabledForegroundColor: AppColors.textMuted,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm), // 8.0 — less rounded
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        textStyle: AppTextStyles.headingMedium.copyWith(
          color: Colors.white,
        ),
        minimumSize: const Size(64, 48),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColorsLight.primary,
        disabledForegroundColor: AppColorsLight.textMuted,
        side: const BorderSide(color: AppColorsLight.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        textStyle: AppTextStyles.headingMedium,
        minimumSize: const Size(64, 48),
      ).copyWith(
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused) ||
              states.contains(WidgetState.pressed)) {
            return const BorderSide(
                color: AppColorsLight.primary, width: 1.5);
          }
          return const BorderSide(color: AppColorsLight.border);
        }),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColorsLight.primary,
        disabledForegroundColor: AppColorsLight.textMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        textStyle: AppTextStyles.headingMedium,
        minimumSize: const Size(48, 40),
      ),
    ),

    // Icon Button
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColorsLight.textSecondary,
        disabledForegroundColor: AppColorsLight.textMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        minimumSize: const Size(40, 40),
      ),
    ),

    // FAB
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColorsLight.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
      ),
    ),

    // ── Input / Form ─────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsLight.surfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsLight.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsLight.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:
        const BorderSide(color: AppColorsLight.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:
        const BorderSide(color: Color(0xFFB00020), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:
        const BorderSide(color: Color(0xFFB00020), width: 1.5),
      ),
      labelStyle: AppTextStyles.bodyMedium,
      hintStyle: AppTextStyles.bodyMedium
          .copyWith(color: AppColorsLight.textMuted),
      errorStyle: AppTextStyles.bodyMedium
          .copyWith(color: Color(0xFFB00020), fontSize: 12),
      prefixIconColor: AppColorsLight.textMuted,
      suffixIconColor: AppColorsLight.textMuted,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // ── Selection Controls ────────────────────────────────────────────

    // Checkbox
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsLight.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: AppColorsLight.borderBright, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      overlayColor: WidgetStateProperty.all(
        AppColorsLight.primary.withOpacity(0.08),
      ),
    ),

    // Radio
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsLight.primary;
        }
        return AppColorsLight.borderBright;
      }),
      overlayColor: WidgetStateProperty.all(
        AppColorsLight.primary.withOpacity(0.08),
      ),
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return AppColorsLight.textMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsLight.primary;
        }
        return AppColorsLight.border;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      overlayColor: WidgetStateProperty.all(
        AppColorsLight.primary.withOpacity(0.08),
      ),
    ),

    // Slider
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColorsLight.primary,
      inactiveTrackColor: AppColorsLight.border,
      thumbColor: AppColorsLight.primary,
      overlayColor: AppColorsLight.primary.withOpacity(0.12),
      valueIndicatorColor: AppColorsLight.surfaceHighlight,
      valueIndicatorTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColorsLight.textPrimary,
      ),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
    ),

    // ── Lists & Tiles ─────────────────────────────────────────────────
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: AppColorsLight.primaryMuted,
      selectedColor: AppColorsLight.primary,
      iconColor: AppColorsLight.textSecondary,
      textColor: AppColorsLight.textPrimary,
      titleTextStyle: AppTextStyles.headingMedium.copyWith(
        color: AppColorsLight.textPrimary,
      ),
      subtitleTextStyle: AppTextStyles.bodyMedium,
      leadingAndTrailingTextStyle: AppTextStyles.bodyMedium,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      minVerticalPadding: AppSpacing.sm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      dense: false,
    ),

    // ── Tabs ─────────────────────────────────────────────────────────
    tabBarTheme: TabBarThemeData(
      labelColor: AppColorsLight.primary,
      unselectedLabelColor: AppColorsLight.textMuted,
      labelStyle: AppTextStyles.headingMedium,
      unselectedLabelStyle: AppTextStyles.headingMedium.copyWith(
        color: AppColorsLight.textMuted,
      ),
      indicatorColor: AppColorsLight.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: AppColorsLight.border,
      overlayColor: WidgetStateProperty.all(
        AppColorsLight.primary.withOpacity(0.06),
      ),
      splashFactory: InkRipple.splashFactory,
    ),

    // ── Progress & Loading ────────────────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColorsLight.primary,
      linearTrackColor: AppColorsLight.border,
      circularTrackColor: AppColorsLight.border,
      linearMinHeight: 4,
    ),

    // ── Tooltip ───────────────────────────────────────────────────────
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColorsLight.surfaceHighlight,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColorsLight.border),
      ),
      textStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColorsLight.textPrimary,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      waitDuration: const Duration(milliseconds: 600),
    ),

    // ── Popup Menu ────────────────────────────────────────────────────
    popupMenuTheme: PopupMenuThemeData(
      color: AppColorsLight.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColorsLight.border),
      ),
      textStyle: AppTextStyles.bodyLarge.copyWith(
        color: AppColorsLight.textPrimary,
      ),
      labelTextStyle: WidgetStateProperty.all(
        AppTextStyles.bodyLarge.copyWith(color: AppColorsLight.textPrimary),
      ),
      surfaceTintColor: Colors.transparent,
      position: PopupMenuPosition.under,
    ),

    // ── Divider ───────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColorsLight.border,
      thickness: 1,
      space: 1,
    ),

    // ── Chip ─────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: AppColorsLight.surfaceElevated,
      selectedColor: AppColorsLight.primaryMuted,
      disabledColor: AppColorsLight.border,
      deleteIconColor: AppColorsLight.textMuted,
      labelStyle: AppTextStyles.bodyMedium
          .copyWith(fontSize: 12, color: AppColorsLight.textSecondary),
      secondaryLabelStyle: AppTextStyles.bodyMedium.copyWith(
        fontSize: 12,
        color: AppColorsLight.primary,
      ),
      side: const BorderSide(color: AppColorsLight.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      showCheckmark: true,
      checkmarkColor: AppColorsLight.primary,
    ),

    // ── Search Bar ────────────────────────────────────────────────────
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(AppColorsLight.surfaceElevated),
      elevation: WidgetStateProperty.all(0),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return const BorderSide(
              color: AppColorsLight.primary, width: 1.5);
        }
        return const BorderSide(color: AppColorsLight.border);
      }),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      textStyle: WidgetStateProperty.all(
        AppTextStyles.bodyLarge.copyWith(color: AppColorsLight.textPrimary),
      ),
      hintStyle: WidgetStateProperty.all(
        AppTextStyles.bodyLarge.copyWith(color: AppColorsLight.textMuted),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
    ),

    // ── Expansion Tile ────────────────────────────────────────────────
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      iconColor: AppColorsLight.textSecondary,
      collapsedIconColor: AppColorsLight.textMuted,
      textColor: AppColorsLight.primary,
      collapsedTextColor: AppColorsLight.textPrimary,
      tilePadding:
      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      childrenPadding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      shape: const Border(),
      collapsedShape: const Border(),
    ),

    // ── Badge ─────────────────────────────────────────────────────────
    badgeTheme: BadgeThemeData(
      backgroundColor: AppColorsLight.accentOrange,
      textColor: Colors.white,
      textStyle: AppTextStyles.label.copyWith(
        color: Colors.white,
        fontSize: 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      smallSize: 8,
      largeSize: 18,
    ),

    // ── Date/Time Picker ──────────────────────────────────────────────
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColorsLight.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      headerBackgroundColor: AppColorsLight.primary,
      headerForegroundColor: Colors.white,
      dayOverlayColor: WidgetStateProperty.all(
        AppColorsLight.primary.withOpacity(0.08),
      ),
      todayBorder: const BorderSide(color: AppColorsLight.primary),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return AppColorsLight.textPrimary;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsLight.primary;
        }
        return Colors.transparent;
      }),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return AppColorsLight.textPrimary;
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsLight.primary;
        }
        return Colors.transparent;
      }),
      dividerColor: AppColorsLight.border,
      elevation: 0,
    ),
  );

  // ── Dark theme ───────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColorsDark.bg,
    fontFamily: 'DMSans',

    // ── Color Scheme ─────────────────────────────────────────────────
    colorScheme: const ColorScheme.dark(
      primary: AppColorsDark.primary,
      primaryContainer: AppColorsDark.primaryMuted,
      secondary: AppColorsDark.accentOrange,
      secondaryContainer: Color(0xFF4A2010),
      surface: AppColorsDark.surface,
      surfaceContainerHighest: AppColorsDark.surfaceHighlight,
      onPrimary: Colors.white,
      onPrimaryContainer: AppColorsDark.accentGreen,
      onSurface: AppColorsDark.textPrimary,
      onSurfaceVariant: AppColorsDark.textSecondary,
      outline: AppColorsDark.border,
      outlineVariant: AppColorsDark.borderBright,
      error: Color(0xFFCF6679),
      onError: Colors.black,
    ),

    // ── AppBar ───────────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColorsDark.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColorsDark.textPrimary,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: AppColorsDark.textSecondary),
      actionsIconTheme: IconThemeData(color: AppColorsDark.textSecondary),
    ),

    // ── Navigation Bar (bottom) ───────────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColorsDark.surface,
      indicatorColor: AppColorsDark.primaryMuted,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColorsDark.accentGreen);
        }
        return const IconThemeData(color: AppColorsDark.textMuted);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.label
              .copyWith(color: AppColorsDark.accentGreen);
        }
        return AppTextStyles.label;
      }),
      height: 68,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(
        AppColorsDark.accentGreen.withOpacity(0.06),
      ),
    ),

    // ── Navigation Rail ───────────────────────────────────────────────
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColorsDark.surface,
      indicatorColor: AppColorsDark.primaryMuted,
      selectedIconTheme:
      const IconThemeData(color: AppColorsDark.accentGreen),
      unselectedIconTheme:
      const IconThemeData(color: AppColorsDark.textMuted),
      selectedLabelTextStyle: AppTextStyles.label.copyWith(
        color: AppColorsDark.accentGreen,
      ),
      unselectedLabelTextStyle: AppTextStyles.label,
      elevation: 0,
      useIndicator: true,
    ),

    // ── Drawer ───────────────────────────────────────────────────────
    drawerTheme: DrawerThemeData(
      backgroundColor: AppColorsDark.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(AppRadius.xl),
        ),
      ),
      width: 280,
    ),

    // ── Card ─────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: AppColorsDark.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColorsDark.border),
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),

    // ── Bottom Sheet ─────────────────────────────────────────────────
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColorsDark.surfaceElevated,
      modalBackgroundColor: AppColorsDark.surfaceElevated,
      elevation: 0,
      modalElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      dragHandleColor: AppColorsDark.borderBright,
      dragHandleSize: Size(40, 4),
      showDragHandle: true,
    ),

    // ── Dialog ───────────────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: AppColorsDark.surfaceElevated,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      titleTextStyle: AppTextStyles.headingLarge.copyWith(
        color: AppColorsDark.textPrimary,
      ),
      contentTextStyle: AppTextStyles.bodyLarge.copyWith(
        color: AppColorsDark.textSecondary,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
    ),

    // ── Snack Bar ────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColorsDark.surfaceHighlight,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColorsDark.textPrimary,
      ),
      actionTextColor: AppColorsDark.accentGreen,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColorsDark.border),
      ),
      insetPadding: const EdgeInsets.all(AppSpacing.md),
    ),

    // ── Buttons ───────────────────────────────────────────────────────

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsDark.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColorsDark.border,
        disabledForegroundColor: AppColorsDark.textMuted,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        textStyle: AppTextStyles.headingMedium.copyWith(
          color: Colors.white,
        ),
        minimumSize: const Size(64, 48),
      ),
    ),

    // Filled Button
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.border,
        disabledForegroundColor: AppColors.textMuted,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm), // 8.0 — less rounded
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        textStyle: AppTextStyles.headingMedium.copyWith(
          color: Colors.white,
        ),
        minimumSize: const Size(64, 48),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColorsDark.accentGreen,
        disabledForegroundColor: AppColorsDark.textMuted,
        side: const BorderSide(color: AppColorsDark.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        textStyle: AppTextStyles.headingMedium,
        minimumSize: const Size(64, 48),
      ).copyWith(
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused) ||
              states.contains(WidgetState.pressed)) {
            return const BorderSide(
                color: AppColorsDark.accentGreen, width: 1.5);
          }
          return const BorderSide(color: AppColorsDark.border);
        }),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColorsDark.accentGreen,
        disabledForegroundColor: AppColorsDark.textMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        textStyle: AppTextStyles.headingMedium,
        minimumSize: const Size(48, 40),
      ),
    ),

    // Icon Button
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColorsDark.textSecondary,
        disabledForegroundColor: AppColorsDark.textMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        minimumSize: const Size(40, 40),
      ),
    ),

    // FAB
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColorsDark.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
      ),
    ),

    // ── Input / Form ─────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsDark.surfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsDark.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsDark.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:
        const BorderSide(color: AppColorsDark.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: Color(0xFFCF6679), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: Color(0xFFCF6679), width: 1.5),
      ),
      labelStyle: AppTextStyles.bodyMedium,
      hintStyle: AppTextStyles.bodyMedium
          .copyWith(color: AppColorsDark.textMuted),
      errorStyle: AppTextStyles.bodyMedium
          .copyWith(color: Color(0xFFCF6679), fontSize: 12),
      prefixIconColor: AppColorsDark.textMuted,
      suffixIconColor: AppColorsDark.textMuted,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // ── Selection Controls ────────────────────────────────────────────

    // Checkbox
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsDark.accentGreen;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColorsDark.bg),
      side: const BorderSide(color: AppColorsDark.borderBright, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      overlayColor: WidgetStateProperty.all(
        AppColorsDark.accentGreen.withOpacity(0.08),
      ),
    ),

    // Radio
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsDark.accentGreen;
        }
        return AppColorsDark.borderBright;
      }),
      overlayColor: WidgetStateProperty.all(
        AppColorsDark.accentGreen.withOpacity(0.08),
      ),
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsDark.bg;
        }
        return AppColorsDark.textMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsDark.accentGreen;
        }
        return AppColorsDark.border;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      overlayColor: WidgetStateProperty.all(
        AppColorsDark.accentGreen.withOpacity(0.08),
      ),
    ),

    // Slider
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColorsDark.accentGreen,
      inactiveTrackColor: AppColorsDark.border,
      thumbColor: AppColorsDark.accentGreen,
      overlayColor: AppColorsDark.accentGreen.withOpacity(0.12),
      valueIndicatorColor: AppColorsDark.surfaceHighlight,
      valueIndicatorTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColorsDark.textPrimary,
      ),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
    ),

    // ── Lists & Tiles ─────────────────────────────────────────────────
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: AppColorsDark.primaryMuted,
      selectedColor: AppColorsDark.accentGreen,
      iconColor: AppColorsDark.textSecondary,
      textColor: AppColorsDark.textPrimary,
      titleTextStyle: AppTextStyles.headingMedium.copyWith(
        color: AppColorsDark.textPrimary,
      ),
      subtitleTextStyle: AppTextStyles.bodyMedium,
      leadingAndTrailingTextStyle: AppTextStyles.bodyMedium,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      minVerticalPadding: AppSpacing.sm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      dense: false,
    ),

    // ── Tabs ─────────────────────────────────────────────────────────
    tabBarTheme: TabBarThemeData(
      labelColor: AppColorsDark.accentGreen,
      unselectedLabelColor: AppColorsDark.textMuted,
      labelStyle: AppTextStyles.headingMedium,
      unselectedLabelStyle: AppTextStyles.headingMedium.copyWith(
        color: AppColorsDark.textMuted,
      ),
      indicatorColor: AppColorsDark.accentGreen,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: AppColorsDark.border,
      overlayColor: WidgetStateProperty.all(
        AppColorsDark.accentGreen.withOpacity(0.06),
      ),
      splashFactory: InkRipple.splashFactory,
    ),

    // ── Progress & Loading ────────────────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColorsDark.accentGreen,
      linearTrackColor: AppColorsDark.border,
      circularTrackColor: AppColorsDark.border,
      linearMinHeight: 4,
    ),

    // ── Tooltip ───────────────────────────────────────────────────────
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColorsDark.surfaceHighlight,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColorsDark.border),
      ),
      textStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColorsDark.textPrimary,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      waitDuration: const Duration(milliseconds: 600),
    ),

    // ── Popup Menu ────────────────────────────────────────────────────
    popupMenuTheme: PopupMenuThemeData(
      color: AppColorsDark.surfaceElevated,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColorsDark.border),
      ),
      textStyle: AppTextStyles.bodyLarge.copyWith(
        color: AppColorsDark.textPrimary,
      ),
      labelTextStyle: WidgetStateProperty.all(
        AppTextStyles.bodyLarge.copyWith(color: AppColorsDark.textPrimary),
      ),
      surfaceTintColor: Colors.transparent,
      position: PopupMenuPosition.under,
    ),

    // ── Divider ───────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColorsDark.border,
      thickness: 1,
      space: 1,
    ),

    // ── Chip ─────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: AppColorsDark.surfaceElevated,
      selectedColor: AppColorsDark.primaryMuted,
      disabledColor: AppColorsDark.border,
      deleteIconColor: AppColorsDark.textMuted,
      labelStyle: AppTextStyles.bodyMedium
          .copyWith(fontSize: 12, color: AppColorsDark.textSecondary),
      secondaryLabelStyle: AppTextStyles.bodyMedium.copyWith(
        fontSize: 12,
        color: AppColorsDark.accentGreen,
      ),
      side: const BorderSide(color: AppColorsDark.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      showCheckmark: true,
      checkmarkColor: AppColorsDark.accentGreen,
    ),

    // ── Search Bar ────────────────────────────────────────────────────
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(AppColorsDark.surfaceElevated),
      elevation: WidgetStateProperty.all(0),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return const BorderSide(
              color: AppColorsDark.accentGreen, width: 1.5);
        }
        return const BorderSide(color: AppColorsDark.border);
      }),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      textStyle: WidgetStateProperty.all(
        AppTextStyles.bodyLarge.copyWith(color: AppColorsDark.textPrimary),
      ),
      hintStyle: WidgetStateProperty.all(
        AppTextStyles.bodyLarge.copyWith(color: AppColorsDark.textMuted),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
    ),

    // ── Expansion Tile ────────────────────────────────────────────────
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      iconColor: AppColorsDark.textSecondary,
      collapsedIconColor: AppColorsDark.textMuted,
      textColor: AppColorsDark.accentGreen,
      collapsedTextColor: AppColorsDark.textPrimary,
      tilePadding:
      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      childrenPadding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      shape: const Border(),
      collapsedShape: const Border(),
    ),

    // ── Badge ─────────────────────────────────────────────────────────
    badgeTheme: BadgeThemeData(
      backgroundColor: AppColorsDark.accentOrange,
      textColor: Colors.white,
      textStyle: AppTextStyles.label.copyWith(
        color: Colors.white,
        fontSize: 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      smallSize: 8,
      largeSize: 18,
    ),

    // ── Date/Time Picker ──────────────────────────────────────────────
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColorsDark.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      headerBackgroundColor: AppColorsDark.primary,
      headerForegroundColor: Colors.white,
      dayOverlayColor: WidgetStateProperty.all(
        AppColorsDark.accentGreen.withOpacity(0.08),
      ),
      todayBorder: const BorderSide(color: AppColorsDark.accentGreen),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsDark.bg;
        }
        return AppColorsDark.textPrimary;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsDark.accentGreen;
        }
        return Colors.transparent;
      }),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsDark.bg;
        }
        return AppColorsDark.textPrimary;
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsDark.accentGreen;
        }
        return Colors.transparent;
      }),
      dividerColor: AppColorsDark.border,
      elevation: 0,
    ),
  );
}