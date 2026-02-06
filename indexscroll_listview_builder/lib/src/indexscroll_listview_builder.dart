import 'package:flutter/material.dart';
import 'package:indexscroll_listview_builder/src/indexed_scroll_child.dart';
import 'package:indexscroll_listview_builder/src/indexed_scroll_controller.dart';

/// A highly customizable ListView.builder with built-in index-based scrolling capabilities.
///
/// This widget extends the functionality of Flutter's standard [ListView.builder] by adding
/// the ability to programmatically scroll to any item by its index, even before that item
/// has been built or is off-screen.
///
/// Key features:
/// * **Index-based scrolling**: Jump to any item in the list by index
/// * **Automatic scroll on initialization**: Optionally scroll to a specific item when the list is first built
/// * **Smooth animations**: Configurable animation duration and curves
/// * **Smart positioning**: Control where items appear in the viewport (alignment)
/// * **Offset support**: Scroll to an item while keeping previous items visible
/// * **Optional scrollbar**: Built-in scrollbar support with full customization
/// * **Unbounded constraint handling**: Automatically manages shrinkWrap based on layout constraints
///
/// Example - Basic usage:
/// ```dart
/// IndexScrollListViewBuilder(
///   itemCount: 100,
///   itemBuilder: (context, index) => ListTile(
///     title: Text('Item $index'),
///   ),
/// )
/// ```
///
/// Example - Scroll to specific index on initialization:
/// ```dart
/// IndexScrollListViewBuilder(
///   itemCount: 100,
///   indexToScrollTo: 50,  // Automatically scrolls to item 50
///   itemBuilder: (context, index) => ListTile(
///     title: Text('Item $index'),
///   ),
/// )
/// ```
///
/// Example - With custom controller for programmatic control:
/// ```dart
/// final controller = IndexedScrollController();
///
/// IndexScrollListViewBuilder(
///   controller: controller,
///   itemCount: 100,
///   itemBuilder: (context, index) => ListTile(
///     title: Text('Item $index'),
///   ),
/// )
///
/// // Later, scroll programmatically
/// controller.scrollToIndex(75);
/// ```
///
/// See also:
///  * [ListView.builder], the underlying widget being enhanced
///  * [IndexedScrollController], which manages the scrolling logic
///  * [IndexedScrollTag], which tags each item for scrolling
class IndexScrollListViewBuilder extends StatefulWidget {
  /// The total number of items in the list.
  final int itemCount;

  /// Builder function that creates widgets for each item in the list.
  ///
  /// Called with the build context and item index. Should return a widget
  /// representing that item.
  final Widget Function(BuildContext, int) itemBuilder;

  /// Optional index to automatically scroll to when the widget rebuilds.
  ///
  /// This parameter acts as a **declarative "home position"** for the list.
  /// When specified, the list will automatically scroll to this index on every
  /// rebuild, even if you've scrolled away using [controller.scrollToIndex()].
  ///
  /// **Behavior**:
  /// - When `null`: No automatic scrolling occurs. The list stays at its current
  ///   scroll position, and imperative scrolling via controller persists across rebuilds.
  /// - When set to an index: The list will scroll to this index on every rebuild,
  ///   overriding any imperative scrolling done via the controller.
  ///
  /// **Use cases**:
  /// - **Declarative positioning**: Keep the list at a specific position that's
  ///   tied to your app state (e.g., currently selected item).
  /// - **Mixed scrolling**: Use imperative scrolling temporarily (e.g., preview),
  ///   then let rebuilds restore the declarative position.
  /// - **Pure imperative control**: Set to `null` to let controller scrolling
  ///   persist across rebuilds.
  ///
  /// Example:
  /// ```dart
  /// // Declarative: list always shows the selected item
  /// IndexScrollListViewBuilder(
  ///   indexToScrollTo: selectedIndex, // Rebuilds restore this position
  ///   itemCount: 100,
  ///   itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
  /// )
  ///
  /// // Imperative: controller scrolling persists
  /// IndexScrollListViewBuilder(
  ///   indexToScrollTo: null, // No automatic positioning
  ///   controller: myController,
  ///   itemCount: 100,
  ///   itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
  /// )
  /// // myController.scrollToIndex(50) will persist across rebuilds
  /// ```
  final int? indexToScrollTo;

