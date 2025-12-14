class ExerciseModel {
  final String? id;
  final String title;
  final String? slug;
  final String? category;
  final String? description;
  final String? difficulty;
  final int? duration; // in seconds or minutes
  final dynamic equipment; // Can be String or List<String>
  final String? image;
  final String? videoUrl;
  final int? calories;
  final List<String>? muscleGroups;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExerciseModel({
    this.id,
    required this.title,
    this.slug,
    this.category,
    this.description,
    this.difficulty,
    this.duration,
    this.equipment,
    this.image,
    this.videoUrl,
    this.calories,
    this.muscleGroups,
    this.createdAt,
    this.updatedAt,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['_id'] as String?,
      title: json['title'] as String,
      slug: json['slug'] as String?,
      category: json['category'] as String?,
      description: json['description'] as String?,
      difficulty: json['difficulty'] as String?,
      duration: json['duration'] as int?,
      equipment: json['equipment'], // Can be String or List
      image: json['image'] as String?,
      videoUrl: json['videoUrl'] as String?,
      calories: json['calories'] as int?,
      muscleGroups: json['muscleGroups'] != null
          ? List<String>.from(json['muscleGroups'] as List)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'title': title,
      if (slug != null) 'slug': slug,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (difficulty != null) 'difficulty': difficulty,
      if (duration != null) 'duration': duration,
      if (equipment != null) 'equipment': equipment,
      if (image != null) 'image': image,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (calories != null) 'calories': calories,
      if (muscleGroups != null) 'muscleGroups': muscleGroups,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Helper to get equipment as a list
  List<String> get equipmentList {
    if (equipment == null) return [];
    if (equipment is List) return List<String>.from(equipment);
    if (equipment is String) return [equipment];
    return [];
  }

  ExerciseModel copyWith({
    String? id,
    String? title,
    String? slug,
    String? category,
    String? description,
    String? difficulty,
    int? duration,
    dynamic equipment,
    String? image,
    String? videoUrl,
    int? calories,
    List<String>? muscleGroups,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      category: category ?? this.category,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      equipment: equipment ?? this.equipment,
      image: image ?? this.image,
      videoUrl: videoUrl ?? this.videoUrl,
      calories: calories ?? this.calories,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ExerciseListResponse {
  final List<ExerciseModel> exercises;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ExerciseListResponse({
    required this.exercises,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory ExerciseListResponse.fromJson(Map<String, dynamic> json) {
    return ExerciseListResponse(
      exercises: (json['exercises'] as List)
          .map((item) => ExerciseModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
