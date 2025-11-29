import '../models/user_model.dart';

/// Authentication status enum
enum AuthStatus {
  /// Initial state, checking if user is logged in
  unknown,

  /// User is authenticated , 
  authenticated,

  /// User is not authenticated
  unauthenticated,
}

/// Authentication state model
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isLoading = false,
    this.error,
  });

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Check if auth status is still being determined
  bool get isUnknown => status == AuthStatus.unknown;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $status, user: ${user?.email}, isLoading: $isLoading, error: $error)';
  }
}
