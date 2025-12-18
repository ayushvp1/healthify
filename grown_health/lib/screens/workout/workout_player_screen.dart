import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:video_player/video_player.dart';
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

  // Preparation Phase state
  bool _isPrepPhase = false;

  // Video & Audio
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;
  late FlutterTts _flutterTts;
  bool _isVoiceEnabled = true;
  double _volume = 1.0;

  // Mode state
  bool _isSingleExerciseMode = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        // Single Exercise Mode
        _isSingleExerciseMode = true;
        _exercises = [
          {
            'exercise': args,
            'targetDuration': args['duration'] ?? 30,
            'targetReps': args['reps'] ?? 0,
            'targetSets': args['sets'] ?? 1,
          },
        ];
        _currentIndex = 0;
        _loading = false;
        _startPrepPhase();
      } else {
        // Session mode
        _loadCurrentSession();
      }
      _isInitialized = true;
    }
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
  }

  Future<void> _speak(String text) async {
    if (!_isVoiceEnabled) return;
    await _flutterTts.setVolume(_volume);
    await _flutterTts.speak(text);
  }

  void _initializeVideo(String videoUrl) async {
    if (videoUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
          _isVideoError = false;
        });
      }
      return;
    }

    // Reset state for new video
    if (mounted) {
      setState(() {
        _isVideoInitialized = false;
        _isVideoError = false;
      });
    }

    try {
      final oldController = _videoController;
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      // After creating new controller, dispose old one
      if (oldController != null) {
        await oldController.dispose();
      }

      await _videoController!.initialize();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _videoController!.setLooping(true);
          _videoController!.setVolume(_volume);
          if (!_isPaused && !_isResting && !_isPrepPhase) {
            _videoController!.play();
          }
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _isVideoError = true;
          _isVideoInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    _flutterTts.stop();
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
          // If no session, wait 1 second and retry once (in case backend is slow)
          await Future.delayed(const Duration(milliseconds: 1000));
          final retryRes = await http.get(uri, headers: _headers);
          if (retryRes.statusCode >= 200 && retryRes.statusCode < 300) {
            final retryData = jsonDecode(retryRes.body);
            if (retryData['data'] != null) {
              if (mounted) {
                setState(() {
                  _session = retryData['data'];
                  _exercises = _session!['exercises'] ?? [];
                  _currentIndex = _session!['currentExerciseIndex'] ?? 0;
                  _loading = false;
                });
                if (_exercises.isNotEmpty) _startPrepPhase();
              }
              return;
            }
          }

          if (mounted) {
            setState(() {
              _error =
                  'No active workout session found.\n\nPlease go back and try starting the exercise again.';
              _loading = false;
            });
          }
          return;
        }

        if (mounted) {
          setState(() {
            _session = data['data'];
            _exercises = _session!['exercises'] ?? [];
            _currentIndex = _session!['currentExerciseIndex'] ?? 0;
            _loading = false;
          });

          if (_exercises.isNotEmpty) {
            _startPrepPhase();
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

  void _startPrepPhase() {
    _timer?.cancel();

    if (_currentIndex >= _exercises.length) {
      _showCompletionDialog();
      return;
    }

    final exerciseData = _exercises[_currentIndex];
    final exercise = exerciseData['exercise'] ?? {};
    final videoUrl = exercise['video'] ?? '';

    if (videoUrl.isNotEmpty) {
      _initializeVideo(videoUrl);
    }

    setState(() {
      _isPrepPhase = true;
      _isResting = false;
      _isPaused = false;
      _remainingSeconds = 10;
    });

    _speak(
      "Get ready. Next exercise is ${exercise['title'] ?? 'Exercise'}. Starting in 10 seconds.",
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_isPaused) return;

      if (_remainingSeconds <= 1) {
        timer.cancel();
        _startCurrentExercise();
      } else {
        setState(() {
          _remainingSeconds--;
        });

        if (_remainingSeconds <= 3) {
          _speak("$_remainingSeconds");
        }
      }
    });
  }

  void _startCurrentExercise() {
    _timer?.cancel();

    if (_currentIndex >= _exercises.length) {
      _showCompletionDialog();
      return;
    }

    final exerciseData = _exercises[_currentIndex];
    final exercise = exerciseData['exercise'];

    // Get duration
    int duration =
        exerciseData['targetDuration'] as int? ??
        exerciseData['duration'] as int? ??
        exercise?['duration'] as int? ??
        30;

    if (duration == 0) {
      final reps = exerciseData['targetReps'] as int? ?? 10;
      final sets = exerciseData['targetSets'] as int? ?? 1;
      duration = reps * sets * 3;
    }

    setState(() {
      _isPrepPhase = false;
      _isResting = false;
      _isPaused = false;
      _totalDuration = duration;
      _remainingSeconds = duration;
    });

    _speak("Start!");
    _videoController?.play();

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

        // Voice cues during exercise
        if (_remainingSeconds == (_totalDuration / 2).round() &&
            _totalDuration > 15) {
          _speak("Halfway there.");
        } else if (_remainingSeconds == 10) {
          _speak("10 seconds left.");
        } else if (_remainingSeconds <= 3 && _remainingSeconds > 0) {
          _speak("$_remainingSeconds");
        }
      }
    });
  }

  void _startRestPeriod() {
    _timer?.cancel();

    setState(() {
      _isResting = true;
      _isPrepPhase = false;
      _isPaused = false;
      _totalDuration = _restDuration;
      _remainingSeconds = _restDuration;
    });

    _speak("Rest. Next exercise in 15 seconds.");
    _videoController?.pause();

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

        if (_remainingSeconds == 3) {
          _speak("Get ready.");
        }
      }
    });
  }

  Future<void> _completeExercise() async {
    if (_isSingleExerciseMode) {
      _showCompletionDialog();
      return;
    }

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
            const Icon(
              Icons.celebration,
              color: AppTheme.accentColor,
              size: 32,
            ),
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
            const Icon(
              Icons.check_circle,
              color: AppTheme.checkGreen,
              size: 80,
            ),
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
              backgroundColor: AppTheme.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              'Finish',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishSession() async {
    if (_isSingleExerciseMode) return;
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

  void _showSoundSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.grey200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Sound Settings',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isVoiceEnabled
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : AppTheme.grey100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isVoiceEnabled
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    color: _isVoiceEnabled
                        ? AppTheme.primaryColor
                        : AppTheme.grey500,
                  ),
                ),
                title: Text(
                  'Voice Cues',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Get audio instructions during workout'),
                trailing: Switch.adaptive(
                  value: _isVoiceEnabled,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() => _isVoiceEnabled = value);
                    setModalState(() {});
                  },
                ),
              ),
              const Divider(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Volume',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${(_volume * 100).round()}%',
                          style: GoogleFonts.inter(
                            color: AppTheme.grey600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Slider(
                    value: _volume,
                    activeColor: AppTheme.primaryColor,
                    inactiveColor: AppTheme.grey200,
                    onChanged: (value) {
                      setState(() {
                        _volume = value;
                        _videoController?.setVolume(value);
                      });
                      setModalState(() {});
                    },
                  ),
                ],
              ),
              const Divider(height: 32),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: Text(
                  'Exercise Instructions',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                subtitle: const Text('View step-by-step guide'),
                onTap: () {
                  Navigator.pop(context);
                  _showHowTo();
                },
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppTheme.white,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    if (_error != null || _exercises.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.white,
        appBar: AppBar(
          backgroundColor: AppTheme.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fitness_center,
                  color: AppTheme.grey500,
                  size: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  _error ?? 'No exercises found',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppTheme.grey500,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
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
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(
              context,
              stepIndex: _currentIndex,
              total: _exercises.length,
            ),

            // Exercise Visual (Video or Image)
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      // Phase Indicator Overlay (subtle)
                      if (_isPrepPhase || _isResting)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _isPrepPhase
                                ? AppTheme.primaryColor.withOpacity(0.1)
                                : AppTheme.infoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isPrepPhase
                                  ? AppTheme.primaryColor.withOpacity(0.2)
                                  : AppTheme.infoColor.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isPrepPhase
                                    ? Icons.timer_rounded
                                    : Icons.self_improvement_rounded,
                                color: _isPrepPhase
                                    ? AppTheme.primaryColor
                                    : AppTheme.infoColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isPrepPhase ? 'PREPARING' : 'RESTING',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _isPrepPhase
                                      ? AppTheme.primaryColor
                                      : AppTheme.infoColor,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Main Exercise Visual
                      Expanded(
                        child: _buildExerciseVisual(
                          visualUrl,
                          exerciseName,
                          exercise['video'] ?? '',
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Exercise Name
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Text(
                              _isResting
                                  ? 'UP NEXT'
                                  : 'EXERCISE ${_currentIndex + 1}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.grey500,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exerciseName,
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryColor,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (!_isResting && !_isPrepPhase) ...[
                              const SizedBox(height: 8),
                              _buildExerciseInfo(exerciseData),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Timer Section
                      _buildBigTimer(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),

            // Controls
            _buildControls(),
            const SizedBox(height: 12),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            onPressed: () => _confirmExit(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value:
                    (stepIndex +
                        (1 -
                            _remainingSeconds /
                                (_totalDuration > 0 ? _totalDuration : 1))) /
                    total,
                backgroundColor: AppTheme.grey100,
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(
              Icons.tune_rounded,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            onPressed: () => _showSoundSettings(),
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
            child: const Text(
              'Exit',
              style: TextStyle(color: AppTheme.errorColor),
            ),
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

  Widget _buildExerciseVisual(
    String imageUrl,
    String exerciseName,
    String videoUrl,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Layer
            if (videoUrl.isNotEmpty)
              _isVideoInitialized && _videoController != null
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: VideoPlayer(_videoController!),
                      ),
                    )
                  : _isVideoError
                  ? _buildImageFallback(imageUrl, exerciseName)
                  : const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                        strokeWidth: 2,
                      ),
                    )
            else
              _buildImageFallback(imageUrl, exerciseName),

            // Subtle Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),

            // Pause Overlay
            if (_isPaused)
              Container(
                color: Colors.black26,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pause_rounded,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageFallback(String imageUrl, String exerciseName) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) =>
            _buildIconPlaceholder(exerciseName),
      );
    }
    return _buildIconPlaceholder(exerciseName);
  }

  Widget _buildIconPlaceholder(String name) {
    return Container(
      color: AppTheme.grey100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isResting
                  ? Icons.self_improvement_rounded
                  : Icons.fitness_center_rounded,
              size: 80,
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No Media Available',
              style: GoogleFonts.inter(
                color: AppTheme.grey400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseInfo(Map<String, dynamic> exerciseData) {
    final reps = exerciseData['targetReps'] as int? ?? 0;
    final sets = exerciseData['targetSets'] as int? ?? 1;

    if (reps == 0 && sets <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        reps > 0 ? '$sets SETS × $reps REPS' : '$sets SETS',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppTheme.primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBigTimer() {
    final progress = _totalDuration > 0
        ? 1 - (_remainingSeconds / _totalDuration)
        : 0.0;

    final timerColor = _isResting ? AppTheme.infoColor : AppTheme.primaryColor;

    return Container(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow (Pulsing effect if playing)
          if (!_isPaused && !_isResting)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOutSine,
              builder: (context, value, child) => Container(
                width: 160 * value,
                height: 160 * value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: timerColor.withOpacity(0.15 * value),
                      blurRadius: 30 * value,
                      spreadRadius: 8 * value,
                    ),
                  ],
                ),
              ),
              child: const SizedBox.shrink(),
            ),

          // Main Timer Ring
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: AppTheme.grey100,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation(timerColor),
            ),
          ),

          // Timer Center
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formattedTime,
                style: GoogleFonts.inter(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                  letterSpacing: -1,
                ),
              ),
              Text(
                _isResting ? 'REST' : 'SECONDS',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.grey400,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          // Previous Button
          Container(
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _currentIndex > 0 ? _goToPreviousStep : null,
              icon: Icon(
                Icons.skip_previous_rounded,
                color: _currentIndex > 0
                    ? AppTheme.primaryColor
                    : AppTheme.grey300,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Main Play/Pause Button
          Expanded(
            child: SizedBox(
              height: 64,
              child: ElevatedButton(
                onPressed: _togglePause,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 8,
                  shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isPaused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isPaused ? 'RESUME' : 'PAUSE',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Next/Skip Button
          Container(
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _goToNextStep,
              icon: const Icon(
                Icons.skip_next_rounded,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
