// Regression tests for OverlayInterleaveManager's entry bookkeeping.
//
// The manager decided whether a layer's entry still had to be detached from the
// target Overlay by reading `OverlayEntry.mounted`. That flag only turns true
// once the Overlay has rebuilt, so an entry inserted *earlier in the same frame*
// looked unattached while it was already in the overlay's entry list; the
// restack then inserted it a second time and Flutter threw
// "The specified entry is already present in the target Overlay"
// (widgets/overlay.dart, _debugCanInsertEntry).
//
// Two layer changes in a single frame is the normal case in a real app - a
// snackbar landing while a pop/modal layer is added or removed - so the crash
// was reachable from ordinary flows, not just from misuse.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_modoverlay/interleaving_manager/interleave_manager.dart';

void main() {
  setUp(OverlayInterleaveManager.teardownHost);
  tearDown(OverlayInterleaveManager.teardownHost);

  /// Pumps a host app and returns a context that sits inside its root Overlay.
  Future<BuildContext> pumpHost(WidgetTester tester) async {
    late BuildContext hostContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            hostContext = context;
            return const Scaffold(body: SizedBox.shrink());
          },
        ),
      ),
    );
    return hostContext;
  }

  Widget layerMarker(String id) => SizedBox(
        key: ValueKey<String>('marker-$id'),
        width: 1,
        height: 1,
      );

  testWidgets(
    'two layers registered in the same frame are each inserted once',
    (WidgetTester tester) async {
      final BuildContext context = await pumpHost(tester);

      // No pump between the two registrations: the second call restacks while
      // the first entry is in the Overlay but not mounted yet.
      expect(() {
        OverlayInterleaveManager.registerLayer(
          id: 'a',
          activationOrder: 0,
          stackLevel: 0,
          context: context,
          builder: () => layerMarker('a'),
        );
        OverlayInterleaveManager.registerLayer(
          id: 'b',
          activationOrder: 1,
          stackLevel: 0,
          context: context,
          builder: () => layerMarker('b'),
        );
      }, returnsNormally);

      await tester.pump();

      expect(find.byKey(const ValueKey<String>('marker-a')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('marker-b')), findsOneWidget);
    },
  );

  testWidgets(
    'a layer replaced in the same frame leaves no stale entry behind',
    (WidgetTester tester) async {
      final BuildContext context = await pumpHost(tester);
      int builds = 0;

      void register() {
        OverlayInterleaveManager.registerLayer(
          id: 'a',
          activationOrder: 0,
          stackLevel: 0,
          context: context,
          builder: () {
            builds++;
            return layerMarker('a');
          },
        );
      }

      register();
      // Removed before the Overlay ever built the entry, then registered again
      // in the same frame. The first entry has to be detached with it - its id
      // is out of the layer list while the entry itself is still attached, so
      // `mounted` cannot see it and it would keep rendering the re-registered
      // layer a second time.
      OverlayInterleaveManager.unregisterLayer('a');
      register();

      await tester.pump();

      expect(find.byKey(const ValueKey<String>('marker-a')), findsOneWidget);
      expect(builds, 1, reason: 'a stale entry builds a second copy');
    },
  );
}
