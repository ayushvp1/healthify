class UserModel {
  final String? email;
  final String? token;
  final String? name;
  final int? age;
  final String? gender;
  final double? weight;
  final double? height;
  final String? profileImage;
  final bool? isProfileComplete;

  const UserModel({
    this.email,
    this.token,
    this.name,
    this.age,
    this.gender,
    this.weight,
    this.height,
    this.profileImage,
    this.isProfileComplete,
  });

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  UserModel copyWith({
    String? email,
    String? token,
    String? name,
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? profileImage,
    bool? isProfileComplete,
  }) {
    return UserModel(
      email: email ?? this.email,
      token: token ?? this.token,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      profileImage: profileImage ?? this.profileImage,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (email != null) 'email': email,
      if (token != null) 'token': token,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (profileImage != null) 'profileImage': profileImage,
      if (isProfileComplete != null) 'isProfileComplete': isProfileComplete,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] as String?,
      token: json['token'] as String?,
      name: json['name'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      profileImage: json['profileImage'] as String?,
      isProfileComplete: json['isProfileComplete'] as bool?,
    );
  }
}
