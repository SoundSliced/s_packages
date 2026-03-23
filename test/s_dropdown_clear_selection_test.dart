import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_packages.dart';

void main() {
  group('SDropdown clear selection', () {
    testWidgets('restores the initial selection when cleared while closed', (tester) async {
      const String initialItem = 'Banana';
      final controller = SDropdownController();
      String? selectedItem = initialItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SDropdown(
                  items: const ['Apple', 'Banana', 'Cherry', 'Durian'],
                  selectedItem: selectedItem,
                  initialItem: initialItem,
                  hintText: 'Pick a fruit',
                  controller: controller,
                  onChanged: (value) {
                    setState(() {
                      selectedItem = value;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text(initialItem), findsOneWidget);

      controller.selectIndex(2);
      await tester.pumpAndSettle();

      expect(selectedItem, 'Cherry');
      expect(find.text('Cherry'), findsOneWidget);

      controller.clearSelection();
      await tester.pumpAndSettle();

      expect(selectedItem, initialItem);
      expect(find.text(initialItem), findsOneWidget);
    });

    testWidgets('clears to the hint while the overlay stays open', (tester) async {
      final controller = SDropdownController();
      String? selectedItem = 'Banana';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SDropdown(
                  items: const ['Apple', 'Banana', 'Cherry', 'Durian'],
                  selectedItem: selectedItem,
                  initialItem: 'Banana',
                  hintText: 'Pick a fruit',
                  controller: controller,
                  onChanged: (value) {
                    setState(() {
                      selectedItem = value;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      controller.open();
      await tester.pumpAndSettle();

      expect(controller.isExpanded, isTrue);
      expect(find.text('Banana'), findsWidgets);

      controller.clearSelection(restoreInitialSelection: false);
      await tester.pumpAndSettle();

      expect(controller.isExpanded, isTrue);
      expect(selectedItem, isNull);
      expect(find.text('Pick a fruit'), findsOneWidget);
    });

    testWidgets('shows an inline clear button that clears the selection', (tester) async {
      String? selectedItem = 'Banana';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SDropdown(
                  items: const ['Apple', 'Banana', 'Cherry', 'Durian'],
                  selectedItem: selectedItem,
                  initialItem: 'Banana',
                  hintText: 'Pick a fruit',
                  clearButtonRestoresInitialSelection: false,
                  onChanged: (value) {
                    setState(() {
                      selectedItem = value;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(SInkButton), findsOneWidget);

      await tester.tap(find.byType(SInkButton));
      await tester.pumpAndSettle();

      expect(selectedItem, isNull);
      expect(find.text('Pick a fruit'), findsOneWidget);
      expect(find.byType(SInkButton), findsNothing);
    });

    testWidgets('does not show a clear button when only the hint is shown', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SDropdown(
              items: ['Apple', 'Banana', 'Cherry', 'Durian'],
              hintText: 'Pick a fruit',
            ),
          ),
        ),
      );

      expect(find.text('Pick a fruit'), findsOneWidget);
      expect(find.byType(SInkButton), findsNothing);
    });

    testWidgets('inherits a popup tap-region group for the overlay', (tester) async {
      final controller = SDropdownController();
      final inheritedGroupId = Object();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PopOverlayTapRegionScope(
              tapRegionGroupId: inheritedGroupId,
              child: SDropdown(
                items: const ['Apple', 'Banana', 'Cherry', 'Durian'],
                hintText: 'Pick a fruit',
                controller: controller,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      controller.open();
      await tester.pumpAndSettle();

      final tapRegions = tester.widgetList<TapRegion>(find.byType(TapRegion));

      expect(tapRegions, isNotEmpty);
      expect(
        tapRegions.any((region) => identical(region.groupId, inheritedGroupId)),
        isTrue,
      );
    });
  });
}
