part of 'pop_overlay.dart';

/// Pop Overlay Frame Design Template
///
/// For button callbacks:
/// - Use [onSuccess] for synchronous operations where you want manual control
///   Returns bool? - if null or true, the popup will be dismissed
/// - Use [onFutureSuccess] for asynchronous operations that will automatically
///   handle success/error states using MyFutureButton
///   Returns `Future<bool?>` - if null or true, the popup will be dismissed after success animation
/// - Use [onFutureSuccessValidator] to determine whether the popup should be dismissed
///   after onFutureSuccess completes (returns bool? - null or true = dismiss)
///
/// Note: Only one of [onSuccess] or [onFutureSuccess] should be provided, not both.

/// Configuration class for pop overlay frame design template
///
/// Contains all styling and behavior options for the standard pop overlay design.
/// This class serves as a data holder for overlay configuration.
///
/// For button callbacks:
/// - Use [onSuccess] for synchronous operations where you want manual control
///   Returns bool? - if null or true, the popup will be dismissed
/// - Use [onFutureSuccess] for asynchronous operations that will automatically
///   handle success/error states using MyFutureButton
///   Returns `(bool?, Future<void>)` - bool? determines dismissal, `Future<void>` is the async operation
///
/// Note: Only one of [onSuccess] or [onFutureSuccess] should be provided, not both.
class FrameDesign {
  /// Callback executed when the success/save button is pressed
  /// Returns bool? - if null or true, the popup will be dismissed
  final bool? Function()? onSuccess;

  /// Future callback executed when the success/save button is pressed
  /// If provided, a MyFutureButton will be used instead of a regular button
  final Future<void> Function()? onFutureSuccess;

  /// Validator function that determines whether the popup should be dismissed after onFutureSuccess completes
  /// Returns a `Future<bool?>`
  /// - if the future returns null it allows to dismiss proceeding to the next step of calling the onFutureSuccess method, and keep the popup open,
  /// - if the future returns true, then the onFutureSuccess method will be called and the popup will be dismissed
  /// - if the future returns false, then the onFutureSuccess method will NOT be called and the Button will indicate failure
  final Future<bool?> Function()? onFutureSuccessValidator;

  /// Callback executed when the cancel button is pressed
  final VoidCallback? onCancel;

  /// Title text displayed in the header
  final String title;

  /// Text displayed on the success button
  final String successButtonTitle, cancelButtonTitle;

  /// Whether to show the close button in the header
  final bool showCloseButton;

  /// Whether to show the bottom button bar
  final bool showBottomButtonBar;

  /// Whether the success button should be disabled
  final bool conditionToDisableSuccessButton;

  /// Icon displayed before the title text
  final IconData titlePrefixIcon;

  /// Width of the overlay (defaults to 600) - nullable for auto-width
  final double? width;

  /// Height of the overlay (defaults to 600) - nullable for auto-height
  final double? height;

  /// Height of the title bar (defaults to 80)
  final double? titleBarHeight;

  /// Height of the bottom bar (defaults to 50)
  final double? bottomBarHeight;

  /// Optional information string to display about the overlay
  final String? info;

  final Color? successButtonColor, cancelButtonColor;
  // Optional generic focus traversal customization
  final FocusTraversalPolicy? traversalPolicy;
  final bool cycleFocusWithinGroup;
  final FocusNode? cancelButtonFocusNode;
  final FocusNode? saveButtonFocusNode;
  final String? Function()? cycleFocusTargetRoleBuilder;
  final List<String> cycleFocusSkipRoles;

  const FrameDesign({
    this.onSuccess,
    this.onFutureSuccess,
    this.onFutureSuccessValidator,
    this.onCancel,
    this.cancelButtonTitle = "Cancel",
    this.title = "Title",
    this.successButtonTitle = "Save",
    this.showCloseButton = true,
    this.conditionToDisableSuccessButton = false,
    this.titlePrefixIcon = Icons.info,
    this.showBottomButtonBar = true,
    this.width,
    this.height,
    this.titleBarHeight,
    this.bottomBarHeight,
    this.info,
    this.successButtonColor,
    this.cancelButtonColor,
    this.traversalPolicy,
    this.cycleFocusWithinGroup = false,
    this.cancelButtonFocusNode,
    this.saveButtonFocusNode,
    this.cycleFocusTargetRoleBuilder,
    this.cycleFocusSkipRoles = const ['SAVE_BUTTON', 'CANCEL_BUTTON'],
  });
}

/// Internal widget that renders the pop overlay frame design template
///
/// This StatefulWidget handles the rendering and interaction logic for
/// the standardized pop overlay frame design. It's optimized for performance
/// and maintains all features while improving code organization.
class _PopOverlayFrameDesignWidget extends StatefulWidget {
  /// The content widget to display within the overlay
  final Widget child;

  /// The frame design to use for the overlay (can be null)
  final FrameDesign? frameDesign;

