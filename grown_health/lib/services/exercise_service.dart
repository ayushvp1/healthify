import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../models/exercise_model.dart'; // Ensure this model exists

class ExerciseService {
  final String? _token;

  ExerciseService(this._token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// GET /api/exercises/ - List exercises with pagination, search, category and difficulty filters
  Future<ExerciseListResponse> getExercises({
    int page = 1,
    int limit = 10,
    String? searchQuery,
    String? categoryId,
    String? difficulty,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (searchQuery != null && searchQuery.isNotEmpty) 'q': searchQuery,
      if (categoryId != null && categoryId.isNotEmpty) 'category': categoryId,
      if (difficulty != null && difficulty.isNotEmpty) 'difficulty': difficulty,
    };

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/exercises',
    ).replace(queryParameters: queryParams);

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return ExerciseListResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ?? 'Failed to get exercises (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get exercises');
    }
  }

  /// GET /api/exercises/:id - Get a single exercise by id
  Future<ExerciseModel> getExerciseById(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/exercises/$id');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return ExerciseModel.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ?? 'Failed to get exercise (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get exercise');
    }
  }

  /// POST /api/exercises/ - Create an exercise (Admin only)
  Future<ExerciseModel> createExercise({
    required String title,
    String? category,
    String? description,
    String? difficulty,
    int? duration,
    dynamic equipment,
    String? image,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/exercises');

    final body = <String, dynamic>{
      'title': title,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (difficulty != null) 'difficulty': difficulty,
      if (duration != null) 'duration': duration,
      if (equipment != null) 'equipment': equipment,
      if (image != null) 'image': image,
    };

    try {
      final res = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return ExerciseModel.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ??
              'Failed to create exercise (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to create exercise');
    }
  }

  /// PUT /api/exercises/:id - Update an exercise (Admin only)
  Future<ExerciseModel> updateExercise(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/exercises/$id');

    try {
      final res = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode(updates),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return ExerciseModel.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ??
              'Failed to update exercise (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to update exercise');
    }
  }

  /// DELETE /api/exercises/:id - Delete an exercise (Admin only)
  Future<void> deleteExercise(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/exercises/$id');

    try {
      final res = await http.delete(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return;
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ??
              'Failed to delete exercise (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to delete exercise');
    }
  }
}
