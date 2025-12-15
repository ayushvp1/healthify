import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? slug;

  const CategoryModel({required this.id, required this.name, this.slug});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
    );
  }
}

class CategoryService {
  Future<List<CategoryModel>> fetchCategories() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/categories');

    final res = await http.get(uri);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to load categories (${res.statusCode})');
    }

    final decoded = jsonDecode(res.body);

    if (decoded is Map<String, dynamic>) {
      final items = decoded['data'] ?? decoded['items'] ?? decoded['results'];
      if (items is List) {
        return items
            .whereType<Map<String, dynamic>>()
            .map(CategoryModel.fromJson)
            .toList();
      }
    } else if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList();
    }

    return const [];
  }
}
