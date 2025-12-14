import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../models/meditation_model.dart';

class MeditationService {
  final String? _token;

  MeditationService(this._token);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// GET /api/meditations/ - List meditations with pagination, search and category filter
  Future<MeditationListResponse> getMeditations({
    int page = 1,
    int limit = 10,
    String? searchQuery,
    String? categoryId,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (searchQuery != null && searchQuery.isNotEmpty) 'q': searchQuery,
      if (categoryId != null && categoryId.isNotEmpty) 'category': categoryId,
    };

    final uri = Uri.parse('$kBaseUrl/meditations')
        .replace(queryParameters: queryParams);

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return MeditationListResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ??
            'Failed to get meditations (${res.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get meditations');
    }
  }

  /// GET /api/meditations/:id - Get a single meditation by id
  Future<MeditationModel> getMeditationById(String id) async {
    final uri = Uri.parse('$kBaseUrl/meditations/$id');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return MeditationModel.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ??
            'Failed to get meditation (${res.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get meditation');
    }
  }

  /// POST /api/meditations/ - Create a meditation (Admin only)
  Future<MeditationModel> createMeditation(
      Map<String, dynamic> meditationData) async {
    final uri = Uri.parse('$kBaseUrl/meditations');

    try {
      final res = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(meditationData),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return MeditationModel.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ??
            'Failed to create meditation (${res.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to create meditation');
    }
  }

  /// PUT /api/meditations/:id - Update a meditation (Admin only)
  Future<MeditationModel> updateMeditation(
      String id, Map<String, dynamic> updates) async {
    final uri = Uri.parse('$kBaseUrl/meditations/$id');

    try {
      final res = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode(updates),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return MeditationModel.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ??
            'Failed to update meditation (${res.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to update meditation');
    }
  }

  /// DELETE /api/meditations/:id - Delete a meditation (Admin only)
  Future<void> deleteMeditation(String id) async {
    final uri = Uri.parse('$kBaseUrl/meditations/$id');

    try {
      final res = await http.delete(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return;
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ??
            'Failed to delete meditation (${res.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to delete meditation');
    }
  }
}
