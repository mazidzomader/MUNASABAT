import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Gradient constants for hero, empty-state, and decorative surfaces.
///
/// Usage rule per Design.md: keep the **center 60–70% of any hero surface
/// neutral** (cream/surface) and let the two washes bloom from outer corners
/// only, fading to transparent. Never use behind body text or form fields.
abstract class AppGradients {
  /// Top-left / left-edge watercolor bloom. Use with [Alignment.topLeft].
  static const LinearGradient heroBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.gradientBlue1,
      AppColors.gradientBlue2,
      AppColors.gradientBlue3,
      Color(0x00A4E6F6), // transparent
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  /// Top-right / right-edge watercolor bloom. Use with [Alignment.topRight].
  static const LinearGradient heroPink = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.centerLeft,
    colors: [
      AppColors.gradientPink1,
      AppColors.gradientPink2,
      AppColors.gradientPink3,
      Color(0x00FCD2F6), // transparent
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  /// Combined blue+pink corner wash for hero/splash backgrounds.
  /// Compose both [heroBlue] and [heroPink] on separate stacked Containers.
  static BoxDecoration heroBackground({Color base = AppColors.cream}) {
    return BoxDecoration(
      color: base,
    );
  }
}
