import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/core.dart';

/// A card widget for displaying goal options in a grid layout.
/// Shows an icon and label with selection state styling.
class GoalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GoalCard({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animationDuration,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentColor : AppTheme.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusXLarge),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.accentColor.withValues(alpha: 0.3)
                  : AppTheme.grey300.withValues(alpha: 0.5),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.white.withValues(alpha: 0.2)
                    : AppTheme.grey50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? AppTheme.white : AppTheme.accentColor,
              ),
            ),
            const SizedBox(height: 12),
            // Label
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppTheme.white : AppTheme.black,
              ),
            ),
            // Checkmark for selected
            if (isSelected) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
