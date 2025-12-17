import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../providers/auth_provider.dart';
import '../../../services/exercise_bundle_service.dart';

/// Today's Plan Section - Shows user's active workout exercises as horizontal cards
class TodaysPlanSection extends ConsumerStatefulWidget {
  const TodaysPlanSection({super.key});

  @override
  ConsumerState<TodaysPlanSection> createState() => _TodaysPlanSectionState();
}

class _TodaysPlanSectionState extends ConsumerState<TodaysPlanSection> {
  bool _loading = true;
  ActiveSession? _session;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final token = ref.read(authProvider).user?.token;
    if (token == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final service = ExerciseBundleService(token);
      final session = await service.getCurrentSession();
      if (mounted) {
        setState(() {
          _session = session;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load session: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Plan",
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_session != null)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/player'),
                child: Text(
                  'Continue',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Content
        if (_loading)
          _buildLoading()
        else if (_session == null)
          _buildEmptyState()
        else
          _buildActiveSession(_session!),
      ],
    );
  }

  Widget _buildLoading() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.accentColor),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        children: [
          Icon(Icons.fitness_center_rounded, size: 48, color: AppTheme.grey400),
          const SizedBox(height: 12),
          Text(
            'No active workout today',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.grey600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start a program to see today\'s exercises',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.grey500),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/bundles'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Browse Programs',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSession(ActiveSession session) {
    if (session.exercises.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtitle with exercise count and program name
        Row(
          children: [
            Expanded(
              child: Text(
                session.program != null
                    ? '${session.program!.name} • Day ${session.programDay}'
                    : '${session.totalExercises} Exercises',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.grey600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Progress indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${session.completedExercises}/${session.totalExercises}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Horizontal Exercise Cards - Larger and more prominent
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: session.exercises.length,
            itemBuilder: (context, index) {
              final ex = session.exercises[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < session.exercises.length - 1 ? 14 : 0,
                ),
                child: _ExerciseCard(
                  exercise: ex,
                  isCurrentExercise: index == session.currentExerciseIndex,
                  onTap: () => Navigator.pushNamed(context, '/player'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Individual exercise card for horizontal scroll
class _ExerciseCard extends StatelessWidget {
  final SessionExercise exercise;
  final bool isCurrentExercise;
  final VoidCallback? onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.isCurrentExercise,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final info = exercise.exercise;
    final isCompleted = exercise.isCompleted;
    final isSkipped = exercise.isSkipped;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCurrentExercise
                ? AppTheme.accentColor
                : isCompleted
                ? AppTheme.checkGreen
                : AppTheme.grey200,
            width: isCurrentExercise ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isCurrentExercise
                  ? AppTheme.accentColor.withOpacity(0.2)
                  : AppTheme.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section - takes most of the space
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(17),
                  topRight: Radius.circular(17),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image placeholder or actual image
                    info != null && info.displayImage.isNotEmpty
                        ? Image.network(
                            info.displayImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),

                    // Gradient overlay for better text visibility
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppTheme.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Status overlay
                    if (isCompleted || isSkipped)
                      Container(
                        color:
                            (isCompleted
                                    ? AppTheme.checkGreen
                                    : AppTheme.grey500)
                                .withOpacity(0.8),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isCompleted
                                    ? Icons.check_circle
                                    : Icons.skip_next,
                                color: AppTheme.white,
                                size: 36,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isCompleted ? 'Done' : 'Skipped',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Current indicator badge
                    if (isCurrentExercise && !isCompleted && !isSkipped)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentColor.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'UP NEXT',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Info section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      info?.title ?? 'Exercise',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.repeat, size: 14, color: AppTheme.grey500),
                        const SizedBox(width: 4),
                        Text(
                          exercise.displayText,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.cardBackground,
      child: Center(
        child: Icon(Icons.fitness_center, color: AppTheme.grey400, size: 32),
      ),
    );
  }
}
