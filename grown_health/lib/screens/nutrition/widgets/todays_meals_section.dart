import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';

/// Horizontal scrollable section displaying today's meals.
class TodaysMealsSection extends StatelessWidget {
  const TodaysMealsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildMealCard(
            'Breakfast',
            'Avocado Toast',
            '350 cal',
            Icons.breakfast_dining,
          ),
          const SizedBox(width: 16),
          _buildMealCard(
            'Lunch',
            'Grilled Chicken',
            '450 cal',
            Icons.lunch_dining,
          ),
          const SizedBox(width: 16),
          _buildMealCard('Dinner', 'Salmon', '400 cal', Icons.dinner_dining),
        ],
      ),
    );
  }

  Widget _buildMealCard(
    String mealType,
    String foodName,
    String calories,
    IconData icon,
  ) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 12),
          Text(
            mealType,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            foodName,
            style: AppTheme.lightTheme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(calories, style: AppTheme.lightTheme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.lightPinkBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Log Meal',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
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
}
