import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class WorkoutPlayerScreen extends StatefulWidget {
  const WorkoutPlayerScreen({super.key});

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  // Simple hardcoded flow for now: exercise -> rest -> exercise ...
  final List<_ExerciseStep> _steps = const [
    _ExerciseStep(
      name: 'V-Up',
      description:
          'Lie flat on your back with arms extended overhead and legs straight. Simultaneously lift your upper and lower body, reaching your hands toward your feet to form a "V" shape.',
      durationSeconds: 30,
      isRest: false,
    ),
    _ExerciseStep(
      name: 'Rest',
      description: 'Catch your breath and get ready for the next movement.',
      durationSeconds: 15,
      isRest: true,
    ),
    _ExerciseStep(
      name: 'Abdominal Crunches',
      description:
          'Lie on your back with knees bent and feet flat on the floor. Lift your shoulders off the ground using your core, then slowly lower back down.',
      durationSeconds: 30,
      isRest: false,
    ),
  ];

  int _currentIndex = 0;
  int _remainingSeconds = 0;
  int _totalDuration = 0;
  bool _isPaused = false;
  bool _isResting = false;
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
      _isResting = step.isRest;
      _totalDuration = step.durationSeconds;
      _remainingSeconds = step.durationSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_isPaused) return;
      if (_remainingSeconds <= 1) {
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
      // Finished all steps
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentIndex];
    final isLast = _currentIndex == _steps.length - 1;

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
            const SizedBox(height: 8),
            if (_isResting)
              _buildRestView()
            else ...[
              _buildIllustration(step),
              _buildExerciseInfo(step),
            ],
            _buildNextUpCard(isLast: isLast),
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
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            '${stepIndex + 1}/$total',
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(_ExerciseStep step) {
    return Expanded(
      child: Center(
        child: Container(
          width: 260,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            step.isRest
                ? Icons.airline_seat_flat_rounded
                : Icons.self_improvement_rounded,
            size: 80,
            color: Colors.deepOrange,
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseInfo(_ExerciseStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            step.isRest ? 'REST' : step.name,
            style: GoogleFonts.inter(
              textStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: step.isRest ? Colors.redAccent : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            step.isRest
                ? 'NEXT: ${_currentIndex + 1 < _steps.length ? _steps[_currentIndex + 1].name : 'Finished'}'
                : step.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRestView() {
    final bool hasNext = _currentIndex + 1 < _steps.length;
    final String nextName = hasNext
        ? _steps[_currentIndex + 1].name
        : 'Finished';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'REST',
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.redAccent,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Next: $nextName',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextUpCard({required bool isLast}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            _buildTimer(),
            const SizedBox(width: 12),
            _buildNextUpInfo(isLast: isLast),
            if (!isLast)
              GestureDetector(
                onTap: () {
                  _goToNextStep();
                },
                child: const Icon(
                  Icons.fast_forward_rounded,
                  color: Color(0xFFAA3D50),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    final percent = _totalDuration > 0
        ? _remainingSeconds / _totalDuration
        : 0.0;

    return GestureDetector(
      onTap: _togglePause,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFAA3D50), width: 3),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 3,
                backgroundColor: Colors.white,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFAA3D50),
                ),
              ),
            ),
            Text(
              _isPaused ? '||' : '$_remainingSeconds',
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFAA3D50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextUpInfo({required bool isLast}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLast ? 'FINISHING' : 'NEXT UP',
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.5,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isLast
                ? 'Great job!'
                : (_currentIndex + 1 < _steps.length
                      ? _steps[_currentIndex + 1].name
                      : 'Finished'),
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
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
  final bool isRest;

  const _ExerciseStep({
    required this.name,
    required this.description,
    required this.durationSeconds,
    required this.isRest,
  });
}
