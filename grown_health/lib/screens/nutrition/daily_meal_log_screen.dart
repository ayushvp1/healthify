import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../services/nutrition_service.dart';
import '../../providers/auth_provider.dart';

class DailyMealLogScreen extends ConsumerStatefulWidget {
  const DailyMealLogScreen({super.key});

  @override
  ConsumerState<DailyMealLogScreen> createState() => _DailyMealLogScreenState();
}

class _DailyMealLogScreenState extends ConsumerState<DailyMealLogScreen> {
  List<MealLog> _meals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    final token = ref.read(authProvider).user?.token;
    if (token == null) return;

    final meals = await NutritionService.getTodayMeals(token);
    if (mounted) {
      setState(() {
        _meals = meals;
        _loading = false;
      });
    }
  }

  int get _totalCalories => _meals.fold(0, (sum, meal) => sum + meal.calories);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Daily Food Log'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : RefreshIndicator(
              onRefresh: _loadMeals,
              color: AppTheme.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 24),
                    Text(
                      'Logged Meals',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_meals.isEmpty)
                      _buildEmptyState()
                    else
                      ..._meals.map((meal) => _buildMealListItem(meal)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
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
      child: Column(
        children: [
          Text(
            'Total Calories Today',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_totalCalories',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'kcal',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.insights, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${_meals.length} meals logged',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealListItem(MealLog meal) {
    IconData icon;
    Color color;
    switch (meal.type) {
      case 'Breakfast':
        icon = Icons.breakfast_dining;
        color = Colors.orange;
        break;
      case 'Lunch':
        icon = Icons.lunch_dining;
        color = Colors.blue;
        break;
      case 'Dinner':
        icon = Icons.dinner_dining;
        color = Colors.indigo;
        break;
      default:
        icon = Icons.fastfood;
        color = Colors.teal;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      meal.type,
                      style: GoogleFonts.inter(
                        color: AppTheme.grey500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${meal.calories}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: GoogleFonts.inter(
                      color: AppTheme.grey500,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (meal.items.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            ...meal.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['name'] ?? '',
                      style: GoogleFonts.inter(
                        color: AppTheme.grey700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${item['calories']} kcal',
                      style: GoogleFonts.inter(
                        color: AppTheme.grey600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.grey50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu,
                color: AppTheme.grey400,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No food logged for today',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.grey700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use the scanner to track your nutrition!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppTheme.grey500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
