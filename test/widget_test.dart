// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:projekt/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Corrected the widget name from SmartFridgeApp to MyApp
    await tester.pumpWidget(const MyApp());

    // Verify that the home screen is shown by checking for one of the bottom navigation bar labels.
    // Note: This test will only pass if the default device language is German.
    expect(find.text('Startseite'), findsOneWidget);
  });
}
