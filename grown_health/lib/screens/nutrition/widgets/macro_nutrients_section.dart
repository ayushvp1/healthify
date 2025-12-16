import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';

/// Displays macro nutrients (Protein, Carbs, Fats) in a card layout.
class MacroNutrientsSection extends StatelessWidget {
  const MacroNutrientsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMacroItem(
            Icons.restaurant,
            'Protein',
            '0/150g',
            AppTheme.primaryColor,
          ),
          _buildMacroItem(
            Icons.local_fire_department,
            'Carbs',
            '0/250g',
            AppTheme.orange,
          ),
          _buildMacroItem(Icons.eco, 'Fats', '0/65g', AppTheme.green),
        ],
      ),
    );
  }

  Widget _buildMacroItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          '0%',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.grey600,
          ),
        ),
      ],
    );
  }
}
