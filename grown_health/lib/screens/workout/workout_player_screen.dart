import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class WorkoutPlayerScreen extends StatefulWidget {
  const WorkoutPlayerScreen({super.key});

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  final List<_ExerciseStep> _steps = const [
    _ExerciseStep(
      name: 'JUMPING JACKS',
      description:
          'Start with feet together and hands by your sides. Jump while raising arms and separating legs. Return to start.',
      durationSeconds: 30,
    ),
    _ExerciseStep(
      name: 'RUSSIAN TWIST',
      description:
          'Sit on floor, lean back slightly, rotate torso side to side.',
      durationSeconds: 30,
    ),
    _ExerciseStep(
      name: 'PLANK',
      description: 'Hold a push-up position with weight on forearms.',
      durationSeconds: 45,
    ),
  ];

  int _currentIndex = 0;
  int _remainingSeconds = 0;
  int _totalDuration = 0;
  bool _isPaused = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCurrentStep();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCurrentStep() {
    _timer?.cancel();
    final step = _steps[_currentIndex];
    setState(() {
      _isPaused = false;
      _totalDuration = step.durationSeconds;
      _remainingSeconds = step.durationSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_isPaused) return;
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _goToNextStep();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _goToNextStep() {
    if (_currentIndex < _steps.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startCurrentStep();
    } else {
      // Finish
      _showCompletionDialog();
    }
  }

  void _goToPreviousStep() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _startCurrentStep();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Workout Completed!'),
        content: const Text('Great job! You finished the workout.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentIndex];
    final progress = _totalDuration > 0
        ? 1 - (_remainingSeconds / _totalDuration)
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(
              context,
              stepIndex: _currentIndex,
              total: _steps.length,
            ),
            const Spacer(),
            _buildIllustration(),
            const Spacer(),
            Text(
              step.name,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            _buildBigTimer(progress),
            const Spacer(),
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
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Text(
            '${stepIndex + 1}/$total',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
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
              onPressed: _showHowTo,
            ),
          ),
        ],
      ),
    );
  }

  void _showHowTo() {
    final step = _steps[_currentIndex];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('How to: ${step.name}'),
          content: Text(step.description),
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

  Widget _buildIllustration() {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Center(
        child: Image.asset(
          'assets/workout_illustration.png', // Placeholder
          height: 220,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.accessibility_new_rounded,
                size: 100,
                color: Colors.deepOrange,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBigTimer(double progress) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF1B5E20), // Dark Green Border
          width: 5,
        ),
      ),
      child: Center(
        child: Text(
          _formattedTime,
          style: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B5E20), // Dark Green Text
          ),
        ),
      ),
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
                backgroundColor: const Color(0xFF5B0C23), // Dark Maroon
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
                icon: const Icon(
                  Icons.skip_previous_rounded,
                  color: Colors.grey,
                ),
                label: Text(
                  'Previous',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
              ),
              TextButton.icon(
                onPressed: _goToNextStep,
                label: Text(
                  'Skip',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                icon: const Icon(Icons.skip_next_rounded, color: Colors.grey),
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
                // icon alignment? flutter text button icon is usually left.
                // We'll use Directionality for RTL icon or just Row.
                // TextButton.icon puts icon on left. For 'Skip >', we want icon on right.
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseStep {
  final String name;
  final String description;
  final int durationSeconds;

  const _ExerciseStep({
    required this.name,
    required this.description,
    required this.durationSeconds,
  });
}
