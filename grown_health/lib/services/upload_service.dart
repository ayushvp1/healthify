import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class UploadService {
  final String? _token;

  UploadService(this._token);

  Map<String, String> get _authHeaders => {
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// POST /api/uploads/image - Upload an image to Cloudinary (Admin only)
  /// Returns the uploaded image URL
  Future<String> uploadImage(File imageFile) async {
    final uri = Uri.parse('$kBaseUrl/uploads/image');

    try {
      var request = http.MultipartRequest('POST', uri);
      
      // Add authorization header
      request.headers.addAll(_authHeaders);

      // Add the file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // Assuming the API returns the URL in a field like 'url' or 'imageUrl'
        return data['url'] as String? ?? 
               data['imageUrl'] as String? ?? 
               data['secure_url'] as String? ??
               '';
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to upload image (${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to upload image');
    }
  }

  /// Upload image from bytes (useful for web)
  Future<String> uploadImageFromBytes(
    List<int> imageBytes,
    String filename,
  ) async {
    final uri = Uri.parse('$kBaseUrl/uploads/image');

    try {
      var request = http.MultipartRequest('POST', uri);
      
      // Add authorization header
      request.headers.addAll(_authHeaders);

      // Add the file from bytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['url'] as String? ?? 
               data['imageUrl'] as String? ?? 
               data['secure_url'] as String? ??
               '';
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to upload image (${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to upload image');
    }
  }
}
