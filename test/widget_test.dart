import 'package:beautiful_tracker/app.dart';
import 'package:beautiful_tracker/data/local/preferences_service.dart';
import 'package:beautiful_tracker/data/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _user = AppUser(
  id: 1,
  name: 'Kevin Rebakure',
  email: 'kevin@pace.dev',
  passwordHash: 'x',
  passwordSalt: 'y',
  createdAt: DateTime(2026),
);

Future<PreferencesService> _prefs([Map<String, Object> values = const {}]) {
  SharedPreferences.setMockInitialValues(values);
  return PreferencesService.load();
}

/// Phone-sized test screen (412 x 915 logical pixels).
void _usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1236, 2745);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(() {
    // Tests run offline; fall back to the default font instead of fetching.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('signed out: sign-in form validates before submitting', (
    tester,
  ) async {
    _usePhoneScreen(tester);
    await tester.pumpWidget(BeautifulTrackerApp(preferences: await _prefs()));

    await tester.tap(find.text('Sign In'));
    await tester.pump();
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'kevin@');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('sign-up form checks that passwords match', (tester) async {
    _usePhoneScreen(tester);
    await tester.pumpWidget(BeautifulTrackerApp(preferences: await _prefs()));

    await tester.tapOnText(find.textRange.ofSubstring('Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Alice');
    await tester.enterText(fields.at(1), 'alice@team.dev');
    await tester.enterText(fields.at(2), 'secret1');
    await tester.enterText(fields.at(3), 'secret2');
    await tester.ensureVisible(find.text('Create Account'));
    await tester.tap(find.text('Create Account'));
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('signed in: bottom navigation switches between the four tabs', (
    tester,
  ) async {
    _usePhoneScreen(tester);
    await tester.pumpWidget(
      BeautifulTrackerApp(preferences: await _prefs(), initialUser: _user),
    );

    expect(find.text('Project overview will appear here.'), findsOneWidget);

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('No tasks yet.'), findsOneWidget);

    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();
    expect(find.text('No team members yet.'), findsOneWidget);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.text('Kevin Rebakure'), findsOneWidget);
    expect(find.text('KR'), findsOneWidget);
  });

  testWidgets('profile: dark mode is saved and sign out returns to sign-in', (
    tester,
  ) async {
    _usePhoneScreen(tester);
    final prefs = await _prefs({'current_user_id': 1});
    await tester.pumpWidget(
      BeautifulTrackerApp(preferences: prefs, initialUser: _user),
    );
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(prefs.darkMode, isTrue);
    expect(
      Theme.of(tester.element(find.text('Kevin Rebakure'))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign out?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign Out'));
    await tester.pumpAndSettle();

    expect(find.text('Keep your team\'s work on track.'), findsOneWidget);
    expect(prefs.currentUserId, isNull);
    // Auth screens stay light even with dark mode saved.
    expect(
      Theme.of(tester.element(find.text('Sign In'))).brightness,
      Brightness.light,
    );
  });
}
