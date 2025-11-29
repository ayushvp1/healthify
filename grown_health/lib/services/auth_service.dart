import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../api_config.dart';

class AuthService {
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$kBaseUrl/auth/login');
    
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final token = data['token'] as String?;
        if (token == null) {
          throw Exception('Login succeeded but no token returned');
        }
        return token;
      } else {
        String message = 'Login failed';
        try {
          final data = jsonDecode(res.body);
          if (data is Map<String, dynamic> && data['message'] != null) {
            message = data['message'].toString();
          } else {
            message = 'Login failed (${res.statusCode}): ${res.body}';
          }
        } catch (_) {
          message = 'Login failed (${res.statusCode}): ${res.body}';
        }
        throw Exception(message);
      }
    } catch (e) {
      if (e.toString().contains('ClientException') || 
          e.toString().contains('Failed to fetch') ||
          e.toString().contains('XMLHttpRequest')) {
        if (kIsWeb) {
          throw Exception('Network error: CORS issue. The API server needs to allow requests from this origin.');
        }
        throw Exception('Network error: Unable to connect to server. Check your internet connection.');
      }
      rethrow;
    }
  }

  Future<String> register({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$kBaseUrl/auth/register');
    
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final token = data['token'] as String?;
        if (token != null) {
          return token;
        }
        return '';
      } else {
        String message = 'Signup failed';
        try {
          final data = jsonDecode(res.body);
          if (data is Map<String, dynamic> && data['message'] != null) {
            message = data['message'].toString();
          } else {
            message = 'Signup failed (${res.statusCode}): ${res.body}';
          }
        } catch (_) {
          message = 'Signup failed (${res.statusCode}): ${res.body}';
        }
        throw Exception(message);
      }
    } catch (e) {
      if (e.toString().contains('ClientException') || 
          e.toString().contains('Failed to fetch') ||
          e.toString().contains('XMLHttpRequest')) {
        if (kIsWeb) {
          throw Exception('Network error: CORS issue. The API server needs to allow requests from this origin.');
        }
        throw Exception('Network error: Unable to connect to server. Check your internet connection.');
      }
      rethrow;
    }
  }
}
