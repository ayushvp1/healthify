import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkoutPlayerScreen extends StatelessWidget {
  const WorkoutPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            const SizedBox(height: 8),
            _buildIllustration(),
            _buildExerciseInfo(),
            _buildNextUpCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            '1/7',
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Expanded(
      child: Center(
        child: Container(
          width: 260,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.self_improvement_rounded,
            size: 80,
            color: Colors.deepOrange,
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'V-Up',
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Lie flat on your back with arms extended overhead and legs straight. Simultaneously lift your upper and lower body, reaching your hands toward your feet to form a "V" shape. V-ups challenge the entire core, improving strength, control, and flexibility.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNextUpCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            _buildTimer(),
            const SizedBox(width: 12),
            _buildNextUpInfo(),
            const Icon(Icons.fast_forward_rounded, color: Color(0xFFAA3D50)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFAA3D50), width: 3),
      ),
      child: Center(
        child: Text(
          '28',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFAA3D50),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextUpInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEXT UP',
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.5,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Abdominal Crunches',
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
