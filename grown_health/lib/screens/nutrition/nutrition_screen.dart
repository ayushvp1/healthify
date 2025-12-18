import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:grown_health/core/constants/app_constants.dart';
import 'package:grown_health/providers/auth_provider.dart';
import 'package:grown_health/providers/water_provider.dart';
import 'package:grown_health/screens/nutrition/recipes_list_screen.dart';
import 'package:grown_health/services/nutrition_service.dart';
import 'recipe_detail_screen.dart';
import 'calorie_scanner_screen.dart';
import 'widgets/widgets.dart';
import 'nutrition_chat_screen.dart';
import 'meal_plan_screen.dart';
import 'daily_meal_log_screen.dart';
import '../../providers/meal_provider.dart';

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
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CalorieScannerScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingMedium,
          AppConstants.paddingMedium,
          AppConstants.paddingMedium,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HydrationCard(),
            const SizedBox(height: 24),
            const SmartRecommendationsCard(),
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
            _buildSectionHeader('Today\'s Meals', () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DailyMealLogScreen()),
              );
            }),
            const SizedBox(height: 16),
            const _TodaysMealsSection(),
            const SizedBox(height: 24),
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
            _buildSectionHeader('Featured Foods', () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RecipesListScreen()),
              );
            }),
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
    final progress = (waterState.currentMl / waterState.goalMl).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _WaterBottleGraphic(
            currentIntake: waterState.currentMl,
            maxIntake: waterState.goalMl,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hydration',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.grey500,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${waterState.currentMl} / ${waterState.goalMl} ml',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                        ),
                      ],
                    ),
                    _CircularWaterProgress(progress: progress),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.water_drop_outlined,
                        size: 14,
                        color: AppTheme.successColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Left: ${waterState.remainingMl}ml',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Staying hydrated improves energy, brain function and overall health.',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.grey600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: waterState.loading
                        ? null
                        : () {
                            ref
                                .read(waterNotifierProvider(token).notifier)
                                .addWater();
                          },
                    onLongPress: waterState.loading
                        ? null
                        : () => ref
                              .read(waterNotifierProvider(token).notifier)
                              .removeWater(),
                    borderRadius: BorderRadius.circular(15),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            Color(0xFF8B2E42), // Slightly lighter maroon
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: waterState.loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Add 250 ml',
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
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

class _CircularWaterProgress extends StatelessWidget {
  final double progress;

