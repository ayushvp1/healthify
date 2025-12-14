import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/providers.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Workouts',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Continue where you left off',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildFilterChips(context),
              const SizedBox(height: 20),
              _buildProgressCard(),
              const SizedBox(height: 24),
              _buildCategoriesHeader(),
              const SizedBox(height: 12),
              _buildCategoriesList(ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search Workouts',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _FilterChipCard(
            label: 'Start',
            icon: Icons.play_arrow_rounded,
            onTap: () {
              // Quick start: go straight to the workout player.
              Navigator.of(context).pushNamed('/player');
            },
          ),
          const _FilterChipCard(
            label: 'Categories',
            icon: Icons.category_outlined,
            highlighted: true,
          ),
          const _FilterChipCard(
            label: 'Body Scan',
            icon: Icons.favorite_border_rounded,
          ),
          const _FilterChipCard(
            label: 'Steps',
            icon: Icons.directions_walk_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart_rounded, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text(
                "Today's Progress",
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _ProgressRow(
            label: 'Workouts',
            valueText: '3/5',
            color: Color(0xFFAA3D50),
            progress: 0.6,
          ),
          const SizedBox(height: 10),
          const _ProgressRow(
            label: 'Calories',
            valueText: '1,240/2,000',
            color: Color(0xFFFF9800),
            progress: 0.62,
          ),
          const SizedBox(height: 10),
          const _ProgressRow(
            label: 'Steps',
            valueText: '8.2K/10K',
            color: Color(0xFF4CAF50),
            progress: 0.82,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Exercise Categories',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          'See all',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 14,
              color: Colors.redAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesList(WidgetRef ref) {
    final asyncCategories = ref.watch(categoriesProvider);

    return asyncCategories.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Text(
            'No categories yet. Add some in the admin panel.',
            style: GoogleFonts.inter(
              textStyle: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          );
        }

        return Column(
          children: [for (final c in categories) _WorkoutRow(title: c.name)],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Failed to load categories',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(fontSize: 13, color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}

class _FilterChipCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool highlighted;
  final VoidCallback? onTap;

  const _FilterChipCard({
    required this.label,
    required this.icon,
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = highlighted
        ? const Color(0xFFAA3D50)
        : Colors.grey.shade200;
    final Color iconColor = highlighted
        ? const Color(0xFFAA3D50)
        : Colors.grey.shade500;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: highlighted ? 1.2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
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
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
            Text(
              valueText,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _WorkoutRow extends StatelessWidget {
  final String title;

  const _WorkoutRow({required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Open workout detail when tapping a row
        Navigator.of(context).pushNamed('/workout_detail');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFECECEC))),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF7D4DD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.fitness_center, color: Color(0xFFAA3D50)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '30s   •   Beginner',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
