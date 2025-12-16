import 'package:flutter/material.dart';
import '../core/core.dart';

/// A reusable loading spinner widget.
/// Uses the app's accent color for consistent styling.
class LoadingWidget extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.size = 40,
    this.strokeWidth = 3,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppTheme.accentColor,
        ),
      ),
    );
  }
}
