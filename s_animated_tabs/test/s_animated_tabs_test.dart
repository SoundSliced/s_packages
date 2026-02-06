import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_animated_tabs/s_animated_tabs.dart';

void main() {
  const titles = ['Overview', 'Details', 'Reviews'];

  Widget wrap(Widget child) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('renders all tab titles', (tester) async {
    await tester.pumpWidget(
      wrap(
        SAnimatedTabs(
          tabTitles: titles,
          onTabSelected: (_) {},
        ),
      ),
    );

    for (final title in titles) {
      expect(find.text(title), findsOneWidget);
    }
  });

  testWidgets('calls onTabSelected when tapping another tab', (tester) async {
    int? selectedIndex;

    await tester.pumpWidget(
      wrap(
        SAnimatedTabs(
          tabTitles: titles,
          onTabSelected: (index) => selectedIndex = index,
        ),
      ),
    );

    await tester.tap(find.text('Reviews'));
    await tester.pumpAndSettle();

    expect(selectedIndex, 2);
  });

  testWidgets('does not call onTabSelected for current tab', (tester) async {
    int calls = 0;

    await tester.pumpWidget(
      wrap(
        SAnimatedTabs(
          tabTitles: titles,
          initialIndex: 1,
          onTabSelected: (_) => calls++,
        ),
      ),
    );

    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();

    expect(calls, 0);
  });

  testWidgets('accepts custom configuration without errors', (tester) async {
    await tester.pumpWidget(
      wrap(
        SAnimatedTabs(
          tabTitles: titles,
          onTabSelected: (_) {},
          height: 52,
          width: 320,
          padding: const EdgeInsets.all(4),
          borderRadius: 12,
          animationDuration: const Duration(milliseconds: 320),
          animationCurve: Curves.easeOutQuart,
          enableHapticFeedback: false,
          enableElevation: true,
          elevation: 2,
          textSize: TabTextSize.medium,
          colorScheme: TabColorScheme.primary,
          enableEnhancedAnimations: true,
          animationStyle: TabAnimationStyle.smooth,
        ),
      ),
    );

    expect(find.byType(SAnimatedTabs), findsOneWidget);
  });
}
