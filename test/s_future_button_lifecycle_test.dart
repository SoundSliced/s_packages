import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_packages.dart';

Widget _testApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

void main() {
  group('SFutureButton lifecycle and content', () {
    testWidgets('replaces its label when the widget updates', (tester) async {
      await tester.pumpWidget(_testApp(const SFutureButton(label: 'Save')));
      expect(find.text('Save'), findsOneWidget);

      await tester.pumpWidget(_testApp(const SFutureButton(label: 'Saved')));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('replaces its label style when the widget updates',
        (tester) async {
      const initialStyle = TextStyle(color: Colors.red, fontSize: 12);
      const updatedStyle = TextStyle(color: Colors.purple, fontSize: 18);

      await tester.pumpWidget(
        _testApp(
          const SFutureButton(
            label: 'Save',
            labelStyle: initialStyle,
          ),
        ),
      );
      final initialText = tester.widget<Text>(find.text('Save'));
      expect(initialText.style?.color, Colors.red);
      expect(initialText.style?.fontSize, 12);
      expect(initialText.style?.fontWeight, FontWeight.bold);

      await tester.pumpWidget(
        _testApp(
          const SFutureButton(
            label: 'Save',
            labelStyle: updatedStyle,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      final text = tester.widgetList<Text>(find.text('Save')).firstWhere(
            (text) => text.style?.color == Colors.purple,
          );
      expect(text.style?.color, Colors.purple);
      expect(text.style?.fontSize, 18);
      expect(text.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('renders icon and label together when both are supplied',
        (tester) async {
      const iconKey = Key('save-icon');
      await tester.pumpWidget(
        _testApp(
          const SFutureButton(
            label: 'Save',
            icon: Icon(Icons.save, key: iconKey),
          ),
        ),
      );

      expect(find.byKey(iconKey), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SFutureButton),
          matching: find.byType(Row),
        ),
        findsOneWidget,
      );
    });

    testWidgets('keeps icon-only content icon-only', (tester) async {
      const iconKey = Key('upload-icon');
      await tester.pumpWidget(
        _testApp(
          const SFutureButton(icon: Icon(Icons.upload, key: iconKey)),
        ),
      );

      expect(find.byKey(iconKey), findsOneWidget);
      expect(find.text('Tap'), findsNothing);
    });

    testWidgets('forwards completion customization to the animated button',
        (tester) async {
      await tester.pumpWidget(
        _testApp(
          const SFutureButton(
            successColor: Colors.teal,
            errorColor: Colors.deepOrange,
            successIcon: Icons.done_all,
            errorIcon: Icons.warning_amber_rounded,
          ),
        ),
      );

      final button = tester.widget<MyRoundedLoadingButton>(
        find.byType(MyRoundedLoadingButton),
      );
      expect(button.successColor, Colors.teal);
      expect(button.errorColor, Colors.deepOrange);
      expect(button.successIcon, Icons.done_all);
      expect(button.failedIcon, Icons.warning_amber_rounded);
    });

    testWidgets('runs only one async operation while loading', (tester) async {
      final completer = Completer<bool?>();
      var calls = 0;

      await tester.pumpWidget(
        _testApp(
          SFutureButton(
            onTap: () {
              calls++;
              return completer.future;
            },
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      await tester.tap(button);
      await tester.pump();
      await tester.tap(button);
      await tester.pump(const Duration(milliseconds: 500));

      expect(calls, 1);

      completer.complete(null);
      await tester.pump();
    });

    testWidgets('ignores a future completion after disposal', (tester) async {
      final completer = Completer<bool?>();
      var successCalls = 0;

      await tester.pumpWidget(
        _testApp(
          SFutureButton(
            onTap: () => completer.future,
            onPostSuccess: () => successCalls++,
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(const SizedBox());

      completer.complete(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(successCalls, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('exposes a semantic label and loading state', (tester) async {
      final completer = Completer<bool?>();
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        _testApp(
          SFutureButton(
            label: 'Upload report',
            onTap: () => completer.future,
          ),
        ),
      );

      final semanticsFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Upload report',
      );

      expect(
        tester.getSemantics(semanticsFinder),
        matchesSemantics(
          label: 'Upload report',
          value: 'idle',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(
        tester.getSemantics(semanticsFinder),
        matchesSemantics(
          label: 'Upload report',
          value: 'Loading',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );

      completer.complete(null);
      await tester.pump(const Duration(milliseconds: 400));
      semantics.dispose();
    });

    testWidgets('exposes a disabled semantic state', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _testApp(
          const SFutureButton(
            label: 'Unavailable upload',
            isEnabled: false,
          ),
        ),
      );

      final semanticsFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Unavailable upload',
      );
      expect(
        tester.getSemantics(semanticsFinder),
        matchesSemantics(
          label: 'Unavailable upload',
          value: 'idle',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      semantics.dispose();
    });
  });
}
