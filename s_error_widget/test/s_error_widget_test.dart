import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_error_widget/s_error_widget.dart';

void main() {
  group('SErrorWidget Tests', () {
    testWidgets('renders default widget correctly',
        (WidgetTester tester) async {
      const exceptionText = 'Something went wrong';
      await tester.pumpWidget(
        const MaterialApp(
          home: SErrorWidget(exceptionText: exceptionText),
        ),
      );

      // Verify default header
      expect(find.text('Error!'), findsOneWidget);
      // Verify exception text
      expect(find.text(exceptionText), findsOneWidget);
      // Verify default icon (warning text char)
      expect(find.text('\u26A0'), findsOneWidget);
      // Verify no retry button by default
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('renders custom header and styling',
        (WidgetTester tester) async {
      const headerText = 'Custom Header';
      const exceptionText = 'Custom Exception';
      const backgroundColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: SErrorWidget(
            headerText: headerText,
            exceptionText: exceptionText,
            backgroundColor: backgroundColor,
          ),
        ),
      );

      expect(find.text(headerText), findsOneWidget);
      expect(find.text(exceptionText), findsOneWidget);

      final material = tester.widget<Material>(find.byType(Material));
      expect(material.color, backgroundColor);
    });

    testWidgets('renders custom icon', (WidgetTester tester) async {
      const iconKey = Key('custom-icon');
      await tester.pumpWidget(
        const MaterialApp(
          home: SErrorWidget(
            exceptionText: 'Error',
            icon: Icon(Icons.error, key: iconKey),
          ),
        ),
      );

      expect(find.byKey(iconKey), findsOneWidget);
      // Default icon text should not be present
      expect(find.text('\u26A0'), findsNothing);
    });

    testWidgets('shows retry button and handles callback',
        (WidgetTester tester) async {
      bool retryPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: SErrorWidget(
            exceptionText: 'Error',
            onRetry: () => retryPressed = true,
            retryText: 'Try Again',
          ),
        ),
      );

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pump();

      expect(retryPressed, isTrue);
    });

    testWidgets('uses exceptionBuilder when provided',
        (WidgetTester tester) async {
      const exceptionText = 'Error Message';
      const key = Key('custom-builder');

      await tester.pumpWidget(
        MaterialApp(
          home: SErrorWidget(
            exceptionText: exceptionText,
            exceptionBuilder: (context, text) {
              return Text(text,
                  key: key, style: const TextStyle(color: Colors.pink));
            },
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
      // The default text logic uses SelectableText, our builder uses Text.
      // So finding Text widget with key proves builder usage.
      final textWidget = tester.widget<Text>(find.byKey(key));
      expect(textWidget.data, exceptionText);
      expect(textWidget.style?.color, Colors.pink);
    });
  });
}
