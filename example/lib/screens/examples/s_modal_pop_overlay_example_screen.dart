import 'package:flutter/material.dart';
import 'package:s_packages/s_packages.dart';
import 'dart:math' as math;

enum _DemoModalKind {
  dialog,
  bottomSheet,
  topSheet,
  leftSheet,
  rightSheet,
  custom,
  snackbar,
}

enum _DemoPopKind { normal, framed }

class SModalPopOverlayExampleScreen extends StatefulWidget {
  const SModalPopOverlayExampleScreen({super.key});

  @override
  State<SModalPopOverlayExampleScreen> createState() =>
      _SModalPopOverlayExampleScreenState();
}

class _SModalPopOverlayExampleScreenState
    extends State<SModalPopOverlayExampleScreen> {
  int _idSeed = 0;

  String _nextId(String prefix) {
    _idSeed++;
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_$_idSeed';
  }

  String _modalKindLabel(_DemoModalKind kind) {
    switch (kind) {
      case _DemoModalKind.dialog:
        return 'Dialog';
      case _DemoModalKind.bottomSheet:
        return 'Bottom Sheet';
      case _DemoModalKind.topSheet:
        return 'Top Sheet';
      case _DemoModalKind.leftSheet:
        return 'Left Sheet';
      case _DemoModalKind.rightSheet:
        return 'Right Sheet';
      case _DemoModalKind.custom:
        return 'Custom Modal';
      case _DemoModalKind.snackbar:
        return 'Snackbar';
    }
  }

  String _popKindLabel(_DemoPopKind kind) {
    switch (kind) {
      case _DemoPopKind.normal:
        return 'Normal PopOverlay';
      case _DemoPopKind.framed:
        return 'Framed PopOverlay';
    }
  }

  _DemoModalKind _randomModalKind(math.Random random) {
    return _DemoModalKind.values[random.nextInt(_DemoModalKind.values.length)];
  }

  _DemoPopKind _randomPopKind(math.Random random) {
    return _DemoPopKind.values[random.nextInt(_DemoPopKind.values.length)];
  }

  void _showPopOverlayPopup({
    String title = 'PopOverlay Popup',
    _DemoPopKind kind = _DemoPopKind.normal,
  }) {
    final popupId = _nextId(
      kind == _DemoPopKind.framed
          ? 'combo_pop_overlay_framed'
          : 'combo_pop_overlay_normal',
    );

    final normalContent = Container(
      width: 340,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.layers,
              size: 52, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${_popKindLabel(kind)} rendered by pop_overlay.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),
          FilledButton.tonal(
            onPressed: () => PopOverlay.removePop(popupId),
            child: const Text('Close popup'),
          ),
        ],
      ),
    );

    final framedInnerContent = SizedBox(
      width: 340,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'This popup uses frameDesign.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => PopOverlay.removePop(popupId),
              child: const Text('Close framed popup'),
            ),
          ],
        ),
      ),
    );

    PopOverlay.addPop(
      PopOverlayContent(
        id: popupId,
        shouldDismissOnBackgroundTap: true,
        shouldBlurBackground: true,
        borderRadius: BorderRadius.circular(20),
        frameDesign: kind == _DemoPopKind.framed
            ? FrameDesign(
                title: title,
                subtitle: 'Framed PopOverlay',
                showCloseButton: true,
                showBottomButtonBar: false,
                width: 420,
                height: 220,
              )
            : null,
        widget:
            kind == _DemoPopKind.framed ? framedInnerContent : normalContent,
      ),
    );
  }

  void _showModalDialog({String title = 's_modal Dialog'}) {
    final dialogId = _nextId('combo_modal_dialog');
    Modal.show(
      id: dialogId,
      modalType: ModalType.dialog,
      shouldBlurBackground: true,
      isDismissable: true,
      blockBackgroundInteraction: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: () => Container(
        width: 360,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 52, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This dialog comes from s_modal.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Modal.dismissDialog(id: dialogId),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showModalSheet() {
    final sheetId = _nextId('combo_modal_sheet');
    Modal.show(
      id: sheetId,
      modalType: ModalType.sheet,
      size: 320,
      shouldBlurBackground: true,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: () => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.vertical_align_bottom,
                size: 52, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              's_modal Bottom Sheet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Use this to test sheet layering above or below popups.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Modal.dismissBottomSheet(id: sheetId),
              child: const Text('Close sheet'),
            ),
          ],
        ),
      ),
    );
  }

  void _showModalCustom({String title = 's_modal Custom'}) {
    final customId = _nextId('combo_modal_custom');
    Modal.show(
      id: customId,
      modalType: ModalType.custom,
      modalPosition: Alignment.centerRight,
      shouldBlurBackground: true,
      isDismissable: true,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: () => Container(
        width: 360,
        margin: const EdgeInsets.only(right: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Custom modal variant for sequencing checks.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => Modal.dismissById(customId),
              child: const Text('Close custom modal'),
            ),
          ],
        ),
      ),
    );
  }

  void _showModalSheetVariant({
    required SheetPosition position,
    required String title,
  }) {
    final sheetId = _nextId('combo_modal_sheet_${position.name}');
    final isVertical =
        position == SheetPosition.bottom || position == SheetPosition.top;
    final icon = switch (position) {
      SheetPosition.bottom => Icons.vertical_align_bottom,
      SheetPosition.top => Icons.vertical_align_top,
      SheetPosition.left => Icons.keyboard_double_arrow_left,
      SheetPosition.right => Icons.keyboard_double_arrow_right,
    };

    Modal.show(
      id: sheetId,
      modalType: ModalType.sheet,
      sheetPosition: position,
      size: isVertical ? 300 : 360,
      shouldBlurBackground: true,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: () => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(icon, size: 42, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'SheetPosition.${position.name} sequence check.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Modal.dismissById(sheetId),
              child: const Text('Close sheet'),
            ),
          ],
        ),
      ),
    );
  }

  void _showModalVariant({
    required _DemoModalKind kind,
    required String title,
  }) {
    switch (kind) {
      case _DemoModalKind.dialog:
        _showModalDialog(title: title);
      case _DemoModalKind.bottomSheet:
        _showModalSheetVariant(position: SheetPosition.bottom, title: title);
      case _DemoModalKind.topSheet:
        _showModalSheetVariant(position: SheetPosition.top, title: title);
      case _DemoModalKind.leftSheet:
        _showModalSheetVariant(position: SheetPosition.left, title: title);
      case _DemoModalKind.rightSheet:
        _showModalSheetVariant(position: SheetPosition.right, title: title);
      case _DemoModalKind.custom:
        _showModalCustom(title: title);
      case _DemoModalKind.snackbar:
        final snackbarId = _nextId('combo_modal_snackbar_variant');
        Modal.showSnackbar(
          id: snackbarId,
          text: title,
          backgroundColor: Colors.deepPurple,
          blockBackgroundInteraction: false,
          duration: const Duration(seconds: 5),
          position: Alignment.topCenter,
        );
    }
  }

  void _showModalSnackbar() {
    final snackbarId = _nextId('combo_modal_snackbar');
    Modal.showSnackbar(
      id: snackbarId,
      text: 's_modal snackbar',
      backgroundColor: Colors.deepPurple,
      blockBackgroundInteraction: false,
      duration: const Duration(seconds: 4),
      position: Alignment.topCenter,
    );
  }

  Future<void> _showPopThenModal() async {
    await _clearAll();
    final random = math.Random(DateTime.now().microsecondsSinceEpoch);
    final modalKind = _randomModalKind(random);
    final popKind = _randomPopKind(random);

    _showPopOverlayPopup(
      title: '${_popKindLabel(popKind)} first',
      kind: popKind,
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    _showModalVariant(
      kind: modalKind,
      title: '${_modalKindLabel(modalKind)} above PopOverlay',
    );
  }

  Future<void> _showModalThenPop() async {
    await _clearAll();
    final random = math.Random(DateTime.now().microsecondsSinceEpoch + 1);
    final modalKind = _randomModalKind(random);
    final popKind = _randomPopKind(random);

    _showModalVariant(
      kind: modalKind,
      title: '${_modalKindLabel(modalKind)} first',
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    _showPopOverlayPopup(
      title: '${_popKindLabel(popKind)} above Modal',
      kind: popKind,
    );
  }

  Future<void> _showModalPopModalPopSequence() async {
    await _clearAll();

    final random = math.Random(DateTime.now().microsecondsSinceEpoch + 2);

    final modalKind1 = _randomModalKind(random);
    final popKind1 = _randomPopKind(random);
    final modalKind2 = _randomModalKind(random);
    final popKind2 = _randomPopKind(random);

    _showModalVariant(
      kind: modalKind1,
      title: '1. ${_modalKindLabel(modalKind1)}',
    );
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;

    _showPopOverlayPopup(
      title: '2. ${_popKindLabel(popKind1)}',
      kind: popKind1,
    );
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;

    _showModalVariant(
      kind: modalKind2,
      title: '3. ${_modalKindLabel(modalKind2)}',
    );
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;

    _showPopOverlayPopup(
      title: '4. ${_popKindLabel(popKind2)}',
      kind: popKind2,
    );
  }

  Future<void> _showPopModalPopModalSequence() async {
    await _clearAll();

    final random = math.Random(DateTime.now().microsecondsSinceEpoch + 3);

    final popKind1 = _randomPopKind(random);
    final modalKind1 = _randomModalKind(random);
    final popKind2 = _randomPopKind(random);
    final modalKind2 = _randomModalKind(random);

    _showPopOverlayPopup(
      title: '1. ${_popKindLabel(popKind1)}',
      kind: popKind1,
    );
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;

    _showModalVariant(
      kind: modalKind1,
      title: '2. ${_modalKindLabel(modalKind1)}',
    );
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;

    _showPopOverlayPopup(
      title: '3. ${_popKindLabel(popKind2)}',
      kind: popKind2,
    );
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;

    _showModalVariant(
      kind: modalKind2,
      title: '4. ${_modalKindLabel(modalKind2)}',
    );
  }

  Future<void> _showAllModalKindsInterleavedWithPops() async {
    await _clearAll();

    final allKinds = _DemoModalKind.values;
    for (var i = 0; i < allKinds.length; i++) {
      if (!mounted) return;

      final popKind = i.isEven ? _DemoPopKind.normal : _DemoPopKind.framed;
      final modalKind = allKinds[i];

      _showPopOverlayPopup(
        title: '${i + 1}A. ${_popKindLabel(popKind)}',
        kind: popKind,
      );

      await Future<void>.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;

      _showModalVariant(
        kind: modalKind,
        title: '${i + 1}B. ${_modalKindLabel(modalKind)}',
      );

      await Future<void>.delayed(const Duration(milliseconds: 380));
    }
  }

  Future<void> _showAllPopKindsAgainstMixedModals() async {
    await _clearAll();

    const popKinds = _DemoPopKind.values;
    final modalKinds = _DemoModalKind.values;

    for (var i = 0; i < popKinds.length; i++) {
      if (!mounted) return;

      final modalKind = modalKinds[i % modalKinds.length];
      final popKind = popKinds[i];

      _showModalVariant(
        kind: modalKind,
        title: '${i + 1}A. ${_modalKindLabel(modalKind)}',
      );

      await Future<void>.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;

      _showPopOverlayPopup(
        title: '${i + 1}B. ${_popKindLabel(popKind)}',
        kind: popKind,
      );

      await Future<void>.delayed(const Duration(milliseconds: 380));
    }
  }

  Future<void> _showRandomInterleavedSequence({int count = 12}) async {
    await _clearAll();
    final random = math.Random(DateTime.now().microsecondsSinceEpoch);

    for (var i = 1; i <= count; i++) {
      if (!mounted) return;

      final showPop = random.nextBool();
      if (showPop) {
        final popKind = _randomPopKind(random);
        _showPopOverlayPopup(
          title: '$i. Random ${_popKindLabel(popKind)}',
          kind: popKind,
        );
      } else {
        final modalKind = _randomModalKind(random);
        _showModalVariant(
          kind: modalKind,
          title: '$i. Random ${_modalKindLabel(modalKind)}',
        );
      }

      await Future<void>.delayed(
        Duration(milliseconds: 180 + random.nextInt(160)),
      );
    }
  }

  Future<void> _resetForDemo() async {
    PopOverlay.clearAll();
    Modal.dismissAll();
    await _waitForOverlaySystemsToSettle();
  }

  Future<void> _clearAll() async {
    await _resetForDemo();
  }

  Future<void> _waitForOverlaySystemsToSettle() async {
    final deadline = DateTime.now().add(const Duration(milliseconds: 900));

    while (DateTime.now().isBefore(deadline)) {
      if (!PopOverlay.isActive && !Modal.isActive) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }

    // Give the next frame a chance to install/rebuild the overlay hosts.
    await Future<void>.delayed(const Duration(milliseconds: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('s_modal + PopOverlay'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Cross-package stacking demo',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use these buttons to verify which overlay stays on top when pop_overlay and s_modal are both active.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            _ActionCard(
              title: 'PopOverlay actions',
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => _showPopOverlayPopup(
                    kind: _DemoPopKind.normal,
                  ),
                  icon: const Icon(Icons.layers),
                  label: const Text('Show normal PopOverlay'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => _showPopOverlayPopup(
                    kind: _DemoPopKind.framed,
                  ),
                  icon: const Icon(Icons.crop_16_9),
                  label: const Text('Show framed PopOverlay'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _showPopOverlayPopup(
                    title: 'Second normal PopOverlay',
                    kind: _DemoPopKind.normal,
                  ),
                  icon: const Icon(Icons.copy),
                  label: const Text('Show another normal PopOverlay'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ActionCard(
              title: 's_modal actions',
              children: [
                FilledButton.tonalIcon(
                  onPressed: _showModalDialog,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Show dialog'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: _showModalSheet,
                  icon: const Icon(Icons.vertical_align_bottom),
                  label: const Text('Show bottom sheet'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => _showModalSheetVariant(
                    position: SheetPosition.top,
                    title: 's_modal Top Sheet',
                  ),
                  icon: const Icon(Icons.vertical_align_top),
                  label: const Text('Show top sheet'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => _showModalSheetVariant(
                    position: SheetPosition.left,
                    title: 's_modal Left Sheet',
                  ),
                  icon: const Icon(Icons.keyboard_double_arrow_left),
                  label: const Text('Show left sheet'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => _showModalSheetVariant(
                    position: SheetPosition.right,
                    title: 's_modal Right Sheet',
                  ),
                  icon: const Icon(Icons.keyboard_double_arrow_right),
                  label: const Text('Show right sheet'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: _showModalCustom,
                  icon: const Icon(Icons.tune),
                  label: const Text('Show custom modal'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: _showModalSnackbar,
                  icon: const Icon(Icons.notifications),
                  label: const Text('Show snackbar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ActionCard(
              title: 'Cross-stack checks',
              children: [
                FilledButton.icon(
                  onPressed: () {
                    _showPopThenModal();
                  },
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('PopOverlay then Modal'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    _showModalThenPop();
                  },
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('Modal then PopOverlay'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    _showModalPopModalPopSequence();
                  },
                  icon: const Icon(Icons.layers),
                  label: const Text('Modal → Pop → Modal → Pop (mixed)'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    _showPopModalPopModalSequence();
                  },
                  icon: const Icon(Icons.swap_vert),
                  label: const Text('Pop → Modal → Pop → Modal (mixed)'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    _showAllModalKindsInterleavedWithPops();
                  },
                  icon: const Icon(Icons.view_carousel),
                  label: const Text('All modal kinds interleaved with pops'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    _showAllPopKindsAgainstMixedModals();
                  },
                  icon: const Icon(Icons.filter_2),
                  label: const Text('Normal + framed pops against modals'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    _showRandomInterleavedSequence(count: 14);
                  },
                  icon: const Icon(Icons.casino_outlined),
                  label: const Text('Random mixed sequence (n=14)'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    _clearAll();
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear all overlays'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ActionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
