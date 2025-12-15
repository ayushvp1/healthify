import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  late Future<List<dynamic>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = fetchRecipes();
  }

  Future<List<dynamic>> fetchRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('https://dummyjson.com/recipes?limit=10'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['recipes'];
      }
    } catch (e) {
      debugPrint("Error fetching recipes: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'Nutrition',
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFA03E4E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFFA03E4E),
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HydrationBatteryCard(),
              const SizedBox(height: 24),
              const _MacroNutrientsSummary(),
              const SizedBox(height: 24),
              _buildArticleSection(),
              const SizedBox(height: 24),
              const _RecipeOfTheDayCard(),
              const SizedBox(height: 24),
              const _MacroNutrientChartCard(title: 'Macronutrient Ratio'),
              const SizedBox(height: 24),
              _buildTodaysMeals(),
              const SizedBox(height: 24),
              const _MacroNutrientChartCard(
                title: 'Macronutrient Ratio',
                isSmall: true,
              ), // Placeholder for second chart in design
              const SizedBox(height: 24),
              const _HealthyHabitsSection(),
              const SizedBox(height: 24),
              const _NutritionTipsCarousel(),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildFeaturedFoods(),
              const SizedBox(height: 100), // Spacing for navbar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleSection() {
    return Row(
      children: [
        Expanded(
          child: _ArticleCard(
            title: 'Weight\nGain',
            imageColor: Colors.orange.shade100,
            icon: Icons.fitness_center,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ArticleCard(
            title: 'Weight\nLoss',
            imageColor: Colors.blue.shade100,
            icon: Icons.directions_run,
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysMeals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Meals",
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(
              child: _MealScanCard(
                title: 'Breakfast',
                subtitle: 'Avocado Toast',
                calories: '350 cal',
                isBreakfast: true,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _MealScanCard(
                title: 'Lunch',
                subtitle: 'Grilled Chicken',
                calories: '450 cal',
                isBreakfast: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1, // Near square
          children: [
            _QuickActionBtn(
              label: 'Scan Food',
              icon: Icons.camera_alt_rounded,
              color: const Color(0xFF7C4DFF), // Light Violet
              bgColor: const Color(
                0xFFF3E5F5,
              ), // Not used for background in new design, but kept for compatibility or icon bg
            ),
            _QuickActionBtn(
              label: 'Log Meal',
              icon: Icons.restaurant_menu_rounded,
              color: const Color(0xFF00ACC1), // Teal
              bgColor: const Color(0xFFE0F7FA),
            ),
            _QuickActionBtn(
              label: 'View History',
              icon: Icons.history, // Clock with arrow
              color: const Color(0xFF43A047), // Green
              bgColor: const Color(0xFFE8F5E9),
            ),
            _QuickActionBtn(
              label: 'Set Reminder',
              icon: Icons.notifications, // Bell
              color: const Color(0xFF039BE5), // Blue
              bgColor: const Color(0xFFE1F5FE),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturedFoods() {
    return FutureBuilder<List<dynamic>>(
      future: _recipesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // You might want a skeleton loader here,
          // but for now simple empty or loading indicator is okay,
          // or just return empty SizedBox to avoid layout shift if fast.
          return const Center(child: CircularProgressIndicator());
        }

        final recipes = snapshot.data!;
        // Simple logic: Take first 2 for featured
        final featured = recipes.take(2).toList();
        // Take next 2 that are "Medium" difficulty for the second section
        final mediumCalorie = recipes
            .where((r) => r['difficulty'] == 'Medium')
            .take(2)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Featured Foods",
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  "See all",
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA03E4E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...featured.map(
              (recipe) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _FoodListItem(
                  name: recipe['name'],
                  calorieLabel:
                      '${recipe['caloriesPerServing']} Cal • ${recipe['difficulty']}',
                  subtitle: recipe['cuisine'] ?? 'Healthy',
                  imageUrl: recipe['image'],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Medium Calorie Foods",
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...mediumCalorie.map(
              (recipe) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _FoodListItem(
                  name: recipe['name'],
                  calorieLabel:
                      '${recipe['caloriesPerServing']} Cal • ${recipe['difficulty']}',
                  subtitle: recipe['cuisine'] ?? 'Healthy',
                  imageUrl: recipe['image'],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HydrationBatteryCard extends StatelessWidget {
  const _HydrationBatteryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 24, 28), // Increased Padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36), // Slightly more rounded
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Battery Illustration
          SizedBox(
            height: 190, // Enlarge battery height
            width: 100, // Enlarge battery width
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Top Cap
                Container(
                  width: 44, // Wider cap
                  height: 14, // Taller cap
                  margin: const EdgeInsets.only(top: 2),
                  decoration: const BoxDecoration(
                    color: Color(0xFFC86B7B),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                ),
                // Main Body Outline
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: double.infinity,
                  height: 176, // Taller body
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE6B8C0),
                      width: 3.5,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Empty segments (Top 4)
                        _BatterySegment(filled: false),
                        _BatterySegment(filled: false),
                        _BatterySegment(filled: false),
                        _BatterySegment(filled: false),
                        // Filled segments (Bottom 4)
                        _BatterySegment(filled: true),
                        _BatterySegment(filled: true),
                        _BatterySegment(filled: true),
                        _BatterySegment(filled: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32), // More spacing
          // Text Content
          Expanded(
            child: SizedBox(
              height: 190, // Match battery height
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '0ml ',
                          style: GoogleFonts.inter(
                            fontSize: 26, // Larger text
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5B0C23), // Dark Maroon
                          ),
                        ),
                        TextSpan(
                          text: '/ 2000ml',
                          style: GoogleFonts.inter(
                            fontSize: 26, // Larger text
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5B0C23),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Remaining: 2000ml',
                    style: GoogleFonts.inter(
                      fontSize: 18, // Larger text
                      color: const Color(0xFF1E6F3E), // Dark Green
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Staying hydrated imporves energy, brain function and overall health',
                    style: GoogleFonts.inter(
                      fontSize: 14, // Slightly larger
                      color: Colors.grey.shade700,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 150, // Wider button
                    height: 50, // Taller button
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF1E6F3E),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, size: 22, color: Colors.black87),
                        const SizedBox(width: 8),
                        Text(
                          '200 ml',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1E6F3E),
                          ),
                        ),
                      ],
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

class _BatterySegment extends StatelessWidget {
  final bool filled;

  const _BatterySegment({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 15, // Slightly taller segments
      width: double.infinity,
      decoration: BoxDecoration(
        color: filled
            ? const Color(0xFFC84760)
            : Colors.transparent, // Filled: Darkish Pink
        border: filled
            ? null
            : Border.all(color: const Color(0xFFFFE0E6), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _MacroNutrientsSummary extends StatelessWidget {
  const _MacroNutrientsSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Macro Nutrients',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _MacroItem(
                label: 'Protein',
                value: '0/150g',
                percentage: '0%',
                icon: Icons.restaurant_menu,
                color: Color(0xFFE57373),
              ),
              _MacroItem(
                label: 'Carbs',
                value: '0/265g',
                percentage: '0%',
                icon: Icons.local_fire_department,
                color: Color(0xFFFFB74D),
              ),
              _MacroItem(
                label: 'Fats',
                value: '0/65g',
                percentage: '0%',
                icon: Icons.eco,
                color: Color(0xFF81C784),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final String value;
  final String percentage;
  final IconData icon;
  final Color color;

  const _MacroItem({
    required this.label,
    required this.value,
    required this.percentage,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          percentage,
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _RecipeOfTheDayCard extends StatelessWidget {
  const _RecipeOfTheDayCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recipe of the Day',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFA03E4E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      'View',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
          const SizedBox(height: 16),
          Text(
            'Avocado & Spinach Salad',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                size: 16,
                color: Color(0xFFA03E4E),
              ),
              const SizedBox(width: 4),
              Text(
                '180 cal',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time_filled,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '15 min',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroNutrientChartCard extends StatelessWidget {
  final String title;
  final bool isSmall;

  const _MacroNutrientChartCard({required this.title, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    if (isSmall) {
      // Placeholder for the smaller duplicate chart in the design
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: _DonutChartPainter(),
                      child: Center(
                        child: Text(
                          '55%',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _LegendItem(color: Color(0xFFA03E4E), label: 'Protein'),
                      _LegendItem(color: Color(0xFF2E7D32), label: 'Carbs'),
                      _LegendItem(color: Colors.black, label: 'Fat'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CustomPaint(
                  painter: _DonutChartPainter(),
                  child: Center(
                    child: Text(
                      '38%',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _LegendItem(color: Color(0xFFA03E4E), label: 'Protein'),
                  SizedBox(height: 12),
                  _LegendItem(color: Color(0xFF2E7D32), label: 'Carbs'),
                  SizedBox(height: 12),
                  _LegendItem(color: Colors.black, label: 'Fat'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 25.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Segment 1: Protein (Red) - 40%
    paint.color = const Color(0xFFA03E4E);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi / 2, // Start from bottom
      2 * math.pi * 0.40,
      false,
      paint,
    );

    // Segment 2: Fat (Black) - 35%
    paint.color = Colors.black;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi / 2 + (2 * math.pi * 0.40),
      2 * math.pi * 0.35,
      false,
      paint,
    );

    // Segment 3: Carbs (Green) - 25% (or remaining)
    paint.color = const Color(0xFF2E7D32); // Green
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi / 2 + (2 * math.pi * 0.75),
      2 * math.pi * 0.25,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArticleCard extends StatelessWidget {
  final String title;
  final Color imageColor;
  final IconData icon;

  const _ArticleCard({
    required this.title,
    required this.imageColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: imageColor,
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage(
                  'assets/images/profile_icon.png',
                ), // Placeholder
                fit: BoxFit.cover,
                opacity: 0.8,
              ),
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _MealScanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String calories;
  final bool isBreakfast;

  const _MealScanCard({
    required this.title,
    required this.subtitle,
    required this.calories,
    required this.isBreakfast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Icon Background
          _buildIcon(),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            calories,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isBreakfast
                  ? const Color(0xFFFBF4F6) // Light Pinkish BG
                  : const Color(0xFFE4ECE9), // Light Greenish BG
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isBreakfast
                          ? const Color(0xFF5B0C23) // Maroon
                          : const Color(0xFF1E6F3E), // Dark Green
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: isBreakfast
                        ? const Color(0xFF5B0C23)
                        : const Color(0xFF1E6F3E),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Log Meal',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isBreakfast
                        ? const Color(0xFF5B0C23)
                        : const Color(0xFF1E6F3E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (isBreakfast) {
      // Toast Icon
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF00C853), // Bright Green
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Bread Shape (simplified)
            const Icon(
              Icons.bakery_dining_rounded,
              color: Colors.white,
              size: 32,
            ),
            // Checkmark/Dot simulation
            Positioned(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Burger Icon
      return Container(
        width: 48,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Using a colored version of lunch icon
            const Icon(
              Icons.lunch_dining_rounded,
              color: Color(0xFF0091EA),
              size: 48,
            ), // Blue Burger
          ],
        ),
      );
    }
  }
}

class _HealthyHabitsSection extends StatelessWidget {
  const _HealthyHabitsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Healthy Habits',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _HabitCircle(
              label: '8h Sleep',
              icon: Icons.bedtime,
              progress: 0.7,
              color: Color(0xFF7986CB),
            ),
            _HabitCircle(
              label: 'Read Book',
              icon: Icons.book,
              progress: 0.4,
              color: Color(0xFFFFA726),
            ),
            _HabitCircle(
              label: 'Meditate',
              icon: Icons.self_improvement,
              progress: 0.8,
              color: Color(0xFF26A69A),
            ),
            _HabitCircle(
              label: '10k Steps',
              icon: Icons.directions_walk,
              progress: 0.3,
              color: Color(0xFF29B6F6),
            ),
          ],
        ),
      ],
    );
  }
}

class _HabitCircle extends StatelessWidget {
  final String label;
  final IconData icon;
  final double progress;
  final Color color;

  const _HabitCircle({
    required this.label,
    required this.icon,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Icon is colored only if the habit is "complete" or near complete.
    // Based on the image, inactive habits have grey icons.
    final bool isComplete = progress > 0.99;

    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200, // Light grey track
                valueColor: AlwaysStoppedAnimation(color),
                strokeWidth: 5, // Thicker stroke
                strokeCap: StrokeCap.round, // Rounded ends
              ),
              Center(
                child: Icon(
                  icon,
                  color: isComplete ? color : Colors.grey.shade600,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _NutritionTipsCarousel extends StatelessWidget {
  const _NutritionTipsCarousel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutrition Tips',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Container(
          height: 100,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'drinking at least 8 glasses of water daily',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              VerticalDivider(
                color: Colors.grey.shade200,
                thickness: 1,
                width: 32,
              ),
              Expanded(
                child: Text(
                  'Include protein in every meal to keep you full',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor; // Unused but kept for existing calls

  const _QuickActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32), // More rounded "squircle"
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 38, // Larger icon to match image scale
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodListItem extends StatelessWidget {
  final String name;
  final String calorieLabel;
  final String subtitle;
  final String? imageUrl;

  const _FoodListItem({
    required this.name,
    required this.calorieLabel,
    this.subtitle = '',
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: (imageUrl != null && imageUrl!.startsWith('http'))
                    ? NetworkImage(imageUrl!)
                    : const AssetImage('assets/images/profile_icon.png')
                          as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  calorieLabel,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