  /// Whether the overlay can be dragged
  final bool isDraggable;

  /// Reference to the pop overlay content for state management
  final PopOverlayContent popContent;

  const _PopOverlayFrameDesignWidget({
    required this.child,
    required this.popContent,
    this.frameDesign,
    this.isDraggable = true,
  });

  @override
  State<_PopOverlayFrameDesignWidget> createState() =>
      _PopOverlayFrameDesignWidgetState();
}

/// State class for the pop overlay design template widget
///
/// Handles the lifecycle and state management for the overlay.
/// Optimized to minimize unnecessary rebuilds and improve performance.
class _PopOverlayFrameDesignWidgetState
    extends State<_PopOverlayFrameDesignWidget> {
  // Performance-optimized constants
  // Removed _defaultWidth and _defaultHeight to support auto-sizing
  static const double _defaultTitleBarHeight = 80.0;

  // Cache computed values to avoid repeated calculations
  late double? _computedWidth; // Made nullable to support auto-width
  late double? _computedHeight; // Made nullable to support auto-height
  late double _computedTitleBarHeight;

  bool isOffstage = true;

  @override
  void initState() {
    super.initState();
    _initializeComputedValues();
  }

  /// Initialize computed values once to avoid repeated calculations
  ///
  /// This optimization caches the computed dimensions to prevent
  /// recalculation on every build, improving performance.
  void _initializeComputedValues() {
    _computedWidth = widget.frameDesign?.width; // Allow null for auto-width
    _computedHeight = widget.frameDesign?.height; // Allow null for auto-height
    _computedTitleBarHeight =
        widget.frameDesign?.titleBarHeight ?? _defaultTitleBarHeight;
  }

  @override
  void didUpdateWidget(_PopOverlayFrameDesignWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recalculate dimensions only if they changed
    final dimensionsChanged =
        oldWidget.frameDesign?.width != widget.frameDesign?.width ||
            oldWidget.frameDesign?.height != widget.frameDesign?.height ||
            oldWidget.frameDesign?.titleBarHeight !=
                widget.frameDesign?.titleBarHeight;

    if (dimensionsChanged) {
      _initializeComputedValues();
    }

    // Only rebuild if meaningful properties changed
    if (_shouldRebuild(oldWidget) || dimensionsChanged) {
      setState(() {});
    }
  }

  /// Memory-efficient check for whether the widget needs rebuilding
  bool _shouldRebuild(_PopOverlayFrameDesignWidget oldWidget) {
    return oldWidget.child != widget.child ||
        oldWidget.frameDesign?.width != widget.frameDesign?.width ||
        oldWidget.frameDesign?.height != widget.frameDesign?.height ||
        oldWidget.frameDesign?.titleBarHeight !=
            widget.frameDesign?.titleBarHeight ||
        oldWidget.frameDesign?.title != widget.frameDesign?.title ||
        oldWidget.frameDesign?.showCloseButton !=
            widget.frameDesign?.showCloseButton ||
        oldWidget.frameDesign?.showBottomButtonBar !=
            widget.frameDesign?.showBottomButtonBar ||
        oldWidget.frameDesign?.conditionToDisableSuccessButton !=
            widget.frameDesign?.conditionToDisableSuccessButton;
  }

  @override
  Widget build(BuildContext context) {
    // If no design template, return a simple wrapper with the original styling
    if (widget.frameDesign == null) {
      return _buildNonTemplateWrapper();
    }

    // Use LayoutBuilder to ensure we have proper sizing context for template popups
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesignTemplateAutoSized =
            widget.frameDesign?.width == null &&
                widget.frameDesign?.height == null;
        final FocusTraversalPolicy traversalPolicy =
            widget.frameDesign?.traversalPolicy ?? OrderedTraversalPolicy();

        // Auto-sized design template branch (both width & height null)
        if (isDesignTemplateAutoSized) {
          //NOTE: AnimatedSize - see below - doesn't adapt to the widget.child's width, but adapts well to height changes
          //therefore, we need to calculate the initial widget.child's width and pass it as the _computedWidth variable

          Widget built = Center(
            child: Stack(
              children: [
                //show loading indicator while measuring the child width
                if (isOffstage == true)
                  Container(
                    color: widget.popContent.dismissBarrierColor ??
                        Colors.black.withValues(alpha: 0.8),
                    child: Center(
                      child: TickerFreeCircularProgressIndicator(
                        color: Colors.blue[500],
                        backgroundColor: Colors.blue.shade100.withValues(
                            alpha: 0.8), // Lighter, semi-transparent background
                      ),
                    ),
                  ),

                // Use MyOffstage to measure child width without rendering it initially
                if (isOffstage == true)
                  SOffstage(
                    isOffstage: true,
                    showLoadingIndicator: false,
                    child: MeasureChildSizeWidget(
                      onChange: (size) {
                        // Trigger a rebuild if the child size changes
                        _computedWidth = size.width;

                        //Future used when debugging for testing purposes
                        //  Future.delayed(10.sec, () {
                        if (mounted) {
                          setState(() {
                            isOffstage = false;
                          });
                        }
                        //  });
                      },
                      child: widget.child,
                    ),
                  ),

                // Main content container

                if (isOffstage == false)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.fastEaseInToSlowEaseOut,
                    alignment: Alignment.topCenter,
                    child: _PopOverlayContainer(
                      height: _computedHeight,
                      width: _computedWidth,
                      borderRadius: widget.popContent.borderRadius,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PopOverlayHeader(
                            title: widget.frameDesign!.title,
                            titlePrefixIcon:
                                widget.frameDesign!.titlePrefixIcon,
                            showCloseButton:
                                widget.frameDesign!.showCloseButton,
                            titleBarHeight: _computedTitleBarHeight,
                            width: null,
                            isDraggable: widget.isDraggable,
                            popContent: widget.popContent,
                            info: widget.frameDesign!.info,
                          ),

                          // Use MyOffstage to measure child size without rendering it initially

                          // Only render the child if we have a valid size
                          Flexible(child: widget.child),

                          // Bottom bar
                          if (widget.frameDesign!.showBottomButtonBar)
                            _PopOverlayBottomBar(
                              height: widget.frameDesign!.bottomBarHeight,
                              successButtonColor:
                                  widget.frameDesign!.successButtonColor,
                              cancelButtonColor:
                                  widget.frameDesign!.cancelButtonColor,
                              successButtonTitle:
                                  widget.frameDesign!.successButtonTitle,
                              cancelButtonTitle:
                                  widget.frameDesign!.cancelButtonTitle,
                              isSuccessButtonDisabled: widget
                                  .frameDesign!.conditionToDisableSuccessButton,
                              showBottomButtonBar:
                                  widget.frameDesign!.showBottomButtonBar,
                              onSuccess: widget.frameDesign!.onSuccess,
                              onFutureSuccess:
                                  widget.frameDesign!.onFutureSuccess,
                              onFutureSuccessValidator:
                                  widget.frameDesign!.onFutureSuccessValidator,
                              onCancel: widget.frameDesign!.onCancel,
                              popContent: widget.popContent,
                              width: null,
                              cycleFocusWithinGroup:
                                  widget.frameDesign!.cycleFocusWithinGroup,
                              cancelButtonFocusNode:
                                  widget.frameDesign!.cancelButtonFocusNode,
                              saveButtonFocusNode:
                                  widget.frameDesign!.saveButtonFocusNode,
                              wrapFocusTargetRoleBuilder: widget
                                  .frameDesign!.cycleFocusTargetRoleBuilder,
                              wrapFocusSkipRoles:
                                  widget.frameDesign!.cycleFocusSkipRoles,
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
          // Wrap in traversal group to allow unified focus flow including buttons
          if (widget.frameDesign != null) {
            built = FocusTraversalGroup(policy: traversalPolicy, child: built);
          }
          return built;
        }

        // Legacy fixed-size mode
        double finalHeight = _computedHeight ?? 600.0;

        if (_computedHeight != null &&
            _computedHeight! > 0 &&
            _computedHeight! < 1) {
          // It's a percentage value, try to convert it to screen percentage
          try {
            // First try using Sizer if available
            final screenHeight = MediaQuery.of(context).size.height;
            finalHeight = screenHeight * _computedHeight!;
          } catch (e) {
            // Fallback to a reasonable default
            finalHeight = 600.0;
          }
        }

        Widget legacy = _PopOverlayContainer(
          height: finalHeight,
          width: _computedWidth ?? 600.0,
          borderRadius: widget.popContent.borderRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PopOverlayHeader(
                title: widget.frameDesign!.title,
                titlePrefixIcon: widget.frameDesign!.titlePrefixIcon,
                showCloseButton: widget.frameDesign!.showCloseButton,
                titleBarHeight: _computedTitleBarHeight,
                width: _computedWidth ?? 600.0,
                isDraggable: widget.isDraggable,
                popContent: widget.popContent,
                info: widget.frameDesign!.info, // Pass info if available
              ),
              Expanded(child: widget.child),
              _PopOverlayBottomBar(
                height: widget.frameDesign!.bottomBarHeight,
                cancelButtonTitle: widget.frameDesign!.cancelButtonTitle,
                successButtonTitle: widget.frameDesign!.successButtonTitle,
                isSuccessButtonDisabled:
                    widget.frameDesign!.conditionToDisableSuccessButton,
                showBottomButtonBar: widget.frameDesign!.showBottomButtonBar,
                onSuccess: widget.frameDesign!.onSuccess,
                onFutureSuccess: widget.frameDesign!.onFutureSuccess,
                onFutureSuccessValidator:
                    widget.frameDesign!.onFutureSuccessValidator,
                onCancel: widget.frameDesign!.onCancel,
                popContent: widget
                    .popContent, // Pass full popContent instead of just ID
                cycleFocusWithinGroup:
                    widget.frameDesign!.cycleFocusWithinGroup,
                cancelButtonFocusNode:
                    widget.frameDesign!.cancelButtonFocusNode,
                saveButtonFocusNode: widget.frameDesign!.saveButtonFocusNode,
                wrapFocusTargetRoleBuilder:
                    widget.frameDesign!.cycleFocusTargetRoleBuilder,
                wrapFocusSkipRoles: widget.frameDesign!.cycleFocusSkipRoles,
              ),
            ],
          ),
        );
        legacy = FocusTraversalGroup(policy: traversalPolicy, child: legacy);
        return legacy;
      },
    );
  }

  /// Builds a simple wrapper for non-template popups that mimics the original styling
  Widget _buildNonTemplateWrapper() {
    Widget content = widget.child;

    // Apply the same styling as the original non-template popups
    Widget styledContent = FittedBox(
      fit: BoxFit.none,
      child: Container(
        padding: EdgeInsets.all(widget.popContent.frameWidth),
        decoration: BoxDecoration(
          color: widget.popContent.frameColor ??
              Colors.white.withValues(alpha: 0.85),
          borderRadius:
              widget.popContent.borderRadius ?? BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
              widget.popContent.borderRadius ?? BorderRadius.circular(10),
          child: content,
        ),
      ),
    );

    // Handle dragging directly within _PopOverlayDesignTemplateWidget for non-template popups
    if (widget.isDraggable) {
      return MouseRegion(
        cursor: SystemMouseCursors.move,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: _handleNonTemplateDrag,
          child: styledContent,
        ),
      );
    }

    return styledContent;
  }

  /// Handles dragging for non-template popups using the same system as template popups
  void _handleNonTemplateDrag(DragUpdateDetails details) {
    // Use the same dragging logic as template popups - this ensures consistency
    final currentOffset = widget.popContent.positionController.state;
    final newOffset = currentOffset + details.delta;

    // Only update if the change is significant enough (reduces micro-updates)
    if ((newOffset - currentOffset).distance > 0.5) {
      widget.popContent.positionController.state = newOffset;
    }
  }
}

