import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

/// Model for overall health score
class OverallScore {
  final int score;
  final int maxScore;
  final int percentage;
  final String level;

  const OverallScore({
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.level,
  });

  factory OverallScore.fromJson(Map<String, dynamic> json) {
    return OverallScore(
      score: json['score'] ?? 0,
      maxScore: json['maxScore'] ?? 0,
      percentage: json['percentage'] ?? 0,
      level: json['level'] ?? 'Unknown',
    );
  }
}

/// Model for category score
class CategoryScore {
  final String category;
  final int totalScore;
  final int maxScore;
  final int answeredCount;
  final int percentage;

  const CategoryScore({
    required this.category,
    required this.totalScore,
    required this.maxScore,
    required this.answeredCount,
    required this.percentage,
  });

  factory CategoryScore.fromJson(String category, Map<String, dynamic> json) {
    return CategoryScore(
      category: category,
      totalScore: json['totalScore'] ?? 0,
      maxScore: json['maxScore'] ?? 0,
      answeredCount: json['answeredCount'] ?? 0,
      percentage: json['percentage'] ?? 0,
    );
  }
}

/// Model for recommendation
class HealthRecommendation {
  final String category;
  final String priority;
  final String title;
  final String description;
  final String icon;

  const HealthRecommendation({
    required this.category,
    required this.priority,
    required this.title,
    required this.description,
    required this.icon,
  });

  factory HealthRecommendation.fromJson(Map<String, dynamic> json) {
    return HealthRecommendation(
      category: json['category'] ?? '',
      priority: json['priority'] ?? 'low',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'info',
    );
  }
}

/// Model for assessment results
class AssessmentResults {
  final OverallScore overallScore;
  final List<CategoryScore> categoryScores;
  final List<HealthRecommendation> recommendations;
  final DateTime? completedAt;
  final int totalQuestionsAnswered;

  const AssessmentResults({
    required this.overallScore,
    required this.categoryScores,
    required this.recommendations,
    this.completedAt,
    required this.totalQuestionsAnswered,
  });

  factory AssessmentResults.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    // Parse category scores
    final categoryScoresMap =
        data['categoryScores'] as Map<String, dynamic>? ?? {};
    final categoryScoresList = categoryScoresMap.entries.map((entry) {
      return CategoryScore.fromJson(
        entry.key,
        entry.value as Map<String, dynamic>,
      );
    }).toList();

    // Parse recommendations
    final recommendationsList =
        (data['recommendations'] as List<dynamic>? ?? [])
            .map(
              (r) => HealthRecommendation.fromJson(r as Map<String, dynamic>),
            )
            .toList();

    return AssessmentResults(
      overallScore: OverallScore.fromJson(
        data['overallScore'] as Map<String, dynamic>? ?? {},
      ),
      categoryScores: categoryScoresList,
      recommendations: recommendationsList,
      completedAt: data['completedAt'] != null
          ? DateTime.tryParse(data['completedAt'].toString())
          : null,
      totalQuestionsAnswered: data['totalQuestionsAnswered'] ?? 0,
    );
  }
}

/// Service for health assessment API calls
class HealthAssessmentService {
  final String? _token;

  HealthAssessmentService(this._token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// GET /api/health-assessment/results - Get assessment results with scores
  Future<AssessmentResults> getResults() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/health-assessment/results');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return AssessmentResults.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ?? 'Failed to get assessment results',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get assessment results');
    }
  }

  /// DELETE /api/health-assessment/reset - Reset assessment
  Future<void> resetAssessment() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/health-assessment/reset');

    try {
      final res = await http.delete(uri, headers: _headers);

      if (res.statusCode < 200 || res.statusCode >= 300) {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['message'] ?? 'Failed to reset assessment');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to reset assessment');
    }
  }
}
