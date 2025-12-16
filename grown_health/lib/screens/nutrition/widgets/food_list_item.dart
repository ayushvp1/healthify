import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';

/// A list item widget for displaying food information.
class FoodListItem extends StatelessWidget {
  final String name;
  final String calories;
  final String size;
  final String subtitle;
  final Color imagePlaceholder;

  const FoodListItem({
    super.key,
    required this.name,
    required this.calories,
    required this.size,
    required this.subtitle,
    required this.imagePlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: imagePlaceholder,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fastfood, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$calories • $size',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                Text(
                  subtitle,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.grey500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.grey400),
        ],
      ),
    );
  }
}
