import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';

/// Circular chart displaying macronutrient ratio with legend.
class MacronutrientRatioChart extends StatelessWidget {
  const MacronutrientRatioChart({super.key});

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
      child: Row(
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: 0.65,
                      strokeWidth: 20,
                      backgroundColor: AppTheme.grey200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: 0.35,
                      strokeWidth: 20,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.black,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '36%',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegend(AppTheme.primaryColor, 'Protein'),
              const SizedBox(height: 8),
              _buildLegend(AppTheme.green, 'Carbs'),
              const SizedBox(height: 8),
              _buildLegend(Colors.black, 'Fat'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 8),
        Text(label, style: AppTheme.lightTheme.textTheme.bodyMedium),
      ],
    );
  }
}
