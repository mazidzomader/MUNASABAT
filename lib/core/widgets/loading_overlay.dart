import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Displays a semi-transparent dark overlay with a centered white spinner.
///
/// Wrap around the screen body to block interaction during async operations.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          const ColoredBox(
            color: Color(0x55000000),
            child: SizedBox.expand(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.surface,
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
