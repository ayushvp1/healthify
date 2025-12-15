import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class HealthMetricsModel {
  final String cholesterol;
  final String cholesterolUnit;
  final String bloodSugar;
  final String bloodSugarUnit;
  final String bloodSugarType;
  final String bloodPressure;
  final int? systolic;
  final int? diastolic;
  final DateTime? updatedAt;

  const HealthMetricsModel({
    this.cholesterol = '',
    this.cholesterolUnit = 'mg/dL',
    this.bloodSugar = '',
    this.bloodSugarUnit = 'mg/dL',
    this.bloodSugarType = 'fasting',
    this.bloodPressure = '',
    this.systolic,
    this.diastolic,
    this.updatedAt,
  });

  factory HealthMetricsModel.fromJson(Map<String, dynamic> json) {
    // Handle wrapped response
    final data =
        json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return HealthMetricsModel(
      cholesterol: data['cholesterol']?.toString() ?? '',
      cholesterolUnit: data['cholesterolUnit']?.toString() ?? 'mg/dL',
      bloodSugar: data['bloodSugar']?.toString() ?? '',
      bloodSugarUnit: data['bloodSugarUnit']?.toString() ?? 'mg/dL',
      bloodSugarType: data['bloodSugarType']?.toString() ?? 'fasting',
      bloodPressure: data['bloodPressure']?.toString() ?? '',
      systolic: data['systolic'] as int?,
      diastolic: data['diastolic'] as int?,
      updatedAt: data['updatedAt'] != null
          ? DateTime.tryParse(data['updatedAt'].toString())
          : null,
    );
  }

  String get cholesterolDisplay =>
      cholesterol.isEmpty ? 'Not set' : '$cholesterol $cholesterolUnit';
  String get bloodSugarDisplay =>
      bloodSugar.isEmpty ? 'Not set' : '$bloodSugar $bloodSugarUnit';
  String get bloodPressureDisplay =>
      bloodPressure.isEmpty ? 'Not set' : bloodPressure;
}

class HealthMetricsService {
  final String? _token;

  HealthMetricsService(this._token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// GET /api/health-metrics - Get current user's health metrics
  Future<HealthMetricsModel> getHealthMetrics() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/health-metrics/latest');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return HealthMetricsModel.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ??
              'Failed to get health metrics (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get health metrics');
    }
  }

  /// PUT /api/health-metrics - Update all health metrics
  Future<HealthMetricsModel> updateHealthMetrics({
    String? cholesterol,
    String? bloodSugar,
    String? bloodPressure,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/health-metrics');

    final body = <String, dynamic>{
      if (cholesterol != null) 'cholesterol': cholesterol,
      if (bloodSugar != null) 'bloodSugar': bloodSugar,
      if (bloodPressure != null) 'bloodPressure': bloodPressure,
    };

    try {
      final res = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return HealthMetricsModel.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ??
              'Failed to update health metrics (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to update health metrics');
    }
  }

  /// PATCH /api/health-metrics/:type - Update individual metric
  Future<void> updateMetric(String type, String value) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/health-metrics/$type');

    try {
      final res = await http.patch(
        uri,
        headers: _headers,
        body: jsonEncode({'value': value}),
      );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ?? 'Failed to update $type (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to update $type');
    }
  }
}
