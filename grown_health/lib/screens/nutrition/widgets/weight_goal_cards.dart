import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';

/// Two-column card display for weight gain/loss goals.
class WeightGoalCards extends StatelessWidget {
  const WeightGoalCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildCard('Weight\nGain', Icons.fitness_center)),
        const SizedBox(width: 16),
        Expanded(child: _buildCard('Weight\nLoss', Icons.directions_run)),
      ],
    );
  }

  Widget _buildCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.lightPinkBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