//************************************************* */
/// SEPARATE STATELESS WIDGETS FOR ENHANCED PERFORMANCE
//************************************************* */

/// Main container widget for the pop overlay
///
/// Separated as a StatelessWidget to optimize rebuild performance.
/// This widget only rebuilds when its size or styling properties change.
class _PopOverlayContainer extends StatefulWidget {
  final double? height; // Made nullable to support auto-height
  final double? width; // Made nullable to support auto-width
  final Widget child;

  final BorderRadiusGeometry? borderRadius;

  static const double _borderRadius = 12.0;

  const _PopOverlayContainer({
    required this.height,
    required this.width,
    required this.child,
    this.borderRadius,
  });

  @override
  State<_PopOverlayContainer> createState() => _PopOverlayContainerState();
}

class _PopOverlayContainerState extends State<_PopOverlayContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _PopOverlayContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.height != widget.height || oldWidget.width != widget.width) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 235, 241, 245),
        border: Border.all(
          color: const Color.fromARGB(255, 215, 220, 227),
          width: 0.4,
        ),
        borderRadius: widget.borderRadius ??
            BorderRadius.circular(_PopOverlayContainer._borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(20, 0, 0, 0), // 0.08 alpha = 20/255
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ??
            BorderRadius.circular(_PopOverlayContainer._borderRadius),
        child: widget.child,
      ),
    );
  }
}

