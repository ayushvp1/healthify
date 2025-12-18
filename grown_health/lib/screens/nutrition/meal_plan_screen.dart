import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grown_health/core/constants/app_theme.dart';
import 'package:grown_health/services/gemini_service.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  int _mealsPerDay = 3;
  String _goal = "Weight Loss";
  bool _isLoading = false;
  Map<String, dynamic>? _generatedPlan;

  final List<String> _goals = [
    "Weight Loss",
    "Muscle Gain",
    "Maintenance",
    "General Health",
  ];

  Future<void> _generatePlan() async {
    setState(() => _isLoading = true);
    try {
      final response = await GeminiService.generateFoodPlan(
        mealsPerDay: _mealsPerDay,
        goal: _goal,
      );

      // Basic cleaning for potential AI markdown wrapping
      String cleanJson = response.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }

      if (mounted) {
        setState(() {
          _generatedPlan = jsonDecode(cleanJson);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Generation error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.primaryColor,
            content: Text(
              "Failed to generate plan. Please try again.",
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: Text(
          'AI MEAL PLANNER',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _isLoading
            ? _buildLoadingState()
            : _generatedPlan == null
            ? _buildSetupState()
            : _buildPlanState(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SpinKitDoubleBounce(color: AppTheme.primaryColor, size: 80.0),
          const SizedBox(height: 32),
          Text(
            'CRAFTING YOUR PLAN',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Calculating calories & choosing recipes...',
            style: GoogleFonts.inter(color: AppTheme.grey600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Precision',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        'Optimized nutrition based on your goal.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'MEALS PER DAY',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: AppTheme.grey500,
            ),
          ),
          const SizedBox(height: 16),
          _buildMealCountPicker(),
          const SizedBox(height: 32),
          Text(
            'PRIMARY GOAL',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: AppTheme.grey500,
            ),
          ),
          const SizedBox(height: 16),
          _buildGoalPicker(),
          const SizedBox(height: 50),
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildMealCountPicker() {
    return Row(
      children: [3, 4, 5, 6].map((n) {
        final isSelected = _mealsPerDay == n;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _mealsPerDay = n),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.grey200,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  '$n',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppTheme.grey800,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoalPicker() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _goals.map((g) {
        final isSelected = _goal == g;
        return GestureDetector(
          onTap: () => setState(() => _goal = g),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : AppTheme.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : AppTheme.grey200,
              ),
            ),
            child: Text(
              g,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.grey800,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenerateButton() {
    return InkWell(
      onTap: _generatePlan,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.black,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.rocket_launch_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'GENERATE PLAN',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanHeader() {
    final calories = _generatedPlan?['total_calories'] ?? 0;
    final summary = _generatedPlan?['goal_summary'] ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.black,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Target',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '$calories kcal',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              summary,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanState() {
    final List meals = _generatedPlan!['meals'] ?? [];
    return Column(
      children: [
        _buildPlanHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              return _MealPlanCard(meal: meals[index], index: index);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: TextButton(
            onPressed: () => setState(() => _generatedPlan = null),
            child: Text(
              'Reset & Create New Plan',
              style: GoogleFonts.inter(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MealPlanCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final int index;

  const _MealPlanCard({required this.meal, required this.index});

  @override
  Widget build(BuildContext context) {
    final items = meal['items'] as List? ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 8, color: AppTheme.primaryColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            meal['name']?.toUpperCase() ?? 'MEAL',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppTheme.primaryColor,
                              letterSpacing: 1,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.grey100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              meal['time'] ?? '',
                              style: GoogleFonts.inter(
                                color: AppTheme.grey700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${meal['calories'] ?? 0} kcal',
                        style: GoogleFonts.inter(
                          color: AppTheme.grey500,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item is Map
                                          ? item['name']
                                          : item.toString(),
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppTheme.black,
                                      ),
                                    ),
                                    if (item is Map &&
                                        item['description'] != null)
                                      Text(
                                        item['description'],
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppTheme.grey600,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
