import 'package:flutter/material.dart';
import 'app_colors.dart';

/// All typography token definitions for Munasabat per Design.md.
///
/// Headings use Playfair Display (serif, elegant — wedding-facing screens).
/// Body/UI uses Poppins (clean sans-serif — forms, lists, buttons).
///
/// Never reference font families as raw strings in widget files;
/// always use AppTextStyles.* or Theme.of(context).textTheme.*.
abstract class AppTextStyles {
  // ── Font family constants ──────────────────────────────────────────────────
  static const String _playfair = 'PlayfairDisplay';
  static const String _poppins = 'Poppins';

  // ── Heading styles (Playfair Display) ─────────────────────────────────────

  /// Invitation title, event hero title — 32 / Bold 700.
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _playfair,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.2,
  );

  /// Section headers ("Your Wedding", "Memories") — 24 / SemiBold 600.
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _playfair,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    height: 1.3,
  );

  // ── UI styles (Poppins) ────────────────────────────────────────────────────

  /// Screen titles (Guests, Profile) — 20 / SemiBold 600.
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _poppins,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  /// Card titles, list item titles — 16 / SemiBold 600.
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _poppins,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  /// Primary body text — 16 / Regular 400.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _poppins,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
  );

  /// Secondary body text, descriptions — 14 / Regular 400.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _poppins,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.charcoal,
  );

  /// Badges, status chips, captions — 12 / Medium 500.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _poppins,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.charcoal,
  );

  /// Link / action text — 14 / SemiBold 600 in accentBlue.
  static const TextStyle link = TextStyle(
    fontFamily: _poppins,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.accentBlue,
  );

  /// Hint / placeholder text — 14 / Regular 400 in stone.
  static const TextStyle hint = TextStyle(
    fontFamily: _poppins,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.stone,
  );

  /// Button label — 16 / SemiBold 600.
  static const TextStyle button = TextStyle(
    fontFamily: _poppins,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
