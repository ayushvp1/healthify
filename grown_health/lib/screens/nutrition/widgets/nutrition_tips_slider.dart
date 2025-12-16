import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';

/// Slider displaying nutrition tips with pagination dots.
class NutritionTipsSlider extends StatelessWidget {
  const NutritionTipsSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Text(
                  'drinking at least 8\nwater daily',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'Include protein\nkeep you',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(true),
              _buildDot(false),
              _buildDot(false),
              _buildDot(false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: active ? 8 : 6,
      height: active ? 8 : 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppTheme.green : AppTheme.grey300,
      ),
    );
  }
}
