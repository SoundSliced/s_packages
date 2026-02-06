part of 's_button.dart';

mixin BubbleLabelMixin {
  GlobalKey get widgetKey;
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
    return MouseRegion(
      onEnter: (_) async => await BubbleLabel.show(
        context: context,
        bubbleContent: widget.widget.bubbleLabelContent!,
      ),
      onExit: (_) async => await BubbleLabel.dismiss(),
      opaque: false,
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
    // Don't wrap with GestureDetector - let SInkButton handle gestures
    // The long press callbacks will be wrapped by the parent to show/hide bubble
    return child;
  }
}
