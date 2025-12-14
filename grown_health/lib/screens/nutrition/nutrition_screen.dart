import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/widgets.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              const HydrationCard(),
              const SizedBox(height: 24),
              const MacroNutrientsCard(),
              const SizedBox(height: 20),
              _buildGoalCards(),
              const SizedBox(height: 24),
              _buildRecipeOfDay(context),
              const SizedBox(height: 24),
              _buildMacroRatio(),
              const SizedBox(height: 24),
              _buildTodaysMeals(),
              const SizedBox(height: 24),
              _buildHealthyHabits(),
              const SizedBox(height: 24),
              _buildNutritionTips(),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Nutrition',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const CircleAvatar(radius: 17, backgroundColor: Colors.grey),
      ],
    );
  }

  Widget _buildGoalCards() {
    return Row(
      children: const [
        Expanded(
          child: _GoalCard(title: 'Weight Gain', color: Color(0xFFFFE0E0)),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _GoalCard(title: 'Weight Loss', color: Color(0xFFE0F2FF)),
        ),
      ],
    );
  }

  Widget _buildRecipeOfDay(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 7),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            right: 190,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: Colors.deepOrange,
                size: 40,
              ),
            ),
          ),
          Positioned(
            left: 150,
            top: 28,
            child: Text(
              'Recipe of the Day',
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 24,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recipe details coming soon!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFAA3D50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'View',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 150,
            top: 80,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avocado & Spinach Salad',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '180 cal',
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.timer_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '15 min',
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRatio() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 7),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Macronutrient Ratio',
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 150,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 130,
                          height: 130,
                          child: CircularProgressIndicator(
                            value: 0.6,
                            strokeWidth: 18,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFFAA3D50),
                            ),
                          ),
                        ),
                        Text(
                          '60%',
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _LegendDot(color: Color(0xFFAA3D50), label: 'Protein'),
                  SizedBox(height: 8),
                  _LegendDot(color: Colors.white, border: true, label: 'Carbs'),
                  SizedBox(height: 8),
                  _LegendDot(color: Colors.black, label: 'Fat'),
                ],
              ),
            ],
          ),
        ],
      ),
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
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(
              child: MealCard(
                title: 'Breakfast',
                subtitle: 'Avocado Toast',
                calories: '350 cal',
                buttonLabel: 'Log Meal',
                buttonColor: Color(0xFF4CB050),
                chipColor: Color(0xFFEDF7EE),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: MealCard(
                title: 'Lunch',
                subtitle: 'Grilled Chicken',
                calories: '450 cal',
                buttonLabel: 'Log Meal',
                buttonColor: Color(0xFF3192DF),
                chipColor: Color(0xFFE8F5FE),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthyHabits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Healthy Habits',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _HabitIcon(label: '8 Glasses', icon: Icons.local_drink_outlined),
              _HabitIcon(
                label: 'Balanced',
                icon: Icons.emoji_food_beverage_outlined,
              ),
              _HabitIcon(
                label: 'Walk 30m',
                icon: Icons.directions_walk_rounded,
              ),
              _HabitIcon(label: 'Sleep 7h', icon: Icons.bedtime_outlined),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutrition Tips',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Expanded(
              child: _TipCard(
                text:
                    'Drinking at least 8 glasses of water daily improves digestion.',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _TipCard(
                text: 'Include protein in every meal to keep you full longer.',
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
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            QuickActionCard(
              label: 'Scan Food',
              icon: Icons.qr_code_scanner,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Food scanner coming soon!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            QuickActionCard(
              label: 'Log Meal',
              icon: Icons.restaurant_menu_rounded,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Meal logging coming soon!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            QuickActionCard(
              label: 'View History',
              icon: Icons.history_rounded,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nutrition history coming soon!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            QuickActionCard(
              label: 'Set Reminder',
              icon: Icons.notifications_active_rounded,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nutrition reminders coming soon!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

// Private widgets that are only used in this screen
class _GoalCard extends StatelessWidget {
  final String title;
  final Color color;

  const _GoalCard({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 7),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fastfood_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final bool border;
  final String label;

  const _LegendDot({
    required this.color,
    this.border = false,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 17,
          height: 17,
          decoration: BoxDecoration(
            color: color,
            border: border ? Border.all(color: Colors.black26) : null,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: GoogleFonts.inter(textStyle: const TextStyle(fontSize: 17)),
        ),
      ],
    );
  }
}

class _HabitIcon extends StatelessWidget {
  final String label;
  final IconData icon;

  const _HabitIcon({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              const BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.08),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFFAA3D50)),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 72,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(textStyle: const TextStyle(fontSize: 11)),
          ),
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  final String text;

  const _TipCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 6),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(textStyle: const TextStyle(fontSize: 13)),
      ),
    );
  }
}
