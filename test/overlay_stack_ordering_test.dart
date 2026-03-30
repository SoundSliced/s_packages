import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_packages.dart';
import 'dart:math' as math;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    PopOverlay.clearAll();
    Modal.dismissAll();
    OverlayInterleaveManager.clearLayers();
  });

  group('pop_overlay stack ordering', () {
    test('activeIdsByStackOrder sorts by effective level', () {
      PopOverlay.controller.state = [
        PopOverlayContent(
          id: 'UnderMaintenancePopup',
          widget: const SizedBox.shrink(),
          stackLevel: PopOverlayStackLevels.overlay,
        ),
        PopOverlayContent(
          id: 'normal',
          widget: const SizedBox.shrink(),
          stackLevel: 120,
        ),
        PopOverlayContent(
          id: 'priorityCustom',
          widget: const SizedBox.shrink(),
          stackLevel: 600,
        ),
      ];

      final ordered = PopOverlay.activeIdsByStackOrder;

      expect(ordered.first, equals('normal'));
      expect(ordered.last, equals('UnderMaintenancePopup'));
      expect(ordered, contains('priorityCustom'));
    });

    test('bringToFront and sendToBack update ordering', () {
      PopOverlay.controller.state = [
        PopOverlayContent(
          id: 'a',
          widget: const SizedBox.shrink(),
          stackLevel: 100,
        ),
        PopOverlayContent(
          id: 'b',
          widget: const SizedBox.shrink(),
          stackLevel: 200,
        ),
      ];

      expect(PopOverlay.bringToFront('a'), isTrue);
      expect(PopOverlay.getStackLevel('a')! > PopOverlay.getStackLevel('b')!,
          isTrue);

      expect(PopOverlay.sendToBack('b'), isTrue);
      expect(PopOverlay.getStackLevel('b')! < PopOverlay.getStackLevel('a')!,
          isTrue);
    });
  });

  group('s_modal stack smoke checks', () {
    test('stack constants and empty state helpers', () {
      expect(ModalStackLevels.critical > ModalStackLevels.snackbar, isTrue);
      expect(ModalStackLevelBands.criticalMin >= ModalStackLevels.critical,
          isTrue);

      expect(Modal.activeIdsByStackOrder, isEmpty);
      expect(Modal.topMostActiveId, isNull);
      expect(Modal.setStackLevel('missing-id', 123), isFalse);
    });
  });

  group('interleaved manager random sequence checks', () {
    test('supports arbitrary mixed add/remove sequence ordering', () {
      const seed = 20260330;
      final random = math.Random(seed);

      final active = <String, ({int activationOrder, int stackLevel})>{};
      var order = 0;
      var idSeed = 0;

      List<String> expectedOrder() {
        final sorted = active.entries.toList()
          ..sort((a, b) {
            final byOrder =
                a.value.activationOrder.compareTo(b.value.activationOrder);
            if (byOrder != 0) return byOrder;
            final byLevel = a.value.stackLevel.compareTo(b.value.stackLevel);
            if (byLevel != 0) return byLevel;
            return a.key.compareTo(b.key);
          });
        return sorted.map((e) => e.key).toList();
      }

      for (var step = 0; step < 120; step++) {
        final shouldRemove = active.isNotEmpty && random.nextDouble() < 0.38;

        if (shouldRemove) {
          final keys = active.keys.toList(growable: false);
          final id = keys[random.nextInt(keys.length)];
          OverlayInterleaveManager.unregisterLayer(id);
          active.remove(id);
        } else {
          order++;
          idSeed++;
          final isDialog = random.nextBool();
          final id = isDialog ? 'dialog:$idSeed' : 'pop:$idSeed';
          final stackLevel = isDialog ? 200 : 100;

          OverlayInterleaveManager.registerLayer(
            id: id,
            activationOrder: order,
            stackLevel: stackLevel,
            builder: () => const SizedBox.shrink(),
          );
          active[id] = (activationOrder: order, stackLevel: stackLevel);
        }

        final actualIds = OverlayInterleaveManager.layers
            .map((layer) => layer.id)
            .toList(growable: false);
        expect(actualIds, equals(expectedOrder()), reason: 'step=$step');
      }
    });

    test('updating existing layer preserves identity and avoids duplicates',
        () {
      OverlayInterleaveManager.registerLayer(
        id: 'dialog:test',
        activationOrder: 10,
        stackLevel: 200,
        builder: () => const SizedBox.shrink(),
      );

      OverlayInterleaveManager.registerLayer(
        id: 'dialog:test',
        activationOrder: 11,
        stackLevel: 200,
        builder: () => const SizedBox.shrink(),
      );

      final layers = OverlayInterleaveManager.layers;
      expect(layers.length, equals(1));
      expect(layers.single.id, equals('dialog:test'));
      expect(layers.single.activationOrder, equals(11));
    });
  });
}
