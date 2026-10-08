import 'package:shared_preferences/shared_preferences.dart';

/// Small key-value settings kept in SharedPreferences. Relational data
/// (users, tasks, members) lives in SQLite instead.
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static Future<PreferencesService> load() async =>
      PreferencesService(await SharedPreferences.getInstance());

  static const _currentUserIdKey = 'current_user_id';
  static const _darkModeKey = 'dark_mode';

  /// Signed-in user, or null when signed out.
  int? get currentUserId => _prefs.getInt(_currentUserIdKey);

  Future<void> setCurrentUserId(int? id) => id == null
      ? _prefs.remove(_currentUserIdKey)
      : _prefs.setInt(_currentUserIdKey, id);

  bool get darkMode => _prefs.getBool(_darkModeKey) ?? false;

  Future<void> setDarkMode(bool value) => _prefs.setBool(_darkModeKey, value);
}
