import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:grown_health/core/constants/app_constants.dart';
import 'package:grown_health/providers/auth_provider.dart';
import 'package:grown_health/providers/water_provider.dart';
import 'package:grown_health/services/nutrition_service.dart';
import 'recipe_detail_screen.dart';

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
            const _HydrationCard(),
            const SizedBox(height: 24),
            // Macro Nutrients Section - commented out for cleanup
            // _buildSectionTitle('Macro Nutrients'),
            // const SizedBox(height: 16),
            // const _MacroNutrientsSection(),
            // const SizedBox(height: 24),
            const _WeightGoalCards(),
            const SizedBox(height: 24),
            const _RecipeOfTheDayCard(),
            const SizedBox(height: 24),
            // Macronutrient Ratio Section - commented out for cleanup
            // _buildSectionTitle('Macronutrient Ratio'),
            // const SizedBox(height: 16),
            // const _MacronutrientRatioChart(),
            // const SizedBox(height: 24),
            // Today's Meals Section - commented out for cleanup
            // _buildSectionTitle('Today\'s Meals'),
            // const SizedBox(height: 16),
            // const _TodaysMealsSection(),
            // const SizedBox(height: 24),
            // Healthy Habits Section - commented out for cleanup
            // const _HealthyHabitsSection(),
            // const SizedBox(height: 24),
            // Nutrition Tips Section - commented out for cleanup
            // _buildSectionTitle('Nutrition Tips'),
            // const SizedBox(height: 16),
            // const _NutritionTipsSlider(),
            // const SizedBox(height: 24),
            // Quick Actions Section
            _buildSectionTitle('Quick Actions'),
            const SizedBox(height: 16),
            const _QuickActionsGrid(),
            const SizedBox(height: 24),
            // Featured Foods Section
            _buildSectionHeader('Featured Foods', () {}),
            const SizedBox(height: 16),
            const _FoodListItem(
              name: 'NT!',
              calories: '100 Cal',
              size: 'Medium',
              subtitle: 'just your food',
              imagePlaceholder: Colors.orange,
            ),
            const SizedBox(height: 24),
            // Medium Calorie Foods Section - commented out for cleanup
            // _buildSectionHeader('Medium Calorie Foods', () {}),
            // const SizedBox(height: 16),
            // const _FoodListItem(
            //   name: 'NT!',
            //   calories: '100 Cal',
            //   size: 'Medium',
            //   subtitle: 'just your food',
            //   imagePlaceholder: Colors.orange,
            // ),
            // const SizedBox(height: 24),
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

