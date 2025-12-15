import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class UploadService {
  final String? _token;

  UploadService(this._token);

  Future<String> uploadImage(File file) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/uploads/image');

    final request = http.MultipartRequest('POST', uri);

    // Add headers
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    // Critical for localtunnel
    request.headers['Bypass-Tunnel-Reminder'] = 'true';

    // Add file
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return data['url'] as String;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? 'Upload failed (${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error during upload: $e');
    }
  }

  Future<String> uploadImageFromBytes(List<int> bytes, String filename) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/uploads/image');
    final request = http.MultipartRequest('POST', uri);

    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    request.headers['Bypass-Tunnel-Reminder'] = 'true';

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return data['url'] as String;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? 'Upload failed (${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error during upload: $e');
    }
  }
}
