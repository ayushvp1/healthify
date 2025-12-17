import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class ExerciseBundleService {
  final String? _token;

  ExerciseBundleService(this._token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// GET /api/exercise-bundles - List all bundles
  Future<BundleListResponse> getBundles({
    int page = 1,
    int limit = 10,
    String? query,
    String? difficulty,
    String? category,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'published': 'true', // Only show published bundles
    };

    if (query != null && query.isNotEmpty) params['q'] = query;
    if (difficulty != null) params['difficulty'] = difficulty;
    if (category != null) params['category'] = category;

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/exercise-bundles',
    ).replace(queryParameters: params);

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        return BundleListResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ?? 'Failed to get bundles (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get bundles');
    }
  }

  /// GET /api/exercise-bundles/:id - Get single bundle with full details
  Future<ExerciseBundle> getBundleById(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/exercise-bundles/$id');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        return ExerciseBundle.fromJson(data['data']);
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ?? 'Failed to get bundle (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to get bundle');
    }
  }

  /// GET /api/workout-progress/program/:programId - Get user's progress in a bundle
  Future<BundleProgress> getBundleProgress(String bundleId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/workout-progress/program/$bundleId',
    );

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        return BundleProgress.fromJson(data['data']);
      } else {
        // If 404, user hasn't started this program yet
        return BundleProgress(
          totalDays: 0,
          completedDays: 0,
          progressPercentage: 0,
          dayStatus: {},
        );
      }
    } catch (e) {
      // Return empty progress on error
      return BundleProgress(
        totalDays: 0,
        completedDays: 0,
        progressPercentage: 0,
        dayStatus: {},
      );
    }
  }

  /// POST /api/workout-progress/start - Start a workout session
  Future<Map<String, dynamic>> startWorkout({
    required String programId,
    required int day,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/workout-progress/start');

    try {
      final res = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode({'programId': programId, 'day': day}),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        return data['data'];
      } else {
        final errorData = jsonDecode(res.body);
        throw Exception(
          errorData['message'] ?? 'Failed to start workout (${res.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to start workout');
    }
  }

  /// GET /api/workout-progress/current - Get active workout session
  Future<ActiveSession?> getCurrentSession() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/workout-progress/current');

    try {
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        if (data['data'] == null) {
          return null; // No active session
        }
        return ActiveSession.fromJson(data['data']);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

// ============ MODELS ============

class BundleListResponse {
  final List<ExerciseBundle> bundles;
  final int total;
  final int page;
  final int limit;
  final int pages;

  BundleListResponse({
    required this.bundles,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory BundleListResponse.fromJson(Map<String, dynamic> json) {
    return BundleListResponse(
      bundles:
          (json['data'] as List?)
              ?.map((e) => ExerciseBundle.fromJson(e))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      pages: json['pages'] as int? ?? 1,
    );
  }
}

class ExerciseBundle {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String thumbnail;
  final String difficulty;
  final int totalDays;
  final List<BundleDay> schedule;
  final BundleCategory? category;
  final List<String> tags;
  final bool isPublished;

  ExerciseBundle({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.thumbnail,
    required this.difficulty,
    required this.totalDays,
    required this.schedule,
    this.category,
    required this.tags,
    required this.isPublished,
  });

  factory ExerciseBundle.fromJson(Map<String, dynamic> json) {
    return ExerciseBundle(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'beginner',
      totalDays: json['totalDays'] as int? ?? 1,
      schedule:
          (json['schedule'] as List?)
              ?.map((e) => BundleDay.fromJson(e))
              .toList() ??
          [],
      category: json['category'] != null
          ? BundleCategory.fromJson(json['category'])
          : null,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isPublished: json['isPublished'] as bool? ?? false,
    );
  }

  /// Get total exercise count across all days
  int get totalExercises {
    int count = 0;
    for (final day in schedule) {
      if (!day.isRestDay) {
        count += day.exercises.length;
      }
    }
    return count;
  }

  /// Get estimated total duration in minutes
  int get estimatedDuration {
    int seconds = 0;
    for (final day in schedule) {
      for (final ex in day.exercises) {
        seconds += ex.duration;
      }
    }
    return (seconds / 60).ceil();
  }

  /// Get difficulty display text
  String get difficultyDisplay {
    switch (difficulty) {
      case 'beginner':
        return 'BEGINNER';
      case 'intermediate':
        return 'INTERMEDIATE';
      case 'advanced':
        return 'ADVANCED';
      default:
        return difficulty.toUpperCase();
    }
  }
}

class BundleDay {
  final int day;
  final bool isRestDay;
  final String title;
  final List<BundleDayExercise> exercises;

  BundleDay({
    required this.day,
    required this.isRestDay,
    required this.title,
    required this.exercises,
  });

  factory BundleDay.fromJson(Map<String, dynamic> json) {
    return BundleDay(
      day: json['day'] as int? ?? 1,
      isRestDay: json['isRestDay'] as bool? ?? false,
      title: json['title'] as String? ?? '',
      exercises:
          (json['exercises'] as List?)
              ?.map((e) => BundleDayExercise.fromJson(e))
              .toList() ??
          [],
    );
  }

  /// Get total duration for this day in seconds
  int get totalDuration {
    int seconds = 0;
    for (final ex in exercises) {
      seconds += ex.duration;
    }
    return seconds;
  }

  /// Get formatted duration string
  String get durationText {
    final mins = (totalDuration / 60).ceil();
    return '$mins:${(totalDuration % 60).toString().padLeft(2, '0')}';
  }
}

class BundleDayExercise {
  final ExerciseInfo? exercise;
  final int reps;
  final int sets;
  final int duration; // in seconds

  BundleDayExercise({
    this.exercise,
    required this.reps,
    required this.sets,
    required this.duration,
  });

  factory BundleDayExercise.fromJson(Map<String, dynamic> json) {
    return BundleDayExercise(
      exercise: json['exercise'] != null
          ? ExerciseInfo.fromJson(json['exercise'])
          : null,
      reps: json['reps'] as int? ?? 0,
      sets: json['sets'] as int? ?? 1,
      duration: json['duration'] as int? ?? 0,
    );
  }
}

class ExerciseInfo {
  final String id;
  final String title;
  final String slug;
  final String image;
  final String gif; // GIF URL for animated demonstration
  final String difficulty;
  final int duration;
  final String description;

  ExerciseInfo({
    required this.id,
    required this.title,
    required this.slug,
    required this.image,
    required this.gif,
    required this.difficulty,
    required this.duration,
    required this.description,
  });

  factory ExerciseInfo.fromJson(Map<String, dynamic> json) {
    return ExerciseInfo(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      image: json['image'] as String? ?? '',
      gif: json['gif'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'beginner',
      duration: json['duration'] as int? ?? 0,
      description: json['description'] as String? ?? '',
    );
  }
}

class BundleCategory {
  final String id;
  final String name;
  final String slug;

  BundleCategory({required this.id, required this.name, required this.slug});

  factory BundleCategory.fromJson(Map<String, dynamic> json) {
    return BundleCategory(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class BundleProgress {
  final int totalDays;
  final int completedDays;
  final int progressPercentage;
  final Map<String, DayStatus> dayStatus;

  BundleProgress({
    required this.totalDays,
    required this.completedDays,
    required this.progressPercentage,
    required this.dayStatus,
  });

  factory BundleProgress.fromJson(Map<String, dynamic> json) {
    final dayStatusMap = <String, DayStatus>{};
    final rawDayStatus = json['dayStatus'] as Map<String, dynamic>? ?? {};
    rawDayStatus.forEach((key, value) {
      dayStatusMap[key] = DayStatus.fromJson(value);
    });

    return BundleProgress(
      totalDays: json['totalDays'] as int? ?? 0,
      completedDays: json['completedDays'] as int? ?? 0,
      progressPercentage: json['progressPercentage'] as int? ?? 0,
      dayStatus: dayStatusMap,
    );
  }

  /// Check if a specific day is completed
  bool isDayCompleted(int day) {
    final status = dayStatus[day.toString()];
    return status?.status == 'completed';
  }

  /// Get the current day user should be on (first incomplete day)
  /// Always returns at least 1 since days are 1-indexed
  int get currentDay {
    // If no totalDays info, default to day 1
    if (totalDays <= 0) return 1;

    for (int i = 1; i <= totalDays; i++) {
      if (!isDayCompleted(i)) return i;
    }
    return totalDays > 0 ? totalDays : 1;
  }

  /// Check if user can start a specific day based on date rules
  /// Day 1 is always available. Other days require previous day to be
  /// completed on a previous calendar date (one day per calendar day).
  bool canStartDay(int day) {
    // Day 1 is always available
    if (day == 1) return true;

    // Check if this day is already completed
    if (isDayCompleted(day)) return true;

    // Check if previous day is completed
    final prevDayStatus = dayStatus[(day - 1).toString()];
    if (prevDayStatus?.status != 'completed') return false;

    // Check if previous day was completed today - if so, lock this day until tomorrow
    final completedAt = prevDayStatus?.completedAt;
    if (completedAt == null) return true; // No date info, allow starting

    final now = DateTime.now();
    final completedDate = DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
    );
    final todayDate = DateTime(now.year, now.month, now.day);

    // Can start only if previous day was completed on a previous date
    return completedDate.isBefore(todayDate);
  }

  /// Get message for why a day is locked
  String getLockedMessage(int day) {
    final prevDayStatus = dayStatus[(day - 1).toString()];
    if (prevDayStatus?.status != 'completed') {
      return 'Complete Day ${day - 1} first';
    }
    return 'Available tomorrow';
  }
}

class DayStatus {
  final int day;
  final String status;
  final DateTime? completedAt;
  final int totalDuration;
  final int? rating;

  DayStatus({
    required this.day,
    required this.status,
    this.completedAt,
    required this.totalDuration,
    this.rating,
  });

  factory DayStatus.fromJson(Map<String, dynamic> json) {
    return DayStatus(
      day: json['day'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      totalDuration: json['totalDuration'] as int? ?? 0,
      rating: json['rating'] as int?,
    );
  }
}

/// Active workout session model
class ActiveSession {
  final String id;
  final String title;
  final String date;
  final String status;
  final SessionProgram? program;
  final int? programDay;
  final String? programDayTitle;
  final int currentExerciseIndex;
  final int completedExercises;
  final int totalExercises;
  final List<SessionExercise> exercises;

  ActiveSession({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
    this.program,
    this.programDay,
    this.programDayTitle,
    required this.currentExerciseIndex,
    required this.completedExercises,
    required this.totalExercises,
    required this.exercises,
  });

  factory ActiveSession.fromJson(Map<String, dynamic> json) {
    return ActiveSession(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Workout',
      date: json['date'] as String? ?? '',
      status: json['status'] as String? ?? 'in_progress',
      program: json['program'] != null
          ? SessionProgram.fromJson(json['program'])
          : null,
      programDay: json['programDay'] as int?,
      programDayTitle: json['programDayTitle'] as String?,
      currentExerciseIndex: json['currentExerciseIndex'] as int? ?? 0,
      completedExercises: json['completedExercises'] as int? ?? 0,
      totalExercises: json['totalExercises'] as int? ?? 0,
      exercises:
          (json['exercises'] as List?)
              ?.map((e) => SessionExercise.fromJson(e))
              .toList() ??
          [],
    );
  }

  /// Get progress percentage
  int get progressPercentage {
    if (totalExercises == 0) return 0;
    return ((completedExercises / totalExercises) * 100).round();
  }
}

class SessionProgram {
  final String id;
  final String name;
  final String slug;
  final String thumbnail;

  SessionProgram({
    required this.id,
    required this.name,
    required this.slug,
    required this.thumbnail,
  });

  factory SessionProgram.fromJson(Map<String, dynamic> json) {
    return SessionProgram(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
    );
  }
}

class SessionExercise {
  final SessionExerciseInfo? exercise;
  final int targetReps;
  final int targetSets;
  final int completedReps;
  final int completedSets;
  final int duration;
  final String status; // pending, in_progress, completed, skipped
  final int order;

  SessionExercise({
    this.exercise,
    required this.targetReps,
    required this.targetSets,
    required this.completedReps,
    required this.completedSets,
    required this.duration,
    required this.status,
    required this.order,
  });

  factory SessionExercise.fromJson(Map<String, dynamic> json) {
    return SessionExercise(
      exercise: json['exercise'] != null
          ? SessionExerciseInfo.fromJson(json['exercise'])
          : null,
      targetReps: json['targetReps'] as int? ?? 0,
      targetSets: json['targetSets'] as int? ?? 1,
      completedReps: json['completedReps'] as int? ?? 0,
      completedSets: json['completedSets'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      order: json['order'] as int? ?? 0,
    );
  }

  /// Get display text for reps/sets or duration
  String get displayText {
    if (targetReps > 0) {
      return '${targetSets}x$targetReps';
    } else if (duration > 0) {
      return '${duration}s';
    }
    return '${targetSets} sets';
  }

  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
  bool get isSkipped => status == 'skipped';
}

class SessionExerciseInfo {
  final String id;
  final String title;
  final String slug;
  final String image;
  final String gif;
  final String difficulty;
  final int duration;
  final String description;

  SessionExerciseInfo({
    required this.id,
    required this.title,
    required this.slug,
    required this.image,
    required this.gif,
    required this.difficulty,
    required this.duration,
    required this.description,
  });

  factory SessionExerciseInfo.fromJson(Map<String, dynamic> json) {
    return SessionExerciseInfo(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      image: json['image'] as String? ?? '',
      gif: json['gif'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'beginner',
      duration: json['duration'] as int? ?? 0,
      description: json['description'] as String? ?? '',
    );
  }

  /// Get the best available image (prefer gif)
  String get displayImage => gif.isNotEmpty ? gif : image;
}
