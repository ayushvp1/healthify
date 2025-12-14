import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MindDetailScreen extends StatelessWidget {
  const MindDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Colors.black,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Morning Mindfulness',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Main Illustration with decorative lines
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Left decorative line
                        Positioned(
                          left: 20,
                          child: Container(
                            width: 4,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE5D0),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // Right decorative line
                        Positioned(
                          right: 20,
                          child: Container(
                            width: 4,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE5D0),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // Main illustration
                        Container(
                          width: 200,
                          height: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5D0),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Image.asset(
                            'assets/mind/morning_mindfulness.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.self_improvement_rounded,
                                size: 80,
                                color: Color(0xFFAA3D50),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Instruction text below illustration
                  Center(
                    child: Text(
                      'Find a comfortable position and focus on your breath.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Chips row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildChip('Mindfulness'),
                      const SizedBox(width: 8),
                      _buildChip('Beginner', isSecondary: true),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Stats row
                  Row(
                    children: [
                      _buildStatCard(
                        icon: Icons.timer_outlined,
                        title: '10 min',
                        subtitle: 'Duration',
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.trending_up_rounded,
                        title: 'Beginner',
                        subtitle: 'Level',
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.favorite_border_rounded,
                        title: '4',
                        subtitle: 'Benefits',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // About section
                  Text(
                    'About',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your day with peaceful mindfulness meditation to set a positive tone.',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Benefits section
                  Text(
                    'Benefits',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _BenefitChip(label: 'stress relief'),
                      _BenefitChip(label: 'focus'),
                      _BenefitChip(label: 'calm'),
                      _BenefitChip(label: 'mental clarity'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Instructions section
                  Text(
                    'Instructions',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find a comfortable seated position. Close your eyes and focus on your breath. Notice each inhale and exhale without trying to change anything.',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Bottom session bar with play button
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Session',
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '10 min · Mindfulness',
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Start meditation / play audio
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Starting meditation...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFF007BFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {bool isSecondary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSecondary ? const Color(0xFFE5F7E8) : const Color(0xFFE5F0FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          textStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSecondary
                ? const Color(0xFF1E8842)
                : const Color(0xFF1E5FFF),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: Colors.black87),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  final String label;

  const _BenefitChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4E8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFFAA3D50),
          ),
        ),
      ),
    );
  }
}
