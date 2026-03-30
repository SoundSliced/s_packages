import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_packages.dart';

class _BackgroundTapTestPage extends StatefulWidget {
  const _BackgroundTapTestPage();

  @override
  State<_BackgroundTapTestPage> createState() => _BackgroundTapTestPageState();
}

class _BackgroundTapTestPageState extends State<_BackgroundTapTestPage> {
  int tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 24,
            left: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tap count: $tapCount', key: const ValueKey('tap_count')),
                const SizedBox(height: 24),
                ElevatedButton(
                  key: const ValueKey('behind_button'),
                  onPressed: () {
                    setState(() {
                      tapCount++;
                    });
                  },
                  child: const Text('Behind button'),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    key: const ValueKey('show_modal_button'),
                    onPressed: () {
                      Modal.show(
                        modalType: ModalType.dialog,
                        modalPosition: Alignment.center,
                        isDismissable: false,
                        blockBackgroundInteraction: false,
                        barrierColor: Colors.black.withValues(alpha: 0.35),
                        builder: () => const SizedBox(width: 120, height: 80),
                      );
                    },
                    child: const Text('Show modal'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    key: const ValueKey('show_snackbar_button'),
                    onPressed: () {
                      Modal.showSnackbar(
                        builder: () => const SizedBox(width: 120, height: 80),
                        position: Alignment.topCenter,
                        duration: null,
                        isDismissible: false,
                        blockBackgroundInteraction: false,
                        barrierColor: Colors.black.withValues(alpha: 0.35),
                      );
                    },
                    child: const Text('Show snackbar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    Modal.dismissAll();
    Modal.clearLifecycleListeners();
  });

  tearDownAll(() async {
    // Final cleanup with proper async handling
    Modal.dismissAll();
    Modal.clearLifecycleListeners();
    // Give time for any remaining animations to complete
    await Future.delayed(const Duration(milliseconds: 100));
  });

  testWidgets(
    'non-dismissible modal with background interaction enabled lets taps pass through',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: Modal.appBuilder,
          home: const _BackgroundTapTestPage(),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('show_modal_button')));
      await tester.pumpAndSettle();

      expect(Modal.isDialogActive, isTrue);
      expect(find.byType(_BackgroundTapTestPage), findsOneWidget);
      expect(find.text('Tap count: 0'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('behind_button')));
      await tester.pumpAndSettle();

