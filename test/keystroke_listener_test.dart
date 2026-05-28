import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_packages.dart';

class _CustomShortcutIntent extends Intent {
  const _CustomShortcutIntent();
}

void main() {
  group('KeystrokeListener', () {
    testWidgets('invokes caller-provided custom intent shortcuts', (tester) async {
      var invokedCount = 0;
      final focusNode = FocusNode(debugLabel: 'keystroke_listener_test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeystrokeListener(
              focusNode: focusNode,
              shortcuts: const <ShortcutActivator, Intent>{
                SingleActivator(LogicalKeyboardKey.keyD): _CustomShortcutIntent(),
              },
              actionHandlers: <Type, VoidCallback>{_CustomShortcutIntent: () => invokedCount++},
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyD);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyD);
      await tester.pump();

      expect(invokedCount, equals(1));

      focusNode.dispose();
    });
  });
}
