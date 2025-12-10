// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:lindav/main.dart';

void main() {
  testWidgets('Lindav Security dashboard smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LindavSecurityApp());
    // Wait for the splash screen to finish and navigate
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Basic structure
    expect(find.text('Lindav Security'), findsOneWidget);
    expect(find.text('Quick Scan'), findsOneWidget);
    expect(find.text('Full Scan'), findsOneWidget);
    expect(find.text('USB Scan'), findsOneWidget);

    // Initial history state
    expect(find.text('Scan history'), findsOneWidget);
    expect(find.text('No scans yet. Tap Quick Scan to start.'), findsOneWidget);
  });
}
