class UserModel {
  final String? email;
  final String? token;

  const UserModel({this.email, this.token});

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  UserModel copyWith({String? email, String? token}) {
    return UserModel(
      email: email ?? this.email,
      token: token ?? this.token,
    );
  }
}
