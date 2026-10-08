import 'package:flutter/material.dart';

import 'app.dart';
import 'data/local/preferences_service.dart';
import 'data/models/app_user.dart';
import 'data/services/account_service.dart';

Future<void> main() async {
  // Plugins (sqflite, shared_preferences) need the binding before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await PreferencesService.load();
  final initialUser = await _restoreSession(preferences);

  runApp(
    BeautifulTrackerApp(preferences: preferences, initialUser: initialUser),
  );
}

/// Loads the user saved by the last sign-in so the app opens straight to
/// the dashboard. Falls back to the sign-in screen if that fails.
Future<AppUser?> _restoreSession(PreferencesService preferences) async {
  final userId = preferences.currentUserId;
  if (userId == null) return null;
  try {
    final user = await AccountService().findById(userId);
    if (user == null) await preferences.setCurrentUserId(null);
    return user;
  } catch (e) {
    debugPrint('Could not restore session: $e');
    return null;
  }
}
