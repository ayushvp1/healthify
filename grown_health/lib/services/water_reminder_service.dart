import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import '../services/water_service.dart';

/// Simple water reminder service that checks if user needs to drink water
/// and shows in-app notifications
class WaterReminderService {
  Timer? _timer;
  final WaterService _waterService;
  final BuildContext? _context;

  WaterReminderService(this._waterService, [this._context]);

  /// Start checking water intake every hour
  void startReminders() {
    // Check immediately
    _checkWaterIntake();

    // Then check every hour
    _timer = Timer.periodic(const Duration(hours: 1), (timer) {
      _checkWaterIntake();
    });
  }

  /// Stop the reminders
  void stopReminders() {
    _timer?.cancel();
    _timer = null;
  }

  /// Check if user needs to drink water and show reminder
  Future<void> _checkWaterIntake() async {
    try {
      final today = await _waterService.getTodayWaterIntake();

      // If goal is not met and it's during waking hours (8 AM - 10 PM)
      final hour = DateTime.now().hour;
      if (!today.isCompleted && hour >= 8 && hour <= 22) {
        _showWaterReminder(today.remaining);
      }
    } catch (e) {
      // Silently fail - don't bother user with errors
      // This includes "Invalid token" errors when user is not logged in
      debugPrint('Water reminder check failed: $e');
    }
  }

  /// Show in-app reminder to drink water
  void _showWaterReminder(int remainingGlasses) {
    if (_context == null || !_context.mounted) return;

    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.local_drink, color: AppTheme.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '💧 Time to hydrate! You have $remainingGlasses glasses left to reach your goal.',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.accentColor,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: AppTheme.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Dispose the service
  void dispose() {
    stopReminders();
  }
}

/// Provider-friendly water reminder manager
class WaterReminderManager {
  static WaterReminderService? _instance;

  static void start(WaterService waterService, BuildContext context) {
    _instance?.dispose();
    _instance = WaterReminderService(waterService, context);
    _instance!.startReminders();
  }

  static void stop() {
    _instance?.dispose();
    _instance = null;
  }
}