  /// The axis along which the list scrolls.
  ///
  /// Defaults to [Axis.vertical].
  final Axis? scrollDirection;

  /// The scroll physics for the list.
  ///
  /// Defaults to [BouncingScrollPhysics].
  final ScrollPhysics? physics;

  /// Whether the list should shrink-wrap its content.
  ///
  /// If null (default), this is automatically determined based on the layout
  /// constraints. When the list has unbounded constraints, shrinkWrap is
  /// automatically enabled to prevent errors.
  final bool? shrinkWrap;

  /// Number of items to show before the target item when scrolling.
  ///
  /// When scrolling to an item, this offset determines how many previous items
  /// should remain visible above (or to the left of) the target item.
  ///
  /// For example, with a value of 2, scrolling to index 10 will actually scroll
  /// to index 8, keeping items 8 and 9 visible above item 10.
  ///
  /// Defaults to 1. Values are automatically clamped to valid ranges.
  final int numberOfOffsetedItemsPriorToSelectedItem;

  /// The alignment of the target item in the viewport (0.0 to 1.0).
  ///
  /// * 0.0: Aligns the item at the start (top for vertical, left for horizontal)
  /// * 0.5: Centers the item in the viewport
  /// * 1.0: Aligns the item at the end (bottom for vertical, right for horizontal)
  ///
  /// Defaults to 0.2 (20% from the start). This property is passed to the
  /// [IndexedScrollController].
  final double? scrollAlignment;

  /// Starting padding for the list.
  ///
  /// Deprecated and currently unused. Use [padding] instead.
  @Deprecated('Use padding parameter instead')
  final double? startPadding;

  /// Optional [IndexedScrollController] to use for this list.
  ///
  /// If provided, this controller can be used to programmatically scroll the
  /// list from outside the widget. If null, an internal controller is created
  /// and managed automatically.
  final IndexedScrollController? controller;

  /// Unified callback invoked whenever the list scrolls to an index
  /// as a result of either declarative `indexToScrollTo` or a programmatic
  /// `controller.scrollToIndex(...)`.
  ///
  /// Use this to confirm that a requested index was reached and optionally
  /// update your declarative state (e.g., set `indexToScrollTo` to the new
  /// index or to `null` to switch to imperative persistence).
  final void Function(int index) onScrolledTo;

  /// Duration of the scroll animation.
  ///
  /// Defaults to 400 milliseconds.
  final Duration scrollAnimationDuration;

  /// Padding around the list content.
  ///
  /// Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry? padding;

  /// Whether to show a scrollbar.
  ///
  /// Defaults to false. When true, a [Scrollbar] widget wraps the list.
  final bool showScrollbar;

  /// Whether the scrollbar thumb should always be visible.
  ///
  /// Only applies when [showScrollbar] is true.
  final bool? scrollbarThumbVisibility;

  /// Whether the scrollbar track should always be visible.
  ///
  /// Only applies when [showScrollbar] is true.
  final bool? scrollbarTrackVisibility;

  /// The thickness of the scrollbar.
  ///
  /// Only applies when [showScrollbar] is true.
  final double? scrollbarThickness;

  /// The radius of the scrollbar corners.
  ///
  /// Only applies when [showScrollbar] is true.
  final Radius? scrollbarRadius;

  /// Which side of the list to show the scrollbar.
  ///
  /// Only applies when [showScrollbar] is true.
  final ScrollbarOrientation? scrollbarOrientation;

  /// Whether the scrollbar can be dragged for seeking.
  ///
  /// Only applies when [showScrollbar] is true.
  final bool? scrollbarInteractive;

  /// Whether to suppress platform-specific scrollbars.
  ///
  /// Defaults to false. When true, platform scrollbars (like those on web)
  /// are hidden in favor of custom scrollbar configuration.
  final bool suppressPlatformScrollbars;

  /// Maximum number of frames to wait before initiating auto-scroll.
  ///
  /// Overrides the controller's default [maxFramePasses] value.
  final int? autoScrollMaxFrameDelay;

  /// Number of frames to wait at the end of auto-scroll.
  ///
  /// Overrides the controller's default [endOfFramePasses] value.
  final int? autoScrollEndOfFrameDelay;