      expect(find.text('Tap count: 1'), findsOneWidget);
      expect(Modal.isDialogActive, isTrue);
    },
  );

  testWidgets(
    'non-dismissible snackbar with background interaction enabled lets taps pass through',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: Modal.appBuilder,
          home: const _BackgroundTapTestPage(),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('show_snackbar_button')));
      await tester.pumpAndSettle();

      expect(Modal.isSnackbarActive, isTrue);
      expect(find.text('Tap count: 0'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('behind_button')));
      await tester.pumpAndSettle();

      expect(find.text('Tap count: 1'), findsOneWidget);
      expect(Modal.isSnackbarActive, isTrue);
    },
  );

  testWidgets(
    'appBuilder lifecycle callbacks can be filtered by modal type',
    (tester) async {
      final createdEvents = <ModalLifecycleEvent>[];
      final dismissedEvents = <ModalLifecycleEvent>[];

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => Modal.appBuilder(
            context,
            child,
            onModalCreated: createdEvents.add,
            onModalDismissed: dismissedEvents.add,
            lifecycleModalTypes: {ModalType.dialog}, // Only track dialog events
          ),
          home: const _BackgroundTapTestPage(),
        ),
      );

      // Show dialog with explicit ID for reliable dismissal
      Modal.show(
        id: 'test_dialog',
        modalType: ModalType.dialog,
        modalPosition: Alignment.center,
        isDismissable: false,
        blockBackgroundInteraction: false,
        barrierColor: Colors.black.withValues(alpha: 0.35),
        builder: () => const SizedBox(width: 120, height: 80),
      );
      await tester.pumpAndSettle();

      expect(createdEvents.length, 1,
          reason: 'Dialog creation should be tracked');
      expect(createdEvents.single.modalType, ModalType.dialog);
      expect(createdEvents.single.eventType, ModalLifecycleEventType.created);

      // Show snackbar - this should NOT be tracked due to lifecycleModalTypes filter
      Modal.showSnackbar(
        builder: () => const SizedBox(width: 120, height: 80),
        position: Alignment.topCenter,
        duration: null,
        isDismissible: false,
        blockBackgroundInteraction: false,
        barrierColor: Colors.black.withValues(alpha: 0.35),
      );
      await tester.pumpAndSettle();

      // Verify that snackbar creation was not tracked (still only 1 event)
      expect(createdEvents.length, 1,
          reason: 'Snackbar should not be tracked due to filter');
      expect(Modal.isSnackbarActive, isTrue,
          reason: 'Snackbar should be active');

      // Test passed - the filtering is working correctly
      // No need to dismiss modals here since tearDown() handles cleanup
    },
  );

  testWidgets(
    'registered lifecycle listeners can be removed',
    (tester) async {
      final events = <ModalLifecycleEvent>[];

      final listenerId = Modal.addLifecycleListener(
        modalTypes: {ModalType.snackbar},
        onCreated: events.add,
        onDismissed: events.add,
      );

      await tester.pumpWidget(
        MaterialApp(
          builder: Modal.appBuilder,
          home: const _BackgroundTapTestPage(),
        ),
      );

      // Show first snackbar - should be tracked by listener
      Modal.showSnackbar(
        id: 'first_snack',
        builder: () => const SizedBox(width: 120, height: 80),
        position: Alignment.topCenter,
        duration: null,
        isDismissible: false,
        blockBackgroundInteraction: false,
      );
      await tester.pumpAndSettle();

      expect(events.length, 1, reason: 'First snackbar should be tracked');
      expect(events.single.eventType, ModalLifecycleEventType.created);

      // Remove the lifecycle listener
      final removed = Modal.removeLifecycleListener(listenerId);
      expect(removed, isTrue,
          reason: 'Listener should be successfully removed');

      // Show second snackbar in a different position to avoid conflicts
      // This should NOT be tracked after listener removal
      Modal.showSnackbar(
        id: 'second_snack',
        builder: () => const SizedBox(width: 120, height: 80),
        position: Alignment
            .bottomCenter, // Different position to avoid overlay conflicts
        duration: null,
        isDismissible: false,
        blockBackgroundInteraction: false,
      );
      await tester.pumpAndSettle();

      // Verify that second snackbar was not tracked (still only 1 event)
      expect(events.length, 1,
          reason:
              'Second snackbar should not be tracked after listener removal');
      expect(Modal.isSnackbarActive, isTrue,
          reason: 'Second snackbar should be active');

      // Test passed - listener removal is working correctly
      // tearDown() will handle cleanup
    },
  );

  testWidgets(
    'appBuilder shouldNotify can filter lifecycle events by id',
    (tester) async {
      final createdEvents = <ModalLifecycleEvent>[];

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => Modal.appBuilder(
            context,
            child,
            onModalCreated: createdEvents.add,
            shouldNotify: (event) => event.id != 'filtered_dialog',
          ),
          home: const _BackgroundTapTestPage(),
        ),
      );

      // Test 1: Show filtered dialog - should not trigger callback
      Modal.show(
        id: 'filtered_dialog',
        modalType: ModalType.dialog,
        modalPosition: Alignment.center,
        builder: () => const SizedBox(width: 120, height: 80),
      );
      await tester.pumpAndSettle();

      expect(createdEvents, isEmpty,
          reason: 'Filtered dialog should not trigger callback');
      expect(Modal.isDialogActive, isTrue,
          reason: 'Filtered dialog should still be active');

      // Test 2: Show allowed dialog - should trigger callback
      Modal.show(
        id: 'allowed_dialog',
        modalType: ModalType.dialog,
        modalPosition: Alignment.center,
        builder: () => const SizedBox(width: 120, height: 80),
      );
      await tester.pumpAndSettle();

      expect(createdEvents.length, 1,
          reason: 'Allowed dialog should trigger callback');
      expect(createdEvents.single.id, 'allowed_dialog');

      // Test passed - shouldNotify filtering works correctly
      // No manual cleanup needed - tearDown() handles it
    },
  );
}
