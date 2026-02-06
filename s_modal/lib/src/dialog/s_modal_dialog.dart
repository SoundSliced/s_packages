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
  State<DialogModal> createState() => _DialogModalState();
}

class _DialogModalState extends State<DialogModal> {
  /// Current drag offset from the initial position
  Offset _dragOffset = Offset.zero;

  @override
  void didUpdateWidget(covariant DialogModal oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset drag offset when draggable is disabled
    // This ensures the dialog snaps back to its base position
    if (!widget.isDraggable && oldWidget.isDraggable) {
      setState(() {
        _dragOffset = Offset.zero;
      });
    }

    // Reset drag offset when position changes
    // This ensures the dialog moves to the new position cleanly
    if (widget.position != oldWidget.position) {
      setState(() {
        _dragOffset = Offset.zero;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.isDraggable) {
      setState(() {
        _dragOffset += details.delta;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget dialogContent = widget.child;

    // Wrap with MouseRegion and GestureDetector if draggable
    if (widget.isDraggable) {
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

    // Apply animation to the dialog content BEFORE positioning
    // This ensures Positioned/Align is a direct child of Stack for proper positioning
    // Create unique animation key using dialogId to prevent animation conflicts between dialogs
    final animationKeyId =
        widget.dialogId ?? widget.key?.toString() ?? 'unknown';
    final animationKey =
        ValueKey("dialog_anim_${animationKeyId}_${widget.isDismissing}");

    // Apply fade/scale animation to content
    final animatedContent = Transform.translate(
      offset: _dragOffset,
      child: widget.isDraggable
          ? GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              child: dialogContent,
            )
          : dialogContent,
    ).animate(
      key: animationKey,
      effects: widget.isDismissing
          ? [
              // Fade out and scale down when dismissing
              FadeEffect(
                duration: 0.3.sec,
                begin: 1.0,
                end: 0.0,
                curve: Curves.easeOut,
              ),
              ScaleEffect(
                duration: 0.3.sec,
                begin: const Offset(1.0, 1.0),
                end: const Offset(0.9, 0.9),
                curve: Curves.easeOut,
              ),
            ]
          : [
              // Fade in and scale up when appearing
              FadeEffect(
                duration: 0.3.sec,
                begin: 0.0,
                end: 1.0,
                curve: Curves.easeOut,
              ),
              ScaleEffect(
                duration: 0.3.sec,
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.0, 1.0),
                curve: Curves.easeOut,
              ),
            ],
    );

    // Handle positioning with smooth transitions between alignment and offset modes
    // Use Positioned.fill + AnimatedAlign with FractionalTranslation for unified positioning
    final screenSize = MediaQuery.of(context).size;

    // Calculate alignment based on mode
    Alignment effectiveAlignment;

    if (widget.offset != null) {
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