/// Header widget for the pop overlay with drag functionality
///
/// Separated as a StatelessWidget to optimize rebuild performance.
/// This widget only rebuilds when header-specific properties change.
class _PopOverlayHeader extends StatelessWidget {
  final String title;
  final IconData titlePrefixIcon;
  final bool showCloseButton;
  final double titleBarHeight;
  final double? width; // Made nullable to support auto-width
  final bool isDraggable;
  final PopOverlayContent popContent;
  final String? info;
  static const double _titleBarBorderRadius = 10.0;
  static const EdgeInsets _headerPadding = EdgeInsets.symmetric(horizontal: 15);

  const _PopOverlayHeader({
    required this.title,
    required this.titlePrefixIcon,
    required this.showCloseButton,
    required this.titleBarHeight,
    required this.width,
    required this.isDraggable,
    required this.popContent,
    this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: titleBarHeight,
      width: width,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 40, 45,
            50), // Slightly lighter dark color for better visibility
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_titleBarBorderRadius),
          topRight: Radius.circular(_titleBarBorderRadius),
        ),
      ),
      child: Padding(
        padding: _headerPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _DraggableTitle(
                title: title,
                titlePrefixIcon: titlePrefixIcon,
                isDraggable: isDraggable,
                popContent: popContent,
              ),
            ),
            if (info != null)
              PopOverlay.infoButton(info: info!, popContentId: popContent.id),
            if (showCloseButton) PopOverlay.closeButton(popContent.id),
          ],
        ),
      ),
    );
  }
}

