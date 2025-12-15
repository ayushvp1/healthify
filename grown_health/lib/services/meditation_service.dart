import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class MeditationService {
  final String? _token;

  MeditationService(this._token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// GET /api/meditations/ - List meditations (pagination supported)
  Future<Map<String, dynamic>> getMeditations({
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (category != null) 'category': category,
    };
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/meditations',
    ).replace(queryParameters: queryParams);

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ??
              'Failed to get meditations (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get meditations');
    }
  }

  /// GET /api/meditations/:id - Get single meditation
  Future<Map<String, dynamic>> getMeditationById(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/meditations/$id');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ??
              'Failed to get meditation (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get meditation');
    }
  }

  /// POST /api/meditations/history - Add to user meditation history
  Future<Map<String, dynamic>> addToHistory(
    String meditationId,
    int durationSeconds,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/meditations/history');

    try {
      final res = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'meditationId': meditationId,
          'durationSeconds': durationSeconds,
        }),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ??
              'Failed to add to history (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to add to history');
    }
  }

  /// GET /api/meditations/history - Get user's meditation history
  Future<List<Map<String, dynamic>>> getHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/meditations/history?page=$page&limit=$limit',
    );

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        if (data['data'] is List) {
          // Check if data is nested
          return (data['data'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        } else if (data is List) {
          return data.map((e) => e as Map<String, dynamic>).toList();
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

  /// GET /api/meditations/stats - Get user's meditation stats
  Future<Map<String, dynamic>> getStats() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/meditations/stats');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ?? 'Failed to get stats (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get stats');
    }
  }
}
