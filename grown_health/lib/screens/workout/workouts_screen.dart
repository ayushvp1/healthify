import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Workouts',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Continue where you left off',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildRefinedFilterChips(context),
              const SizedBox(height: 24),
              _buildProgressCard(),
              const SizedBox(height: 24),
              _buildSectionHeader('Abs', 'See all'),
              const SizedBox(height: 16),
              _buildExercisesList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF5B0C23), // Dark Maroon
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Search Workouts',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefinedFilterChips(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CustomChip(
          label: 'Start',
          icon: Icons.search,
          color: const Color(0xFFFFF0F3), // Light Pink
          iconColor: const Color(0xFFAA3D50),
          textColor: const Color(0xFFAA3D50),
          onTap: () => Navigator.of(context).pushNamed('/player'),
        ),
        _CustomChip(
          label: 'Categories',
          icon: Icons.search,
          color: const Color(0xFFE3F2FD), // Light Blue
          iconColor: const Color(0xFF1976D2),
          textColor: const Color(0xFF1565C0),
          onTap: () {},
        ),
        _CustomChip(
          label: 'Body Scan',
          icon: Icons.search,
          color: const Color(0xFFF5F5F5), // Light Grey
          iconColor: Colors.black54,
          textColor: Colors.black87,
          onTap: () {},
        ),
        _CustomChip(
          label: 'Steps',
          icon: Icons.search,
          color: const Color(0xFFFFEBEE), // Light Red/Pink
          iconColor: const Color(0xFFD32F2F),
          textColor: const Color(0xFFC62828),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.show_chart_rounded,
                color: Color(0xFF5B0C23),
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                "Today's Progress",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _ProgressRow(
            label: 'Workouts',
            valueText: '3/5',
            color: Color(0xFF880E4F), // Deep Maroon
            progress: 0.6,
          ),
          const SizedBox(height: 16),
          const _ProgressRow(
            label: 'Calories',
            valueText: '1,240/2,000',
            color: Color(0xFFFF9800), // Orange
            progress: 0.62,
          ),
          const SizedBox(height: 16),
          const _ProgressRow(
            label: 'Steps',
            valueText: '8.2K/10K',
            color: Color(0xFF2E7D32), // Dark Green
            progress: 0.82,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        Text(
          action,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF5B0C23),
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesList(BuildContext context) {
    // Hardcoded list to match visual for now, as requested "exactly layout"
    // In a real app, this would come from the API/Provider
    return Column(
      children: List.generate(
        5,
        (index) => _WorkoutRow(
          title: 'Russian Twist',
          onTap: () => Navigator.of(context).pushNamed('/workout_detail'),
        ),
      ),
    );
  }
}

class _CustomChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const _CustomChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.iconColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70, // Slightly square
            height: 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final String valueText;
  final double progress;
  final Color color;

  const _ProgressRow({
    required this.label,
    required this.valueText,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Text(
              valueText,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WorkoutRow extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _WorkoutRow({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          // border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F3), // Light Pink bg
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: Color(0xFFAA3D50),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '30s',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.circle,
                          size: 4,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Text(
                        'Beginner',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
