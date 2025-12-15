import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'About Us',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF5B0C23), // Maroon
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Grown Health',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5B0C23),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your personal companion for a healthier, happier life.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              'Our Mission',
              'To empower individuals to take control of their health through holistic tracking and personalized guidance.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Features',
              '• Medicine Reminders\n• Water Intake Tracking\n• Workout Plans\n• Health Metrics Analysis',
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'Version 1.0.0',
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B5E20), // Dark Green
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.black87,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
