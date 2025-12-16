import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../providers/providers.dart';
import '../../../services/exercise_bundle_service.dart';

/// Widget showing workout bundles as horizontal scrolling gradient cards.
class BodyFocusWidget extends ConsumerStatefulWidget {
  const BodyFocusWidget({super.key});

  @override
  ConsumerState<BodyFocusWidget> createState() => _BodyFocusWidgetState();
}

class _BodyFocusWidgetState extends ConsumerState<BodyFocusWidget> {
  bool _isLoading = true;
  String? _error;
  List<ExerciseBundle> _bundles = [];

  // Gradient colors for cards - cycling through for variety
  static const List<List<Color>> _cardGradients = [
    [Color(0xFF1ABC9C), Color(0xFF16A085)], // Teal
    [Color(0xFF8E44AD), Color(0xFFD980FA)], // Purple
    [Color(0xFFF39C12), Color(0xFFF1C40F)], // Orange
    [Color(0xFF3498DB), Color(0xFF2980B9)], // Blue
    [Color(0xFFE74C3C), Color(0xFFC0392B)], // Red
    [Color(0xFF2ECC71), Color(0xFF27AE60)], // Green
  ];

  @override
  void initState() {
    super.initState();
    _loadBundles();
  }

  Future<void> _loadBundles() async {
    final token = ref.read(authProvider).user?.token;
    if (token == null) {
      setState(() {
        _isLoading = false;
        _error = 'Please log in to view workouts';
      });
      return;
    }

    try {
      final service = ExerciseBundleService(token);
      final response = await service.getBundles(limit: 10);

      if (mounted) {
        setState(() {
          _bundles = response.bundles;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load workouts';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    if (_error != null || _bundles.isEmpty) {
      return Container(
        height: 150,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center_outlined,
                size: 40,
                color: AppTheme.grey400,
              ),
              const SizedBox(height: 12),
              Text(
                _error ?? 'No workout programs available',
                style: GoogleFonts.inter(color: AppTheme.grey600, fontSize: 14),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                TextButton(onPressed: _loadBundles, child: const Text('Retry')),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Workout Programs',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.black,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/bundles'),
                child: Text(
                  'See all',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Horizontal Scrolling Cards
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _bundles.length,
            itemBuilder: (context, index) {
              final bundle = _bundles[index];
              final colors = _cardGradients[index % _cardGradients.length];

              return Padding(
                padding: EdgeInsets.only(
                  right: index < _bundles.length - 1 ? 16 : 0,
                ),
                child: _BundleCard(
                  bundle: bundle,
                  gradientColors: colors,
                  onTap: () {
                    Navigator.pushNamed(context, '/bundle/${bundle.id}');
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Gradient card for workout bundle (similar to Browse Programs style)
class _BundleCard extends StatelessWidget {
  final ExerciseBundle bundle;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const _BundleCard({
    required this.bundle,
    required this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient Header with badges
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Difficulty Badge (top-left)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          bundle.difficultyDisplay,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ),

                    // Days Badge (top-right)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${bundle.totalDays} Days',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ),

                    // Center Icon
                    Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: 36,
                        color: AppTheme.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // White Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bundle Name
                      Text(
                        bundle.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Description
                      Text(
                        bundle.description.isNotEmpty
                            ? bundle.description
                            : '${bundle.totalDays} days program',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.grey500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Exercise count badge
                      Row(
                        children: [
                          Icon(
                            Icons.fitness_center_rounded,
                            size: 12,
                            color: AppTheme.accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${bundle.totalExercises} exercises',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.accentColor,
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
      ),
    );
  }
}