/// Draggable title area widget
///
/// Separated as a StatelessWidget to optimize rebuild performance.
/// This widget only rebuilds when title or dragging properties change.
class _DraggableTitle extends StatelessWidget {
  final String title;
  final IconData titlePrefixIcon;
  final bool isDraggable;
  final PopOverlayContent popContent;

  // Cache container properties for non-draggable state
  static const double _containerHeight = double.infinity;
  static const Alignment _containerAlignment = Alignment.centerLeft;

  const _DraggableTitle({
    required this.title,
    required this.titlePrefixIcon,
    required this.isDraggable,
    required this.popContent,
  });

  @override
  Widget build(BuildContext context) {
    final titleContent = _TitleContent(
      title: title,
      titlePrefixIcon: titlePrefixIcon,
    );

    // Early return for non-draggable case to avoid unnecessary widget creation
    if (!isDraggable) {
      return Container(
        height: _containerHeight,
        alignment: _containerAlignment,
        child: titleContent,
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.move,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: _handlePanUpdate,
        child: Container(
          height: _containerHeight,
          alignment: _containerAlignment,
          child: titleContent,
        ),
      ),
    );
  }

  /// Handles pan update for dragging functionality
  ///
  /// Optimized to minimize allocations and use efficient state updates
  void _handlePanUpdate(DragUpdateDetails details) {
    // OPTIMIZATION: Batch position updates to reduce rebuild frequency
    final currentOffset = popContent.positionController.state;
    final newOffset = currentOffset + details.delta;

    // Only update if the change is significant enough (reduces micro-updates)
    if ((newOffset - currentOffset).distance > 0.5) {
      popContent.positionController.state = newOffset;
    }
  }
}

/// Title content widget with icon and text
///
/// Separated as a StatelessWidget to optimize rebuild performance.
/// This widget only rebuilds when title or icon properties change.
class _TitleContent extends StatelessWidget {
  final String title;
  final IconData titlePrefixIcon;

  static const double _iconSize = 24.0;
  static const double _iconTextSpacing = 12.0;

