import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../models/water_intake_model.dart';

class WaterService {
  final String? _token;

  WaterService(this._token);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// GET /api/water/goal - Get user's daily water goal (number of glasses)
  Future<int> getWaterGoal() async {
    final uri = Uri.parse('$kBaseUrl/water/goal');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['goal'] as int;
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ??
            'Failed to get water goal (${res.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get water goal');
    }
  }

  /// PUT /api/water/goal - Set user's daily water goal
  Future<Map<String, dynamic>> setWaterGoal(int goal) async {
    final uri = Uri.parse('$kBaseUrl/water/goal');

    final body = {'goal': goal};

    try {
      final res = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ??
            'Failed to set water goal (${res.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to set water goal');
    }
  }

  /// GET /api/water/today - Get today's water intake progress
  Future<WaterTodayResponse> getTodayWaterIntake() async {
    final uri = Uri.parse('$kBaseUrl/water/today');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return WaterTodayResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ??
            'Failed to get today\'s water intake (${res.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get today\'s water intake');
    }
  }

  /// POST /api/water/drink - Add one glass of water (+1)
  Future<WaterTodayResponse> addWaterGlass() async {
    final uri = Uri.parse('$kBaseUrl/water/drink');

    try {
      final res = await http.post(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return WaterTodayResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ??
            'Failed to add water glass (${res.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to add water glass');
    }
  }

  /// DELETE /api/water/drink - Remove one glass of water (-1)
  Future<WaterTodayResponse> removeWaterGlass() async {
    final uri = Uri.parse('$kBaseUrl/water/drink');

    try {
      final res = await http.delete(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return WaterTodayResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ??
            'Failed to remove water glass (${res.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to remove water glass');
    }
  }

  /// PUT /api/water/today - Set today's water count to a specific value
  Future<WaterTodayResponse> setTodayWaterCount(int count) async {
    final uri = Uri.parse('$kBaseUrl/water/today');

    final body = {'count': count};

    try {
      final res = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return WaterTodayResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ??
            'Failed to set water count (${res.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to set water count');
    }
  }

  /// GET /api/water/history - Get water intake history for calendar/graph view
  Future<WaterHistoryResponse> getWaterHistory({
    int? days,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      if (days != null) 'days': days.toString(),
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };

    final uri = Uri.parse('$kBaseUrl/water/history')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return WaterHistoryResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ??
            'Failed to get water history (${res.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get water history');
    }
  }

  /// GET /api/water/date/:date - Get water intake for a specific date
  Future<WaterIntakeModel> getWaterIntakeByDate(String date) async {
    final uri = Uri.parse('$kBaseUrl/water/date/$date');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return WaterIntakeModel.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ??
            'Failed to get water intake for date (${res.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get water intake for date');
    }
  }
}
