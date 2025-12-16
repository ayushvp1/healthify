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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Session Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Program Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (session.program != null) ...[
                      Text(
                        session.program!.name,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      session.programDayTitle ?? 'Day ${session.programDay}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Progress
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: session.progressPercentage / 100,
                              backgroundColor: AppTheme.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.white,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${session.progressPercentage}%',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Continue Button
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/player'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Exercise count
        Text(
          '${session.totalExercises} Exercises',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.grey600,
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Exercise Cards
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: session.exercises.length,
            itemBuilder: (context, index) {
              final ex = session.exercises[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < session.exercises.length - 1 ? 12 : 0,
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
        width: 120,
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentExercise
                ? AppTheme.accentColor
                : isCompleted
                ? AppTheme.checkGreen
                : AppTheme.grey200,
            width: isCurrentExercise ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
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

                    // Status overlay
                    if (isCompleted || isSkipped)
                      Container(
                        color:
                            (isCompleted
                                    ? AppTheme.checkGreen
                                    : AppTheme.grey500)
                                .withOpacity(0.7),
                        child: Center(
                          child: Icon(
                            isCompleted ? Icons.check_circle : Icons.skip_next,
                            color: AppTheme.white,
                            size: 32,
                          ),
                        ),
                      ),

                    // Current indicator
                    if (isCurrentExercise && !isCompleted && !isSkipped)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'NOW',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info?.title ?? 'Exercise',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    exercise.displayText,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.grey600,
                    ),
                  ),
                ],
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