  const _TitleContent({
    required this.title,
    required this.titlePrefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          titlePrefixIcon,
          size: _iconSize,
          color: Colors.grey[500],
        ),
        const SizedBox(width: _iconTextSpacing),
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[300],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Bottom bar widget for pop overlay actions
///
/// Separated as a StatelessWidget to optimize rebuild performance.
/// This widget only rebuilds when button properties or callbacks change.
class _PopOverlayBottomBar extends StatelessWidget {
  final String successButtonTitle, cancelButtonTitle;
  final bool isSuccessButtonDisabled;
  final bool showBottomButtonBar;
  final bool? Function()? onSuccess;
  final Future<void> Function()? onFutureSuccess;
  final Future<bool?> Function()? onFutureSuccessValidator;
  final VoidCallback? onCancel;
  final PopOverlayContent popContent; // Changed from String popContentId
  final double? height;
  final double? width; // Added for width control
  final Color? successButtonColor, cancelButtonColor;
  final bool? cycleFocusWithinGroup;
  final FocusNode? cancelButtonFocusNode;
  final FocusNode? saveButtonFocusNode;
  final String? Function()? wrapFocusTargetRoleBuilder;
  final List<String>? wrapFocusSkipRoles;

  const _PopOverlayBottomBar({
    required this.successButtonTitle,
    required this.cancelButtonTitle,
    required this.isSuccessButtonDisabled,
    required this.showBottomButtonBar,
    required this.onSuccess,
    this.onFutureSuccess,
    this.onFutureSuccessValidator,
    required this.onCancel,
    required this.popContent, // Changed from String popContentId
    this.height, // Default height for the bottom bar
    this.width, // Added for width control
    this.successButtonColor,
    this.cancelButtonColor,
    this.cycleFocusWithinGroup,
    this.cancelButtonFocusNode,
    this.saveButtonFocusNode,
    this.wrapFocusTargetRoleBuilder,
    this.wrapFocusSkipRoles,
  });

  @override
  Widget build(BuildContext context) {
    return _BottomBarButtons(
      height: height,
      successButtonTitle: successButtonTitle,
      cancelButtonTitle: cancelButtonTitle,
      successButtonColor: successButtonColor,
      cancelButtonColor: cancelButtonColor,
      cancelButtonFocusNode: cancelButtonFocusNode ??
          popContent.frameDesign?.cancelButtonFocusNode,
      saveButtonFocusNode:
          saveButtonFocusNode ?? popContent.frameDesign?.saveButtonFocusNode,
      cycleFocusWithinGroup: cycleFocusWithinGroup ??
          popContent.frameDesign?.cycleFocusWithinGroup ??
          false,
      isSuccessButtonDisabled: isSuccessButtonDisabled,
      showBottomButtonBar: showBottomButtonBar,
      popContent: popContent,
      width: width, // Pass width
      wrapFocusTargetRoleBuilder: wrapFocusTargetRoleBuilder,
      wrapFocusSkipRoles: wrapFocusSkipRoles ?? const [],
      onSuccess: () {
        final result = onSuccess?.call();
        if (result == null || result == true) {
          PopOverlay.dismissPop(popContent.id);
        }
      },
      onFutureSuccess: onFutureSuccess,
      onFutureSuccessValidator: onFutureSuccessValidator,
      onCancel: () {
        // Call the onCancel callback
        onCancel?.call();
        // Close the popup - automatically respects shouldMakeInvisibleOnDismiss
        PopOverlay.dismissPop(popContent.id);
      },
    );
  }
}

/// Optimized bottom button bar widget for pop overlays
///
/// Features:
/// - Conditional rendering based on showBottomButtonBar flag
/// - Cancel button that closes the popup without saving
/// - Save/Success button with conditional disabling
/// - Responsive layout with proper spacing and styling
/// - Improved performance through const constructors and cached styles
class _BottomBarButtons extends StatelessWidget {
  /// Callback executed when the Save button is pressed
  final VoidCallback onSuccess;

  /// Future callback executed when the Save button is pressed
  /// If provided, a MyFutureButton will be used instead of a regular button
  final Future<void> Function()? onFutureSuccess;

  /// Validator function that determines whether the popup should be dismissed after onFutureSuccess completes
  /// Returns bool? - if null or true, the popup will be dismissed
  final Future<bool?> Function()? onFutureSuccessValidator;

  /// Callback executed when the Cancel button is pressed
  final VoidCallback onCancel;

  /// Text displayed on the success button
  final String successButtonTitle, cancelButtonTitle;

  /// Whether the success button should be disabled
  final bool isSuccessButtonDisabled;

  /// Whether to show the bottom button bar
  final bool showBottomButtonBar;

  /// Height of the bottom button bar (defaults to 50)
  final double? height;

  /// Width of the bottom button bar (for constraining width)
  final double? width;

  /// Reference to the pop overlay content for dismissal
  final PopOverlayContent popContent;

  // Performance optimized constants
  static const double _containerPadding = 28.0;
  static const double _buttonSpacing = 16.0;
  static const double _buttonHeight = 48.0;
  static const double _borderRadiusValue = 12.0;
  final Color? successButtonColor, cancelButtonColor;
  final FocusNode? cancelButtonFocusNode;
  final FocusNode? saveButtonFocusNode;
  final bool cycleFocusWithinGroup;
  final String? Function()? wrapFocusTargetRoleBuilder;
  final List<String> wrapFocusSkipRoles;

  const _BottomBarButtons({
    required this.onSuccess,
    this.onFutureSuccess,
    this.onFutureSuccessValidator,
    required this.onCancel,
    required this.successButtonTitle,
    required this.cancelButtonTitle,
    required this.popContent,
    this.isSuccessButtonDisabled = false,
    this.showBottomButtonBar = true,
    this.height, // Optional height for the bottom bar
    this.width, // Added for width control
    this.successButtonColor,
    this.cancelButtonColor,
    this.cancelButtonFocusNode,
    this.saveButtonFocusNode,
    this.cycleFocusWithinGroup = false,
    this.wrapFocusTargetRoleBuilder,
    this.wrapFocusSkipRoles = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (!showBottomButtonBar) {
      return const SizedBox.shrink();
    }

    final container = Container(
      height: height,
      padding: EdgeInsets.all(height == null ? _containerPadding : 8),
      decoration: const BoxDecoration(
        color: Color.fromARGB(
            198, 216, 222, 233), // More opaque for better visibility
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: _buttonSpacing,
        children: [
          Expanded(
            child: _CancelButton(
              focusNode: cancelButtonFocusNode,
              cancelButtonTitle: cancelButtonTitle,
              onCancel: onCancel,
              buttonHeight: _buttonHeight,
              borderRadiusValue: _borderRadiusValue,
              cancelButtonColor: cancelButtonColor,
            ),
          ),
          if (successButtonTitle.isNotEmpty)
            Expanded(
              child: _SuccessButton(
                focusNode: saveButtonFocusNode,
                cycleFocusWithinGroup: cycleFocusWithinGroup,
                onSuccess: onSuccess,
                onFutureSuccess: onFutureSuccess,
                validator: onFutureSuccessValidator,
                isSuccessButtonDisabled: isSuccessButtonDisabled,
                successButtonTitle: successButtonTitle,
                popContent: popContent,
                borderRadiusValue: _borderRadiusValue,
                buttonHeight: _buttonHeight,
                successButtonColor: successButtonColor,
                wrapFocusTargetRoleBuilder: wrapFocusTargetRoleBuilder,
                wrapFocusSkipRoles: wrapFocusSkipRoles,
              ),
            ),
        ],
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: container);
    } else {
      return container;
    }
  }
}

//************************************************* */

class _CancelButton extends StatefulWidget {
  final double buttonHeight;
  final double borderRadiusValue;
  final VoidCallback? onCancel;
  final String cancelButtonTitle;

  // Performance optimized constants
  static const double _buttonWidth = 260.0;
  static const Color _backgroundColor = Color(0xFFF3F4F6);
  static const Color _borderColor = Color(0xFFD1D5DB);
  static const Color _textColor = Color(0xFF374151);
  static const double _fontSize = 15.0;
  static const double _letterSpacing = -0.25;
  static const FontWeight _fontWeight = FontWeight.w800;
  final Color? cancelButtonColor;
  final FocusNode? focusNode;
  const _CancelButton({
    this.onCancel,
    this.buttonHeight = 48.0,
    this.borderRadiusValue = 12.0,
    this.cancelButtonTitle = 'Cancel',
    this.cancelButtonColor,
    this.focusNode,
  });

  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton> {
  Color? onFocusColor;

  @override
  void didUpdateWidget(covariant _CancelButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cancelButtonTitle != widget.cancelButtonTitle ||
        oldWidget.buttonHeight != widget.buttonHeight ||
        oldWidget.borderRadiusValue != widget.borderRadiusValue ||
        oldWidget.cancelButtonColor != widget.cancelButtonColor ||
        oldWidget.onCancel != widget.onCancel) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(widget.borderRadiusValue),
        focusNode: widget.focusNode,
        onTap: () => widget.onCancel?.call(),
        onFocusChange: (value) => setState(() => onFocusColor =
            value ? Colors.blue.shade800.withValues(alpha: 0.6) : null),
        child: Container(
          height: widget.buttonHeight,
          width: _CancelButton._buttonWidth,
          decoration: BoxDecoration(
            color: _CancelButton._backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadiusValue),
            border: Border.all(
              color: onFocusColor ??
                  widget.cancelButtonColor ??
                  _CancelButton._borderColor,
              width: onFocusColor == null ? 1 : 2,
            ),
          ),
          child: Center(
            child: Text(
              widget.cancelButtonTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _CancelButton._textColor,
                fontSize: _CancelButton._fontSize,
                fontWeight: _CancelButton._fontWeight,
                letterSpacing: _CancelButton._letterSpacing,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessButton extends StatefulWidget {
  final VoidCallback? onSuccess;
  final Future<void> Function()? onFutureSuccess;
  final Future<bool?> Function()? validator;
  final bool isSuccessButtonDisabled;
  final String successButtonTitle;
  final PopOverlayContent popContent;
  final double borderRadiusValue;
  final double buttonHeight;

  // Performance optimized constants
  static const double _buttonWidth = 260.0;
  static const Color _backgroundColor = Color.fromARGB(188, 1, 183, 125);
  static const Color _textColor = Colors.white;
  static const double _fontSize = 15.0;
  static const double _letterSpacing = -0.25;
  static const FontWeight _fontWeight = FontWeight.w600;
  final Color? successButtonColor;
  final FocusNode? focusNode;
  final bool cycleFocusWithinGroup;
  final String? Function()? wrapFocusTargetRoleBuilder;
  final List<String> wrapFocusSkipRoles;

  const _SuccessButton({
    this.onSuccess,
    this.onFutureSuccess,
    this.validator,
    this.isSuccessButtonDisabled = false,
    this.successButtonTitle = 'Save',
    required this.popContent,
    required this.borderRadiusValue,
    this.buttonHeight = 48.0,
    this.successButtonColor,
    this.focusNode,
    this.cycleFocusWithinGroup = false,
    this.wrapFocusTargetRoleBuilder,
    this.wrapFocusSkipRoles = const [],
  });

  @override
  State<_SuccessButton> createState() => _SuccessButtonState();
}

class _SuccessButtonState extends State<_SuccessButton> {
  Color? onFocusColor;

  late FocusNode node;

  @override
  initState() {
    super.initState();

    node = widget.focusNode ?? RoleFocusNode('SAVE_BUTTON_FALLBACK');
    if (widget.cycleFocusWithinGroup) {
      node.canRequestFocus = true;
    }
  }

  @override
  void didUpdateWidget(covariant _SuccessButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.successButtonTitle != widget.successButtonTitle ||
        oldWidget.buttonHeight != widget.buttonHeight ||
        oldWidget.borderRadiusValue != widget.borderRadiusValue ||
        oldWidget.successButtonColor != widget.successButtonColor ||
        oldWidget.isSuccessButtonDisabled != widget.isSuccessButtonDisabled ||
        oldWidget.onSuccess != widget.onSuccess ||
        oldWidget.onFutureSuccess != widget.onFutureSuccess ||
        oldWidget.validator != widget.validator) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cycleFocusWithinGroup) {
      node.onKeyEvent = (wrappedNode, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.tab &&
            !HardwareKeyboard.instance.isShiftPressed) {
          _wrapToFirst(wrappedNode);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    } else {
      // Reset any previously attached handler to avoid leaking closures when cycling disabled
      if (node.onKeyEvent != null) {
        node.onKeyEvent = null;
      }
    }

    // If onFutureSuccess is provided, use MyFutureButton
    if (widget.onFutureSuccess != null) {
      return SFutureButton(
        isEnabled: !widget.isSuccessButtonDisabled,
        focusNode: node,
        isElevatedButton: false,
        onTap: () async {
          // If a validator is provided, call it first
          if (widget.validator != null) {
            final validationResult = await widget.validator!.call();

            if (validationResult == false) {
              return false; // Show error
            } else if (validationResult == null) {
              return null; // Silent dismissal
            }
          }

          // Execute the future success callback
          await widget.onFutureSuccess!.call();
          return true; // Show success animation
        },
        onPostSuccess: () {
          PopOverlay.dismissPop(widget.popContent.id);
        },
        borderRadius: widget.borderRadiusValue,
        label: widget.successButtonTitle,
        width: _SuccessButton._buttonWidth,
        height: widget.buttonHeight + 30,
        bgColor: widget.successButtonColor ?? _SuccessButton._backgroundColor,
        iconColor: _SuccessButton._textColor,
      );
    }

    // Otherwise, use the original button implementation
    final core = SDisabled(
      isDisabled: widget.isSuccessButtonDisabled,
      opacityWhenDisabled: 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.borderRadiusValue),
          onTap: widget.onSuccess,
          focusNode: node,
          onFocusChange: (value) {
            if (mounted) {
              setState(
                () => onFocusColor =
                    value ? Colors.blue.shade800.withValues(alpha: 0.6) : null,
              );
            }
          },
          child: Container(
            height: widget.buttonHeight,
            width: _SuccessButton._buttonWidth,
            decoration: BoxDecoration(
              color: _SuccessButton._backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadiusValue),
              border: Border.all(
                color: onFocusColor ??
                    widget.successButtonColor ??
                    _SuccessButton._backgroundColor,
                width: onFocusColor != null ? 2 : 0.2,
              ),
            ),
            child: Center(
              child: Text(
                widget.successButtonTitle,
                style: TextStyle(
                  color: _SuccessButton._textColor,
                  fontSize: _SuccessButton._fontSize,
                  fontWeight: _SuccessButton._fontWeight,
                  letterSpacing: _SuccessButton._letterSpacing,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return core;
  }

  void _wrapToFirst(FocusNode currentNode) {
    final BuildContext? context = currentNode.context;
    if (context == null) return;

    final FocusScopeNode scope = FocusScope.of(context);
    final String? desiredRole = widget.wrapFocusTargetRoleBuilder?.call();
    final Set<String> skipRoles = widget.wrapFocusSkipRoles.isEmpty
        ? const <String>{}
        : widget.wrapFocusSkipRoles.toSet();

    FocusNode? target;
    if (desiredRole != null && desiredRole.isNotEmpty) {
      target = _findNodeByRole(scope, desiredRole, skipRoles);
    }

    target ??= _findFirstFocusable(scope, skipRoles);

    if (target != null) {
      scope.requestFocus(target);
    }
  }

  FocusNode? _findNodeByRole(
      FocusNode node, String role, Set<String> skipRoles) {
    if (node is RoleFocusNode &&
        node.role == role &&
        node.canRequestFocus &&
        node.context != null) {
      if (!skipRoles.contains(node.role)) {
        return node;
      }
    }

    for (final FocusNode child in node.children) {
      final FocusNode? nested = _findNodeByRole(child, role, skipRoles);
      if (nested != null) {
        return nested;
      }
    }

    return null;
  }

  FocusNode? _findFirstFocusable(FocusNode node, Set<String> skipRoles) {
    for (final FocusNode child in node.children) {
      if (child is RoleFocusNode && skipRoles.contains(child.role)) {
        final FocusNode? nested = _findFirstFocusable(child, skipRoles);
        if (nested != null) return nested;
        continue;
      }

      if (child.canRequestFocus &&
          child.context != null &&
          child is! FocusScopeNode) {
        return child;
      }

      final FocusNode? nested = _findFirstFocusable(child, skipRoles);
      if (nested != null) return nested;
    }
    return null;
  }
}

//******************************** */

/// FocusNode with a stable role identifier preserved in release builds.
class RoleFocusNode extends FocusNode {
  final String role;
  RoleFocusNode(this.role, {super.skipTraversal}) : super(debugLabel: role);
}
