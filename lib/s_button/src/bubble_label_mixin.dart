part of 's_button.dart';

mixin BubbleLabelMixin {
  GlobalKey get widgetKey;
}

/// Shows the bubble once the mouse has hovered over [child] for
/// `content.showOnHoverAfter`, and dismisses it when the mouse leaves.
/// Does nothing when the delay is null. Touch pointers are ignored.
class _BubbleHoverRegion extends StatefulWidget {
  final BubbleLabelContent? content;
  final Widget child;

  const _BubbleHoverRegion({required this.content, required this.child});

  @override
  State<_BubbleHoverRegion> createState() => _BubbleHoverRegionState();
}

class _BubbleHoverRegionState extends State<_BubbleHoverRegion> {
  Timer? _hoverTimer;

  /// True when this region opened the bubble, so exit only dismisses
  /// bubbles it opened itself.
  bool _shownByHover = false;

  void _onEnter(PointerEnterEvent event) {
    if (event.kind == PointerDeviceKind.touch) return;
    final delay = widget.content?.showOnHoverAfter;
    if (delay == null) return;

    _hoverTimer?.cancel();
    _hoverTimer = Timer(delay, () {
      final content = widget.content;
      if (!mounted || content == null) return;
      _shownByHover = true;
      BubbleLabel.show(context: context, bubbleContent: content);
    });
  }

  void _onExit(PointerExitEvent event) {
    _hoverTimer?.cancel();
    _hoverTimer = null;
    if (_shownByHover) {
      _shownByHover = false;
      BubbleLabel.dismiss();
    }
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    if (_shownByHover) {
      // Dismissing during dispose would update overlay state mid-teardown.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => BubbleLabel.dismiss(),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      opaque: false,
      child: widget.child,
    );
  }
}

class _WebBubbleLabel extends StatefulWidget {
  final GlobalKey widgetKey;
  final dynamic widget;
  final Widget child;

  const _WebBubbleLabel({
    required this.widgetKey,
    required this.widget,
    required this.child,
  });

  @override
  State<_WebBubbleLabel> createState() => _WebBubbleLabelState();
}

class _WebBubbleLabelState extends State<_WebBubbleLabel>
    with BubbleLabelMixin {
  Offset? _tapPosition;

  @override
  GlobalKey get widgetKey => widget.widgetKey;

  @override
  Widget build(BuildContext context) {
    return _BubbleHoverRegion(
      content: widget.widget.bubbleLabelContent,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent, // Don't consume tap events
        onDoubleTapDown: (details) => _tapPosition = details.globalPosition,
        onDoubleTap: () =>
            widget.widget.onDoubleTap?.call(_tapPosition ?? Offset.zero),
        onLongPressStart: widget.widget.onLongPressStart,
        onLongPressEnd: widget.widget.onLongPressEnd,
        child: widget.child,
      ),
    );
  }
}

class _MobileBubbleLabel extends StatelessWidget {
  final GlobalKey widgetKey;
  final dynamic widget;
  final Widget child;

  const _MobileBubbleLabel({
    required this.widgetKey,
    required this.widget,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Long press is wired by SButton itself; this only adds mouse hover.
    return _BubbleHoverRegion(
      content: widget.bubbleLabelContent,
      child: child,
    );
  }
}
