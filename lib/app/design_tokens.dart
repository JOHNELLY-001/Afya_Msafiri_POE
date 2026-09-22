import 'package:flutter/material.dart';

/// Single source of truth for the AfyaMsafiri design system.
/// Implements `lib/manualguide.txt` exactly; `app/theme.dart` maps these
/// tokens into a Material [ColorScheme]/[TextTheme]/component themes.
class AppColors {
  AppColors._();

  // Brand primary. Do not change without a design decision.
  static const primaryBlue = Color(0xFF3C92CD);
  static const deepSlate = Color(0xFF0F172A);
  static const successGreen = Color(0xFF22C55E);
  static const urgentRed = Color(0xFFEF4444);
  static const lightAccent = Color(0xFFF1F5F9);
  static const surfaceGray = Color(0xFFF2F2F2);

  // Professional derivations (states, containers, borders). Tonal companions
  // of the six guide colors so M3 stays legible, incl. outdoor use.
  static const primaryDark = Color(0xFF3178A8);
  static const primarySoft = Color(0xFFE8F2F9);
  static const onPrimary = Color(0xFFFFFFFF);

  static const slateSoft = Color(0xFF334155);
  static const mutedGray = Color(0xFF64748B);
  static const borderLight = Color(0xFFE2E8F0);
  static const borderMedium = Color(0xFFCBD5E1);

  static const successBg = Color(0xFFDCFCE7);
  static const successDark = Color(0xFF15803D);
  static const urgentBg = Color(0xFFFEE2E2);
  static const urgentDark = Color(0xFFB91C1C);
  static const infoBg = Color(0xFFE8F2F9);

  // Warning/amber is NOT in the guide but is required professionally for the
  // 3-level risk model (low/elevated/high). Amber-600 keeps elevated distinct
  // from urgent red while staying sunlight-legible.
  static const warningAmber = Color(0xFFD97706);
  static const warningBg = Color(0xFFFEF3C7);
  static const warningDark = Color(0xFF92400E);
}

class AppSpacing {
  AppSpacing._();
  static const double base = 8;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24; // guide spacing-md: global container padding
  static const double xl = 32;
  static const double gutter = 16;
  static const double margin = 24;
}

class AppRadius {
  AppRadius._();
  static const double sm = 8; // guide outline buttons
  static const double base = 12; // guide secondary buttons
  static const double md = 16;
  static const double lg = 20; // guide status / info cards
  static const double xl = 28; // guide form containers / bottom sheets
  static const double full = 9999; // guide status badges (pill)

  // Guide §3 button radii (aliases for readability at call sites).
  static const double primaryBtn = 18;
  static const double secondaryBtn = 12;
  static const double outlineBtn = 8;

  // Guide inputs: 12–16 range; 14 is the canonical midpoint.
  static const double input = 14;
}

/// Guide §3 shadow-card: Offset(0,4), blur 24, black 4%.
class AppShadow {
  AppShadow._();
  static List<BoxShadow> get card => [
        BoxShadow(
          offset: const Offset(0, 4),
          blurRadius: 24,
          color: Colors.black.withValues(alpha: 0.04),
        ),
      ];
}

/// Guide §2 typography helpers. The full M3 TextTheme lives in
/// `AppTheme.textTheme`; these are the four named guide styles.
class AppTypography {
  AppTypography._();
  static const double fontSizeBase = 15;

  /// Heading 1: Inter Bold 24.
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.25,
    color: AppColors.deepSlate,
  );

  /// Body: Inter Regular 15 (base font size).
  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 24 / 15,
    color: AppColors.deepSlate,
  );

  /// Input Label: Inter SemiBold 13, ls 0.65. Caller uppercases.
  static const TextStyle inputLabel = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.65,
    color: AppColors.deepSlate,
  );

  /// Caption: Inter Regular 11.
  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 15 / 11,
    color: AppColors.mutedGray,
  );
}

/// Semantic status colors (risk + sync states). Guide §4 badges:
/// confirmed = light-green bg + Success Green text (pill);
/// urgent = light-red bg + Urgent Red text (pill).
/// Warning amber + info blue are professional extensions for the
/// elevated-risk and informational states; they follow the same pill pattern.
class AppStatus {
  AppStatus._();
  static const success = AppColors.successGreen;
  static const successBg = AppColors.successBg;
  static const warning = AppColors.warningAmber;
  static const warningBg = AppColors.warningBg;
  static const danger = AppColors.urgentRed;
  static const dangerBg = AppColors.urgentBg;
  static const info = AppColors.primaryBlue;
  static const infoBg = AppColors.infoBg;

  /// Dark (on-light) text companions for sunlight legibility.
  static const successText = AppColors.successDark;
  static const warningText = AppColors.warningDark;
  static const dangerText = AppColors.urgentDark;
  static const infoText = AppColors.primaryDark;
}
