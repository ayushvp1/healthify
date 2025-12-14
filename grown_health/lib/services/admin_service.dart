import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class AdminSummary {
  final int users;
  final int categories;
  final int exercises;
  final int workouts;
  final int meditations;
  final int nutrition;
  final int medicines;
  final int faqs;

  const AdminSummary({
    required this.users,
    required this.categories,
    required this.exercises,
    required this.workouts,
    required this.meditations,
    required this.nutrition,
    required this.medicines,
    required this.faqs,
  });

  factory AdminSummary.fromJson(Map<String, dynamic> json) {
    return AdminSummary(
      users: json['users'] as int? ?? 0,
      categories: json['categories'] as int? ?? 0,
      exercises: json['exercises'] as int? ?? 0,
      workouts: json['workouts'] as int? ?? 0,
      meditations: json['meditations'] as int? ?? 0,
      nutrition: json['nutrition'] as int? ?? 0,
      medicines: json['medicines'] as int? ?? 0,
      faqs: json['faqs'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users,
      'categories': categories,
      'exercises': exercises,
      'workouts': workouts,
      'meditations': meditations,
      'nutrition': nutrition,
      'medicines': medicines,
      'faqs': faqs,
    };
  }
}

class AdminService {
  final String? _token;

  AdminService(this._token);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// GET /api/admin/summary/ - Get counts for all entities (Admin only)
  Future<AdminSummary> getSummary() async {
    final uri = Uri.parse('$kBaseUrl/admin/summary');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return AdminSummary.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ??
            'Failed to get admin summary (${res.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get admin summary');
    }
  }
}
