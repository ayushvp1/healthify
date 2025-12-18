import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/nutrition_service.dart';
import 'auth_provider.dart';

class MealNotifier extends StateNotifier<AsyncValue<List<MealLog>>> {
  final String? token;

  MealNotifier(this.token) : super(const AsyncValue.loading()) {
    loadMeals();
  }

  Future<void> loadMeals() async {
    if (token == null) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final meals = await NutritionService.getTodayMeals(token!);
      state = AsyncValue.data(meals);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> addMeal({
    required String name,
    required int calories,
    String type = 'Snack',
    List<Map<String, dynamic>>? items,
  }) async {
    if (token == null) return false;

    try {
      final success = await NutritionService.logMeal(
        token: token!,
        name: name,
        calories: calories,
        type: type,
        items: items,
      );

      if (success) {
        await loadMeals();
      }
      return success;
    } catch (e) {
      return false;
    }
  Future<bool> deleteMeal(String id) async {
    if (token == null) return false;

    try {
      final success = await NutritionService.deleteMeal(token!, id);
      if (success) {
        await loadMeals();
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}

final mealProvider =
    StateNotifierProvider<MealNotifier, AsyncValue<List<MealLog>>>((ref) {
      final token = ref.watch(authProvider).user?.token;
      return MealNotifier(token);
    });

final totalCaloriesProvider = Provider<int>((ref) {
  final mealsAsync = ref.watch(mealProvider);
  return mealsAsync.maybeWhen(
    data: (meals) => meals.fold(0, (sum, meal) => sum + meal.calories),
    orElse: () => 0,
  );
});

final mealCountProvider = Provider<int>((ref) {
  final mealsAsync = ref.watch(mealProvider);
  return mealsAsync.maybeWhen(data: (meals) => meals.length, orElse: () => 0);
});
