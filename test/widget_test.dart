import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:beautiful_tracker/app.dart';

void main() {
  setUpAll(() {
    // Tests run offline; fall back to the default font instead of fetching.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('bottom navigation switches between the four tabs', (
    tester,
  ) async {
    await tester.pumpWidget(const BeautifulTrackerApp());

    expect(find.text('Project overview will appear here.'), findsOneWidget);

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('No tasks yet.'), findsOneWidget);

    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();
    expect(find.text('No team members yet.'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Profile details will appear here.'), findsOneWidget);
  });
}
