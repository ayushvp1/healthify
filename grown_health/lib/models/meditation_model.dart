class MeditationModel {
  final String? id;
  final String title;
  final String? description;
  final String? category;
  final int? duration; // in seconds or minutes
  final String? audioUrl;
  final String? imageUrl;
  final String? instructor;
  final String? difficulty;
  final List<String>? tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MeditationModel({
    this.id,
    required this.title,
    this.description,
    this.category,
    this.duration,
    this.audioUrl,
    this.imageUrl,
    this.instructor,
    this.difficulty,
    this.tags,
    this.createdAt,
    this.updatedAt,
  });

  factory MeditationModel.fromJson(Map<String, dynamic> json) {
    return MeditationModel(
      id: json['_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      duration: json['duration'] as int?,
      audioUrl: json['audioUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      instructor: json['instructor'] as String?,
      difficulty: json['difficulty'] as String?,
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'] as List)
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
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (duration != null) 'duration': duration,
      if (audioUrl != null) 'audioUrl': audioUrl,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (instructor != null) 'instructor': instructor,
      if (difficulty != null) 'difficulty': difficulty,
      if (tags != null) 'tags': tags,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  MeditationModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? duration,
    String? audioUrl,
    String? imageUrl,
    String? instructor,
    String? difficulty,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MeditationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      instructor: instructor ?? this.instructor,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MeditationListResponse {
  final List<MeditationModel> meditations;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const MeditationListResponse({
    required this.meditations,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory MeditationListResponse.fromJson(Map<String, dynamic> json) {
    return MeditationListResponse(
      meditations: (json['meditations'] as List)
          .map((item) => MeditationModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
