import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:grown_health/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../api_config.dart';
import '../../services/exercise_bundle_service.dart';
import '../../providers/auth_provider.dart';
import 'day_detail_screen.dart';

class BundleDetailScreen extends ConsumerStatefulWidget {
  final String bundleId;

  const BundleDetailScreen({super.key, required this.bundleId});

  @override
  ConsumerState<BundleDetailScreen> createState() => _BundleDetailScreenState();
}

class _BundleDetailScreenState extends ConsumerState<BundleDetailScreen> {
  bool _loading = true;
  ExerciseBundle? _bundle;
  BundleProgress? _progress;
  int? _expandedDay;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = ref.read(authProvider).user?.token;
    if (token == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = ExerciseBundleService(token);

      // Load bundle and progress in parallel
      final results = await Future.wait([
        service.getBundleById(widget.bundleId),
        service.getBundleProgress(widget.bundleId),
      ]);

      if (mounted) {
        setState(() {
          _bundle = results[0] as ExerciseBundle;
          _progress = results[1] as BundleProgress;
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

  Future<void> _startDay(int day) async {
    final token = ref.read(authProvider).user?.token;
    if (token == null || _bundle == null) return;

    // Show loading dialog
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
      // First check if there's an active session
      final checkUri = Uri.parse(
        '${ApiConfig.baseUrl}/workout-progress/current',
      );
      final checkRes = await http.get(checkUri, headers: headers);

      if (checkRes.statusCode >= 200 && checkRes.statusCode < 300) {
        final checkData = jsonDecode(checkRes.body);
        final existingSession = checkData['data'];

        if (existingSession != null) {
          // There's already an active session - close loading and show dialog
          if (mounted) Navigator.of(context).pop();

          final sessionDay = existingSession['programDay'];

          // Ask user what to do
          final result = await showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.fitness_center, color: AppTheme.accentColor),
                  SizedBox(width: 8),
                  Text('Active Workout'),
                ],
              ),
              content: Text(
                'You have an unfinished workout${sessionDay != null ? " (Day $sessionDay)" : ""}.\n\nWhat would you like to do?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, 'continue'),
                  child: const Text('Continue Workout'),
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
            // Just go to player with existing session
            if (mounted) Navigator.of(context).pushNamed('/player');
            return;
          } else if (result == 'abandon') {
            // Abandon the session and start fresh
            final sessionId = existingSession['_id'];
            await http.post(
              Uri.parse(
                '${ApiConfig.baseUrl}/workout-progress/session/$sessionId/abandon',
              ),
              headers: headers,
            );
            // Recursive call to start new session
            if (mounted) _startDay(day);
            return;
          } else {
            // User cancelled
            return;
          }
        }
      }

      // No active session - start a new one
      final startUri = Uri.parse('${ApiConfig.baseUrl}/workout-progress/start');
      final startRes = await http.post(
        startUri,
        headers: headers,
        body: jsonEncode({'programId': _bundle!.id, 'day': day}),
      );

      if (mounted) Navigator.of(context).pop(); // Close loading dialog

      if (startRes.statusCode >= 200 && startRes.statusCode < 300) {
        // Success - go to player
        if (mounted) Navigator.of(context).pushNamed('/player');
      } else {
        // Check if error is about active session
        final errorData = jsonDecode(startRes.body);
        final errorMsg = errorData['message']?.toString().toLowerCase() ?? '';

        if (errorMsg.contains('active') || errorMsg.contains('already')) {
          // There's an active session - just go to player
          if (mounted) Navigator.of(context).pushNamed('/player');
        } else {
          // Other error
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
        Navigator.of(context).pop(); // Close loading dialog
        // If error mentions active session, just navigate to player
        if (e.toString().toLowerCase().contains('active')) {
          Navigator.of(context).pushNamed('/player');
        } else {
          SnackBarUtils.showError(
            context,
            'Error: ${e.toString().replaceAll('Exception: ', '')}',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.accentColor),
        ),
      );
    }

    if (_error != null || _bundle == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: AppTheme.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppTheme.white54,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load bundle',
                style: GoogleFonts.inter(color: AppTheme.white70, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final bundle = _bundle!;
    final progress = _progress!;
    final daysLeft = bundle.totalDays - progress.completedDays;

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Column(
        children: [
          // Hero Section (Dark background)
          _buildHeroSection(bundle, progress, daysLeft),

          // Days List (White background with rounded top)
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Motivation Card
                      _buildMotivationCard(bundle),
                      const SizedBox(height: 24),
                      // Days List
                      ...bundle.schedule.map(
                        (day) => _buildDayCard(day, progress),
                      ),
                      // Fill remaining days if schedule is incomplete
                      ..._buildRemainingDays(bundle, progress),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    ExerciseBundle bundle,
    BundleProgress progress,
    int daysLeft,
  ) {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with back button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.white,
                        size: 22,
                      ),
                    ),
                  ),
                  // Thumbnail moved to top-right
                  if (bundle.thumbnail.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        bundle.thumbnail,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppTheme.white10,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: AppTheme.white54,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Category badge
              if (bundle.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bundle.category!.name.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFB4C4),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              const SizedBox(height: 8),

              // Title
              Text(
                bundle.name.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.white,
                  letterSpacing: 0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),

              // Stats Row
              Row(
                children: [
                  _buildStatPill(Icons.bolt, bundle.difficultyDisplay),
                  const SizedBox(width: 8),
                  _buildStatPill(
                    Icons.calendar_today,
                    '${bundle.totalDays} Days',
                  ),
                  const SizedBox(width: 8),
                  _buildStatPill(
                    Icons.fitness_center,
                    '${bundle.totalExercises} Exercises',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Segmented Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Color(0xFFFF6B6B),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${progress.completedDays} of ${bundle.totalDays} days completed',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.white70,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${progress.progressPercentage}%',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildSegmentedProgressBar(bundle.totalDays, progress),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedProgressBar(int totalDays, BundleProgress progress) {
    // Show individual day segments (max 14 visible, then group)
    final visibleDays = totalDays > 14 ? 14 : totalDays;

    return Row(
      children: List.generate(visibleDays, (index) {
        final dayNum = index + 1;
        final isCompleted = progress.isDayCompleted(dayNum);
        final isCurrent = dayNum == progress.currentDay;

        return Expanded(
          child: Container(
            height: 8,
            margin: EdgeInsets.only(right: index < visibleDays - 1 ? 3 : 0),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppTheme.checkGreen
                  : isCurrent
                  ? AppTheme.accentColor
                  : AppTheme.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMotivationCard(ExerciseBundle bundle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Person Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: AppTheme.accentColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              bundle.description.isNotEmpty
                  ? bundle.description
                  : 'Start your fitness journey with this ${bundle.totalDays}-day program!',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(BundleDay day, BundleProgress progress) {
    final isCompleted = progress.isDayCompleted(day.day);
    final isExpanded = _expandedDay == day.day;
    final isLocked = day.day > progress.currentDay && !isCompleted;
    final isCurrentDay = day.day == progress.currentDay;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (day.isRestDay) return;
            // Navigate to day detail page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DayDetailScreen(
                  bundleId: widget.bundleId,
                  dayNumber: day.day,
                  bundleName: _bundle?.name ?? 'Workout',
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrentDay ? AppTheme.accentColor : AppTheme.grey200,
                width: isCurrentDay ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Day Number
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DAY',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.grey500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${day.day}',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Duration
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: AppTheme.grey600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                day.isRestDay ? 'Rest Day' : day.durationText,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Progress Indicators (Lightning bolts)
                          _buildProgressBolts(day, isCompleted),
                        ],
                      ),
                    ),

                    // Status Icon / Start Button
                    if (day.isRestDay)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.grey100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.self_improvement,
                          color: AppTheme.grey500,
                          size: 24,
                        ),
                      )
                    else if (isCompleted)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppTheme.checkGreen,
                          size: 24,
                        ),
                      )
                    else if (isLocked)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.grey100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          color: AppTheme.grey400,
                          size: 24,
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: CircularProgressIndicator(
                          value: 0,
                          strokeWidth: 3,
                          backgroundColor: AppTheme.grey200,
                          color: AppTheme.accentColor,
                        ),
                      ),
                  ],
                ),

                // Show Start button for current day
                if (isCurrentDay && !day.isRestDay && !isCompleted) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _startDay(day.day),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.infoColor,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Start',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Expanded exercise list
        if (isExpanded && !day.isRestDay)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.grey200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exercises',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 12),
                ...day.exercises.map((ex) => _buildExerciseItem(ex, day.day)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProgressBolts(BundleDay day, bool isCompleted) {
    // 3 bolts representing progress
    // All filled if completed, none if not started
    final boltCount = 3;
    final filledCount = isCompleted ? 3 : 0;

    return Row(
      children: List.generate(boltCount, (index) {
        final isFilled = index < filledCount;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            Icons.bolt,
            size: 18,
            color: isFilled ? AppTheme.accentColor : AppTheme.grey300,
          ),
        );
      }),
    );
  }

  Widget _buildExerciseItem(BundleDayExercise ex, int dayNumber) {
    final exercise = ex.exercise;
    if (exercise == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _startDay(dayNumber),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: AppTheme.black.withOpacity(0.03), blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            // Exercise Image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.highlightPink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: exercise.image.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        exercise.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.fitness_center,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.fitness_center,
                      color: AppTheme.accentColor,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.black,
                    ),
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
                            fontSize: 13,
                            color: AppTheme.grey600,
                          ),
                        ),
                      ],
                      if (ex.sets > 1 || ex.reps > 0) ...[
                        if (ex.duration > 0) const SizedBox(width: 12),
                        Text(
                          ex.reps > 0
                              ? '${ex.sets} × ${ex.reps} reps'
                              : '${ex.sets} sets',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.grey600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Play button indicator
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppTheme.accentColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: AppTheme.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRemainingDays(
    ExerciseBundle bundle,
    BundleProgress progress,
  ) {
    // If schedule doesn't have all days defined, create placeholders
    final existingDays = bundle.schedule.map((d) => d.day).toSet();
    final widgets = <Widget>[];

    for (int i = 1; i <= bundle.totalDays; i++) {
      if (!existingDays.contains(i)) {
        // Create placeholder day card for days not in schedule

        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.grey200),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAY',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.grey500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '$i',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'Coming soon...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.grey500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: AppTheme.grey400,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }
}
