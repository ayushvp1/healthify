import 'package:flutter/material.dart';
import '../core/core.dart';

/// Button types matching the Healthify design system
enum ButtonType { primary, secondary, outline, text, elevated }

/// Custom button with multiple style variants.
/// Supports primary, secondary, outline, text, and elevated styles.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final bool? isIconRight;
  final double? iconSize;
  final double? fontSize;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.isIconRight,
    this.iconSize,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == ButtonType.primary
                    ? AppTheme.white
                    : AppTheme.accentColor,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null && isIconRight != true) ...[
                Icon(icon, size: iconSize ?? AppConstants.iconSizeSmall),
                const SizedBox(width: AppConstants.paddingXSmall),
              ],
              Text(
                text,
                style: TextStyle(
                  color: textColor ?? _getDefaultTextColor(),
                  fontSize: fontSize ?? AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isIconRight == true && icon != null) ...[
                const SizedBox(width: AppConstants.paddingXSmall),
                Icon(icon, size: iconSize ?? AppConstants.iconSizeSmall),
              ],
            ],
          );

    Widget button;

    switch (type) {
      case ButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppTheme.accentColor,
            foregroundColor: textColor ?? AppTheme.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
            ),
          ),
          child: buttonChild,
        );
        break;
      case ButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppTheme.grey100,
            foregroundColor: textColor ?? AppTheme.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
            ),
          ),
          child: buttonChild,
        );
        break;
      case ButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? AppTheme.accentColor,
            side: BorderSide(color: backgroundColor ?? AppTheme.accentColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
            ),
          ),
          child: buttonChild,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? AppTheme.accentColor,
            textStyle: TextStyle(
              fontSize: fontSize ?? AppConstants.fontSizeSmall,
            ),
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          child: buttonChild,
        );
        break;
      case ButtonType.elevated:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppTheme.white,
            foregroundColor: textColor ?? AppTheme.grey800,
            elevation: 4,
            shadowColor: AppTheme.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
            ),
          ),
          child: buttonChild,
        );
        break;
    }

    if (isFullWidth) {
      button = SizedBox(
        width: double.infinity,
        height: height ?? 48,
        child: button,
      );
    } else if (width != null || height != null) {
      button = SizedBox(width: width, height: height ?? 48, child: button);
    }

    return button;
  }

  Color _getDefaultTextColor() {
    switch (type) {
      case ButtonType.primary:
        return AppTheme.white;
      case ButtonType.secondary:
        return AppTheme.black;
      case ButtonType.outline:
      case ButtonType.text:
        return AppTheme.accentColor;
      case ButtonType.elevated:
        return AppTheme.grey800;
    }
  }
}
