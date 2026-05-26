import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_packages.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    ModOverlay.clearLifecycleHooks();
    PopOverlay.clearAll();
    Modal.dismissAll();
    Modal.clearLifecycleListeners();
    OverlayInterleaveManager.clearLayers();
  });

  test('PopOverlay addPop and dismissPop dispatch global hooks', () async {
    final initEvents = <ModOverlayLifecycleEvent>[];
    final dismissEvents = <ModOverlayLifecycleEvent>[];
    ModOverlay.onInit = initEvents.add;
    ModOverlay.onDismiss = dismissEvents.add;

    PopOverlay.addPop(
      PopOverlayContent(
          id: 'global_pop',
          widget: const SizedBox.shrink(),
          shouldMakeInvisibleOnDismiss: true),
    );

    expect(initEvents.length, 1);
    expect(initEvents.single.id, 'global_pop');
    expect(initEvents.single.semanticId, 'global_pop');
    expect(initEvents.single.source, ModOverlayLifecycleSource.popOverlay);
    expect(initEvents.single.isVisible, isTrue);

    PopOverlay.dismissPop('global_pop');

    expect(dismissEvents.length, 1);
    expect(dismissEvents.single.id, 'global_pop');
    expect(dismissEvents.single.source, ModOverlayLifecycleSource.popOverlay);
    expect(dismissEvents.single.isVisible, isFalse);
  });

  testWidgets('Modal show and dismissById dispatch global hooks',
      (tester) async {
    final initEvents = <ModOverlayLifecycleEvent>[];
    final dismissEvents = <ModOverlayLifecycleEvent>[];
    ModOverlay.onInit = initEvents.add;
    ModOverlay.onDismiss = dismissEvents.add;

    await tester.pumpWidget(
        MaterialApp(builder: Modal.appBuilder, home: const SizedBox.shrink()));

    Modal.show(
      id: 'global_dialog',
      modalType: ModalType.dialog,
      modalPosition: Alignment.center,
      builder: () => const SizedBox(width: 120, height: 80),
    );
    await tester.pump();

    expect(initEvents.length, 1);
    expect(initEvents.single.id, 'global_dialog');
    expect(initEvents.single.semanticId, 'global_dialog');
    expect(initEvents.single.source, ModOverlayLifecycleSource.modal);
    expect(initEvents.single.modalType, ModalType.dialog);

    // IMPORTANT: dismissById internally awaits animation delays.
    // In widget tests, fake time must be advanced via pump *before* awaiting,
    // otherwise the future can appear stuck.
    final dismissFuture = Modal.dismissById('global_dialog');
    await tester.pump(const Duration(milliseconds: 300));
    final dismissed = await dismissFuture;
    await tester.pump();

    expect(dismissed, isTrue);
    expect(dismissEvents.length, 1);
    expect(dismissEvents.single.id, 'global_dialog');
    expect(dismissEvents.single.semanticId, 'global_dialog');
    expect(dismissEvents.single.source, ModOverlayLifecycleSource.modal);
    expect(dismissEvents.single.modalType, ModalType.dialog);
  });
}
