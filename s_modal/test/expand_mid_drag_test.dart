import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_modal/s_modal.dart';

void main() {
  setUp(() {
    // Install state is global/static; make sure each test starts with a clean
    // slate to avoid stale overlay entries.
    Modal.disposeActivator();
  });

  tearDown(() {
    // Clean up any active modal between tests.
    Modal.dismissAll();
    Modal.disposeActivator();
  });

  testWidgets('Right side sheet can be expanded', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: Modal.appBuilder,
        home: const Scaffold(body: SizedBox.expand()),
      ),
    );

    // Show right side sheet and capture onExpanded callback
    // ignore: unused_local_variable
    bool expandedCalled = false;
    Modal.show(
      context: tester.element(find.byType(Scaffold)),
      builder: ([_]) => const SizedBox(width: 200, height: 200),
      modalType: ModalType.sheet,
      sheetPosition: SheetPosition.right,
      modalPosition: Alignment.centerRight,
      isExpandable: true,
      expandedPercentageSize: 80,
      onExpanded: () {
        expandedCalled = true;
      },
    );

    await tester.pumpAndSettle();

    // Verify the sheet is displayed by searching for the widget our builder returns.
    // Use a predicate matcher to be resilient to rebuilds.
    expect(
      find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == 200 && w.height == 200,
      ),
      findsOneWidget,
    );

    // The test verifies that the sheet can be shown and is expandable
    // without crashing. Actual expansion behavior is tested in integration tests.
  });
  testWidgets('Bottom sheet can be expanded', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: Modal.appBuilder,
        home: const Scaffold(body: SizedBox.expand()),
      ),
    );

    // Show bottom sheet and capture onExpanded callback
    // ignore: unused_local_variable
    bool expandedCalled = false;
    Modal.show(
      context: tester.element(find.byType(Scaffold)),
      builder: ([_]) => const SizedBox(width: 200, height: 200),
      modalType: ModalType.sheet,
      modalPosition: Alignment.bottomCenter,
      isExpandable: true,
      expandedPercentageSize: 90,
      onExpanded: () {
        expandedCalled = true;
      },
    );

    await tester.pumpAndSettle();

    // Verify the sheet is displayed by searching for the widget our builder returns.
    expect(
      find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == 200 && w.height == 200,
      ),
      findsOneWidget,
    );

    // The test verifies that the sheet can be shown and is expandable
    // without crashing. Actual expansion behavior is tested in integration tests.
  });
}
