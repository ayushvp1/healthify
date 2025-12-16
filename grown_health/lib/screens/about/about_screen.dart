import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: Text(
          'About Us',
          style: GoogleFonts.inter(
            color: AppTheme.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.black),
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
                  color: AppTheme.primaryColor, // Maroon
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  size: 50,
                  color: AppTheme.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Grown Health',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your personal companion for a healthier, happier life.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.black87,
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
                style: GoogleFonts.inter(color: AppTheme.grey500, fontSize: 12),
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
            color: AppTheme.darkGreen, // Dark Green
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppTheme.black87,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
