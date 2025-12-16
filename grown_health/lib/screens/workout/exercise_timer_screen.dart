import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../api_config.dart';
import '../../providers/auth_provider.dart';

/// Simple Exercise Timer Screen - For standalone exercise playback
/// Receives exercise data as arguments via Navigator
class ExerciseTimerScreen extends ConsumerStatefulWidget {
  const ExerciseTimerScreen({super.key});

  @override
  ConsumerState<ExerciseTimerScreen> createState() =>
      _ExerciseTimerScreenState();
}

class _ExerciseTimerScreenState extends ConsumerState<ExerciseTimerScreen> {
  Timer? _timer;
  int _remainingSeconds = 30;
  int _totalDuration = 30;
  bool _isPaused = false;
  bool _isComplete = false;
  bool _isSaving = false;
  Map<String, dynamic>? _exercise;
  DateTime? _startTime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_exercise == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _exercise =
          args ?? {'title': 'Exercise', 'duration': 30, 'image': '', 'gif': ''};
      _totalDuration = _exercise!['duration'] ?? 30;
      if (_totalDuration <= 0) _totalDuration = 30;
      _remainingSeconds = _totalDuration;
      _startTime = DateTime.now();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isComplete = true;
        });
        _showCompletionDialog();
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  Future<void> _logExerciseToHistory() async {
    if (_isSaving) return;

    final token = ref.read(authProvider).user?.token;
    if (token == null) {
      debugPrint('No auth token available');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final actualDuration = _startTime != null
          ? DateTime.now().difference(_startTime!).inSeconds
          : _totalDuration;

      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/workout-progress/log-exercise'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'exerciseId': _exercise?['_id'],
          'exerciseTitle': _exercise?['title'] ?? 'Exercise',
          'duration': actualDuration,
          'reps': _exercise?['reps'] ?? 0,
          'sets': _exercise?['sets'] ?? 1,
        }),
      );

      if (res.statusCode == 201) {
        debugPrint('Exercise logged successfully');
      } else {
        debugPrint('Failed to log exercise: ${res.body}');
      }
    } catch (e) {
      debugPrint('Error logging exercise: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.celebration, color: AppTheme.darkGreen, size: 28),
            const SizedBox(width: 10),
            Text(
              'Great Job! 🎉',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'You completed ${_exercise!['title'] ?? 'the exercise'}!',
          style: GoogleFonts.inter(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving
                ? null
                : () async {
                    // Log the exercise and close
                    await _logExerciseToHistory();
                    if (mounted) {
                      Navigator.pop(ctx);
                      Navigator.pop(
                        context,
                        true,
                      ); // Return true to indicate completion
                    }
                  },
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Done',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
          ),
          ElevatedButton(
            onPressed: _isSaving
                ? null
                : () {
                    Navigator.pop(ctx);
                    setState(() {
                      _remainingSeconds = _totalDuration;
                      _isComplete = false;
                      _isPaused = false;
                      _startTime = DateTime.now();
                    });
                    _startTimer();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Repeat',
              style: GoogleFonts.inter(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _formattedTime {
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_exercise == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final title = _exercise!['title'] ?? 'Exercise';
    final gifUrl = _exercise!['gif'] ?? '';
    final imageUrl = _exercise!['image'] ?? '';
    final visualUrl = gifUrl.isNotEmpty ? gifUrl : imageUrl;

    final progress = _totalDuration > 0
        ? 1 - (_remainingSeconds / _totalDuration)
        : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.grey100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.black),
                      onPressed: () => _confirmExit(),
                    ),
                  ),
                  Text(
                    'Exercise Timer',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance
                ],
              ),
            ),

            const Spacer(),

            // Exercise Visual
            SizedBox(
              height: 200,
              width: 200,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.highlightPink,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: visualUrl.isNotEmpty
                      ? Image.network(
                          visualUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.fitness_center,
                            size: 80,
                            color: AppTheme.accentColor,
                          ),
                        )
                      : const Icon(
                          Icons.fitness_center,
                          size: 80,
                          color: AppTheme.accentColor,
                        ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Exercise Name
            Text(
              title.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.black,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // Timer Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: AppTheme.grey200,
                    valueColor: const AlwaysStoppedAnimation(
                      AppTheme.successColor,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formattedTime,
                      style: GoogleFonts.inter(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.successColor,
                      ),
                    ),
                    if (_isPaused)
                      Text(
                        'PAUSED',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.warningColor,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const Spacer(),

            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _togglePause,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isPaused ? 'Resume' : 'Pause',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _isPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                            color: AppTheme.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      _timer?.cancel();
                      setState(() {
                        _isComplete = true;
                      });
                      _showCompletionDialog();
                    },
                    child: Text(
                      'Complete Early',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.grey500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _confirmExit() {
    _timer?.cancel();
    setState(() => _isPaused = true);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stop Exercise?'),
        content: const Text('Are you sure you want to stop?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isPaused = false);
              _startTimer();
            },
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              'Stop',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
