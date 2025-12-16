import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendedCard extends StatelessWidget {
  final String title;
  final String duration;
  final String exercises;
  final String level;
  final String badge;
  final Color backgroundColor;
  final Color accentColor;
  final VoidCallback? onStart;

  const RecommendedCard({
    super.key,
    this.title = '30 Day Challenge',
    this.duration = '3 Days',
    this.exercises = '4 Exercises',
    this.level = 'BEGINNER',
    this.badge = 'Workout Program',
    required this.backgroundColor,
    required this.accentColor,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundColor, accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Glow (Top Right)
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // Background Glow (Bottom Left)
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04), // Very subtle
              ),
            ),
          ),

          // Content Pattern
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Content
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Metadata (Time & Exercises)
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_filled_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            duration,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.fitness_center_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            exercises,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Level (Lightning bolts)
                      Row(
                        children: [
                          const Icon(Icons.bolt, color: Colors.white, size: 18),
                          Icon(
                            Icons.bolt,
                            color: Colors.white.withOpacity(0.6),
                            size: 18,
                          ),
                          Icon(
                            Icons.bolt,
                            color: Colors.white.withOpacity(0.6),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            level,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Start Button
                      SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: onStart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.white,
                            foregroundColor:
                                backgroundColor, // Match text to card bg
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: Text(
                            'Start Bundle',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Column: Decorative Squircle
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFB2EBF2,
                        ).withOpacity(0.3), // Cyan tint
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
