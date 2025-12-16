import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// Snackbar type enum for consistent styling
enum SnackBarType { info, success, warning, error }

/// Global utility class for showing consistent snackbar messages throughout the app.
/// Usage: SnackBarUtils.show(context, 'Your message here');
class SnackBarUtils {
  SnackBarUtils._(); // Private constructor to prevent instantiation

  /// Shows a styled snackbar with consistent theming
  ///
  /// [context] - BuildContext for showing the snackbar
  /// [message] - The message to display
  /// [type] - Type of snackbar (info, success, warning, error)
  /// [duration] - How long to show the snackbar (default: 3 seconds)
  /// [action] - Optional action button
  /// [showIcon] - Whether to show a leading icon (default: true)
  static void show(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    bool showIcon = true,
  }) {
    // Dismiss any existing snackbar first
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (showIcon) ...[
              Icon(_getIcon(type), color: AppTheme.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _getBackgroundColor(type),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: duration,
        action: action,
      ),
    );
  }

  /// Shows an info snackbar (default grey styling)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    show(
      context,
      message,
      type: SnackBarType.info,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Shows a success snackbar (green styling)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    show(
      context,
      message,
      type: SnackBarType.success,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Shows a warning snackbar (amber/orange styling)
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    show(
      context,
      message,
      type: SnackBarType.warning,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Shows an error snackbar (red styling)
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    show(
      context,
      message,
      type: SnackBarType.error,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  /// Shows a simple snackbar with just text (minimal styling)
  static void showSimple(BuildContext context, String message) {
    show(context, message, showIcon: false);
  }

  /// Hides the current snackbar
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Gets the background color based on the snackbar type
  static Color _getBackgroundColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return AppTheme.successColor;
      case SnackBarType.warning:
        return AppTheme.warningColor;
      case SnackBarType.error:
        return AppTheme.errorColor;
      case SnackBarType.info:
      default:
        return AppTheme.grey800;
    }
  }

  /// Gets the icon based on the snackbar type
  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_outline;
      case SnackBarType.warning:
        return Icons.warning_amber_outlined;
      case SnackBarType.error:
        return Icons.error_outline;
      case SnackBarType.info:
      default:
        return Icons.info_outline;
    }
  }
}
