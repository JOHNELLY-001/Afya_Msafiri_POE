import 'package:flutter/material.dart';
// Bundled Inter (see pubspec `fonts`). The google_fonts *package* is
// intentionally not used: d2_touch pins intl ^0.19.0 which conflicts with
// google_fonts v6, and runtime-fetched fonts break offline field use.
import 'design_tokens.dart';

/// AfyaMsafiri theme — implements `lib/manualguide.txt` (AfyaMsafiri guide)
/// while keeping the professional structure of the previous "Azure Horizon"
/// theme (full M3 ColorScheme, complete TextTheme, component themes).
///
/// Guide source of truth:
///  Primary Blue #3C92CD | Deep Slate #0F172A | Success #22C55E |
///  Urgent #EF4444 | Light Accent #F1F5F9 | Surface Gray #F2F2F2
class AppTheme {
  AppTheme._();

  static const String fontFamily = 'Inter';

  // ---------------------------------------------------------------------------
  // 1. Guide palette — single source in AppColors (design_tokens.dart).
  // Aliases kept here so existing `AppTheme.primary` call sites keep working.
  // ---------------------------------------------------------------------------
  static const Color primaryBlue = AppColors.primaryBlue;
  static const Color deepSlate = AppColors.deepSlate;
  static const Color successGreen = AppColors.successGreen;
  static const Color urgentRed = AppColors.urgentRed;
  static const Color lightAccent = AppColors.lightAccent;
  static const Color surfaceGray = AppColors.surfaceGray;

  static const Color primaryDark = AppColors.primaryDark;
  static const Color primarySoft = AppColors.primarySoft;
  static const Color onPrimaryBlue = AppColors.onPrimary;

  static const Color slateSoft = AppColors.slateSoft;
  static const Color mutedGray = AppColors.mutedGray;
  static const Color borderLight = AppColors.borderLight;
  static const Color borderMedium = AppColors.borderMedium;

  static const Color successBg = AppColors.successBg;
  static const Color successDark = AppColors.successDark;
  static const Color urgentBg = AppColors.urgentBg;
  static const Color urgentDark = AppColors.urgentDark;

  // ---------------------------------------------------------------------------
  // Backward-compatible aliases.
  // Existing code uses AppTheme.primary/secondary/etc. They now resolve to
  // guide values so nothing breaks, while new code should prefer the
  // guide-named constants above.
  // ---------------------------------------------------------------------------
  static const Color primary = primaryBlue;
  static const Color onPrimary = onPrimaryBlue;
  static const Color primaryContainer = primarySoft;
  static const Color onPrimaryContainer = deepSlate;

  static const Color secondary = deepSlate;
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = lightAccent;
  static const Color onSecondaryContainer = deepSlate;

  static const Color tertiary = slateSoft;
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = borderLight;
  static const Color onTertiaryContainer = deepSlate;

  static const Color error = urgentRed;
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = urgentBg;
  static const Color onErrorContainer = urgentDark;

  static const Color background = surfaceGray;
  static const Color onBackground = deepSlate;
  static const Color surface = surfaceGray;
  static const Color onSurface = deepSlate;
  static const Color surfaceVariant = lightAccent;
  static const Color onSurfaceVariant = slateSoft;

  static const Color outline = borderMedium;
  static const Color outlineVariant = borderLight;

  static const Color inverseSurface = deepSlate;
  static const Color onInverseSurface = Color(0xFFF8FAFC);
  static const Color inversePrimary = primarySoft;
  static const Color surfaceTint = primaryBlue;

  // ---------------------------------------------------------------------------
  // 3. Layout tokens (guide §3) + professional shadow.
  // ---------------------------------------------------------------------------
  static const double spacingMd = AppSpacing.lg; // guide 24
  static const double fontSizeBase = AppTypography.fontSizeBase;

  static const double radiusXl = AppRadius.xl; // form containers, bottom sheets
  static const double radiusLg = AppRadius.lg; // status / info cards
  static const double radiusPrimaryBtn = AppRadius.primaryBtn;
  static const double radiusSecondaryBtn = AppRadius.secondaryBtn;
  static const double radiusOutlineBtn = AppRadius.outlineBtn;
  static const double radiusInputMin = 12.0;
  static const double radiusInputMax = 16.0;
  static const double radiusInput = AppRadius.input;

  /// Guide shadow-card: Offset(0,4), blur 24, black 4%.
  static List<BoxShadow> get cardShadow => AppShadow.card;

