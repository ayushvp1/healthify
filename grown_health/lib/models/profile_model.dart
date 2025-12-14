class ProfileModel {
  final String? id;
  final String? email;
  final String? name;
  final int? age;
  final String? gender;
  final double? weight;
  final double? height;
  final String? fitnessGoal;
  final String? profileImage;
  final bool? isProfileComplete;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileModel({
    this.id,
    this.email,
    this.name,
    this.age,
    this.gender,
    this.weight,
    this.height,
    this.fitnessGoal,
    this.profileImage,
    this.isProfileComplete,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Handle wrapped response (backend returns {success: true, data: {...}})
    final data =
        json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    // Parse age - handle both int and null
    int? parsedAge;
    if (data['age'] != null) {
      if (data['age'] is int) {
        parsedAge = data['age'] as int;
      } else if (data['age'] is num) {
        parsedAge = (data['age'] as num).toInt();
      }
    }

    // Parse createdAt/updatedAt - handle both String and null
    DateTime? parsedCreatedAt;
    DateTime? parsedUpdatedAt;
    try {
      if (data['createdAt'] != null) {
        parsedCreatedAt = DateTime.parse(data['createdAt'].toString());
      }
      if (data['updatedAt'] != null) {
        parsedUpdatedAt = DateTime.parse(data['updatedAt'].toString());
      }
    } catch (_) {
      // Ignore date parsing errors
    }

    return ProfileModel(
      // Backend returns 'id' but also might use '_id'
      id: (data['id'] ?? data['_id'])?.toString(),
      email: data['email'] as String?,
      name: data['name'] as String?,
      age: parsedAge,
      gender: data['gender'] as String?,
      weight: (data['weight'] as num?)?.toDouble(),
      height: (data['height'] as num?)?.toDouble(),
      fitnessGoal: data['fitnessGoal'] as String?,
      profileImage: data['profileImage'] as String?,
      // Backend returns 'profileCompleted' not 'isProfileComplete'
      isProfileComplete:
          (data['profileCompleted'] ?? data['isProfileComplete']) as bool?,
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (fitnessGoal != null) 'fitnessGoal': fitnessGoal,
      if (profileImage != null) 'profileImage': profileImage,
      if (isProfileComplete != null) 'isProfileComplete': isProfileComplete,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? email,
    String? name,
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? fitnessGoal,
    String? profileImage,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      profileImage: profileImage ?? this.profileImage,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
