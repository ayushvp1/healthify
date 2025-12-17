import 'package:flutter/material.dart';
import 'package:grown_health/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../api_config.dart';
import '../../providers/auth_provider.dart';
import '../../services/exercise_bundle_service.dart';

/// Day Detail Screen - Shows exercises for a specific day in a workout bundle.
/// Navigated to from BundleDetailScreen when user taps on a day.
class DayDetailScreen extends ConsumerStatefulWidget {
  final String bundleId;
  final int dayNumber;
  final String bundleName;

  const DayDetailScreen({
    super.key,
    required this.bundleId,
    required this.dayNumber,
    required this.bundleName,
  });

  @override
  ConsumerState<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends ConsumerState<DayDetailScreen> {
  bool _loading = true;
  String? _error;
  BundleDay? _day;
  BundleProgress? _progress;

  @override
  void initState() {
    super.initState();
    _loadDayData();
  }

  Future<void> _loadDayData() async {
    final token = ref.read(authProvider).user?.token;
    if (token == null) {
      setState(() {
        _error = 'Not authenticated';
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = ExerciseBundleService(token);
      final bundle = await service.getBundleById(widget.bundleId);
      final progress = await service.getBundleProgress(widget.bundleId);

      // Find the specific day
      final day = bundle.schedule.firstWhere(
        (d) => d.day == widget.dayNumber,
        orElse: () => BundleDay(
          day: widget.dayNumber,
          isRestDay: true,
          title: 'Rest Day',
          exercises: [],
        ),
      );

      if (mounted) {
        setState(() {
          _day = day;
          _progress = progress;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _startWorkout() async {
    final token = ref.read(authProvider).user?.token;
    if (token == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppTheme.accentColor),
      ),
    );

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      // Check for active session first
      final checkUri = Uri.parse(
        '${ApiConfig.baseUrl}/workout-progress/current',
      );
      final checkRes = await http.get(checkUri, headers: headers);

      if (checkRes.statusCode >= 200 && checkRes.statusCode < 300) {
        final checkData = jsonDecode(checkRes.body);
        final existingSession = checkData['data'];

        if (existingSession != null) {
          if (mounted) Navigator.of(context).pop();

          // Ask user
          final result = await showDialog<String>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.fitness_center, color: AppTheme.accentColor),
                  SizedBox(width: 8),
                  Text('Active Workout'),
                ],
              ),
              content: const Text(
                'You have an unfinished workout.\n\nWhat would you like to do?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, 'continue'),
                  child: const Text('Continue'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, 'abandon'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.warningColor,
                  ),
                  child: const Text('Start Fresh'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, 'cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.grey500,
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );

          if (result == 'continue') {
            if (mounted) Navigator.of(context).pushNamed('/player');
            return;
          } else if (result == 'abandon') {
            final sessionId = existingSession['_id'];
            await http.post(
              Uri.parse(
                '${ApiConfig.baseUrl}/workout-progress/session/$sessionId/abandon',
              ),
              headers: headers,
            );
            if (mounted) _startWorkout();
            return;
          } else {
            return;
          }
        }
      }

      // Start new session
      final startUri = Uri.parse('${ApiConfig.baseUrl}/workout-progress/start');
      final startRes = await http.post(
        startUri,
        headers: headers,
        body: jsonEncode({
          'programId': widget.bundleId,
          'day': widget.dayNumber,
        }),
      );

      if (mounted) Navigator.of(context).pop();

      if (startRes.statusCode >= 200 && startRes.statusCode < 300) {
        if (mounted) Navigator.of(context).pushNamed('/player');
      } else {
        final errorData = jsonDecode(startRes.body);
        final errorMsg = errorData['message']?.toString().toLowerCase() ?? '';

        if (errorMsg.contains('active') || errorMsg.contains('already')) {
          if (mounted) Navigator.of(context).pushNamed('/player');
        } else {
          if (mounted) {
            SnackBarUtils.showError(
              context,
              errorData['message'] ?? 'Failed to start workout',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        if (e.toString().toLowerCase().contains('active')) {
          Navigator.of(context).pushNamed('/player');
        } else {
          SnackBarUtils.showError(
            context,
            'Error: ${e.toString().replaceAll("Exception: ", "")}',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Day ${widget.dayNumber}',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentColor),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.grey500, size: 60),
            const SizedBox(height: 16),
            Text(_error!, style: GoogleFonts.inter(color: AppTheme.grey500)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadDayData, child: const Text('Retry')),
          ],
        ),
      );
    }

    final day = _day;
    if (day == null) {
      return const Center(child: Text('Day not found'));
    }

    if (day.isRestDay) {
      return _buildRestDayContent();
    }

    return _buildExerciseList(day);
  }

  Widget _buildRestDayContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.self_improvement,
              size: 60,
              color: AppTheme.infoColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Rest Day',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take time to recover and recharge',
            style: GoogleFonts.inter(fontSize: 16, color: AppTheme.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(BundleDay day) {
    final isCompleted = _progress?.isDayCompleted(day.day) ?? false;
    // Use canStartDay for date-based locking (one day per calendar day)
    final canStart = _progress?.canStartDay(day.day) ?? true;
    final isLocked = !isCompleted && !canStart;

    return Column(
      children: [
        // Header section
        Container(
          padding: const EdgeInsets.all(20),
          color: const Color(0xFF1A1A2E),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.bundleName.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.white70,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${day.exercises.length} Exercises',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
                    ),
                  ),
                  Text(
                    day.durationText,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Status indicator
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.checkGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.checkGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Completed',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.checkGreen,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        color: AppTheme.warningColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _progress?.getLockedMessage(day.day) ?? 'Locked',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.warningColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Exercise list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: day.exercises.length,
            itemBuilder: (context, index) {
              final ex = day.exercises[index];
              return _buildExerciseCard(ex, index + 1, isLocked);
            },
          ),
        ),

        // Start button - show disabled when locked
        if (!isCompleted)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLocked ? null : _startWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLocked
                        ? AppTheme.grey300
                        : AppTheme.infoColor,
                    foregroundColor: AppTheme.white,
                    disabledBackgroundColor: AppTheme.grey200,
                    disabledForegroundColor: AppTheme.grey500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isLocked) ...[
                        const Icon(Icons.lock_outline, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        isLocked ? 'Locked' : 'Start Workout',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExerciseCard(BundleDayExercise ex, int order, bool isLocked) {
    final exercise = ex.exercise;
    if (exercise == null) return const SizedBox.shrink();

    // Prefer GIF over image
    final imageUrl = exercise.gif.isNotEmpty ? exercise.gif : exercise.image;

    return GestureDetector(
      onTap: isLocked ? null : _startWorkout,
      child: Opacity(
        opacity: isLocked ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Order number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isLocked ? AppTheme.grey100 : AppTheme.highlightPink,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$order',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isLocked ? AppTheme.grey500 : AppTheme.accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Exercise image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isLocked ? AppTheme.grey100 : AppTheme.highlightPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.fitness_center,
                            color: isLocked
                                ? AppTheme.grey400
                                : AppTheme.accentColor,
                          ),
                        )
                      : Icon(
                          Icons.fitness_center,
                          color: isLocked
                              ? AppTheme.grey400
                              : AppTheme.accentColor,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Exercise details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isLocked ? AppTheme.grey500 : AppTheme.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (ex.duration > 0) ...[
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: AppTheme.grey600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${ex.duration}s',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.grey600,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (ex.reps > 0) ...[
                          Icon(Icons.repeat, size: 14, color: AppTheme.grey600),
                          const SizedBox(width: 4),
                          Text(
                            '${ex.sets}×${ex.reps}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.grey600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Play icon or Lock icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isLocked ? AppTheme.grey100 : AppTheme.lightBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLocked ? Icons.lock_outline : Icons.play_arrow_rounded,
                  color: isLocked ? AppTheme.grey400 : AppTheme.infoColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
