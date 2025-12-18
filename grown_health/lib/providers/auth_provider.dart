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
    final name = _storageService.getName();
    final profileCompleted = _storageService.getProfileCompleted();
    final tutorialSeen = _storageService.getTutorialSeen();

    if (token != null && token.isNotEmpty) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: UserModel(
          email: email,
          token: token,
          name: name,
          isProfileComplete: profileCompleted,
          hasSeenTutorial: tutorialSeen,
        ),
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Login with email and password
  /// Returns a map with 'success' and 'profileCompleted' boolean values
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Clear any previous user's data first
      await _storageService.clearAuth();

      final result = await _authService.login(email: email, password: password);
      final token = result['token'] as String;
      final profileCompleted = result['profileCompleted'] as bool? ?? false;
      final tutorialSeen = result['hasSeenTutorial'] as bool? ?? false;
      final name = result['name'] as String? ?? '';

      await _storageService.saveToken(token);
      await _storageService.saveEmail(email);
      if (name.isNotEmpty) {
        await _storageService.saveName(name);
      }
      await _storageService.saveProfileCompleted(profileCompleted);
      await _storageService.saveTutorialSeen(tutorialSeen);

      state = AuthState(
        status: AuthStatus.authenticated,
        user: UserModel(
          email: email,
          token: token,
          name: name,
          isProfileComplete: profileCompleted,
          hasSeenTutorial: tutorialSeen,
        ),
      );
      return {'success': true, 'profileCompleted': profileCompleted};
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return {'success': false, 'profileCompleted': false};
    }
  }

  /// Register new account
  Future<bool> register({
    required String email,
    required String password,
    String? name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Clear any previous user's data first
      await _storageService.clearAuth();

      final token = await _authService.register(
        email: email,
        password: password,
        name: name,
      );

      if (token.isNotEmpty) {
        await _storageService.saveToken(token);
        await _storageService.saveEmail(email);
        if (name != null) {
          await _storageService.saveName(name);
        }
        state = AuthState(
          status: AuthStatus.authenticated,
          user: UserModel(email: email, token: token, name: name),
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

  /// Update profile completion status
  Future<void> setProfileCompleted(bool completed) async {
    await _storageService.saveProfileCompleted(completed);
    if (state.user != null) {
      state = state.copyWith(
        user: state.user!.copyWith(isProfileComplete: completed),
      );
    }
  }

  /// Update user information in state and storage
  Future<void> updateUser({String? name, bool? profileCompleted}) async {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(
      name: name ?? state.user!.name,
      isProfileComplete: profileCompleted ?? state.user!.isProfileComplete,
    );

    if (name != null) {
      await _storageService.saveName(name);
    }
    if (profileCompleted != null) {
      await _storageService.saveProfileCompleted(profileCompleted);
    }

    state = state.copyWith(user: updatedUser);
  }

  /// Update tutorial seen status
  Future<void> setTutorialSeen(bool seen) async {
    await _storageService.saveTutorialSeen(seen);
    if (state.user != null) {
      state = state.copyWith(user: state.user!.copyWith(hasSeenTutorial: seen));
    }
  }
}

/// Main auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(storageService, authService);
});
