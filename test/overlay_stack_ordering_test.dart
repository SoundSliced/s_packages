import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_packages.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    PopOverlay.clearAll();
    Modal.dismissAll();
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
}
