import 'dart:convert';

class CalorieAnalysisResult {
  final List<FoodItem> foodItems;
  final int totalCalories;
  final int confidenceLevel;
  final String recommendations;
  final String? warning;

  CalorieAnalysisResult({
    required this.foodItems,
    required this.totalCalories,
    required this.confidenceLevel,
    required this.recommendations,
    this.warning,
  });

  factory CalorieAnalysisResult.fromGeminiResponse(String response) {
    try {
      // Clean the response to extract JSON
      String jsonString = response.trim();

      // Remove markdown code blocks if present
      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.substring(7);
      }
      if (jsonString.startsWith('```')) {
        jsonString = jsonString.substring(3);
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString.substring(0, jsonString.length - 3);
      }

      jsonString = jsonString.trim();

      final Map<String, dynamic> json = jsonDecode(jsonString);

      // Extract food items
      final foodItemsJson = json['food_items'] as List<dynamic>? ?? [];
      final foodItems = foodItemsJson
          .map((item) => FoodItem.fromJson(item as Map<String, dynamic>))
          .toList();

      // If no food items found, create a default one
      if (foodItems.isEmpty) {
        final totalCals = (json['total_calories'] as num?)?.toInt() ?? 200;
        foodItems.add(
          FoodItem(
            name: 'Detected Food',
            calories: totalCals,
            description: 'Food item from image analysis',
          ),
        );
      }

      return CalorieAnalysisResult(
        foodItems: foodItems,
        totalCalories:
            (json['total_calories'] as num?)?.toInt() ??
            foodItems.fold(0, (sum, item) => sum + item.calories),
        confidenceLevel: (json['analysis_confidence'] as num?)?.toInt() ?? 70,
        recommendations:
            json['recommendations'] as String? ??
            'Maintain a balanced diet with proper portion control.',
        warning: json['warning'] as String?,
      );
    } catch (e) {
      // Fallback: try to extract calorie numbers from text if JSON parsing fails
      final calorieRegex = RegExp(
        r'(\d+)\s*(?:cal|kcal)',
        caseSensitive: false,
      );
      final calorieMatches = calorieRegex.allMatches(response);

      int totalCalories = 200; // Default
      if (calorieMatches.isNotEmpty) {
        final calories = calorieMatches
            .map((m) => int.parse(m.group(1)!))
            .toList();
        totalCalories = calories.length == 1
            ? calories.first
            : calories.reduce((a, b) => a + b);
      }

      return CalorieAnalysisResult(
        foodItems: [
          FoodItem(
            name: 'Analyzed Food',
            calories: totalCalories,
            description: 'Food item analyzed from image',
          ),
        ],
        totalCalories: totalCalories,
        confidenceLevel: 60,
        recommendations:
            'Maintain a balanced diet with proper portion control.',
        warning:
            'Analysis used text extraction. For better accuracy, ensure clear food images.',
      );
    }
  }

  bool get isHighConfidence => confidenceLevel >= 70;
  bool get isMediumConfidence => confidenceLevel >= 40 && confidenceLevel < 70;
  bool get isLowConfidence => confidenceLevel < 40;

  String get confidenceDescription {
    if (isHighConfidence) return 'High confidence';
    if (isMediumConfidence) return 'Medium confidence';
    return 'Low confidence';
  }
}

class FoodItem {
  final String name;
  final int calories;
  final String description;

  FoodItem({
    required this.name,
    required this.calories,
    required this.description,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] ?? 'Unknown Food',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      description: json['description'] ?? '',
    );
  }
}
