import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_sidebar/s_sidebar.dart';

void main() {
  group('SSideBar Widget Tests', () {
    late List<SSideBarItem> testItems;

    setUp(() {
      testItems = [
        SSideBarItem(
          iconSelected: Icons.home,
          title: 'Home',
        ),
        SSideBarItem(
          iconSelected: Icons.settings,
          iconUnselected: Icons.settings_outlined,
          title: 'Settings',
        ),
      ];
    });

    testWidgets('SSideBar creates successfully with required parameters',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: testItems,
              onTapForAllTabButtons: (index) {},
            ),
          ),
        ),
      );

      expect(find.byType(SSideBar), findsOneWidget);
    });

    testWidgets('SSideBar displays correct number of items',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: testItems,
              onTapForAllTabButtons: (index) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify items are present
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('SSideBar handles tap events correctly',
        (WidgetTester tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: testItems,
              isMinimized: false,
              onTapForAllTabButtons: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the settings item
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(tappedIndex, equals(1));
    });

    testWidgets('SSideBar respects isMinimized property',
        (WidgetTester tester) async {
      // Test minimized state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: testItems,
              isMinimized: true,
              onTapForAllTabButtons: (index) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // In minimized state, text should not be visible
      expect(find.text('Home'), findsNothing);
      expect(find.text('Settings'), findsNothing);

      // Icons should still be present
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('SSideBar displays logo when provided',
        (WidgetTester tester) async {
      const logoKey = Key('test_logo');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: testItems,
              onTapForAllTabButtons: (index) {},
              logo: Container(
                key: logoKey,
                width: 50,
                height: 50,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(logoKey), findsOneWidget);
    });

    testWidgets('SSideBar respects custom colors', (WidgetTester tester) async {
      const customColor = Color(0xFF123456);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: testItems,
              onTapForAllTabButtons: (index) {},
              sideBarColor: customColor,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the AnimatedContainer and verify decoration
      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      final decoration = animatedContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(customColor));
    });

    testWidgets('SSideBar handles preSelectedItemIndex correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: testItems,
              onTapForAllTabButtons: (index) {},
              preSelectedItemIndex: 1,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The second item should be selected (verified by visual state)
      // This is a basic check; more detailed state verification could be added
      expect(find.byType(SSideBar), findsOneWidget);
    });

    testWidgets('SSideBar applies custom dimensions',
        (WidgetTester tester) async {
      const customWidth = 300.0;
      const customSmallWidth = 100.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: testItems,
              onTapForAllTabButtons: (index) {},
              sideBarWidth: customWidth,
              sideBarSmallWidth: customSmallWidth,
              isMinimized: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      final constraints = animatedContainer.constraints as BoxConstraints;
      expect(constraints.maxWidth, equals(customWidth));
      expect(constraints.minWidth, equals(customWidth));
    });

    testWidgets('SSideBar displays badges when provided',
        (WidgetTester tester) async {
      final itemsWithBadge = [
        SSideBarItem(
          iconSelected: Icons.notifications,
          title: 'Notifications',
          badgeText: '5',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: itemsWithBadge,
              onTapForAllTabButtons: (index) {},
              isMinimized: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('SSideBar handles compact mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: testItems,
              onTapForAllTabButtons: (index) {},
              compactMode: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SSideBar), findsOneWidget);
    });

    testWidgets('SSideBar minimize button toggles state',
        (WidgetTester tester) async {
      bool? minimizedState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: testItems,
              onTapForAllTabButtons: (index) {},
              isMinimized: false,
              minimizeButtonOnTap: (isMinimized) {
                minimizedState = isMinimized;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the minimize button by key (works for both icon variants)
      final minimizeButton =
          find.byKey(ValueKey("SSideBar MinimizeButton + false"));
      expect(minimizeButton, findsOneWidget);

      await tester.tap(minimizeButton);
      await tester.pumpAndSettle();

      expect(minimizedState, isTrue);
    });
  });

  group('SSideBarItem Tests', () {
    test('SSideBarItem creates with required parameters', () {
      final item = SSideBarItem(
        iconSelected: Icons.home,
        title: 'Home',
      );

      expect(item.iconSelected, equals(Icons.home));
      expect(item.title, equals('Home'));
      expect(item.iconUnselected, isNull);
      expect(item.tooltip, isNull);
      expect(item.badgeText, isNull);
    });

    test('SSideBarItem creates with all parameters', () {
      final item = SSideBarItem(
        iconSelected: Icons.home,
        iconUnselected: Icons.home_outlined,
        title: 'Home',
        tooltip: 'Go to Home',
        badgeText: '3',
        badgeColor: Colors.red,
        onTap: (offset) {},
      );

      expect(item.iconSelected, equals(Icons.home));
      expect(item.iconUnselected, equals(Icons.home_outlined));
      expect(item.title, equals('Home'));
      expect(item.tooltip, equals('Go to Home'));
      expect(item.badgeText, equals('3'));
      expect(item.badgeColor, equals(Colors.red));
      expect(item.onTap, isNotNull);
    });
  });

  group('SideBarController Tests', () {
    setUp(() {
      // Reset controller state before each test
      final controller = SideBarController.getController();
      controller.setState((s) => s
        ..isActive = false
        ..isMinimized = false);
    });

    test('SideBarController initializes correctly', () {
      final controller = SideBarController.getController();
      expect(controller, isNotNull);
      expect(SideBarController.isSideBarActive(), isFalse);
      expect(SideBarController.isSideBarMinimized(), isFalse);
    });

    test('SideBarController setMinimizedState updates state', () {
      SideBarController.setMinimizedState(true);
      expect(SideBarController.isSideBarMinimized(), isTrue);

      SideBarController.setMinimizedState(false);
      expect(SideBarController.isSideBarMinimized(), isFalse);
    });
  });

  group('SSideBar Edge Cases', () {
    testWidgets('SSideBar throws error with empty items list',
        (WidgetTester tester) async {
      // The assert happens in initState, so we need to pump the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: [],
              onTapForAllTabButtons: (index) {},
            ),
          ),
        ),
      );

      // Expect an assertion error
      expect(tester.takeException(), isA<AssertionError>());
    });

    testWidgets('SSideBar handles shouldTapItems correctly',
        (WidgetTester tester) async {
      int? tappedIndex;
      final items = [
        SSideBarItem(iconSelected: Icons.home, title: 'Home'),
        SSideBarItem(iconSelected: Icons.settings, title: 'Settings'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: items,
              onTapForAllTabButtons: (index) {
                tappedIndex = index;
              },
              shouldTapItems: [true, false], // Second item disabled
              preSelectedItemIndex: 1, // Start with Settings selected
              isMinimized: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the enabled home item - should work
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(tappedIndex, equals(0));

      // Reset tappedIndex
      tappedIndex = null;

      // Try to tap the disabled settings item - should not trigger callback
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Index should remain null as the item is disabled
      expect(tappedIndex, isNull);
    });

    testWidgets('SSideBar handles divider with settingsDivider enabled',
        (WidgetTester tester) async {
      final items = [
        SSideBarItem(iconSelected: Icons.home, title: 'Home'),
        SSideBarItem(iconSelected: Icons.dashboard, title: 'Dashboard'),
        SSideBarItem(iconSelected: Icons.settings, title: 'Settings'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SSideBar(
              sidebarItems: items,
              onTapForAllTabButtons: (index) {},
              settingsDivider: true,
              isMinimized: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Divider should be present before the last item
      expect(find.byType(Divider), findsOneWidget);
    });
  });
}