  /// Creates an [IndexScrollListViewBuilder].
  ///
  /// The [itemBuilder] and [itemCount] parameters are required.
  ///
  /// All other parameters are optional and provide fine-grained control over
  /// scrolling behavior, appearance, and performance.
  const IndexScrollListViewBuilder({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.scrollDirection,
    this.physics,
    this.shrinkWrap,
    this.indexToScrollTo,
    this.numberOfOffsetedItemsPriorToSelectedItem = 1,
    this.startPadding,
    this.controller,
    required this.onScrolledTo,
    this.scrollAnimationDuration = const Duration(milliseconds: 400),
    this.scrollAlignment,
    this.padding,
    this.showScrollbar = false,
    this.scrollbarThumbVisibility,
    this.scrollbarTrackVisibility,
    this.scrollbarThickness,
    this.scrollbarRadius,
    this.scrollbarOrientation,
    this.scrollbarInteractive,
    this.suppressPlatformScrollbars = false,
    this.autoScrollMaxFrameDelay,
    this.autoScrollEndOfFrameDelay,
  });

  @override
  State<IndexScrollListViewBuilder> createState() =>
      _IndexScrollListViewBuilderState();
}

/// State class for [IndexScrollListViewBuilder].
///
/// Manages the scroll controller lifecycle, handles widget updates, and
/// coordinates automatic scrolling operations.
class _IndexScrollListViewBuilderState
    extends State<IndexScrollListViewBuilder> {
  /// The scroll controller used for this list.
  /// Either provided externally or created internally.
  late IndexedScrollController _scrollController;

  /// Whether this state object owns and should dispose the scroll controller.
  /// True when using an internally created controller, false when using an external one.
  late bool _ownsController;

  /// Current target index for automatic scrolling.
  /// Null if no auto-scroll is requested.
  int? indexToScrollTo;

  /// Current offset value, clamped to valid range based on item count.
  late int numberOfOffsetedItemsPriorToSelectedItem;

  /// Flag to track if we're currently handling a programmatic scroll.
  /// When true, prevents declarative scroll from cancelling the imperative one.
  bool _isHandlingProgrammaticScroll = false;

  /// Tracks whether we've had at least one rebuild since the last programmatic scroll.
  /// Used to distinguish between immediate rebuilds (from onScrolledTo) and subsequent
  /// external rebuilds (from user actions like clicking a button).
  bool _hasRebuiltSinceProgrammaticScroll = false;

  @override
  void initState() {
    super.initState();

    // Initialize with the provided controller or create a new one
    if (widget.controller != null) {
      // Use the externally provided controller
      _scrollController = widget.controller!;
      _ownsController = false;
      // Subscribe to programmatic scroll events and forward to callback
      _scrollController.programmaticScrollIndex
          .addListener(_handleProgrammaticScroll);
    } else {
      // Create and manage our own controller
      _scrollController = IndexedScrollController(
        scrollController: ScrollController(),
        alignment: widget.scrollAlignment ?? 0.2,
        duration: widget.scrollAnimationDuration,
        curve: Curves.easeOut,
      );
      _ownsController = true;
    }

    // Initialize state variables and trigger initial auto-scroll if needed
    initializeAll();
  }

  void _handleProgrammaticScroll() {
    final idx = _scrollController.programmaticScrollIndex.value;
    if (idx != null) {
      // Mark that we're handling a programmatic scroll
      _isHandlingProgrammaticScroll = true;
      // Reset the rebuild tracker - we haven't rebuilt since this new scroll
      _hasRebuiltSinceProgrammaticScroll = false;
      // Defer callback to post-frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onScrolledTo(idx);
          // Reset flag after a short delay to allow user's setState to complete
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) {
              _isHandlingProgrammaticScroll = false;
              // Mark that the programmatic scroll sequence is complete and ready
              // for auto-restore detection on the next rebuild
              _hasRebuiltSinceProgrammaticScroll = true;
            }
          });
        }
      });
    }
  }

  /// Initializes or re-initializes state variables and triggers auto-scroll if needed.
  ///
  /// This method:
  /// 1. Clamps the offset value to a valid range
  /// 2. Updates the target scroll index
  /// 3. Triggers auto-scroll if an index is specified
  void initializeAll() {
    // Ensure offset doesn't exceed item count to prevent out-of-bounds errors
    numberOfOffsetedItemsPriorToSelectedItem =
        widget.numberOfOffsetedItemsPriorToSelectedItem >= widget.itemCount
            ? widget.itemCount - 1
            : widget.numberOfOffsetedItemsPriorToSelectedItem;

    // Set the target index from widget property
    indexToScrollTo = widget.indexToScrollTo;

    // Only auto-scroll if we need to (if index is specified)
    if (indexToScrollTo != null) {
      _autoScroll();
    }
  }

  /// Performs automatic scrolling to the target index with offset applied.
  ///
  /// This method calculates the effective scroll target by:
  /// 1. Subtracting the offset from the target index
  /// 2. Clamping the result to valid list bounds [0, itemCount-1]
  /// 3. Initiating the scroll animation
  ///
  /// The offset allows showing items before the target, providing better context.
  void _autoScroll() {
    // Calculate the effective index with offset applied
    // If no target, default to 0
    // Otherwise, subtract offset and clamp to [0, itemCount-1]
    int ind = indexToScrollTo == null
        ? 0
        : (indexToScrollTo! - numberOfOffsetedItemsPriorToSelectedItem) < 0
            ? 0 // Clamp to start of list
            : (indexToScrollTo! - numberOfOffsetedItemsPriorToSelectedItem) >=
                    widget.itemCount
                ? widget.itemCount - 1 // Clamp to end of list
                : indexToScrollTo! - numberOfOffsetedItemsPriorToSelectedItem;

    // Initiate the scroll operation with configured parameters
    _scrollController.scrollToIndex(
      ind,
      duration: widget.scrollAnimationDuration,
      alignmentOverride: widget.scrollAlignment,
      maxFrameDelay: widget.autoScrollMaxFrameDelay,
      endOfFrameDelay: widget.autoScrollEndOfFrameDelay,
      itemCount: widget.itemCount,
    );
    // Inform parent that a declarative scroll was initiated to the target index
    // Note: we report the requested indexToScrollTo, not the offset-adjusted `ind`.
    // Defer to post-frame to avoid setState during build.
    if (indexToScrollTo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onScrolledTo(indexToScrollTo!);
        }
      });
    }
  }

  @override
  void didUpdateWidget(IndexScrollListViewBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle controller updates if provided externally
    // Case 1: New external controller provided
    if (widget.controller != null &&
        !identical(widget.controller, _scrollController)) {
      // Dispose old controller if we owned it
      if (_ownsController) {
        _scrollController.controller.dispose();
      }
      // Switch to the new external controller
      _scrollController = widget.controller!;
      _ownsController = false;
      _scrollController.programmaticScrollIndex
          .addListener(_handleProgrammaticScroll);
      initializeAll();
    }
    // Case 2: External controller removed, need to create our own
    else if (widget.controller == null && !_ownsController) {
      // Create a new internal controller
      _scrollController = IndexedScrollController(
        scrollController: ScrollController(),
        alignment: widget.scrollAlignment ?? 0.2,
        duration: widget.scrollAnimationDuration,
        curve: Curves.easeOut,
      );
      _ownsController = true;
      // No external controller, ensure listener is not attached
      initializeAll();
    }

    // Handle declarative scroll target:
    // If indexToScrollTo is non-null, always honor it (acts as "home position")
    // This means rebuilds will restore the declarative position, even if
    // the user scrolled away imperatively via controller.scrollToIndex()
    // UNLESS we're currently handling a programmatic scroll - in that case,
    // the user is updating indexToScrollTo in response to the imperative scroll,
    // so we should NOT trigger another scroll (which would cancel the current one).
    if (widget.indexToScrollTo != null &&
        widget.indexToScrollTo != indexToScrollTo) {
      // Skip if we're handling a programmatic scroll and the new value matches
      // what we're scrolling to (user is following the imperative scroll)
      final skipBecauseProgrammatic = _isHandlingProgrammaticScroll;

      if (!skipBecauseProgrammatic) {
        setState(() {
          indexToScrollTo = widget.indexToScrollTo!;
          _autoScroll();
        });
      } else {
        // Just update the target without scrolling
        indexToScrollTo = widget.indexToScrollTo!;
      }
    }
    // NEW: Auto-restore logic - only triggers when ALL these conditions are met:
    // 1. indexToScrollTo is non-null (declarative mode active)
    // 2. We have an external controller (user provided one)
    // 3. Controller's last scroll differs from declarative target (mismatch exists)
    // 4. We're NOT currently handling a programmatic scroll (not in the middle of one)
    // 5. We've had at least one rebuild since the programmatic scroll
    //    (ensures the immediate rebuild from onScrolledTo doesn't trigger auto-restore)
    //
    // This ensures we only auto-restore on truly "external" rebuilds (like user
    // clicking a button that calls setState), not on the immediate rebuild that
    // happens as part of the programmatic scroll's onScrolledTo callback.
    else if (widget.indexToScrollTo != null &&
        !_ownsController &&
        _scrollController.programmaticScrollIndex.value != null &&
        _scrollController.programmaticScrollIndex.value !=
            widget.indexToScrollTo &&
        !_isHandlingProgrammaticScroll &&
        _hasRebuiltSinceProgrammaticScroll) {
      // Mismatch detected: controller scrolled to one index, declarative target
      // is different, and we've already had the first rebuild after that scroll.
      // This is a subsequent "external" rebuild.
      // User didn't update indexToScrollTo in callback → auto-restore to home position.
      setState(() {
        indexToScrollTo = widget.indexToScrollTo!;
        _autoScroll();
      });
    }

    // Handle offset changes - re-initialize to recalculate with new offset
    if (oldWidget.numberOfOffsetedItemsPriorToSelectedItem !=
        widget.numberOfOffsetedItemsPriorToSelectedItem) {
      setState(() {
        initializeAll();
      });
    }
  }

  @override
  void dispose() {
    // Only dispose the controller if we created it internally
    // External controllers are managed by their owner, not by us
    if (_ownsController) {
      _scrollController.controller.dispose();
    }
    // Detach listener from external controller if present
    if (!_ownsController) {
      _scrollController.programmaticScrollIndex
          .removeListener(_handleProgrammaticScroll);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap in LayoutBuilder to detect unbounded constraints
    // This is necessary to automatically handle shrinkWrap when needed
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we need shrinkWrap based on constraints
        // shrinkWrap is required when:
        // - The user explicitly requests it, OR
        // - We have unbounded constraints in the scroll direction
        //   (vertical scroll with infinite height, or horizontal scroll with infinite width)
        final bool needsShrinkWrap = widget.shrinkWrap ??
            (constraints.maxHeight == double.infinity &&
                    (widget.scrollDirection ?? Axis.vertical) ==
                        Axis.vertical) ||
                (constraints.maxWidth == double.infinity &&
                    (widget.scrollDirection ?? Axis.vertical) ==
                        Axis.horizontal);

        // Build the core ListView with all configured properties
        final listView = ListView.builder(
          padding: widget.padding ?? EdgeInsets.zero,
          controller: _scrollController.controller,
          itemCount: widget.itemCount,
          scrollDirection: widget.scrollDirection ?? Axis.vertical,
          physics: widget.physics ?? const BouncingScrollPhysics(),
          shrinkWrap: needsShrinkWrap,

          // Use enhanced caching for smoother scrolling and better performance
          // The larger cache extent pre-builds more items off-screen,
          // reducing jank during fast scrolling
          cacheExtent: 500,

          // Wrap each item in IndexedScrollTag to enable index-based scrolling
          itemBuilder: (context, index) => IndexedScrollTag(
            key: ValueKey(index), // Stable key based on index
            controller: _scrollController,
            index: index,
            child: widget.itemBuilder(context, index),
          ),
        );

        // Start with the base ListView
        Widget content = listView;

        // Optionally wrap in a Scrollbar widget
        if (widget.showScrollbar) {
          content = Scrollbar(
            controller: _scrollController.controller,
            thumbVisibility: widget.scrollbarThumbVisibility,
            trackVisibility: widget.scrollbarTrackVisibility,
            thickness: widget.scrollbarThickness,
            radius: widget.scrollbarRadius,
            scrollbarOrientation: widget.scrollbarOrientation,
            interactive: widget.scrollbarInteractive,
            child: content,
          );
        }

        // Optionally suppress platform-specific scrollbars
        // This is useful when you want complete control over scrollbar appearance
        if (widget.suppressPlatformScrollbars) {
          final ScrollBehavior behavior = ScrollConfiguration.of(context);
          content = ScrollConfiguration(
            behavior: behavior.copyWith(scrollbars: false),
            child: content,
          );
        }

        return content;
      },
    );
  }
}
