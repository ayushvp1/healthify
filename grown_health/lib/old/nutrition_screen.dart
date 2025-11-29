import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
              // Title row
              Row(
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
              ),
              const SizedBox(height: 24),
              // Hydration card
              _HydrationCard(),
              const SizedBox(height: 24),
              // Macro nutrients summary card
              _MacroNutrientsCard(),
              const SizedBox(height: 20),
              // Weight goal cards row
              Row(
                children: const [
                  Expanded(
                    child: _GoalCard(
                      title: 'Weight Gain',
                      color: Color(0xFFFFE0E0),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _GoalCard(
                      title: 'Weight Loss',
                      color: Color(0xFFE0F2FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Recipe of the Day
              _RecipeOfDayCard(),
              const SizedBox(height: 24),
              // Macronutrient ratio detailed card
              _MacroRatioCard(),
              const SizedBox(height: 24),
              // Today’s Meals
              Text(
                "Today’s Meals",
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
                    child: _MealCard(
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
                    child: _MealCard(
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
              const SizedBox(height: 24),
              // Healthy Habits
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
                    _HabitIcon(
                      label: '8 Glasses',
                      icon: Icons.local_drink_outlined,
                    ),
                    _HabitIcon(
                      label: 'Balanced Meal',
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
              const SizedBox(height: 24),
              // Nutrition Tips
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
                      text:
                          'Include protein in every meal to keep you full longer.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Pager dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Dot(active: true),
                  const SizedBox(width: 6),
                  _Dot(active: false),
                  const SizedBox(width: 6),
                  _Dot(active: false),
                  const SizedBox(width: 6),
                  _Dot(active: false),
                  const SizedBox(width: 6),
                  _Dot(active: false),
                ],
              ),
              const SizedBox(height: 24),
              // Quick Actions
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
                children: const [
                  _QuickActionCard(
                    label: 'Scan Food',
                    icon: Icons.qr_code_scanner,
                  ),
                  _QuickActionCard(
                    label: 'Log Meal',
                    icon: Icons.restaurant_menu_rounded,
                  ),
                  _QuickActionCard(
                    label: 'View History',
                    icon: Icons.history_rounded,
                  ),
                  _QuickActionCard(
                    label: 'Set Reminder',
                    icon: Icons.notifications_active_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Featured Foods header
              _SectionHeader(title: 'Featured Foods'),
              const SizedBox(height: 8),
              const _FoodListCard(),
              const SizedBox(height: 16),
              _SectionHeader(title: 'Medium Calorie Foods'),
              const SizedBox(height: 8),
              const _FoodListCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _HydrationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 9),
        ],
      ),
      child: Row(
        children: [
          // Left bottle image
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: SizedBox(
              width: 110,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.local_drink_rounded,
                  size: 48,
                  color: Color(0xFFAA3D50),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Right texts + button
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 20, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '0ml / 2000ml',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFAA3D50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Remaining: 2000ml',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Staying hydrated improves energy, brain function and overall health.',
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        color: Color(0xFF3B3B3B),
                      ),
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      side: const BorderSide(color: Colors.black, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18, color: Colors.black),
                    label: Text(
                      '200 ml',
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
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

class _MacroNutrientsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 9),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Macro Nutrients',
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _MacroItem(
                label: 'Protein',
                value: '0/150g',
                icon: Icons.close_rounded,
                iconColor: Color(0xFFAA3D50),
              ),
              _MacroItem(
                label: 'Carbs',
                value: '0/250g',
                icon: Icons.local_fire_department_rounded,
                iconColor: Colors.orange,
              ),
              _MacroItem(
                label: 'Fats',
                value: '0/65g',
                icon: Icons.water_drop_rounded,
                iconColor: Colors.amber,
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
  final IconData icon;
  final Color iconColor;

  const _MacroItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

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
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 7),
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

class _RecipeOfDayCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 7),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
}

class _MacroRatioCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 7),
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
                children: [
                  _LegendDot(color: const Color(0xFFAA3D50), label: 'Protein'),
                  const SizedBox(height: 8),
                  _LegendDot(color: Colors.white, border: true, label: 'Carbs'),
                  const SizedBox(height: 8),
                  _LegendDot(color: Colors.black, label: 'Fat'),
                ],
              ),
            ],
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

class _MealCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String calories;
  final String buttonLabel;
  final Color buttonColor;
  final Color chipColor;

  const _MealCard({
    required this.title,
    required this.subtitle,
    required this.calories,
    required this.buttonLabel,
    required this.buttonColor,
    required this.chipColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.13), blurRadius: 6),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.breakfast_dining_rounded),
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
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4C4C4C),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              calories,
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4C4C4C),
                ),
              ),
            ),
            const Spacer(),
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_note_rounded, size: 20, color: buttonColor),
                    const SizedBox(width: 6),
                    Text(
                      buttonLabel,
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: buttonColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6),
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
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(textStyle: const TextStyle(fontSize: 13)),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;

  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF6200ED) : const Color(0xFFE0E0E0),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;

  const _QuickActionCard({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFAA3D50)),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(textStyle: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          'See all',
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA44052),
            ),
          ),
        ),
      ],
    );
  }
}

class _FoodListCard extends StatelessWidget {
  const _FoodListCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            width: 87,
            height: 83,
            decoration: BoxDecoration(
              color: const Color(0xFF9E4B4B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_pizza_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'NT!',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '100 Cal',
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF4C4C4C),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4C4C4C),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Medium',
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF4C4C4C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Adjust your food',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4C4C4C),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
