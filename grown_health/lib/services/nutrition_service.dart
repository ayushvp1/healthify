import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

/// Model class for Nutrition/Recipe items
class NutritionItem {
  final String id;
  final String title;
  final String slug;
  final String description;
  final String type;
  final String image;
  final int calories;
  final int prepTime;
  final List<String> ingredients;
  final String instructions;
  final DateTime createdAt;

  NutritionItem({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.type,
    required this.image,
    required this.calories,
    required this.prepTime,
    required this.ingredients,
    required this.instructions,
    required this.createdAt,
  });

  factory NutritionItem.fromJson(Map<String, dynamic> json) {
    return NutritionItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'Recipe',
      image: json['image'] ?? '',
      calories: json['calories'] ?? 0,
      prepTime: json['prepTime'] ?? 0,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: json['instructions'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

/// Model class for logged meals
class MealLog {
  final String id;
  final String name;
  final int calories;
  final String type;
  final List<Map<String, dynamic>> items;
  final DateTime date;

  MealLog({
    required this.id,
    required this.name,
    required this.calories,
    required this.type,
    required this.items,
    required this.date,
  });

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      calories: json['calories'] ?? 0,
      type: json['type'] ?? 'Snack',
      items: List<Map<String, dynamic>>.from(json['items'] ?? []),
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
    );
  }
}

/// Service for nutrition-related API calls
class NutritionService {
  static const String _baseUrl = ApiConfig.baseUrl;

  /// Fetch the recipe of the day
  static Future<NutritionItem?> getRecipeOfTheDay() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/nutrition/recipe-of-the-day'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NutritionItem.fromJson(data);
      } else if (response.statusCode == 404) {
        // No recipes available
        return null;
      }
      return null;
    } catch (e) {
      print('Error fetching recipe of the day: $e');
      return null;
    }
  }

  /// Fetch all recipes with pagination
  static Future<List<NutritionItem>> getRecipes({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'type': 'Recipe',
        if (search != null && search.isNotEmpty) 'q': search,
      };

      final uri = Uri.parse(
        '$_baseUrl/nutrition',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final recipes = data['data'] as List<dynamic>;
        return recipes.map((json) => NutritionItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching recipes: $e');
      return [];
    }
  }

  /// Fetch a single recipe by ID
  static Future<NutritionItem?> getRecipeById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/nutrition/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NutritionItem.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching recipe: $e');
      return null;
    }
  }

  /// Log a new meal
  static Future<bool> logMeal({
    required String token,
    required String name,
    required int calories,
    String type = 'Snack',
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/meals/log'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'calories': calories,
          'type': type,
          'items': items ?? [],
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error logging meal: $e');
      return false;
    }
  }

  /// Fetch today's logged meals
  static Future<List<MealLog>> getTodayMeals(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/meals/today'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> mealsJson = data['data'] ?? [];
        return mealsJson.map((json) => MealLog.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching today meals: $e');
      return [];
    }
  }
}
