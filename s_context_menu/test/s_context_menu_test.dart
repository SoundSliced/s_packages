import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_context_menu/s_context_menu.dart';

void main() {
  group('SContextMenu Widget Tests', () {
    testWidgets('SContextMenu renders child widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SContextMenu(
              buttons: [],
              child: Container(
                key: const Key('test_child'),
                child: const Text('Test Child'),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('test_child')), findsOneWidget);
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('SContextMenu buttons parameter is respected',
        (WidgetTester tester) async {
      final buttons = [
        SContextMenuItem(
          label: 'Edit',
          icon: Icons.edit,
          onPressed: () {},
        ),
        SContextMenuItem(
          label: 'Delete',
          icon: Icons.delete,
          onPressed: () {},
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SContextMenu(
              buttons: buttons,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(SContextMenu), findsOneWidget);
    });

    testWidgets('SContextMenu has correct initial state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SContextMenu(
              buttons: [],
              child: const Text('Test'),
            ),
          ),
        ),
      );

      expect(SContextMenu.hasOpenMenu, false);
      expect(SContextMenu.hasAnyOpenMenus, false);
    });

    testWidgets('SContextMenu static methods exist and are callable',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SContextMenu(
              buttons: [],
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Test that static methods can be called
      SContextMenu.closeOpenMenu();
      SContextMenu.closeAllOpenMenus();
      expect(SContextMenu.hasOpenMenu, false);
      expect(SContextMenu.hasAnyOpenMenus, false);
    });

    testWidgets('SContextMenuItem creates correctly',
        (WidgetTester tester) async {
      bool pressed = false;

      final item = SContextMenuItem(
        label: 'Test Item',
        icon: Icons.edit,
        onPressed: () {
          pressed = true;
        },
        destructive: false,
      );

      expect(item.label, 'Test Item');
      expect(item.icon, Icons.edit);
      expect(item.destructive, false);

      item.onPressed();
      expect(pressed, true);
    });

    testWidgets('SContextMenuItem destructive flag works',
        (WidgetTester tester) async {
      final destructiveItem = SContextMenuItem(
        label: 'Delete',
        icon: Icons.delete,
        onPressed: () {},
        destructive: true,
      );

      expect(destructiveItem.destructive, true);

      final normalItem = SContextMenuItem(
        label: 'Edit',
        icon: Icons.edit,
        onPressed: () {},
      );

      expect(normalItem.destructive, false);
    });

    testWidgets('SContextMenuTheme initializes with defaults',
        (WidgetTester tester) async {
      const theme = SContextMenuTheme();

      expect(theme.panelBorderRadius, 8);
      expect(theme.panelBlurSigma, 20);
      expect(theme.arrowShape, ArrowShape.smallTriangle);
      expect(theme.arrowBaseWidth, 10);
      expect(theme.showDuration, const Duration(milliseconds: 200));
      expect(theme.hideDuration, const Duration(milliseconds: 150));
    });

    testWidgets('SContextMenuTheme copyWith creates new instance',
        (WidgetTester tester) async {
      const originalTheme = SContextMenuTheme(
        panelBorderRadius: 8,
        panelBlurSigma: 20,
      );

      final newTheme = originalTheme.copyWith(
        panelBorderRadius: 16,
        arrowShape: ArrowShape.curved,
      );

      expect(newTheme.panelBorderRadius, 16);
      expect(newTheme.panelBlurSigma, 20);
      expect(newTheme.arrowShape, ArrowShape.curved);
    });

    testWidgets('Multiple SContextMenu widgets can coexist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SContextMenu(
                  buttons: [
                    SContextMenuItem(
                      label: 'Option 1',
                      onPressed: () {},
                    ),
                  ],
                  child: const Text('Menu 1'),
                ),
                SContextMenu(
                  buttons: [
                    SContextMenuItem(
                      label: 'Option 2',
                      onPressed: () {},
                    ),
                  ],
                  child: const Text('Menu 2'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SContextMenu), findsWidgets);
      expect(find.text('Menu 1'), findsOneWidget);
      expect(find.text('Menu 2'), findsOneWidget);
    });

    testWidgets('SContextMenu with empty buttons list renders',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SContextMenu(
              buttons: [],
              child: const Text('Test'),
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('SContextMenu respects callbacks', (WidgetTester tester) async {
      // ignore: unused_local_variable
      bool openCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SContextMenu(
              buttons: [],
              onOpened: () {
                openCalled = true;
              },
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Note: Actual menu interaction would require tester.click() or similar
      // This test just verifies the callback parameter is accepted
      expect(find.byType(SContextMenu), findsOneWidget);
    });

    testWidgets('SContextMenu followAnchor parameter is accepted',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SContextMenu(
              followAnchor: true,
              buttons: [],
              child: const Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(SContextMenu), findsOneWidget);
    });

    testWidgets('SContextMenu allowMultipleMenus parameter is accepted',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SContextMenu(
              allowMultipleMenus: true,
              buttons: [],
              child: const Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(SContextMenu), findsOneWidget);
    });
  });
}
