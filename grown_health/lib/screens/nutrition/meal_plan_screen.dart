import 'dart:convert';
import 'package:flutter/material.dart';
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
      if (mounted) {
        setState(() {
          _generatedPlan = jsonDecode(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to generate plan. Please try again."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Meal Planner')),
      body: _isLoading
          ? _buildLoadingState()
          : _generatedPlan == null
          ? _buildSetupState()
          : _buildPlanState(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryColor),
          const SizedBox(height: 24),
          Text(
            'Crafting your personalized plan...',
            style: TextStyle(color: AppTheme.grey700, fontSize: 16),
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
          const Text(
            'Create Your Plan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us your goals and we\'ll build a perfect day of eating for you.',
            style: TextStyle(color: AppTheme.grey600),
          ),
          const SizedBox(height: 32),
          const Text(
            'How many meals per day?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [3, 4, 5, 6].map((n) {
              final isSelected = _mealsPerDay == n;
              return ChoiceChip(
                label: Text('$n Meals'),
                selected: isSelected,
                onSelected: (val) => setState(() => _mealsPerDay = n),
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.grey800,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'What is your primary goal?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _goals.map((g) {
              final isSelected = _goal == g;
              return ChoiceChip(
                label: Text(g),
                selected: isSelected,
                onSelected: (val) => setState(() => _goal = g),
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.grey800,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _generatePlan,
              child: const Text('Generate My Plan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanState() {
    final List meals = _generatedPlan!['meals'] ?? [];
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              return _MealPlanCard(meal: meal);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: OutlinedButton(
            onPressed: () => setState(() => _generatedPlan = null),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Create New Plan'),
          ),
        ),
      ],
    );
  }
}

class _MealPlanCard extends StatelessWidget {
  final Map<String, dynamic> meal;

  const _MealPlanCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final items = meal['items'] as List? ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                meal['name'] ?? 'Meal',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                meal['time'] ?? '',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item.toString())),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
