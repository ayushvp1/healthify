import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../models/profile_model.dart';

class ProfileService {
  final String? _token;

  ProfileService(this._token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// GET /api/profile/ - Get current user's full profile
  Future<ProfileModel> getProfile() async {
    final uri = Uri.parse('$kBaseUrl/profile');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return ProfileModel.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ?? 'Failed to get profile (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get profile');
    }
  }

  /// POST /api/profile/complete - Complete profile after registration
  /// Required fields: name, age, gender, weight
  Future<ProfileModel> completeProfile({
    required String name,
    required int age,
    required String gender,
    required double weight,
    double? height,
    String? fitnessGoal,
  }) async {
    final uri = Uri.parse('$kBaseUrl/profile/complete');

    final body = {
      'name': name,
      'age': age,
      'gender': gender,
      'weight': weight,
      if (height != null) 'height': height,
      if (fitnessGoal != null) 'fitnessGoal': fitnessGoal,
    };

    try {
      final res = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );

      debugPrint('📝 Complete Profile Response: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return ProfileModel.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ??
              'Failed to complete profile (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to complete profile');
    }
  }

  /// PUT /api/profile/ - Update profile fields (partial update supported)
  Future<ProfileModel> updateProfile({
    String? name,
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? fitnessGoal,
    String? profileImage,
  }) async {
    final uri = Uri.parse('$kBaseUrl/profile');

    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (fitnessGoal != null) 'fitnessGoal': fitnessGoal,
      if (profileImage != null) 'profileImage': profileImage,
    };

    try {
      final res = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return ProfileModel.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ??
              'Failed to update profile (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to update profile');
    }
  }

  /// PUT /api/profile/image - Update profile image URL only
  Future<ProfileModel> updateProfileImage(String profileImageUrl) async {
    final uri = Uri.parse('$kBaseUrl/profile/image');

    final body = {'profileImage': profileImageUrl};

    try {
      final res = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return ProfileModel.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ??
              'Failed to update profile image (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to update profile image');
    }
  }

  /// GET /api/profile/status - Check if user has completed profile setup
  Future<Map<String, dynamic>> getProfileStatus() async {
    final uri = Uri.parse('$kBaseUrl/profile/status');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ??
              'Failed to get profile status (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get profile status');
    }
  }
}
