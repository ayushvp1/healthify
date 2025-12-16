import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkoutPlanScreen extends StatelessWidget {
  const WorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Header Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350, // Occupy top portion
            child: Image.asset(
              'assets/images/todays_plan_new.png', // Placeholder
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.black26,
                  child: const Center(
                    child: Icon(
                      Icons.fitness_center,
                      size: 60,
                      color: AppTheme.white54,
                    ),
                  ),
                );
              },
            ),
          ),

          // Dark Overlay Gradient for text visibility
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.black.withOpacity(0.6),
                    AppTheme.transparent,
                    AppTheme.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),

          // Back Button & Header Text
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: AppTheme.white,
              radius: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppTheme.black,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          Positioned(
            top: 220, // Adjust based on design
            left: 24,
            child: Text(
              'Beginner Workout',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.white,
              ),
            ),
          ),

          // Draggable/Scrollable Sheet Content
          Positioned.fill(
            top: 280, // Start below the text
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsCard(),
                      const SizedBox(height: 30),
                      Text(
                        'Exercises',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // List of Exercises
                      _buildExerciseTile(context),
                      const SizedBox(height: 16),
                      _buildExerciseTile(context),
                      const SizedBox(height: 16),
                      _buildExerciseTile(context),
                      const SizedBox(height: 16),
                      _buildExerciseTile(context),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/player');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Start Workout',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.grey200),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _DetailStat(
            icon: Icons.access_time_filled_rounded,
            value: '30s',
            label: 'Duration',
          ),
          Container(height: 40, width: 1, color: AppTheme.grey200),
          _DetailStat(
            icon: Icons.local_fire_department_rounded,
            value: '2 cal',
            label: 'calories',
          ),
          Container(height: 40, width: 1, color: AppTheme.grey200),
          _DetailStat(
            icon: Icons.fitness_center_rounded,
            value: 'Med',
            label: 'Level',
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/workout_detail');
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.grey200),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Exercise Thumb
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.accessibility_new_rounded,
                color: AppTheme.warningColor,
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Russian Twist',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '30s',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.grey600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 14,
                        color: AppTheme.primaryColor,
                      ),
                      Icon(
                        Icons.bolt_rounded,
                        size: 14,
                        color: AppTheme.grey300,
                      ),
                      Icon(
                        Icons.bolt_rounded,
                        size: 14,
                        color: AppTheme.grey300,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.black,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _DetailStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.darkGreen, size: 24), // Green Icon
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.accentColor, // Maroon Value
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.grey600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
