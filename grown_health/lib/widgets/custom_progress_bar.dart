import 'package:flutter/material.dart';
import '../core/core.dart';

/// A progress bar with back button, progress indicator, and skip option.
/// Designed for multi-step profile setup flows.
class CustomProgressBar extends StatelessWidget {
  final double value;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final bool showBack;
  final bool showSkip;

  const CustomProgressBar({
    super.key,
    required this.value,
    this.onBack,
    this.onSkip,
    this.showBack = true,
    this.showSkip = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        if (showBack)
          CircleAvatar(
            backgroundColor: AppTheme.accentColor,
            radius: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppTheme.white,
              ),
              onPressed: onBack,
              padding: EdgeInsets.zero,
            ),
          )
        else
          const SizedBox(width: 40),

        // Progress Bar
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusLarge,
              ),
              child: SizedBox(
                height: 8,
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppTheme.grey200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.accentColor,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Skip Text
        if (showSkip)
          GestureDetector(
            onTap: onSkip,
            child: Text(
              "Skip",
              style: TextStyle(
                color: AppTheme.grey500,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          const SizedBox(width: 40),
      ],
    );
  }
}
