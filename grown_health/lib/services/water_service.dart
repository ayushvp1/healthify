import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class WaterService {
  final String? _token;

  WaterService(this._token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// GET /api/water/today - Get today's water intake
  Future<Map<String, dynamic>> getTodayWater() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/water/today');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic> && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        return {};
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ??
              'Failed to get water data (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get water data');
    }
  }

  /// POST /api/water/add - Add water intake
  Future<Map<String, dynamic>> addWater(int amountMl) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/water/add');

    try {
      final res = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode({'amount': amountMl}),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ?? 'Failed to add water (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to add water');
    }
  }

  /// POST /api/water/remove - Remove recent water intake (undo)
  Future<Map<String, dynamic>> removeWater() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/water/remove');

    try {
      final res = await http.post(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ?? 'Failed to remove water (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to remove water');
    }
  }

  /// PUT /api/water/goal - Update daily water goal
  Future<Map<String, dynamic>> updateGoal(int goalAmount) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/water/goal');

    try {
      final res = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode({'goal': goalAmount}),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ?? 'Failed to update goal (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to update goal');
    }
  }

  /// GET /api/water/history - Get water history (e.g. for charts)
  Future<List<Map<String, dynamic>>> getWaterHistory({int days = 7}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/water/history?days=$days');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        if (data['data'] is List) {
          return (data['data'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
        return [];
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ?? 'Failed to get history (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get history');
    }
  }

  // Compatibility methods for existing UI widgets
  Future<WaterTodayResponse> getTodayWaterIntake() async {
    final data = await getTodayWater();
    return WaterTodayResponse.fromJson(data);
  }

  Future<WaterTodayResponse> addWaterGlass() async {
    final data = await addWater(250);
    return WaterTodayResponse.fromJson(data);
  }

  Future<WaterTodayResponse> removeWaterGlass() async {
    final data = await removeWater();
    return WaterTodayResponse.fromJson(data);
  }

  Future<WaterTodayResponse> setWaterGoal(int goalGlasses) async {
    final data = await updateGoal(goalGlasses * 250);
    return WaterTodayResponse.fromJson(data);
  }
}

class WaterTodayResponse {
  final int amountMl;
  final int goalMl;

  WaterTodayResponse({required this.amountMl, required this.goalMl});

  factory WaterTodayResponse.fromJson(Map<String, dynamic> json) {
    return WaterTodayResponse(
      amountMl: json['amount'] as int? ?? 0,
      goalMl: json['goal'] as int? ?? 2000,
    );
  }

  // Getters expected by UI
  int get count => (amountMl / 250).round();
  int get goal => (goalMl / 250).round();
  bool get isCompleted => amountMl >= goalMl;
  int get remaining => ((goalMl - amountMl) / 250).round().clamp(0, 99);
}
