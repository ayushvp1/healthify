import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/core.dart';
import '../../providers/providers.dart';
import '../../services/meditation_service.dart';

/// Beautiful meditation audio player with progress tracking and calming visuals.
class AudioPlayerScreen extends ConsumerStatefulWidget {
  final String meditationId;
  final String title;
  final String? audioUrl;
  final String? thumbnailUrl;
  final int durationSeconds;
  final String? categoryName;

  const AudioPlayerScreen({
    super.key,
    required this.meditationId,
    required this.title,
    this.audioUrl,
    this.thumbnailUrl,
    required this.durationSeconds,
    this.categoryName,
  });

  @override
  ConsumerState<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends ConsumerState<AudioPlayerScreen>
    with TickerProviderStateMixin {
  late AudioPlayer _player;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  Duration _position = Duration.zero;
  late Duration _duration;
  bool _isPlaying = false;
  bool _isCompleted = false;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    // Use duration from admin panel (durationSeconds)
    _duration = Duration(seconds: widget.durationSeconds);
    _initBreathingAnimation();
    _initAudio();
  }

  void _initBreathingAnimation() {
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _breathingAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
    _breathingController.repeat(reverse: true);
  }

  Future<void> _initAudio() async {
    if (widget.audioUrl == null || widget.audioUrl!.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'No audio URL available for this meditation';
      });
      return;
    }

    try {
      await _player.setUrl(widget.audioUrl!);

      // Note: We intentionally don't update _duration from audio file
      // We use the duration set in admin panel instead
      _durationSubscription = _player.durationStream.listen((d) {
        // Duration is fixed from admin panel, no update needed
      });

      _positionSubscription = _player.positionStream.listen((p) {
        if (mounted) {
          setState(() => _position = p);
        }
      });

      _playerStateSubscription = _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            if (state.processingState == ProcessingState.completed) {
              _handleCompletion();
            }
          });
        }
      });

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load audio: ${e.toString()}';
      });
    }
  }

  void _handleCompletion() async {
    if (_isCompleted) return;
    setState(() => _isCompleted = true);

    // Log to history
    final token = ref.read(authProvider).user?.token;
    if (token != null) {
      try {
        final service = MeditationService(token);
        await service.addToHistory(widget.meditationId, _position.inSeconds);
      } catch (e) {
        // Silently fail - history logging is not critical
        debugPrint('Failed to log meditation history: $e');
      }
    }

    if (mounted) {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Well Done!',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You completed ${_formatDuration(_position)} of meditation',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.grey600),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Done',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes;
    final secs = d.inSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _player.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
              const Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _isLoading
                    ? _buildLoading()
                    : _hasError
                    ? _buildError()
                    : _buildPlayer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white70,
              size: 28,
            ),
          ),
          const Spacer(),
          if (widget.categoryName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.categoryName!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ),
          const Spacer(),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          const SizedBox(height: 24),
          Text(
            'Preparing your meditation...',
            style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to Play',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    // Clamp progress to 0.0 - 1.0 range
    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // Animated breathing circle with progress
          AnimatedBuilder(
            animation: _breathingAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isPlaying ? _breathingAnimation.value : 1.0,
                child: child,
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
                // Progress ring
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ),
                // Inner circle with icon
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.6),
                        AppTheme.primaryColor.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.self_improvement_rounded,
                    size: 64,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Title
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Focus on your breath',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white60),
          ),

          const SizedBox(height: 48),

          // Progress slider
          Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
                  activeTrackColor: AppTheme.primaryColor,
                  inactiveTrackColor: Colors.white.withOpacity(0.2),
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withOpacity(0.2),
                ),
                child: Builder(
                  builder: (context) {
                    final maxMs = _duration.inMilliseconds.toDouble();
                    // Clamp position to max to prevent slider crash
                    final positionMs = _position.inMilliseconds
                        .toDouble()
                        .clamp(0.0, maxMs);
                    return Slider(
                      value: positionMs,
                      max: maxMs > 0 ? maxMs : 1.0,
                      onChanged: (v) {
                        _player.seek(Duration(milliseconds: v.toInt()));
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // Clamp displayed position to duration
                      _formatDuration(
                        _position > _duration ? _duration : _position,
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),
                    Text(
                      _formatDuration(
                        _duration.inMilliseconds > 0
                            ? _duration
                            : Duration(seconds: widget.durationSeconds),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rewind 15s
              IconButton(
                onPressed: () {
                  final newPos = _position - const Duration(seconds: 15);
                  _player.seek(newPos.isNegative ? Duration.zero : newPos);
                },
                icon: const Icon(
                  Icons.replay_10_rounded,
                  color: Colors.white70,
                  size: 36,
                ),
              ),
              const SizedBox(width: 24),

              // Play/Pause
              GestureDetector(
                onTap: () {
                  if (_isPlaying) {
                    _player.pause();
                  } else {
                    _player.play();
                  }
                },
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: const Color(0xFF1A1A2E),
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Forward 15s
              IconButton(
                onPressed: () {
                  final newPos = _position + const Duration(seconds: 15);
                  if (newPos < _duration) {
                    _player.seek(newPos);
                  }
                },
                icon: const Icon(
                  Icons.forward_10_rounded,
                  color: Colors.white70,
                  size: 36,
                ),
              ),
            ],
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
