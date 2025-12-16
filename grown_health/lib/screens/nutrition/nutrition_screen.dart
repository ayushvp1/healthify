import 'package:flutter/material.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:grown_health/core/constants/app_constants.dart';
import 'widgets/widgets.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.camera_alt_outlined,
              color: AppTheme.primaryColor,
            ),
            onPressed: () {
              // TODO: Implement camera action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HydrationSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('Macro Nutrients'),
            const SizedBox(height: 16),
            const MacroNutrientsSection(),
            const SizedBox(height: 24),
            const WeightGoalCards(),
            const SizedBox(height: 24),
            const RecipeOfTheDayCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Macronutrient Ratio'),
            const SizedBox(height: 16),
            const MacronutrientRatioChart(),
            const SizedBox(height: 24),
            _buildSectionTitle('Today\'s Meals'),
            const SizedBox(height: 16),
            const TodaysMealsSection(),
            const SizedBox(height: 24),
            const HealthyHabitsSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('Nutrition Tips'),
            const SizedBox(height: 16),
            const NutritionTipsSlider(),
            const SizedBox(height: 24),
            _buildSectionTitle('Quick Actions'),
            const SizedBox(height: 16),
            const QuickActionsGrid(),
            const SizedBox(height: 24),
            _buildSectionHeader('Featured Foods', () {}),
            const SizedBox(height: 16),
            const FoodListItem(
              name: 'NT!',
              calories: '100 Cal',
              size: 'Medium',
              subtitle: 'just your food',
              imagePlaceholder: Colors.orange,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Medium Calorie Foods', () {}),
            const SizedBox(height: 16),
            const FoodListItem(
              name: 'NT!',
              calories: '100 Cal',
              size: 'Medium',
              subtitle: 'just your food',
              imagePlaceholder: Colors.orange,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            'See all',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
