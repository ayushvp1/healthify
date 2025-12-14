class ProfileModel {
  final String? id;
  final String? email;
  final String? name;
  final int? age;
  final String? gender;
  final double? weight;
  final double? height;
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
    this.profileImage,
    this.isProfileComplete,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['_id'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      profileImage: json['profileImage'] as String?,
      isProfileComplete: json['isProfileComplete'] as bool?,
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
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
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
      profileImage: profileImage ?? this.profileImage,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
