import 'package:flutter/material.dart';

import 'core/session/session_scope.dart';
import 'core/theme/app_theme.dart';
import 'data/local/preferences_service.dart';
import 'data/models/app_user.dart';
import 'features/auth/sign_in_screen.dart';
import 'navigation/main_shell.dart';

class BeautifulTrackerApp extends StatefulWidget {
  const BeautifulTrackerApp({
    super.key,
    required this.preferences,
    this.initialUser,
  });

  final PreferencesService preferences;

  final AppUser? initialUser;

  @override
  State<BeautifulTrackerApp> createState() => _BeautifulTrackerAppState();
}

class _BeautifulTrackerAppState extends State<BeautifulTrackerApp>
    implements SessionController {
  late AppUser? _user = widget.initialUser;
  late bool _darkMode = widget.preferences.darkMode;

  @override
  void signedIn(AppUser user) {
    setState(() => _user = user);
    widget.preferences.setCurrentUserId(user.id);
  }

  @override
  void userUpdated(AppUser user) {
    setState(() => _user = user);
  }

  @override
  Future<void> signOut() async {
    setState(() => _user = null);
    await widget.preferences.setCurrentUserId(null);
  }

  @override
  Future<void> setDarkMode(bool enabled) async {
    setState(() => _darkMode = enabled);
    await widget.preferences.setDarkMode(enabled);
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = _user != null;
    return SessionScope(
      user: _user,
      darkMode: _darkMode,
      controller: this,
      child: MaterialApp(
        title: 'Beautiful Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        // Dark mode applies only after sign-in.
        themeMode: signedIn && _darkMode ? ThemeMode.dark : ThemeMode.light,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final signedIn = SessionScope.of(context).user != null;
    return signedIn ? const MainShell() : const SignInScreen();
  }
}
