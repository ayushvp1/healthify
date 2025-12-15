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
  Future<WaterTodayResponse> getTodayWaterIntake() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/water/today');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic> && data['data'] != null) {
          return WaterTodayResponse.fromJson(data['data']);
        }
        return WaterTodayResponse(count: 0, goal: 8);
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

  /// POST /api/water/drink - Add one glass of water (+1)
  Future<WaterTodayResponse> addWaterGlass() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/water/drink');

    try {
      final res = await http.post(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        return WaterTodayResponse.fromJson(data['data']);
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

  /// DELETE /api/water/drink - Remove one glass of water (-1)
  Future<WaterTodayResponse> removeWaterGlass() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/water/drink');

    try {
      final res = await http.delete(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        return WaterTodayResponse.fromJson(data['data']);
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

  /// PUT /api/water/goal - Update daily water goal (in glasses)
  Future<void> setWaterGoal(int goalGlasses) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/water/goal');

    try {
      final res = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode({'goal': goalGlasses}),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return; // Success
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

  /// GET /api/water/history - Get water history for analytics
  /// Returns history data with summary statistics
  Future<WaterHistoryResponse> getWaterHistory({int days = 30}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/water/history?days=$days');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        return WaterHistoryResponse.fromJson(data['data']);
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

  /// GET /api/water/history with custom date range for monthly analytics
  Future<WaterHistoryResponse> getMonthlyHistory({
    required String startDate,
    required String endDate,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/water/history?startDate=$startDate&endDate=$endDate',
    );

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        return WaterHistoryResponse.fromJson(data['data']);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ??
              'Failed to get monthly history (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get monthly history');
    }
  }
}

/// Response model for today's water intake
class WaterTodayResponse {
  final String date;
  final int count; // number of glasses drunk today
  final int goal; // daily goal in glasses
  final int percentage;
  final int remaining;
  final bool isCompleted;

  WaterTodayResponse({
    this.date = '',
    required this.count,
    required this.goal,
    this.percentage = 0,
    this.remaining = 0,
    this.isCompleted = false,
  });

  factory WaterTodayResponse.fromJson(Map<String, dynamic> json) {
    final count = json['count'] as int? ?? 0;
    final goal = json['goal'] as int? ?? 8;

    return WaterTodayResponse(
      date: json['date'] as String? ?? '',
      count: count,
      goal: goal,
      percentage: json['percentage'] as int? ?? 0,
      remaining: json['remaining'] as int? ?? (goal - count).clamp(0, 99),
      isCompleted: json['completed'] as bool? ?? (count >= goal),
    );
  }
}

/// Response model for water history (for analytics)
class WaterHistoryResponse {
  final List<WaterDayRecord> history;
  final WaterSummary summary;

  WaterHistoryResponse({required this.history, required this.summary});

  factory WaterHistoryResponse.fromJson(Map<String, dynamic> json) {
    final historyList =
        (json['history'] as List?)
            ?.map((e) => WaterDayRecord.fromJson(e))
            .toList() ??
        [];

    return WaterHistoryResponse(
      history: historyList,
      summary: WaterSummary.fromJson(json['summary'] ?? {}),
    );
  }
}

/// Single day record in history
class WaterDayRecord {
  final String date;
  final int count;
  final int goal;
  final int percentage;
  final bool completed;

  WaterDayRecord({
    required this.date,
    required this.count,
    required this.goal,
    required this.percentage,
    required this.completed,
  });

  factory WaterDayRecord.fromJson(Map<String, dynamic> json) {
    return WaterDayRecord(
      date: json['date'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      goal: json['goal'] as int? ?? 8,
      percentage: json['percentage'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
    );
  }
}

/// Summary statistics for water history
class WaterSummary {
  final String startDate;
  final String endDate;
  final int totalDays;
  final int daysWithData;
  final int completedDays;
  final int completionRate; // percentage
  final int totalGlasses;
  final double averagePerDay;

  WaterSummary({
    this.startDate = '',
    this.endDate = '',
    this.totalDays = 0,
    this.daysWithData = 0,
    this.completedDays = 0,
    this.completionRate = 0,
    this.totalGlasses = 0,
    this.averagePerDay = 0.0,
  });

  factory WaterSummary.fromJson(Map<String, dynamic> json) {
    return WaterSummary(
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      totalDays: json['totalDays'] as int? ?? 0,
      daysWithData: json['daysWithData'] as int? ?? 0,
      completedDays: json['completedDays'] as int? ?? 0,
      completionRate: json['completionRate'] as int? ?? 0,
      totalGlasses: json['totalGlasses'] as int? ?? 0,
      averagePerDay: (json['averagePerDay'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
