import 'package:flutter/widgets.dart';

import '../../data/models/app_user.dart';

abstract interface class SessionController {
  void signedIn(AppUser user);
  void userUpdated(AppUser user);
  Future<void> signOut();
  Future<void> setDarkMode(bool enabled);
}

class SessionScope extends InheritedWidget {
  const SessionScope({
    super.key,
    required this.user,
    required this.darkMode,
    required this.controller,
    required super.child,
  });

  final AppUser? user;
  final bool darkMode;
  final SessionController controller;

  static SessionScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SessionScope>();
    assert(scope != null, 'No SessionScope above this widget');
    return scope!;
  }

  /// The session actions, for use in event handlers (button taps, form
  /// submits). Does not subscribe the caller to rebuilds.
  static SessionController controllerOf(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<SessionScope>();
    assert(scope != null, 'No SessionScope above this widget');
    return scope!.controller;
  }

  /// The signed-in user, without subscribing to rebuilds. For initState and
  /// event handlers on screens shown after sign-in.
  static AppUser readUser(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<SessionScope>();
    assert(scope?.user != null, 'No signed-in user');
    return scope!.user!;
  }

  @override
  bool updateShouldNotify(SessionScope oldWidget) =>
      user != oldWidget.user || darkMode != oldWidget.darkMode;
}
