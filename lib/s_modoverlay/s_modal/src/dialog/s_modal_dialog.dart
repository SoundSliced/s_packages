/// Modal Dialog Implementation
/// This file contains components for dialog-style modals
/// with positioning, drag support, and animations.
part of '../s_modal_libs.dart';

//************************************************ */
// Dialog Modal Widget
//************************************************ */

/// A modal widget specifically designed for dialog-style popups
///
/// Features:
/// - Positions the dialog based on the specified Alignment
/// - Handles entry and exit animations
/// - Supports tap-outside to dismiss
/// - Supports dragging when isDraggable is true
class DialogModal extends StatefulWidget {
  /// Content to display inside the dialog
  final Widget child;

  /// Where on screen the dialog should be positioned
  /// Ignored if [offset] is provided
  final Alignment position;

  /// Whether the dialog is currently being dismissed
  /// Controls which animation set is applied
  final bool isDismissing;

  /// Whether the dialog can be dragged around the screen
  final bool isDraggable;

  /// Optional offset for absolute positioning from top-left corner
  /// When provided, [position] is ignored and the dialog is positioned
  /// at this exact offset from the top-left of the screen
  final Offset? offset;

  /// Unique identifier for this dialog instance
  /// Used to create unique animation keys to prevent animation conflicts between dialogs
  final String? dialogId;

  /// Creates a dialog modal with the specified content and position
  const DialogModal({
    super.key,
    required this.child,
    required this.position,
    required this.isDismissing,
    this.isDraggable = false,
    this.offset,
    this.dialogId,
  });

  @override
  // Create the dialog state holder.
  State<DialogModal> createState() => _DialogModalState();
}

class _DialogModalState extends State<DialogModal> {
  /// Current drag offset from the initial position
  Offset _dragOffset = Offset.zero;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _isVisible = !widget.isDismissing;
      });
    });
  }

  @override
  // Keep drag offset in sync with configuration changes.
  void didUpdateWidget(covariant DialogModal oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset drag offset only once per widget update when needed.
    // This avoids multiple setState calls in a single lifecycle pass.
    final shouldResetOffset = (!widget.isDraggable && oldWidget.isDraggable) ||
        (widget.position != oldWidget.position);

    if (shouldResetOffset && _dragOffset != Offset.zero) {
      // Reset the drag offset when dragging is disabled or alignment changes.
      setState(() {
        _dragOffset = Offset.zero;
      });
    }

    if (oldWidget.isDismissing != widget.isDismissing) {
      setState(() {
        _isVisible = !widget.isDismissing;
      });
    }
  }

  // Apply drag deltas when the dialog is draggable.
  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.isDraggable) {
      // Accumulate the drag delta into the local offset.
      setState(() {
        _dragOffset += details.delta;
      });
    }
  }

  @override
  // Build dialog content with drag handling and animations.
  Widget build(BuildContext context) {
    Widget dialogContent = widget.child;

    // Wrap with MouseRegion and GestureDetector if draggable
    if (widget.isDraggable) {
      // Wrap with pointer cursor and drag gesture support.
      dialogContent = MouseRegion(
        cursor: SystemMouseCursors.move,
        child: GestureDetector(
          onPanUpdate: _onPanUpdate,
          // Use deferToChild so it only responds to hits on the actual dialog content
          behavior: HitTestBehavior.deferToChild,
          child: dialogContent,
        ),
      );
    }

    // Apply padding after MouseRegion/GestureDetector to ensure
    // the drag area matches the visible dialog bounds
    dialogContent = Padding(
      padding: const EdgeInsets.all(24.0),
      child: dialogContent,
    );

    // Apply fade/scale animation to content BEFORE positioning.
    // Keep the subtree mounted during dismiss so stateful dialog content
    // (for example a resized AnimatedContainer) preserves its current size
    // instead of being rebuilt from its initial state.
    final translatedContent = Transform.translate(
      offset: _dragOffset,
      child: widget.isDraggable
          ? GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              child: dialogContent,
            )
          : dialogContent,
    );

    final animatedContent = AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: AnimatedScale(
        scale: _isVisible ? 1.0 : 0.9,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: translatedContent,
      ),
    );

    // Handle positioning with smooth transitions between alignment and offset modes
    // Use Positioned.fill + AnimatedAlign with FractionalTranslation for unified positioning
    final screenSize = MediaQuery.of(context).size;

    // Calculate alignment based on mode
    Alignment effectiveAlignment;

    if (widget.offset != null) {
      // Convert pixel offset into alignment coordinates.
      // Offset mode: convert pixel offset to alignment coordinates
      // Map offset to alignment space (-1 to 1)
      final centerX = widget.offset!.dx / screenSize.width * 2 - 1;
      final centerY = widget.offset!.dy / screenSize.height * 2 - 1;
      effectiveAlignment = Alignment(centerX, centerY);

      // Since Alignment positions the center of the widget, we need to
      // account for that to position top-left corner at the offset
      // This is handled by not using FractionalTranslation in offset mode
    } else {
      // Alignment mode: use the provided alignment directly
      effectiveAlignment = widget.position;
    }

    Widget positionedChild = animatedContent;

    // For offset mode, we need to adjust positioning since Alignment centers the widget
    if (widget.offset != null) {
      // Constrain width in offset mode to keep dialog visible.
      // Wrap in ConstrainedBox to limit width if needed
      final double availableWidth = screenSize.width - widget.offset!.dx - 48.0;
      final double maxWidth =
          availableWidth > 0 ? availableWidth : (screenSize.width - 48.0);

      positionedChild = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: animatedContent,
      );
    }

    return Positioned.fill(
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: effectiveAlignment,
        child: positionedChild,
      ),
    );
  }
}
