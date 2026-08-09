import 'package:flutter/material.dart';

/// All brand color tokens for Munasabat.
/// Sampled directly from the Munasabat hero banner per Design.md.
/// Never hardcode hex values in widget files — always use AppColors.*.
abstract class AppColors {
  // ── Primary / Brand ────────────────────────────────────────────────────────
  /// Wordmark color, primary headings, primary button fill, primary text-on-light.
  static const Color brandInk = Color(0xFF371E08);

  /// Pressed/hover state for brandInk, secondary emphasis text.
  static const Color brandInkLight = Color(0xFF6B4A2E);

  /// Left-side brand accent — links, info highlights, icons, secondary buttons.
  static const Color accentBlue = Color(0xFF7BAAFA);

  /// Soft blue tint — chip fills, card backgrounds, hover states, decorative wash.
  static const Color accentBlueSoft = Color(0xFFA4E6F6);

  /// Right-side brand accent — celebratory highlights, secondary CTAs, badges.
  static const Color accentPink = Color(0xFFF99CEC);

  /// Soft pink/orchid tint — chip fills, card backgrounds, hover states.
  static const Color accentPinkSoft = Color(0xFFEAC0FF);

  // ── Neutrals ───────────────────────────────────────────────────────────────
  /// Primary body text.
  static const Color ink = Color(0xFF2E2318);

  /// Secondary text.
  static const Color charcoal = Color(0xFF5C5248);

  /// Tertiary text, placeholders, disabled.
  static const Color stone = Color(0xFF9B9188);

  /// App background — warm off-white, matches banner's white field.
  static const Color cream = Color(0xFFFBF9F6);

  /// Cards, sheets, elevated surfaces.
  static const Color surface = Color(0xFFFFFFFF);

  /// Borders, dividers.
  static const Color divider = Color(0xFFEFEAE3);

  // ── Status ─────────────────────────────────────────────────────────────────
  /// "Pending" invitation status.
  static const Color statusPending = Color(0xFFB8860B);

  /// "Accepted" / success states.
  static const Color statusAccepted = Color(0xFF2E7D4F);

  /// "Declined" / error states.
  static const Color statusDeclined = Color(0xFFB23A3A);

  /// "Checked In" status.
  static const Color statusCheckedIn = Color(0xFF2E5E8C);

  // ── Hero / Decorative Gradient Stops ───────────────────────────────────────
  /// Top-left / left-edge watercolor bloom — stop 1.
  static const Color gradientBlue1 = Color(0xFF9BA7FD);

  /// Top-left / left-edge watercolor bloom — stop 2.
  static const Color gradientBlue2 = Color(0xFF7BAAFA);

  /// Top-left / left-edge watercolor bloom — stop 3.
  static const Color gradientBlue3 = Color(0xFFA4E6F6);

  /// Top-right / right-edge watercolor bloom — stop 1.
  static const Color gradientPink1 = Color(0xFFF99CEC);

  /// Top-right / right-edge watercolor bloom — stop 2.
  static const Color gradientPink2 = Color(0xFFEAC0FF);

  /// Top-right / right-edge watercolor bloom — stop 3.
  static const Color gradientPink3 = Color(0xFFFCD2F6);
}