class _HydrationCard extends ConsumerWidget {
  const _HydrationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authProvider).user?.token;
    final waterState = ref.watch(waterNotifierProvider(token));

    // Colors extracted from design
    const Color darkMaroon = Color(0xFF64091A);
    const Color forestGreen = Color(0xFF0C5531);
    const Color darkGreyText = Color(0xFF3B3B3B);
    const Color fillColor = Color(0xFFC75B6E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 9,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Water Bottle Graphic
          _WaterBottleGraphic(
            fillColor: fillColor,
            emptyColor: Colors.transparent,
            currentIntake: waterState.currentMl,
            maxIntake: waterState.goalMl,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  '${waterState.currentMl}ml / ${waterState.goalMl}ml',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                    color: darkMaroon,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Remaining: ${waterState.remainingMl}ml',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: forestGreen,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Staying hydrated improves energy, brain function and overall health',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: darkGreyText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: waterState.loading
                        ? null
                        : () => ref
                              .read(waterNotifierProvider(token).notifier)
                              .addWater(),
                    onLongPress: waterState.loading
                        ? null
                        : () => ref
                              .read(waterNotifierProvider(token).notifier)
                              .removeWater(),
                    borderRadius: BorderRadius.circular(7),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: forestGreen),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            waterState.loading
                                ? Icons.hourglass_empty
                                : Icons.add,
                            size: 20,
                            color: forestGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            waterState.loading ? 'Updating...' : '250 ml',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.normal,
                              color: forestGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterBottleGraphic extends StatelessWidget {
  final Color fillColor;
  final Color emptyColor;
  final int currentIntake;
  final int maxIntake;

  const _WaterBottleGraphic({
    required this.fillColor,
    required this.emptyColor,
    required this.currentIntake,
    required this.maxIntake,
  });

  @override
  Widget build(BuildContext context) {
    const double bottleWidth = 80;
    const double bottleHeight = 170;

    final double fillPercentage = (currentIntake / maxIntake).clamp(0.0, 1.0);
    final int filledSegments = (fillPercentage * 8).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cap
        Container(
          width: 36,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFFC76A76),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Body
        Container(
          width: bottleWidth,
          height: bottleHeight,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5ACB6), width: 2.5),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(8, (index) {
              // index 0 is top, index 7 is bottom.
              // index >= (8 - filledSegments) -> filled
              bool isFilled = index >= (8 - filledSegments);

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: isFilled ? fillColor : Colors.white,
                    border: Border.all(
                      color: isFilled ? fillColor : const Color(0xFFF2D1D9),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _MacroNutrientsSection extends StatelessWidget {
  const _MacroNutrientsSection();

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

class _WeightGoalCards extends StatelessWidget {
  const _WeightGoalCards();

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

class _RecipeOfTheDayCard extends StatefulWidget {
  const _RecipeOfTheDayCard();

  @override
  State<_RecipeOfTheDayCard> createState() => _RecipeOfTheDayCardState();
}

class _RecipeOfTheDayCardState extends State<_RecipeOfTheDayCard> {
  NutritionItem? _recipe;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    final recipe = await NutritionService.getRecipeOfTheDay();
    if (mounted) {
      setState(() {
        _recipe = recipe;
        _loading = false;
      });
    }
  }

  void _navigateToDetail() {
    if (_recipe != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: _recipe!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _recipe != null ? _navigateToDetail : null,
      child: Container(
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
        child: _loading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                    strokeWidth: 2,
                  ),
                ),
              )
            : _recipe == null
            ? _buildNoRecipeState()
            : _buildRecipeContent(),
      ),
    );
  }

  Widget _buildNoRecipeState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.restaurant_menu, size: 40, color: AppTheme.grey400),
        const SizedBox(height: 12),
        Text(
          'No recipe available',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.grey500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Check back later for new recipes!',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.grey400,
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recipe of the Day',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.grey700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.darkRedText,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    'View',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _recipe!.title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.local_fire_department,
              size: 16,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              '${_recipe!.calories} cal',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            const SizedBox(width: 16),
            const Icon(Icons.timer, size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 4),
            Text(
              '${_recipe!.prepTime} min',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

class _MacronutrientRatioChart extends StatelessWidget {
  const _MacronutrientRatioChart();

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

class _TodaysMealsSection extends StatelessWidget {
  const _TodaysMealsSection();

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

class _HealthyHabitsSection extends StatelessWidget {
  const _HealthyHabitsSection();

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
              _buildhabitItem(Icons.bed, '8h Sleep', Colors.indigoAccent),
              _buildhabitItem(Icons.book, 'Read Book', Colors.orangeAccent),
              _buildhabitItem(Icons.self_improvement, 'Meditate', Colors.teal),
              _buildhabitItem(Icons.directions_walk, '10k Steps', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildhabitItem(IconData icon, String label, Color color) {
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

class _NutritionTipsSlider extends StatelessWidget {
  const _NutritionTipsSlider();

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

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildActionCard(Icons.camera_alt, 'Scan Food', Colors.deepPurple),
        _buildActionCard(Icons.restaurant_menu, 'Log Meal', Colors.teal),
        _buildActionCard(Icons.history, 'View History', Colors.green),
        _buildActionCard(Icons.notifications, 'Set Reminder', Colors.blue),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _FoodListItem extends StatelessWidget {
  final String name;
  final String calories;
  final String size;
  final String subtitle;
  final Color imagePlaceholder;

  const _FoodListItem({
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
