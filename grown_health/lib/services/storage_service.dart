import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';
  static const String _profileCompletedKey = 'profile_completed';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }

  // Email
  Future<void> saveEmail(String email) async {
    await _prefs.setString(_emailKey, email);
  }

  String? getEmail() {
    return _prefs.getString(_emailKey);
  }

  Future<void> removeEmail() async {
    await _prefs.remove(_emailKey);
  }

  // Name
  Future<void> saveName(String name) async {
    await _prefs.setString(_nameKey, name);
  }

  String? getName() {
    return _prefs.getString(_nameKey);
  }

  Future<void> removeName() async {
    await _prefs.remove(_nameKey);
  }

  // Profile Completed
  Future<void> saveProfileCompleted(bool completed) async {
    await _prefs.setBool(_profileCompletedKey, completed);
  }

  bool getProfileCompleted() {
    return _prefs.getBool(_profileCompletedKey) ?? false;
  }

  Future<void> removeProfileCompleted() async {
    await _prefs.remove(_profileCompletedKey);
  }

  // Clear all auth data
  Future<void> clearAuth() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_nameKey);
    await _prefs.remove(_profileCompletedKey);
    // Also clear any other user-specific data
    await _prefs.remove('userName');
    // Clear all keys that start with 'user_' or 'profile_'
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('user_') || key.startsWith('profile_')) {
        await _prefs.remove(key);
      }
    }
  }
}
