import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../api_config.dart';
import '../../providers/auth_provider.dart';

/// Exercise Timer Screen with Preparation Phase, Video, and Voice Commands
class ExerciseTimerScreen extends ConsumerStatefulWidget {
  const ExerciseTimerScreen({super.key});

  @override
  ConsumerState<ExerciseTimerScreen> createState() =>
      _ExerciseTimerScreenState();
}

class _ExerciseTimerScreenState extends ConsumerState<ExerciseTimerScreen> {
  Timer? _timer;

  // Exercise State
  Map<String, dynamic>? _exercise;
  int _totalDuration = 30;
  int _remainingSeconds = 30;

  // Preparation State
  bool _isPrepPhase = true;
  int _prepTimeLeft = 10;

  // Playback State
  bool _isPaused = false;
  bool _isComplete = false;
  bool _isSaving = false;
  DateTime? _startTime;

  // Video & Audio
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_exercise == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _exercise =
          args ??
          {
            'title': 'Exercise',
            'duration': 30,
            'image': '',
            'gif': '',
            'video': '',
          };

      _totalDuration = _exercise!['duration'] ?? 30;
      if (_totalDuration <= 0) _totalDuration = 30;
      _remainingSeconds = _totalDuration;

      // Initialize Video if available
      _initializeVideo(_exercise!['video'] ?? '');

      // Start the flow (Prep -> Exercise)
      _startPrepPhase();
    }
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5); // Slower for clarity
    _flutterTts.setVolume(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _initializeVideo(String videoUrl) async {
    if (videoUrl.isEmpty) return;

    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    try {
      await _videoController!.initialize();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          // Loop the video
          _videoController!.setLooping(true);
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  // --- PREPARATION PHASE LOGIC ---

  void _startPrepPhase() {
    _speak("Get ready. Exercise starts in 10 seconds.");
    setState(() {
      _isPrepPhase = true;
      _prepTimeLeft = 10;
      _isPaused = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      if (_prepTimeLeft > 0) {
        setState(() {
          _prepTimeLeft--;
        });

        // Voice countdown for last 3 seconds
        if (_prepTimeLeft <= 3 && _prepTimeLeft > 0) {
          _speak(_prepTimeLeft.toString());
        }
      } else {
        _endPrepPhase();
      }
    });
  }

  void _endPrepPhase() {
    _timer?.cancel();
    _speak("Start!");
    setState(() {
      _isPrepPhase = false;
      _startTime = DateTime.now(); // Track actual start time
    });

    // Start video if available
    if (_isVideoInitialized && _videoController != null) {
      _videoController!.play();
    }

    _startExerciseTimer();
  }

  void _skipPrep() {
    _endPrepPhase();
  }

  // --- EXERCISE PHASE LOGIC ---

  void _startExerciseTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });

        // Voice cues
        if (_remainingSeconds == (_totalDuration / 2).round()) {
          _speak("Halfway there.");
        } else if (_remainingSeconds <= 3 && _remainingSeconds > 0) {
          _speak(_remainingSeconds.toString());
        }
      } else {
        _finishExercise();
      }
    });
  }

  void _finishExercise() {
    _timer?.cancel();
    _videoController?.pause();
    _speak("Rest.");

    setState(() {
      _isComplete = true;
    });
    _showCompletionDialog();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isVideoInitialized && _videoController != null) {
      if (_isPaused) {
        _videoController!.pause();
      } else if (!_isPrepPhase) {
        _videoController!.play();
      }
    }
  }

  // --- COMPLETION & SAVING ---

  Future<void> _logExerciseToHistory() async {
    if (_isSaving) return;

    final token = ref.read(authProvider).user?.token;
    if (token == null) return;

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
                    await _logExerciseToHistory();
                    if (mounted) {
                      Navigator.pop(ctx);
                      Navigator.pop(context, true);
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
                      _startPrepPhase(); // Restart with prep
                    });
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

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    if (_exercise == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final title = _exercise!['title'] ?? 'Exercise';
    final visualUrl = (_exercise!['gif']?.isNotEmpty ?? false)
        ? _exercise!['gif']
        : _exercise!['image'] ?? '';

    // Calculate progress for current phase
    double progress = 0.0;
    if (_isPrepPhase) {
      progress = 1 - (_prepTimeLeft / 10.0);
    } else {
      progress = _totalDuration > 0
          ? 1 - (_remainingSeconds / _totalDuration)
          : 0.0;
    }

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
                    _isPrepPhase ? 'Get Ready' : 'In Progress',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const Spacer(),

            // Visual Area (Video or Image)
            Container(
              height: 220,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppTheme.white, // Ensure white background
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _isVideoInitialized && _videoController != null
                    ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoController!.value.size.width,
                          height: _videoController!.value.size.height,
                          child: VideoPlayer(_videoController!),
                        ),
                      )
                    : (visualUrl.isNotEmpty
                          ? Image.network(
                              visualUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.fitness_center,
                                  size: 50,
                                  color: AppTheme.grey400,
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.fitness_center,
                                size: 50,
                                color: AppTheme.grey400,
                              ),
                            )),
              ),
            ),

            const SizedBox(height: 24),

            // Exercise Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _isPrepPhase ? 'NEXT: $title' : title,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 30),

            // Timer Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 240,
                  height: 240,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 16, // Thicker stroke
                    backgroundColor: AppTheme.grey100,
                    valueColor: AlwaysStoppedAnimation(
                      _isPrepPhase
                          ? AppTheme.accentColor
                          : AppTheme.successColor,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isPrepPhase
                          ? '$_prepTimeLeft'
                          : _formatTime(_remainingSeconds),
                      style: GoogleFonts.inter(
                        fontSize: _isPrepPhase ? 80 : 60,
                        fontWeight: FontWeight.w800,
                        color: _isPrepPhase
                            ? AppTheme.accentColor
                            : AppTheme.successColor,
                      ),
                    ),
                    if (_isPaused)
                      Text(
                        'PAUSED',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.warningColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                    if (_isPrepPhase && !_isPaused)
                      Text(
                        'seconds',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.grey500,
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
                  if (_isPrepPhase)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _skipPrep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Skip Preparation',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _togglePause,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isPaused
                                    ? AppTheme.successColor
                                    : AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isPaused
                                        ? Icons.play_arrow_rounded
                                        : Icons.pause_rounded,
                                    color: AppTheme.white,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isPaused ? 'Resume' : 'Pause',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  if (!_isPrepPhase) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        _finishExercise();
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
    _videoController?.pause();
    setState(() => _isPaused = true);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stop Exercise?'),
        content: const Text('Are you sure you want to quit this session?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isPaused = false);

              if (_isPrepPhase) {
                _startPrepPhase(); // Restart prep
              } else {
                _startExerciseTimer();
                if (_isVideoInitialized && _videoController != null)
                  _videoController!.play();
              }
            },
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Dialog
              Navigator.pop(context); // Screen
            },
            child: const Text(
              'Quit',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
