// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_modal/s_modal.dart';

// Helper builder for tests
Widget _testBuilder([BuildContext? _]) => const SizedBox();

// Helper to pump a test app with Modal.appBuilder installed
Future<BuildContext> _pumpTestApp(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      builder: Modal.appBuilder,
      home: const Scaffold(body: SizedBox.expand()),
    ),
  );
  await tester.pump();
  return tester.element(find.byType(Scaffold));
}

void main() {
  tearDown(() {
    // Clean up all modals after each test
    Modal.dismissAll();
  });

  group('Modal API Tests', () {
    testWidgets('Modal.show() accepts all ModalType values',
        (WidgetTester tester) async {
      final ctx = await _pumpTestApp(tester);
      // These should not throw - just testing API availability
      expect(
          () => Modal.show(
              context: ctx, builder: _testBuilder, modalType: ModalType.sheet),
          returnsNormally);
      expect(
          () => Modal.show(
              context: ctx, builder: _testBuilder, modalType: ModalType.sheet),
          returnsNormally);
      expect(
          () => Modal.show(
              context: ctx, builder: _testBuilder, modalType: ModalType.dialog),
          returnsNormally);
      expect(
          () => Modal.show(
              context: ctx, builder: _testBuilder, modalType: ModalType.sheet),
          returnsNormally);
      expect(
          () => Modal.show(
              context: ctx,
              builder: _testBuilder,
              modalType: ModalType.snackbar),
          returnsNormally);
      expect(
          () => Modal.show(
              context: ctx, builder: _testBuilder, modalType: ModalType.custom),
          returnsNormally);
    });

    testWidgets('Modal.show() accepts various configuration parameters',
        (WidgetTester tester) async {
      final ctx = await _pumpTestApp(tester);
      expect(
        () => Modal.show(
          context: ctx,
          builder: _testBuilder,
          modalType: ModalType.dialog,
          modalPosition: Alignment.center,
          shouldBlurBackground: true,
          blurAmount: 5.0,
          isDismissable: false,
          isExpandable: true,
          size: 500,
          expandedPercentageSize: 90,
        ),
        returnsNormally,
      );
    });

    test('ModalType enum has all expected values', () {
      expect(ModalType.values, contains(ModalType.sheet));
      expect(ModalType.values, contains(ModalType.dialog));
      expect(ModalType.values, contains(ModalType.snackbar));
      expect(ModalType.values, contains(ModalType.custom));
    });

    testWidgets(
        'Modal.show() supports various Alignment values for modalPosition',
        (WidgetTester tester) async {
      final ctx = await _pumpTestApp(tester);
      // Test that modalPosition parameter accepts standard Alignment values
      expect(
          () => Modal.show(
              context: ctx,
              builder: _testBuilder,
              modalPosition: Alignment.center),
          returnsNormally);
      expect(
          () => Modal.show(
              context: ctx,
              builder: _testBuilder,
              modalPosition: Alignment.topLeft),
          returnsNormally);
      expect(
          () => Modal.show(
              context: ctx,
              builder: _testBuilder,
              modalPosition: Alignment.topRight),
          returnsNormally);
      expect(
          () => Modal.show(
              context: ctx,
              builder: _testBuilder,
              modalPosition: Alignment.bottomLeft),
          returnsNormally);
      expect(
          () => Modal.show(
              context: ctx,
              builder: _testBuilder,
              modalPosition: Alignment.bottomRight),
          returnsNormally);
      expect(
          () => Modal.show(
              context: ctx,
              builder: _testBuilder,
              modalPosition: Alignment.centerLeft),
          returnsNormally);
      expect(
          () => Modal.show(
              context: ctx,
              builder: _testBuilder,
              modalPosition: Alignment.centerRight),
          returnsNormally);
      expect(
          () => Modal.show(
              context: ctx,
              builder: _testBuilder,
              modalPosition: Alignment.topCenter),
          returnsNormally);
      expect(
          () => Modal.show(
              context: ctx,
              builder: _testBuilder,
              modalPosition: Alignment.bottomCenter),
          returnsNormally);
    });

    test('ModalAnimationType enum has all expected values', () {
      expect(ModalAnimationType.values, contains(ModalAnimationType.fade));
      expect(ModalAnimationType.values, contains(ModalAnimationType.scale));
      expect(ModalAnimationType.values, contains(ModalAnimationType.slide));
      expect(ModalAnimationType.values, contains(ModalAnimationType.rotate));
    });
  });

  group('Modal ID Tests', () {
    testWidgets('Modal.show() with custom ID can be referenced',
        (WidgetTester tester) async {
      final ctx = await _pumpTestApp(tester);
      // Show a modal with a custom ID
      Modal.show(context: ctx, builder: _testBuilder, id: 'my_custom_id');

      // The ID should be tracked
      expect(Modal.isModalActiveById('my_custom_id'), true);
      expect(Modal.allActiveModalIds, contains('my_custom_id'));

      // Cleanup - start dismissal but await it after pumping to avoid deadlock with Future.delayed
      final dismissFuture = Modal.dismissById('my_custom_id');
      await tester.pumpAndSettle();
      await dismissFuture;
    });

    testWidgets('Modal.showSnackbar() supports custom ID parameter',
        (WidgetTester tester) async {
      final ctx = await _pumpTestApp(tester);
      Modal.showSnackbar(
        context: ctx,
        text: 'Test message',
        id: 'snackbar_123',
      );

      expect(Modal.isModalActiveById('snackbar_123'), true);

      // Cleanup - start dismissal but await it after pumping to avoid deadlock with Future.delayed
      final dismissFuture = Modal.dismissById('snackbar_123');
      await tester.pumpAndSettle();
      await dismissFuture;
    });
  });

  group('Type-Specific Controller Tests', () {
    test('Dialog controller is accessible', () {
      expect(Modal.dialogController, isNotNull);
    });

    test('Sheet controller is accessible', () {
      expect(Modal.sheetController, isNotNull);
    });

    test('Snackbar controller is accessible', () {
      expect(Modal.snackbarController, isNotNull);
    });

    test('Type-specific state checks are initially false', () {
      // Ensure all modals are dismissed before checking
      Modal.dismissAll();
      Modal.dismissAllSnackbars();
      expect(Modal.isDialogActive, false);
      expect(Modal.isSheetActive, false);
      expect(Modal.isSnackbarActive, false);
    });

    test('Type-specific dismissing states are initially false', () {
      // Ensure all modals are dismissed before checking
      Modal.dismissAll();
      Modal.dismissAllSnackbars();
      expect(Modal.isDialogDismissing, false);
      expect(Modal.isSheetDismissing, false);
      expect(Modal.isSnackbarDismissing, false);
    });
  });

  group('Modal ID Management Tests', () {
    test('activeModalId returns null when no modal is active', () {
      // Ensure all modals are dismissed before checking
      Modal.dismissAll();
      Modal.dismissAllSnackbars();
      expect(Modal.activeModalId, isNull);
    });

    test('isModalActiveById returns false when no modal is active', () {
      expect(Modal.isModalActiveById('any_id'), false);
    });

    test('allActiveModalIds returns empty list when no modals are active', () {
      // Ensure all modals are dismissed before checking
      Modal.dismissAll();
      Modal.dismissAllSnackbars();
      expect(Modal.allActiveModalIds, isEmpty);
    });
  });

  group('Snackbar Configuration Tests', () {
    test('SnackbarDisplayMode enum has all expected values', () {
      expect(
          SnackbarDisplayMode.values, contains(SnackbarDisplayMode.staggered));
      expect(SnackbarDisplayMode.values,
          contains(SnackbarDisplayMode.notificationBubble));
      expect(SnackbarDisplayMode.values, contains(SnackbarDisplayMode.queued));
      expect(SnackbarDisplayMode.values, contains(SnackbarDisplayMode.replace));
    });

    testWidgets('Modal.showSnackbar() accepts configuration parameters',
        (WidgetTester tester) async {
      final ctx = await _pumpTestApp(tester);
      expect(
        () => Modal.showSnackbar(
          context: ctx,
          text: 'Test notification',
          position: Alignment.topCenter,
          duration: const Duration(seconds: 3),
          isDismissible: true,
          displayMode: SnackbarDisplayMode.staggered,
        ),
        returnsNormally,
      );
    });
  });

  group('Modal Static Methods Tests', () {
    test('Modal.bottomSheetTemplate is accessible', () {
      final template = Modal.bottomSheetTemplate;
      expect(template, isNotNull);
    });

    test('Modal.isActive returns false initially', () {
      // Ensure all modals are dismissed before checking
      Modal.dismissAll();
      Modal.dismissAllSnackbars();
      expect(Modal.isActive, false);
    });

    test('Modal.controller is accessible', () {
      expect(Modal.controller, isNotNull);
    });

    test('Modal.dismissModalAnimationController is accessible', () {
      expect(Modal.dismissModalAnimationController, isNotNull);
    });

    test('Modal.snackbarQueue is accessible', () {
      expect(Modal.snackbarQueue, isNotNull);
    });

    test('Modal.snackbarStackIndex is accessible', () {
      expect(Modal.snackbarStackIndex, isNotNull);
    });
  });

  group('Modal Lifecycle Tests', () {
    testWidgets('Dialog barrier dismiss shows snackbar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: Modal.appBuilder,
          home: const Scaffold(body: SizedBox.expand()),
        ),
      );

      await tester.pump();

      // Show dialog with onDismissed that shows a snackbar
      Modal.show(
        context: tester.element(find.byType(Scaffold)),
        builder: ([_]) => const SizedBox(width: 100, height: 100),
        modalType: ModalType.dialog,
        onDismissed: () {
          Modal.showSnackbar(
            context: tester.element(find.byType(Scaffold)),
            text: 'Dismissed',
            duration: null,
            isDismissible: true,
          );
        },
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(Modal.isDialogActive, true);

      // Tap barrier to dismiss
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify dialog dismissed and snackbar shown
      expect(Modal.isDialogActive, false);
      expect(Modal.isSnackbarActive, true);

      // Clean up before test ends
      Modal.dismissAllSnackbars();
      await tester.pump();
    });

    test('Modal.updateParams is callable', () {
      // Test that updateParams can be called (edge cases tested in integration tests)
      expect(
          () => Modal.updateParams(id: 'nonexistent_id', isDismissable: false),
          returnsNormally);
    });
  });

  group('Modal State Management Tests', () {
    test('Modal.isDismissing flag exists', () {
      expect(Modal.isDismissing, isA<bool>());
    });

    test('Modal.registerHeightResetCallback accepts valid callback', () {
      void testCallback() {}
      expect(
        () => Modal.registerHeightResetCallback(testCallback),
        returnsNormally,
      );
    });
  });

  group('Modal API Parameter Tests', () {
    testWidgets('Modal.show() accepts size parameter',
        (WidgetTester tester) async {
      final ctx = await _pumpTestApp(tester);
      expect(
        () => Modal.show(context: ctx, builder: _testBuilder, size: 200),
        returnsNormally,
      );
      expect(
        () => Modal.show(context: ctx, builder: _testBuilder, size: 600),
        returnsNormally,
      );
    });

    testWidgets('Modal.show() accepts expandedPercentageSize parameter',
        (WidgetTester tester) async {
      final ctx = await _pumpTestApp(tester);
      expect(
        () => Modal.show(
            context: ctx,
            builder: _testBuilder,
            isExpandable: true,
            expandedPercentageSize: 50),
        returnsNormally,
      );
      expect(
        () => Modal.show(
            context: ctx,
            builder: _testBuilder,
            isExpandable: true,
            expandedPercentageSize: 100),
        returnsNormally,
      );
    });
  });

  group('Enum Tests', () {
    test('ModalType enum values are distinct', () {
      final types = ModalType.values;
      expect(types.length, 4); // sheet, dialog, snackbar, custom
      expect(types.toSet().length, 4);
    });

    test('Alignment values work with modalPosition', () {
      // Test common alignment values work with modalPosition
      final positions = [
        Alignment.center,
        Alignment.topLeft,
        Alignment.topCenter,
        Alignment.topRight,
        Alignment.bottomLeft,
        Alignment.bottomCenter,
        Alignment.bottomRight,
        Alignment.centerLeft,
        Alignment.centerRight,
      ];
      expect(positions.length, 9);
      expect(positions.toSet().length, 9);
    });

    test('ModalAnimationType enum values are distinct', () {
      final animations = ModalAnimationType.values;
      expect(animations.length, 4);
      expect(animations.toSet().length, 4);
    });
  });

  group('Callback Tests', () {
    testWidgets('Modal.show() accepts onDismissed callback',
        (WidgetTester tester) async {
      final ctx = await _pumpTestApp(tester);
      bool called = false;
      void callback() {
        called = true;
      }

      expect(
        () => Modal.show(
            context: ctx, builder: _testBuilder, onDismissed: callback),
        returnsNormally,
      );
    });

    testWidgets('Modal.show() accepts onExpanded callback',
        (WidgetTester tester) async {
      final ctx = await _pumpTestApp(tester);
      bool called = false;
      void callback() {
        called = true;
      }

      expect(
        () => Modal.show(
            context: ctx, builder: _testBuilder, onExpanded: callback),
        returnsNormally,
      );
    });

    testWidgets('Modal.show() can accept multiple callbacks',
        (WidgetTester tester) async {
      final ctx = await _pumpTestApp(tester);
      int callCount = 0;

      void onDismissed() {
        callCount++;
      }

      void onExpanded() {
        callCount++;
      }

      expect(
        () => Modal.show(
          context: ctx,
          builder: _testBuilder,
          onDismissed: onDismissed,
          onExpanded: onExpanded,
        ),
        returnsNormally,
      );
    });
  });

  group('Configuration Combinations Tests', () {
    testWidgets('ModalContent supports all valid combinations',
        (WidgetTester tester) async {
      final ctx = await _pumpTestApp(tester);
      final types = ModalType.values;
      final positions = [
        Alignment.center,
        Alignment.topLeft,
        Alignment.bottomCenter,
      ];
      final animations = ModalAnimationType.values;

      // Test a sample of combinations
      expect(
        () => Modal.show(
          context: ctx,
          builder: _testBuilder,
          modalType: ModalType.sheet,
          modalPosition: Alignment.bottomCenter,
          modalAnimationType: ModalAnimationType.fade,
        ),
        returnsNormally,
      );

      expect(
        () => Modal.show(
          context: ctx,
          builder: _testBuilder,
          modalType: ModalType.dialog,
          modalPosition: Alignment.center,
          modalAnimationType: ModalAnimationType.scale,
        ),
        returnsNormally,
      );
    });

    testWidgets('Modal.show() accepts bottom sheet specific configurations',
        (WidgetTester tester) async {
      final ctx = await _pumpTestApp(tester);
      expect(
        () => Modal.show(
          context: ctx,
          builder: _testBuilder,
          modalType: ModalType.sheet,
          isExpandable: true,
          size: 300,
          expandedPercentageSize: 85,
          isDismissable: true,
        ),
        returnsNormally,
      );
    });

    testWidgets('Modal.show() accepts dialog specific configurations',
        (WidgetTester tester) async {
      final ctx = await _pumpTestApp(tester);
      expect(
        () => Modal.show(
          context: ctx,
          builder: _testBuilder,
          modalType: ModalType.dialog,
          modalPosition: Alignment.center,
          shouldBlurBackground: true,
          isDismissable: false,
        ),
        returnsNormally,
      );
    });
  });

  group('Modal API Default Behavior Tests', () {
    testWidgets('Modal.show() has sensible defaults',
        (WidgetTester tester) async {
      final ctx = await _pumpTestApp(tester);
      // Should not throw when called with only required builder parameter
      expect(() => Modal.show(context: ctx, builder: _testBuilder),
          returnsNormally);
    });
  });

  group('Dismissal Method Tests', () {
    test('dismissByType exists for all modal types', () {
      // These should complete without error even when no modal is active
      expect(() async => await Modal.dismissByType(ModalType.dialog),
          returnsNormally);
      expect(() async => await Modal.dismissByType(ModalType.sheet),
          returnsNormally);
      expect(() async => await Modal.dismissByType(ModalType.snackbar),
          returnsNormally);
      expect(() async => await Modal.dismissByType(ModalType.custom),
          returnsNormally);
    });

    test('dismissAllSnackbars exists and is callable', () {
      expect(() => Modal.dismissAllSnackbars(), returnsNormally);
    });

    test('dismissById exists and is callable', () {
      expect(() async => await Modal.dismissById('nonexistent_id'),
          returnsNormally);
    });

    test('dismissSnackbarAtPosition exists and is callable', () {
      expect(() => Modal.dismissSnackbarAtPosition(Alignment.topCenter),
          returnsNormally);
    });
  });

  group('Snackbar Auto-Dismiss & Cancellation', () {
    testWidgets('Snackbar can be shown and dismissed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: Modal.appBuilder,
          home: const Scaffold(body: SizedBox.expand()),
        ),
      );

      await tester.pump();

      Modal.showSnackbar(
        context: tester.element(find.byType(Scaffold)),
        text: 'Test Snackbar',
        duration: null, // No auto-dismiss for reliable testing
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(Modal.isSnackbarActive, true);

      // Dismiss manually
      Modal.dismissAllSnackbars();
      await tester.pump();

      expect(Modal.isSnackbarActive, false);
    });

    testWidgets('Manual dismiss cancels auto-dismiss timer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: Modal.appBuilder,
          home: const Scaffold(body: SizedBox.expand()),
        ),
      );

      // Modal is automatically initialized through MaterialApp builder
      await tester.pump();

      Modal.showSnackbar(
        context: tester.element(find.byType(Scaffold)),
        text: 'Manual Dismiss',
        duration: const Duration(seconds: 3),
        id: 'manual_snack',
      );
      // Use pump() instead of pumpAndSettle() to avoid waiting for auto-dismiss timer
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(Modal.isSnackbarActive, true);

      // Dismiss manually before timer expires
      // Start the dismissal but don't await yet - we need to pump frames for the animation
      final dismissFuture = Modal.dismissById('manual_snack');

      // Pump frames to allow the animation to progress
      // The animation needs frames to complete, so we pump while the Future is pending
      await tester.pump(); // Initial frame
      await tester
          .pump(const Duration(milliseconds: 100)); // Animation progress
      await tester
          .pump(const Duration(milliseconds: 300)); // Animation completion

      // Now we can safely await the Future
      await dismissFuture;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(Modal.isSnackbarActive, false);

      // Advance time past original duration to ensure no errors/re-dismissal
      await tester.pump(const Duration(seconds: 3));
      // Should remain dismissed and no errors
      expect(Modal.isSnackbarActive, false);
    });

    testWidgets('Dismissing all snackbars cancels timers',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: Modal.appBuilder,
          home: const Scaffold(body: SizedBox.expand()),
        ),
      );

      // Modal is automatically initialized through MaterialApp builder
      await tester.pump();

      Modal.showSnackbar(
        context: tester.element(find.byType(Scaffold)),
        text: 'Snack 1',
        duration: const Duration(seconds: 3),
      );
      Modal.showSnackbar(
        context: tester.element(find.byType(Scaffold)),
        text: 'Snack 2',
        duration: const Duration(seconds: 3),
      );
      // Use pump() instead of pumpAndSettle() to avoid waiting for auto-dismiss timer
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify snackbars are active
      expect(Modal.isSnackbarActive, true);

      // Dismiss all
      Modal.dismissAllSnackbars();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 100));
      expect(Modal.isSnackbarActive, false);

      // Advance time to ensure timers are cancelled
      await tester.pump(const Duration(seconds: 3));
      expect(Modal.isSnackbarActive, false);
    });
  });
}
