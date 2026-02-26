// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:s_packages_example/main.dart';

void main() {
  testWidgets('App builds and shows home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SPackagesExampleApp());

    // Verify that the app title is shown.
    expect(find.text('S Packages Examples'), findsOneWidget);

    // Verify that the search hint is shown.
    expect(find.text('Search packages...'), findsOneWidget);
  });
}
