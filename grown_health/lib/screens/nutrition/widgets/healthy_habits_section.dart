import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';

/// Card displaying healthy habits with circular icons.
class HealthyHabitsSection extends StatelessWidget {
  const HealthyHabitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Healthy Habits',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHabitItem(Icons.bed, '8h Sleep', Colors.indigoAccent),
              _buildHabitItem(Icons.book, 'Read Book', Colors.orangeAccent),
              _buildHabitItem(Icons.self_improvement, 'Meditate', Colors.teal),
              _buildHabitItem(Icons.directions_walk, '10k Steps', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            color: color.withOpacity(0.1),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTheme.lightTheme.textTheme.labelMedium),
      ],
    );
  }
}
