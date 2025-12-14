class WaterIntakeModel {
  final String? id;
  final String? userId;
  final DateTime date;
  final int count;
  final int goal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WaterIntakeModel({
    this.id,
    this.userId,
    required this.date,
    required this.count,
    required this.goal,
    this.createdAt,
    this.updatedAt,
  });

  factory WaterIntakeModel.fromJson(Map<String, dynamic> json) {
    return WaterIntakeModel(
      id: json['_id'] as String?,
      userId: json['userId'] as String?,
      date: DateTime.parse(json['date'] as String),
      count: json['count'] as int,
      goal: json['goal'] as int,
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
      if (userId != null) 'userId': userId,
      'date': date.toIso8601String(),
      'count': count,
      'goal': goal,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Calculate percentage of goal completed
  double get percentage => goal > 0 ? (count / goal * 100).clamp(0, 100) : 0;

  // Calculate remaining glasses
  int get remaining => (goal - count).clamp(0, goal);

  // Check if goal is completed
  bool get isCompleted => count >= goal;

  WaterIntakeModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? count,
    int? goal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WaterIntakeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      count: count ?? this.count,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WaterTodayResponse {
  final int count;
  final int goal;
  final double percentage;
  final int remaining;
  final bool isCompleted;

  const WaterTodayResponse({
    required this.count,
    required this.goal,
    required this.percentage,
    required this.remaining,
    required this.isCompleted,
  });

  factory WaterTodayResponse.fromJson(Map<String, dynamic> json) {
    return WaterTodayResponse(
      count: json['count'] as int,
      goal: json['goal'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      remaining: json['remaining'] as int,
      isCompleted: json['isCompleted'] as bool,
    );
  }
}

class WaterHistoryResponse {
  final List<WaterIntakeModel> data;
  final int totalDays;
  final double averageIntake;
  final int totalGlasses;

  const WaterHistoryResponse({
    required this.data,
    required this.totalDays,
    required this.averageIntake,
    required this.totalGlasses,
  });

  factory WaterHistoryResponse.fromJson(Map<String, dynamic> json) {
    return WaterHistoryResponse(
      data: (json['data'] as List)
          .map((item) => WaterIntakeModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalDays: json['totalDays'] as int,
      averageIntake: (json['averageIntake'] as num).toDouble(),
      totalGlasses: json['totalGlasses'] as int,
    );
  }
}