  static BoxDecoration cardDecoration({
    Color color = Colors.white,
    double radius = radiusLg,
    bool withBorder = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: withBorder ? Border.all(color: outlineVariant) : null,
      boxShadow: cardShadow,
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Typography (guide §2) mapped onto M3 TextTheme.
  //  Guide: H1 24 Bold | Body 15 Regular | Input Label 13 SemiBold ls 0.65 |
  //  Caption 11 Regular. Extra M3 slots are filled with Inter companions so
  //  existing screens keep their hierarchy.
  // ---------------------------------------------------------------------------

  /// Guide "Input Label": Inter SemiBold 13, ls 0.65. Caller uppercases.
  static const TextStyle inputLabelStyle = AppTypography.inputLabel;

  /// Guide "Caption": Inter Regular 11.
  static const TextStyle captionStyle = AppTypography.caption;

  static const TextTheme textTheme = TextTheme(
    // Guide H1.
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 32 / 24,
      letterSpacing: -0.25,
      color: deepSlate,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 30 / 22,
      letterSpacing: -0.25,
      color: deepSlate,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 26 / 18,
      color: deepSlate,
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 24 / 17,
      color: deepSlate,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 22 / 15,
      color: deepSlate,
    ),
    // Guide Input Label slot.
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 18 / 13,
      letterSpacing: 0.65,
      color: deepSlate,
    ),
    // Guide Body (base 15).
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 24 / 15,
      color: deepSlate,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 21 / 14,
      color: slateSoft,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 17 / 12,
      color: slateSoft,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 20 / 14,
      color: deepSlate,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 16 / 12,
      color: slateSoft,
    ),
    // Guide Caption slot.
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w400,
      height: 15 / 11,
      color: mutedGray,
    ),
  );

  // ---------------------------------------------------------------------------
  // 4. Button styles per guide §4 (primary 18 / secondary 12 / outline 8).
  // ---------------------------------------------------------------------------
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPrimaryBtn),
        ),
      );

  static ButtonStyle get secondaryButtonStyle => FilledButton.styleFrom(
        backgroundColor: deepSlate,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSecondaryBtn),
        ),
      );

  static ButtonStyle get outlineButtonStyle => OutlinedButton.styleFrom(
        foregroundColor: primaryBlue,
        backgroundColor: Colors.white,
        side: const BorderSide(color: borderLight),
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusOutlineBtn),
        ),
      );

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryBlue,
      onPrimary: onPrimaryBlue,
      primaryContainer: primarySoft,
      onPrimaryContainer: deepSlate,
      secondary: deepSlate,
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: lightAccent,
      onSecondaryContainer: deepSlate,
      tertiary: slateSoft,
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: borderLight,
      onTertiaryContainer: deepSlate,
      error: urgentRed,
      onError: Color(0xFFFFFFFF),
      errorContainer: urgentBg,
      onErrorContainer: urgentDark,
      surface: surfaceGray,
      onSurface: deepSlate,
      surfaceContainerHighest: lightAccent,
      onSurfaceVariant: slateSoft,
      outline: borderMedium,
      outlineVariant: borderLight,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: deepSlate,
      onInverseSurface: Color(0xFFF8FAFC),
      inversePrimary: primarySoft,
      surfaceTint: primaryBlue,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceGray,
      fontFamily: fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: deepSlate,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 18),
        iconTheme: const IconThemeData(color: deepSlate),
      ),
      // Guide inputs: filled Light Accent, no harsh borders, 12–16 radius,
      // muted-gray prefix icons.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightAccent,
        prefixIconColor: mutedGray,
        suffixIconColor: mutedGray,
        hintStyle: textTheme.bodyLarge?.copyWith(color: mutedGray),
        labelStyle: inputLabelStyle.copyWith(color: slateSoft),
        floatingLabelStyle: inputLabelStyle.copyWith(color: primaryBlue),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: urgentRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: urgentRed, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
      filledButtonTheme: FilledButtonThemeData(style: secondaryButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: outlineButtonStyle),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Guide cards: radius-lg 20 + shadow-card. Keep a hairline border too
      // so cards stay crisp on the gray scaffold in bright outdoor light.
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: borderLight),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: successBg,
        labelStyle: textTheme.labelMedium?.copyWith(color: successDark),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
      ),
      // Guide bottom nav: active Primary Blue, inactive Muted Gray.
      // MainScaffold currently uses a standard M3 NavigationBar; this theme
      // makes it guide-compliant, and also styles BottomNavigationBar for a
      // future floating (20–28 radius) variant.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primaryBlue.withValues(alpha: 0.12),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? primaryBlue : mutedGray,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? primaryBlue : mutedGray,
          );
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        selectedItemColor: primaryBlue,
        unselectedItemColor: mutedGray,
        selectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      // Guide icons: outlined / rounded, muted gray by default; warnings use
      // Urgent Red at call sites (see StatusChip / FlowSteps).
      iconTheme: const IconThemeData(color: mutedGray, size: 22),
      primaryIconTheme: const IconThemeData(color: primaryBlue),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryBlue,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}
