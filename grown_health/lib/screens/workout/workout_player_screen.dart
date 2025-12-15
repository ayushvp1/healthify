import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api_config.dart';
import '../../providers/auth_provider.dart';

class WorkoutPlayerScreen extends ConsumerStatefulWidget {
  const WorkoutPlayerScreen({super.key});

  @override
  ConsumerState<WorkoutPlayerScreen> createState() =>
      _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends ConsumerState<WorkoutPlayerScreen> {
  // Session data
  Map<String, dynamic>? _session;
  List<dynamic> _exercises = [];
  int _currentIndex = 0;
  bool _loading = true;
  String? _error;

  // Timer state
  int _remainingSeconds = 0;
  int _totalDuration = 0;
  bool _isPaused = false;
  Timer? _timer;

  // Rest period state
  bool _isResting = false;
  int _restDuration = 15; // 15 seconds rest between exercises

  @override
  void initState() {
    super.initState();
    _loadCurrentSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Map<String, String> get _headers {
    final token = ref.read(authProvider).user?.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _loadCurrentSession() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final token = ref.read(authProvider).user?.token;
    debugPrint('=== Workout Player: Loading session ===');
    debugPrint('Token present: ${token != null}');

    if (token == null) {
      if (mounted) {
        setState(() {
          _error = 'Not logged in. Please log in first.';
          _loading = false;
        });
      }
      return;
    }

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/workout-progress/current');
      debugPrint('Calling: $uri');
      final res = await http.get(uri, headers: _headers);
      debugPrint('Response status: ${res.statusCode}');
      debugPrint('Response body: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);

        if (data['data'] == null) {
          // No active session - this is expected if user hasn't started one
          if (mounted) {
            setState(() {
              _error =
                  'No active workout session.\n\nPlease go to a workout program and tap "Start Workout" first.';
              _loading = false;
            });
          }
          return;
        }

        debugPrint('Session loaded: ${data['data']['_id']}');
        debugPrint(
          'Exercises count: ${(data['data']['exercises'] as List?)?.length ?? 0}',
        );

        if (mounted) {
          setState(() {
            _session = data['data'];
            _exercises = _session!['exercises'] ?? [];
            _currentIndex = _session!['currentExerciseIndex'] ?? 0;
            _loading = false;
          });

          if (_exercises.isNotEmpty) {
            _startCurrentExercise();
          }
        }
      } else {
        debugPrint('API error: ${res.body}');
        throw Exception('Server error: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception: $e');
      if (mounted) {
        setState(() {
          _error =
              'Failed to load session.\n\n${e.toString().replaceAll('Exception: ', '')}';
          _loading = false;
        });
      }
    }
  }

  void _startCurrentExercise() {
    _timer?.cancel();

    if (_currentIndex >= _exercises.length) {
      _showCompletionDialog();
      return;
    }

    final exerciseData = _exercises[_currentIndex];
    final exercise = exerciseData['exercise'];

    // Get duration - prefer targetDuration from session, fallback to exercise duration
    int duration =
        exerciseData['targetDuration'] as int? ??
        exerciseData['duration'] as int? ??
        exercise?['duration'] as int? ??
        30; // Default 30 seconds

    // If duration is 0, use reps-based calculation (estimate 3 seconds per rep)
    if (duration == 0) {
      final reps = exerciseData['targetReps'] as int? ?? 10;
      final sets = exerciseData['targetSets'] as int? ?? 1;
      duration = reps * sets * 3;
    }

    setState(() {
      _isResting = false;
      _isPaused = false;
      _totalDuration = duration;
      _remainingSeconds = duration;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_isPaused) return;

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _completeExercise();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _startRestPeriod() {
    _timer?.cancel();

    setState(() {
      _isResting = true;
      _isPaused = false;
      _totalDuration = _restDuration;
      _remainingSeconds = _restDuration;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_isPaused) return;

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _moveToNextExercise();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  Future<void> _completeExercise() async {
    // Call API to complete current exercise
    try {
      final sessionId = _session?['_id'];
      if (sessionId != null) {
        final uri = Uri.parse(
          '${ApiConfig.baseUrl}/workout-progress/session/$sessionId/complete-exercise',
        );
        final res = await http.post(
          uri,
          headers: _headers,
          body: jsonEncode({'duration': _totalDuration}),
        );

        if (res.statusCode >= 200 && res.statusCode < 300) {
          final data = jsonDecode(res.body);
          if (data['data']['isWorkoutComplete'] == true) {
            _showCompletionDialog();
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to complete exercise: $e');
    }

    // Start rest period before next exercise
    if (_currentIndex < _exercises.length - 1) {
      _startRestPeriod();
    } else {
      _showCompletionDialog();
    }
  }

  void _moveToNextExercise() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startCurrentExercise();
    } else {
      _showCompletionDialog();
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _goToNextStep() {
    _timer?.cancel();
    _moveToNextExercise();
  }

  void _goToPreviousStep() {
    if (_currentIndex > 0) {
      _timer?.cancel();
      setState(() {
        _currentIndex--;
      });
      _startCurrentExercise();
    }
  }

  void _showCompletionDialog() {
    _timer?.cancel();

    // Complete the session
    _finishSession();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.celebration, color: Color(0xFFAA3D50), size: 32),
            const SizedBox(width: 12),
            Text(
              'Workout Complete!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 80),
            const SizedBox(height: 16),
            Text(
              'Great job! You finished all ${_exercises.length} exercises.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 16),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAA3D50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              'Finish',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishSession() async {
    try {
      final sessionId = _session?['_id'];
      if (sessionId != null) {
        final uri = Uri.parse(
          '${ApiConfig.baseUrl}/workout-progress/session/$sessionId/finish',
        );
        await http.post(uri, headers: _headers);
      }
    } catch (e) {
      debugPrint('Failed to finish session: $e');
    }
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFAA3D50)),
        ),
      );
    }

    if (_error != null || _exercises.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fitness_center, color: Colors.grey, size: 80),
                const SizedBox(height: 24),
                Text(
                  _error ?? 'No exercises found',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAA3D50),
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final exerciseData = _exercises[_currentIndex];
    final exercise = exerciseData['exercise'] ?? {};
    final exerciseName = exercise['title'] ?? 'Exercise';
    // Prefer GIF for animated demonstration, fallback to image
    final exerciseGif = exercise['gif'] ?? '';
    final exerciseImage = exercise['image'] ?? '';
    final visualUrl = exerciseGif.isNotEmpty ? exerciseGif : exerciseImage;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(
              context,
              stepIndex: _currentIndex,
              total: _exercises.length,
            ),
            const SizedBox(height: 16),

            // Rest indicator
            if (_isResting)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.self_improvement,
                      color: Color(0xFF2196F3),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REST',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2196F3),
                            ),
                          ),
                          Text(
                            'Get ready for the next exercise',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            // Exercise Image/GIF
            _buildExerciseVisual(visualUrl, exerciseName),

            const SizedBox(height: 24),

            // Exercise Name
            Text(
              _isResting ? 'Next: $exerciseName' : exerciseName.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            // Exercise info (reps/sets)
            if (!_isResting) ...[
              const SizedBox(height: 8),
              _buildExerciseInfo(exerciseData),
            ],

            const SizedBox(height: 30),

            // Timer
            _buildBigTimer(),

            const Spacer(),

            // Controls
            _buildControls(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context, {
    required int stepIndex,
    required int total,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.black,
              ),
              onPressed: () => _confirmExit(),
            ),
          ),
          // Progress indicator
          Column(
            children: [
              Text(
                '${stepIndex + 1}/$total',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  value: (stepIndex + 1) / total,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFAA3D50)),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.question_mark_rounded,
                size: 20,
                color: Colors.black,
              ),
              onPressed: () => _showHowTo(),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmExit() {
    _timer?.cancel();
    setState(() => _isPaused = true);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Workout?'),
        content: const Text(
          'Your progress will be saved. You can continue later.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isPaused = false);
            },
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showHowTo() {
    if (_currentIndex >= _exercises.length) return;

    final exerciseData = _exercises[_currentIndex];
    final exercise = exerciseData['exercise'] ?? {};
    final name = exercise['title'] ?? 'Exercise';
    final description = exercise['description'] ?? 'No description available.';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('How to: $name'),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExerciseVisual(String imageUrl, String exerciseName) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Center(
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: _isResting
                ? const Color(0xFFE3F2FD)
                : const Color(0xFFFFF0F3),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: const Color(0xFFAA3D50),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        _isResting
                            ? Icons.self_improvement
                            : Icons.fitness_center,
                        size: 80,
                        color: _isResting
                            ? const Color(0xFF2196F3)
                            : const Color(0xFFAA3D50),
                      );
                    },
                  )
                : Icon(
                    _isResting ? Icons.self_improvement : Icons.fitness_center,
                    size: 80,
                    color: _isResting
                        ? const Color(0xFF2196F3)
                        : const Color(0xFFAA3D50),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseInfo(Map<String, dynamic> exerciseData) {
    final reps = exerciseData['targetReps'] as int? ?? 0;
    final sets = exerciseData['targetSets'] as int? ?? 1;

    if (reps == 0 && sets <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        reps > 0 ? '$sets × $reps reps' : '$sets sets',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFAA3D50),
        ),
      ),
    );
  }

  Widget _buildBigTimer() {
    final progress = _totalDuration > 0
        ? 1 - (_remainingSeconds / _totalDuration)
        : 0.0;

    // Use green color for timer to match reference design
    const timerColor = Color(0xFF1E6F3E);
    const restColor = Color(0xFF2196F3);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Timer circle with green outline
        SizedBox(
          width: 180,
          height: 180,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(
              _isResting ? restColor : timerColor,
            ),
          ),
        ),
        // Timer text
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formattedTime,
              style: GoogleFonts.inter(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: _isResting ? restColor : timerColor,
              ),
            ),
            if (_isResting)
              Text(
                'REST',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: restColor,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _togglePause,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isResting
                    ? const Color(0xFF2196F3)
                    : const Color(0xFF5B0C23),
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _currentIndex > 0 ? _goToPreviousStep : null,
                icon: Icon(
                  Icons.skip_previous_rounded,
                  color: _currentIndex > 0 ? Colors.grey : Colors.grey.shade300,
                ),
                label: Text(
                  'Previous',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _currentIndex > 0
                        ? Colors.grey
                        : Colors.grey.shade300,
                  ),
                ),
              ),
              TextButton(
                onPressed: _goToNextStep,
                child: Row(
                  children: [
                    Text(
                      'Skip',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.skip_next_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
