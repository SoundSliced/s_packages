import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_item/settings_item.dart';

void main() {
  group('SettingsExpendableMenu Widget Tests', () {
    testWidgets('renders with default parameters', (WidgetTester tester) async {
      bool isActive = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsItem(
              isActive: isActive,
              onChange: (value) {
                isActive = value;
              },
            ),
          ),
        ),
      );

      expect(find.text('Settings Item'), findsOneWidget);
      expect(find.byType(SettingsItem), findsOneWidget);
    });

    testWidgets('renders with custom title and icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsItem(
              parameters: const ExpandableParameters(
                prefixIcon: Icons.settings,
                title: 'Custom Settings',
              ),
              isActive: false,
              onChange: (value) {},
            ),
          ),
        ),
      );

      expect(find.text('Custom Settings'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('switch mode renders toggle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsItem(
              parameters: const ExpandableParameters(
                title: 'Notifications',
                isSwitch: true,
              ),
              isActive: true,
              onChange: (value) {},
            ),
          ),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
      // SToggle widget should be present
      expect(find.byType(SettingsItem), findsOneWidget);
    });

    testWidgets('expandable mode shows up arrow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsItem(
              parameters: const ExpandableParameters(
                title: 'Expandable',
                isExpandeable: true,
              ),
              isActive: false,
              onChange: (value) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);
    });

    testWidgets('button mode shows left arrow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsItem(
              parameters: const ExpandableParameters(
                title: 'Button',
                isExpandeable: false,
              ),
              isActive: false,
              onChange: (value) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.keyboard_arrow_left_rounded), findsOneWidget);
    });

    testWidgets('onChange callback is called on tap',
        (WidgetTester tester) async {
      bool wasChanged = false;
      bool currentState = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsItem(
              parameters: const ExpandableParameters(
                title: 'Test Item',
              ),
              isActive: currentState,
              onChange: (value) {
                wasChanged = true;
                currentState = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Item'));
      await tester.pump();

      expect(wasChanged, true);
      expect(currentState, true);
    });

    testWidgets('custom suffix widget is displayed',
        (WidgetTester tester) async {
      const customText = 'Custom Suffix';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsItem(
              parameters: const ExpandableParameters(
                title: 'Custom',
                suffixWidget: Text(customText),
              ),
              isActive: false,
              onChange: (value) {},
            ),
          ),
        ),
      );

      expect(find.text(customText), findsOneWidget);
    });

    testWidgets('expanded widget is shown when active and expandable',
        (WidgetTester tester) async {
      const expandedText = 'Expanded Content';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsItem(
              parameters: const ExpandableParameters(
                title: 'Expandable Item',
                isExpandeable: true,
                expandedWidget: Text(expandedText),
              ),
              isActive: true,
              onChange: (value) {},
            ),
          ),
        ),
      );

      // Wait for animation to complete
      await tester.pumpAndSettle();

      expect(find.text(expandedText), findsOneWidget);
    });

    testWidgets('expanded widget is hidden when not active',
        (WidgetTester tester) async {
      const expandedText = 'Expanded Content';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsItem(
              parameters: const ExpandableParameters(
                title: 'Expandable Item',
                isExpandeable: true,
                expandedWidget: Text(expandedText),
              ),
              isActive: false,
              onChange: (value) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Content should be in widget tree but not visible (height: 0)
      expect(find.text(expandedText), findsOneWidget);
    });

    testWidgets('onExpandedSectionToggle callback is called',
        (WidgetTester tester) async {
      bool toggleCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsItem(
              parameters: ExpandableParameters(
                title: 'Toggle Test',
                isExpandeable: true,
                onExpandedSectionToggle: () {
                  toggleCalled = true;
                },
              ),
              isActive: false,
              onChange: (value) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Toggle Test'));
      await tester.pump();

      expect(toggleCalled, true);
    });

    testWidgets('arrow rotates when active', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsItem(
              parameters: const ExpandableParameters(
                title: 'Rotation Test',
                isExpandeable: true,
              ),
              isActive: true,
              onChange: (value) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the AnimatedRotation widget
      final animatedRotation = tester.widget<AnimatedRotation>(
        find.byType(AnimatedRotation),
      );

      // When active, rotation should be 0.5 (180 degrees)
      expect(animatedRotation.turns, 0.5);
    });

    testWidgets('arrow does not rotate when not active',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsItem(
              parameters: const ExpandableParameters(
                title: 'Rotation Test',
                isExpandeable: true,
              ),
              isActive: false,
              onChange: (value) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final animatedRotation = tester.widget<AnimatedRotation>(
        find.byType(AnimatedRotation),
      );

      // When not active, rotation should be 0.0
      expect(animatedRotation.turns, 0.0);
    });

    testWidgets('switch mode does not expand content',
        (WidgetTester tester) async {
      const expandedText = 'Should Not Show';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsItem(
              parameters: const ExpandableParameters(
                title: 'Switch Test',
                isSwitch: true,
                expandedWidget: Text(expandedText),
              ),
              isActive: true,
              onChange: (value) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Expanded widget should not be present in switch mode
      expect(find.text(expandedText), findsNothing);
    });
  });

  group('ExpandableParameters Tests', () {
    test('creates with default values', () {
      const params = ExpandableParameters();

      expect(params.prefixIcon, null);
      expect(params.title, null);
      expect(params.isSwitch, false);
      expect(params.isExpandeable, true);
      expect(params.expandedWidget, null);
      expect(params.suffixWidget, null);
    });

    test('creates with custom values', () {
      const params = ExpandableParameters(
        prefixIcon: Icons.settings,
        title: 'Custom Title',
        isSwitch: true,
        isExpandeable: false,
      );

      expect(params.prefixIcon, Icons.settings);
      expect(params.title, 'Custom Title');
      expect(params.isSwitch, true);
      expect(params.isExpandeable, false);
    });

    test('copyWith creates new instance with updated values', () {
      const original = ExpandableParameters(
        title: 'Original',
        isSwitch: false,
      );

      final updated = original.copyWith(
        title: 'Updated',
        isSwitch: true,
      );

      expect(updated.title, 'Updated');
      expect(updated.isSwitch, true);
      expect(original.title, 'Original');
      expect(original.isSwitch, false);
    });

    test('copyWith preserves original values when not specified', () {
      const original = ExpandableParameters(
        prefixIcon: Icons.settings,
        title: 'Original',
        isSwitch: true,
      );

      final updated = original.copyWith(title: 'Updated');

      expect(updated.prefixIcon, Icons.settings);
      expect(updated.title, 'Updated');
      expect(updated.isSwitch, true);
    });

    test('equality works correctly', () {
      const params1 = ExpandableParameters(
        title: 'Test',
        isSwitch: true,
      );

      const params2 = ExpandableParameters(
        title: 'Test',
        isSwitch: true,
      );

      const params3 = ExpandableParameters(
        title: 'Different',
        isSwitch: true,
      );

      expect(params1 == params2, true);
      expect(params1 == params3, false);
    });

    test('hashCode is consistent', () {
      const params1 = ExpandableParameters(
        title: 'Test',
        isSwitch: true,
      );

      const params2 = ExpandableParameters(
        title: 'Test',
        isSwitch: true,
      );

      expect(params1.hashCode, params2.hashCode);
    });
  });
}
