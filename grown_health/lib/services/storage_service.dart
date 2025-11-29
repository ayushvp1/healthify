import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'user_email';

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

  // Clear all auth data
  Future<void> clearAuth() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_emailKey);
  }
}
