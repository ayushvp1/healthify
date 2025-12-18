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
            if (mounted) {
              Navigator.of(context).pushNamed('/player').then((_) {
                if (mounted) _loadData();
              });
            }
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
        if (mounted) {
          Navigator.of(context).pushNamed('/player').then((_) {
            if (mounted) _loadData();
          });
        }
      } else {
        // Check if error is about active session
        final errorData = jsonDecode(startRes.body);
        final errorMsg = errorData['message']?.toString().toLowerCase() ?? '';

        if (errorMsg.contains('active') || errorMsg.contains('already')) {
          // There's an active session - just go to player
          if (mounted) {
            Navigator.of(context).pushNamed('/player').then((_) {
              if (mounted) _loadData();
            });
          }
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
          Navigator.of(context).pushNamed('/player').then((_) {
            if (mounted) _loadData();
          });
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
        backgroundColor: AppTheme.primaryColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.white),
        ),
      );
    }

    if (_error != null || _bundle == null) {
      return Scaffold(
        backgroundColor: AppTheme.primaryColor,
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

    final bool hasStarted =
        progress.completedDays > 0 || progress.currentDay > 1;

    // Check if user can start the current day
    final int nextDay = progress.currentDay;
    final bool canStartNextDay = progress.canStartDay(nextDay);
    final bool allDaysComplete = progress.completedDays >= bundle.totalDays;

    // Button text and state
    String buttonText;
    bool isButtonEnabled;
    IconData buttonIcon;

    if (allDaysComplete) {
      buttonText = 'Program Complete! 🎉';
      isButtonEnabled = false;
      buttonIcon = Icons.check_circle;
    } else if (!canStartNextDay) {
      buttonText = progress.getLockedMessage(nextDay);
      isButtonEnabled = false;
      buttonIcon = Icons.lock_clock;
    } else if (hasStarted) {
      buttonText = 'Continue Program';
      isButtonEnabled = true;
      buttonIcon = Icons.play_arrow_rounded;
    } else {
      buttonText = 'Start Program';
      isButtonEnabled = true;
      buttonIcon = Icons.fitness_center;
    }

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Column(
        children: [
          // Hero Section (Maroon gradient background)
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
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // Floating Start Button at bottom
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isButtonEnabled ? () => _startDay(nextDay) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isButtonEnabled
                    ? AppTheme.primaryColor
                    : AppTheme.grey300,
                foregroundColor: AppTheme.white,
                disabledBackgroundColor: AppTheme.grey200,
                disabledForegroundColor: AppTheme.grey500,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(buttonIcon, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    buttonText,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(
    ExerciseBundle bundle,
    BundleProgress progress,
    int daysLeft,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
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
        color: AppTheme.highlightPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.highlightPink.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.highlightPink.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sparkle/Motivation Icon
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppTheme.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Journey',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bundle.description.isNotEmpty
                      ? bundle.description
                      : 'Transform your body with this professional ${bundle.totalDays}-day program!',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black87,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(BundleDay day, BundleProgress progress) {
    final isCompleted = progress.isDayCompleted(day.day);
    final isExpanded = _expandedDay == day.day;
    final canStart = progress.canStartDay(day.day);
    final isLocked = !isCompleted && !canStart;
    final isCurrentDay = !isCompleted && canStart;

    // Design attributes based on status
    Color bgColor;
    Color accentColor;
    Color? borderColor;
    double elevation = 0;

    if (isCompleted) {
      bgColor = const Color(0xFFF1F8E9); // Light green
      accentColor = AppTheme.checkGreen;
      borderColor = AppTheme.checkGreen.withOpacity(0.2);
    } else if (isCurrentDay) {
      bgColor = AppTheme.white;
      accentColor = AppTheme.accentColor;
      borderColor = AppTheme.accentColor;
      elevation = 4;
    } else if (day.isRestDay) {
      bgColor = const Color(0xFFE1F5FE); // Light blue
      accentColor = const Color(0xFF039BE5);
      borderColor = const Color(0xFF039BE5).withOpacity(0.2);
    } else if (isLocked) {
      bgColor = AppTheme.grey50;
      accentColor = AppTheme.grey400;
      borderColor = AppTheme.grey200;
    } else {
      bgColor = AppTheme.white;
      accentColor = AppTheme.accentColor;
      borderColor = AppTheme.grey200;
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (day.isRestDay) return;
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
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: borderColor ?? AppTheme.transparent,
                width: isCurrentDay ? 2 : 1,
              ),
              boxShadow: elevation > 0
                  ? [
                      BoxShadow(
                        color: accentColor.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Day Number Indicator
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isLocked
                          ? [AppTheme.grey300, AppTheme.grey400]
                          : [accentColor.withOpacity(0.8), accentColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: !isLocked
                        ? [
                            BoxShadow(
                              color: accentColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'DAY',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.white.withOpacity(0.8),
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        '${day.day}',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.isRestDay
                            ? 'Rest & Recover'
                            : (day.title.isNotEmpty
                                  ? day.title
                                  : 'Workout Session'),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isLocked ? AppTheme.grey600 : AppTheme.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            day.isRestDay
                                ? Icons.self_improvement
                                : Icons.access_time_rounded,
                            size: 14,
                            color: isLocked
                                ? AppTheme.grey400
                                : AppTheme.grey600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            day.isRestDay ? 'Rest Day' : day.durationText,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isLocked
                                  ? AppTheme.grey400
                                  : AppTheme.grey600,
                            ),
                          ),
                          if (!day.isRestDay) ...[
                            const SizedBox(width: 12),
                            _buildSmallBoltIndicator(
                              day,
                              isCompleted,
                              isLocked,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Action Area
                _buildStatusAction(day, isCompleted, isLocked, canStart),
              ],
            ),
          ),
        ),

        // Expanded exercise list (if needed in future, currently navigated)
        if (isExpanded && !day.isRestDay) _buildExpandedExercises(day),
      ],
    );
  }

  Widget _buildSmallBoltIndicator(
    BundleDay day,
    bool isCompleted,
    bool isLocked,
  ) {
    return Row(
      children: List.generate(3, (index) {
        return Icon(
          Icons.bolt,
          size: 14,
          color: isCompleted
              ? AppTheme.accentColor
              : (isLocked ? AppTheme.grey300 : AppTheme.grey200),
        );
      }),
    );
  }

  Widget _buildStatusAction(
    BundleDay day,
    bool isCompleted,
    bool isLocked,
    bool canStart,
  ) {
    if (day.isRestDay) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF039BE5).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.spa_rounded,
          color: Color(0xFF039BE5),
          size: 20,
        ),
      );
    }

    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppTheme.checkGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: AppTheme.white, size: 18),
      );
    }

    if (isLocked) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.grey200,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.lock_rounded, color: AppTheme.grey500, size: 18),
      );
    }

    // Current Day - Show Start Button
    return ElevatedButton(
      onPressed: () => _startDay(day.day),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentColor,
        foregroundColor: AppTheme.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'Start',
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildExpandedExercises(BundleDay day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exercises',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 12),
          ...day.exercises.map((ex) => _buildExerciseItem(ex, day.day)),
        ],
      ),
    );
  }

  Widget _buildProgressBolts(BundleDay day, bool isCompleted) {
    // Keep this for backward compatibility if used elsewhere,
    // but we use _buildSmallBoltIndicator inside the card now
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Exercise Image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.highlightPink.withOpacity(0.2),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (ex.duration > 0) ...[
                        const Icon(
                          Icons.timer_outlined,
                          size: 12,
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
                      ],
                      if (ex.sets > 1 || ex.reps > 0) ...[
                        if (ex.duration > 0) const SizedBox(width: 8),
                        Text(
                          ex.reps > 0
                              ? '${ex.sets}×${ex.reps}'
                              : '${ex.sets} sets',
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
            // Minimal Play Icon
            const Icon(
              Icons.play_circle_fill_rounded,
              color: AppTheme.accentColor,
              size: 28,
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
    final existingDays = bundle.schedule.map((d) => d.day).toSet();
    final widgets = <Widget>[];

    for (int i = 1; i <= bundle.totalDays; i++) {
      if (!existingDays.contains(i)) {
        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.grey50,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.grey200),
            ),
            child: Row(
              children: [
                // Day Number Indicator (Greyed out)
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppTheme.grey200,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'DAY',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.grey500,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        '$i',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Next session unlocking soon',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.grey500,
                    ),
                  ),
                ),
                Icon(
                  Icons.lock_clock_rounded,
                  color: AppTheme.grey400,
                  size: 20,
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
