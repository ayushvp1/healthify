import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/water_service.dart';

/// State for water tracking - shared across app
class WaterState {
  final int currentGlasses;
  final int goalGlasses;
  final bool loading;
  final String? error;

  const WaterState({
    this.currentGlasses = 0,
    this.goalGlasses = 8,
    this.loading = false,
    this.error,
  });

  int get currentMl => currentGlasses * 250;
  int get goalMl => goalGlasses * 250;
  int get remainingMl => (goalMl - currentMl).clamp(0, goalMl);
  int get percentage => goalGlasses > 0
      ? ((currentGlasses / goalGlasses) * 100).round().clamp(0, 100)
      : 0;
  bool get isComplete => currentGlasses >= goalGlasses;

  WaterState copyWith({
    int? currentGlasses,
    int? goalGlasses,
    bool? loading,
    String? error,
  }) {
    return WaterState(
      currentGlasses: currentGlasses ?? this.currentGlasses,
      goalGlasses: goalGlasses ?? this.goalGlasses,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

/// StateNotifier for water tracking with API integration
class WaterNotifier extends StateNotifier<WaterState> {
  final String? _token;
  WaterService? _service;

  WaterNotifier(this._token) : super(const WaterState()) {
    if (_token != null && _token.isNotEmpty) {
      _service = WaterService(_token);
      loadWater();
    }
  }

  /// Load today's water data from backend
  Future<void> loadWater() async {
    if (_service == null) return;

    state = state.copyWith(loading: true);

    try {
      final data = await _service!.getTodayWaterIntake();
      state = state.copyWith(
        currentGlasses: data.count,
        goalGlasses: data.goal,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  /// Add one glass of water
  Future<void> addWater() async {
    if (_service == null) return;

    state = state.copyWith(loading: true);

    try {
      final result = await _service!.addWaterGlass();
      state = state.copyWith(
        currentGlasses: result.count,
        goalGlasses: result.goal,
        loading: false,
      );
    } catch (e) {
      // Optimistic update on failure
      state = state.copyWith(
        currentGlasses: state.currentGlasses + 1,
        loading: false,
      );
    }
  }

  /// Remove one glass of water
  Future<void> removeWater() async {
    if (_service == null || state.currentGlasses <= 0) return;

    state = state.copyWith(loading: true);

    try {
      final result = await _service!.removeWaterGlass();
      state = state.copyWith(
        currentGlasses: result.count,
        goalGlasses: result.goal,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(
        currentGlasses: (state.currentGlasses - 1).clamp(0, 99),
        loading: false,
      );
    }
  }

  /// Update goal (in glasses)
  Future<void> setGoal(int glasses) async {
    if (_service == null) return;

    state = state.copyWith(loading: true);

    try {
      await _service!.setWaterGoal(glasses);
      state = state.copyWith(goalGlasses: glasses, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

/// Provider family that takes auth token
final waterNotifierProvider =
    StateNotifierProvider.family<WaterNotifier, WaterState, String?>(
      (ref, token) => WaterNotifier(token),
    );
