import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_button/s_button.dart';
import 'package:s_expendable_menu/s_expendable_menu.dart';

void main() {
  testWidgets('SExpandableMenu expands and collapses', (tester) async {
    final items = [
      SExpandableItem(icon: Icons.home),
      SExpandableItem(icon: Icons.search),
      SExpandableItem(icon: Icons.favorite),
      SExpandableItem(icon: Icons.settings),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SExpandableMenu(
              items: items,
              width: 60,
              height: 60,
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(ListView), findsNothing);

    final handleFinder = find.byType(SInkButton).first;
    await tester.tap(handleFinder);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(ListView), findsOneWidget);

    await tester.tap(handleFinder);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('SExpandableHandles triggers onTap', (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SExpandableHandles(
              width: 60,
              height: 60,
              iconColor: Colors.white,
              isExpanded: false,
              expandsRight: true,
              onTap: () => tapCount++,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(SExpandableHandles));
    await tester.pump(const Duration(milliseconds: 500));

    expect(tapCount, 1);
  });
}
