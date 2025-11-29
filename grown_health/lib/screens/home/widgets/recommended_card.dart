import 'package:flutter/material.dart';
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
    this.title = '30 Days Challenge',
    this.duration = '20 mins',
    this.exercises = '7 Exercises',
    this.level = 'Beginner',
    this.badge = 'Based on your fitness level',
    required this.backgroundColor,
    required this.accentColor,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              badge,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                duration,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.fitness_center_outlined,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                exercises,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.star_border_rounded,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                level,
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: backgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(
                  'Start Bundle',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
