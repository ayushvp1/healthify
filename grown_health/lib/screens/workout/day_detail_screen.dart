import 'package:flutter/material.dart';
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
        child: CircularProgressIndicator(color: Color(0xFFAA3D50)),
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
                  Icon(Icons.fitness_center, color: Color(0xFFAA3D50)),
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
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                  child: const Text('Start Fresh'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, 'cancel'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  errorData['message'] ?? 'Failed to start workout',
                ),
                backgroundColor: Colors.red,
              ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${e.toString().replaceAll("Exception: ", "")}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Day ${widget.dayNumber}',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
        child: CircularProgressIndicator(color: Color(0xFFAA3D50)),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.grey, size: 60),
            const SizedBox(height: 16),
            Text(_error!, style: GoogleFonts.inter(color: Colors.grey)),
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
              color: const Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.self_improvement,
              size: 60,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Rest Day',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take time to recover and recharge',
            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(BundleDay day) {
    final isCompleted = _progress?.isDayCompleted(day.day) ?? false;
    final isCurrentDay = _progress?.currentDay == day.day;

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
                  color: Colors.white70,
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
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    day.durationText,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
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
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Completed',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4CAF50),
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
              return _buildExerciseCard(ex, index + 1);
            },
          ),
        ),

        // Start button
        if (!isCompleted &&
            (isCurrentDay ||
                _progress?.currentDay == null ||
                widget.dayNumber <= (_progress?.currentDay ?? 1)))
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _startWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Start Workout',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExerciseCard(BundleDayExercise ex, int order) {
    final exercise = ex.exercise;
    if (exercise == null) return const SizedBox.shrink();

    // Prefer GIF over image
    final imageUrl = exercise.gif.isNotEmpty ? exercise.gif : exercise.image;

    return GestureDetector(
      onTap: _startWorkout,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                color: const Color(0xFFFFF0F3),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '$order',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFAA3D50),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Exercise image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.fitness_center,
                          color: Color(0xFFAA3D50),
                        ),
                      )
                    : const Icon(
                        Icons.fitness_center,
                        color: Color(0xFFAA3D50),
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
                      color: Colors.black,
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
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${ex.duration}s',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (ex.reps > 0) ...[
                        Icon(
                          Icons.repeat,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${ex.sets}×${ex.reps}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Play icon
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFE3F2FD),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Color(0xFF2196F3),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