  const _CircularWaterProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      height: 45,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.grey100,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryColor,
            ),
            strokeWidth: 4,
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterBottleGraphic extends StatelessWidget {
  final int currentIntake;
  final int maxIntake;

  const _WaterBottleGraphic({
    required this.currentIntake,
    required this.maxIntake,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (currentIntake / maxIntake).clamp(0.0, 1.0);

    return SizedBox(
      width: 80,
      height: 180,
      child: CustomPaint(painter: _BottlePainter(progress: progress)),
    );
  }
}

class _BottlePainter extends CustomPainter {
  final double progress;

  _BottlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bottleOutlinePaint = Paint()
      ..color = AppTheme.grey300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Paint fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    const double cornerRadius = 24.0;
    const double capWidth = 34.0;
    const double capHeight = 12.0;
    const double neckWidth = 42.0;
    const double neckHeight = 8.0;

    final Path bottlePath = Path();

    // Bottle Shape Construction
    // 1. Cap
    final RRect capRRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: Offset(size.width / 2, capHeight / 2),
        width: capWidth,
        height: capHeight,
      ),
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
    );
    bottlePath.addRRect(capRRect);

    // 2. Neck & Body
    final double bodyTop = capHeight + neckHeight;
    final Path bodyPath = Path();
    bodyPath.moveTo(size.width / 2 - neckWidth / 2, capHeight);
    bodyPath.lineTo(size.width / 2 + neckWidth / 2, capHeight);
    bodyPath.lineTo(size.width / 2 + neckWidth / 2, bodyTop);

    // Body curve to shoulders
    bodyPath.quadraticBezierTo(size.width, bodyTop, size.width, bodyTop + 20);
    bodyPath.lineTo(size.width, size.height - cornerRadius);
    bodyPath.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cornerRadius,
      size.height,
    );
    bodyPath.lineTo(cornerRadius, size.height);
    bodyPath.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    bodyPath.lineTo(0, bodyTop + 20);
    bodyPath.quadraticBezierTo(
      0,
      bodyTop,
      size.width / 2 - neckWidth / 2,
      bodyTop,
    );
    bodyPath.close();

    bottlePath.addPath(bodyPath, Offset.zero);

    // Draw Bottle Background/Outline
    canvas.drawPath(
      bottlePath,
      Paint()
        ..color = AppTheme.grey50
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(bottlePath, bottleOutlinePaint);

    // Filter logic: Only fill the body
    canvas.save();
    canvas.clipPath(bodyPath);

    final double fillHeight = progress * (size.height - bodyTop);
    final Rect fillRect = Rect.fromLTWH(
      0,
      size.height - fillHeight,
      size.width,
      fillHeight,
    );

    canvas.drawRect(fillRect, fillPaint);

    // Add glass highlights
    final Paint highlightPaint = Paint()
      ..color = AppTheme.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(size.width * 0.15, bodyTop + 30),
      Offset(size.width * 0.15, size.height - 40),
      highlightPaint..strokeCap = StrokeCap.round,
    );

    // Add Measurement lines
    final Paint linePaint = Paint()
      ..color = AppTheme.black.withOpacity(0.05)
      ..strokeWidth = 1;

    for (int i = 1; i < 4; i++) {
      double y = bodyTop + (size.height - bodyTop) * (i / 4);
      canvas.drawLine(
        Offset(size.width * 0.3, y),
        Offset(size.width * 0.7, y),
        linePaint,
      );
    }

    canvas.restore();

    // Draw Cap separately to keep it on top of fill
    canvas.drawRRect(
      capRRect,
      Paint()..color = AppTheme.primaryColor.withOpacity(0.8),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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

class _TodaysMealsSection extends ConsumerWidget {
  const _TodaysMealsSection();

  void _showManualLogModal(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    String selectedType = 'Breakfast';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Manual Food Log',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Food Name',
                  hintText: 'e.g. Grilled Chicken Salad',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Calories (kcal)',
                  hintText: 'e.g. 350',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Meal Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setModalState) {
                  return Wrap(
                    spacing: 8,
                    children: ['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((
                      type,
                    ) {
                      final isSelected = selectedType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => selectedType = type);
                          }
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.grey600,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        caloriesController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }

                    final calories = int.tryParse(caloriesController.text);
                    if (calories == null) return;

                    final success = await ref
                        .read(mealProvider.notifier)
                        .addMeal(
                          name: nameController.text,
                          calories: calories,
                          type: selectedType,
                        );

                    if (success) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Meal logged successfully!'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save Log'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsync = ref.watch(mealProvider);
    final totalCalories = ref.watch(totalCaloriesProvider);

    return mealsAsync.when(
      data: (meals) {
        if (meals.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.grey50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.grey200),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.restaurant_menu,
                  color: AppTheme.grey400,
                  size: 40,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No meals logged today',
                  style: TextStyle(
                    color: AppTheme.grey600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Scan food to add your first meal!',
                  style: TextStyle(color: AppTheme.grey500, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DailyMealLogScreen()),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  Color(0xFF8B2E42), // Slightly lighter maroon
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(
                    Icons.restaurant,
                    size: 100,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily Intake',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$totalCalories',
                          style: AppTheme.lightTheme.textTheme.headlineLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 42,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'kcal',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.insights_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${meals.length} meals logged',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => _showManualLogModal(context, ref),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppTheme.primaryColor,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
      error: (err, st) => Text('Error: $err'),
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
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CalorieScannerScreen()),
              );
            },
            child: _buildActionCard(
              Icons.camera_alt,
              'Scan Food',
              Colors.deepPurple,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NutritionChatScreen()),
              );
            },
            child: _buildActionCard(
              Icons.chat_bubble_outline,
              'AI Assistant',
              AppTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MealPlanScreen()));
            },
            child: _buildActionCard(
              Icons.restaurant_menu,
              'Meal Plan',
              Colors.teal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color color) {
    return Container(
      height: 80,
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
