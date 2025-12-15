import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Exercise Detail Screen - Shows details of a specific exercise
/// Receives exercise data as arguments via Navigator
class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get exercise data from route arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final exercise =
        args ??
        {
          'title': 'Exercise',
          'description': 'No description available',
          'instructions': '',
          'duration': 30,
          'difficulty': 'beginner',
          'image': '',
          'gif': '',
          'category': {'name': 'General'},
        };

    final title = exercise['title'] ?? 'Exercise';
    final description = exercise['description'] ?? 'No description available';
    final instructions = exercise['instructions'] ?? '';
    final duration = exercise['duration'] ?? 30;
    final difficulty = exercise['difficulty'] ?? 'beginner';
    final categoryName = exercise['category']?['name'] ?? 'General';
    final gifUrl = exercise['gif'] ?? '';
    final imageUrl = exercise['image'] ?? '';
    final visualUrl = gifUrl.isNotEmpty ? gifUrl : imageUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade100,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.black,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              child: IconButton(
                icon: const Icon(
                  Icons.favorite_border_rounded,
                  color: Colors.grey,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to favorites')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Image/GIF
              _buildIllustration(visualUrl),
              const SizedBox(height: 20),

              // Title and Category
              _buildTitle(title, categoryName),
              const SizedBox(height: 24),

              // Stats Card
              _buildStatsCard(duration, difficulty),
              const SizedBox(height: 24),

              // Description
              if (description.isNotEmpty) ...[
                _buildDescriptionCard(description),
                const SizedBox(height: 24),
              ],

              // How to do it (Instructions)
              if (instructions.isNotEmpty) ...[
                _buildHowToSection(instructions),
                const SizedBox(height: 24),
              ],

              const SizedBox(height: 80), // Space for bottom button
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildStartButton(context, exercise),
    );
  }

  Widget _buildIllustration(String imageUrl) {
    return Center(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F3),
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        color: const Color(0xFFAA3D50),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.fitness_center,
                      size: 80,
                      color: Color(0xFFAA3D50),
                    );
                  },
                )
              : const Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Color(0xFFAA3D50),
                ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title, String categoryName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF0F1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            categoryName,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF8B2030),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(int duration, String difficulty) {
    String difficultyLabel =
        difficulty[0].toUpperCase() + difficulty.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
            value: '${duration}s',
            label: 'Duration',
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade200),
          _DetailStat(
            icon: Icons.local_fire_department_rounded,
            value: '${(duration * 0.1).round()} cal',
            label: 'Calories',
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade200),
          _DetailStat(
            icon: Icons.fitness_center_rounded,
            value: difficultyLabel,
            label: 'Level',
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToSection(String instructions) {
    // Split instructions by newlines or numbered list patterns
    final steps = instructions
        .split(RegExp(r'\n|\d+\.\s*'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How to do it',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        if (steps.isEmpty)
          Text(
            instructions,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          )
        else
          ...steps.asMap().entries.map(
            (entry) =>
                _HowToStep(index: entry.key + 1, text: entry.value.trim()),
          ),
      ],
    );
  }

  Widget _buildStartButton(
    BuildContext context,
    Map<String, dynamic> exercise,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamed('/exercise_timer', arguments: exercise);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5B0C23),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 4,
          ),
          icon: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 28,
          ),
          label: Text(
            'Start Exercise',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
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
        Icon(icon, color: const Color(0xFF1B5E20), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFAA3D50),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HowToStep extends StatelessWidget {
  final int index;
  final String text;

  const _HowToStep({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF1B5E20),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.grey.shade800,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
