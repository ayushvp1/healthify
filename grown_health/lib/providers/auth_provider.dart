import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';
import 'core_providers.dart';

/// Auth state notifier - manages authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final StorageService _storageService;
  final AuthService _authService;

  AuthNotifier(this._storageService, this._authService)
      : super(const AuthState()) {
    _checkAuthStatus();
  }

  /// Check if user is already logged in (from stored token)
  Future<void> _checkAuthStatus() async {
    final token = _storageService.getToken();
    final email = _storageService.getEmail();

    if (token != null && token.isNotEmpty) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: UserModel(email: email, token: token),
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Clear any previous user's data first
      await _storageService.clearAuth();
      
      final token = await _authService.login(
        email: email,
        password: password,
      );
      await _storageService.saveToken(token);
      await _storageService.saveEmail(email);

      state = AuthState(
        status: AuthStatus.authenticated,
        user: UserModel(email: email, token: token),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  /// Register new account
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Clear any previous user's data first
      await _storageService.clearAuth();
      
      final token = await _authService.register(
        email: email,
        password: password,
      );

      if (token.isNotEmpty) {
        await _storageService.saveToken(token);
        await _storageService.saveEmail(email);
        state = AuthState(
          status: AuthStatus.authenticated,
          user: UserModel(email: email, token: token),
        );
      } else {
        // Registration succeeded but no auto-login
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  /// Logout and clear stored credentials
  Future<void> logout() async {
    await _storageService.clearAuth();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Clear any error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Main auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(storageService, authService);
});
