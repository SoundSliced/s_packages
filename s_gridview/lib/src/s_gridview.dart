import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';

/// A grid-like, scrollable widget that lays out arbitrary child widgets in
/// rows (or columns when horizontal) with a configurable number of items per
/// cross-axis. The widget provides optional index-based auto-scrolling and
/// simple visual scroll indicators.
///
/// Typical usage:
///
/// ```dart
/// SGridView(
///   crossAxisItemCount: 3,
///   children: myTiles,
///   controller: myController,
/// )
/// ```
class SGridView extends StatefulWidget {
  /// Number of children to place on the cross axis (columns for a vertical
  /// layout, rows for a horizontal layout). Must be greater than zero.
  final int crossAxisItemCount;

  /// The list of widgets displayed by the grid. Widgets are placed in order
  /// and split into rows/columns according to [crossAxisItemCount]. This list
  /// must not be null.
  final List<Widget> children;

  /// The main scroll direction of the grid. Defaults to [Axis.vertical]. If
  /// set to [Axis.horizontal] the grid will scroll horizontally and the small
  /// visual indicators will appear on the left/right edges.
  final Axis mainAxisDirection;

  /// Padding to apply around each child element.
  final EdgeInsetsGeometry itemPadding;

  /// External controller used for programmatic index-based scrolling. If not
  /// provided, `SGridView` will create and manage a controller internally.
  final IndexedScrollController? controller;

  /// Whether to show the simple top/bottom (or left/right for horizontal)
  /// scroll indicators. Defaults to `true`.
  final bool showScrollIndicators;

  /// Color used for the gradient and icon of the scroll indicators. If null
  /// a sensible default (yellow) will be used.
  final Color? indicatorColor;

  /// Optional index to auto-scroll to when the widget first builds. The
  /// value will be clamped to the valid child range; the widget computes the
  /// corresponding row and instructs the inner list to scroll to that row.
  final int? autoScrollToIndex;

  /// When pressing the forward indicator at the initial position (index 0),
  /// or the backward indicator at the final position, the grid will jump by
  /// this many groups (rows/columns) instead of the standard single-step
  /// increment. This creates a more intuitive initial navigation experience.
  /// Defaults to 2.
  final int initialIndicatorJump;

  /// Controls the scroll distance when indicators are pressed, as a fraction
  /// of the viewport dimension. For example:
  /// - 1.0 (default) scrolls exactly one viewport height/width
  /// - 0.5 scrolls half a viewport
  /// - 2.0 scrolls two viewports
  /// Must be greater than 0. Defaults to 1.0.
  final double indicatorScrollFraction;

  /// Creates a [SGridView].
  const SGridView({
    super.key,
    this.crossAxisItemCount = 2,
    required this.children,
    this.mainAxisDirection = Axis.vertical,
    this.itemPadding = EdgeInsets.zero,
    this.controller,
    this.showScrollIndicators = true,
    this.indicatorColor,
    this.autoScrollToIndex,
    this.initialIndicatorJump = 2,
    this.indicatorScrollFraction = 1.0,
  })  : assert(crossAxisItemCount > 0,
            'crossAxisItemCount must be greater than zero'),
        assert(indicatorScrollFraction > 0,
            'indicatorScrollFraction must be greater than zero');

  @override
  State<SGridView> createState() => _SGridViewState();
}

class _SGridViewState extends State<SGridView> {
  late IndexedScrollController _scrollController;
  late bool _ownsController;
  bool _showTopIndicator = false;
  bool _showBottomIndicator = true;
  int? _lastAutoScrollIndex;

  /// Tracks the current row/column group index for programmatic navigation.
  int _currentGroupIndex = 0;

  /// Tracks the last indicator direction to bias rounding during scroll updates.
  bool? _lastIndicatorForward;

  /// Timestamp of the last programmatic scroll to distinguish from manual scrolls.
  DateTime? _lastProgrammaticScrollTime;

  /// Flag to prevent concurrent tap processing.
  bool _isProcessingTap = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? IndexedScrollController();
    _ownsController = widget.controller == null;
    _scrollController.controller.addListener(updateScrollIndicators);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        updateScrollIndicators();
      }
    });
  }

  @override
  void didUpdateWidget(SGridView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      _scrollController.controller.removeListener(updateScrollIndicators);

      if (_ownsController) {
        _scrollController.controller.dispose();
      }

      _scrollController = widget.controller ?? IndexedScrollController();
      _ownsController = widget.controller == null;
      _scrollController.controller.addListener(updateScrollIndicators);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          updateScrollIndicators();
        }
      });
    } else if (oldWidget.children.length != widget.children.length ||
        oldWidget.crossAxisItemCount != widget.crossAxisItemCount ||
        oldWidget.itemPadding != widget.itemPadding ||
        oldWidget.mainAxisDirection != widget.mainAxisDirection) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          updateScrollIndicators();
        }
      });
    }

    if (widget.autoScrollToIndex != null &&
        widget.autoScrollToIndex != _lastAutoScrollIndex) {
      _lastAutoScrollIndex = widget.autoScrollToIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _performAutoScroll();
        }
      });
    } else if (oldWidget.autoScrollToIndex != widget.autoScrollToIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          updateScrollIndicators();
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.controller.removeListener(updateScrollIndicators);
    if (_ownsController) {
      _scrollController.controller.dispose();
    }
    super.dispose();
  }

  void updateScrollIndicators() {
    if (!mounted || !_scrollController.controller.hasClients) return;

    final bool showTop = _scrollController.controller.offset > 20;
    final bool showBottom = _scrollController.controller.offset <
        (_scrollController.controller.position.maxScrollExtent - 20);

    if (showTop != _showTopIndicator || showBottom != _showBottomIndicator) {
      if (mounted) {
        setState(() {
          _showTopIndicator = showTop;
          _showBottomIndicator = showBottom;
        });
      }
    }
  }

  Future<void> _performAutoScroll() async {
    if (!mounted ||
        widget.autoScrollToIndex == null ||
        widget.children.isEmpty) {
      return;
    }

    final int rawIndex = widget.autoScrollToIndex!;
    final int clampedIndex = rawIndex.clamp(0, widget.children.length - 1);
    final int groupCount =
        (widget.children.length / widget.crossAxisItemCount).ceil();
    final int targetGroup =
        (clampedIndex ~/ widget.crossAxisItemCount).clamp(0, groupCount - 1);

    await _scrollController.scrollToIndex(
      targetGroup,
      itemCount: groupCount,
    );

    if (!mounted) return;
  }

  /// Scrolls programmatically by one viewport in the given direction.
  /// When [forward] is true, scrolls towards bottom/right; when false,
  /// scrolls towards top/left. At the start or end positions, uses
  /// [initialIndicatorJump] to create a more intuitive navigation experience.
  Future<void> _scrollByOne({required bool forward}) async {
    if (!mounted || _isProcessingTap) return;
    _isProcessingTap = true;

    try {
      final int groupCount =
          (widget.children.length / widget.crossAxisItemCount).ceil();
      if (groupCount == 0) return;

      final int nextIndex = _calculateNextIndex(groupCount, forward);
      if (nextIndex == _currentGroupIndex) return;

      if (_scrollController.controller.hasClients) {
        final position = _scrollController.controller.position;
        final targetOffset = _calculateTargetOffset(position, forward);

        await _scrollController.controller.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }

      if (!mounted) return;

      _currentGroupIndex = nextIndex;
      _lastProgrammaticScrollTime = DateTime.now();
      updateScrollIndicators();
    } finally {
      if (mounted) {
        _isProcessingTap = false;
      }
    }
  }

  /// Calculates the next group index based on current position and direction.
  int _calculateNextIndex(int groupCount, bool forward) {
    if (forward) {
      return _currentGroupIndex == 0
          ? (_currentGroupIndex + widget.initialIndicatorJump)
              .clamp(0, groupCount - 1)
          : (_currentGroupIndex + 1).clamp(0, groupCount - 1);
    } else {
      return _currentGroupIndex == groupCount - 1
          ? (_currentGroupIndex - widget.initialIndicatorJump)
              .clamp(0, groupCount - 1)
          : (_currentGroupIndex - 1).clamp(0, groupCount - 1);
    }
  }

  /// Calculates the target scroll offset for viewport-aligned scrolling.
  /// Uses [widget.indicatorScrollFraction] to determine scroll distance.
  double _calculateTargetOffset(ScrollPosition position, bool forward) {
    final viewportDimension = position.viewportDimension;
    final currentOffset = position.pixels;
    final step = viewportDimension * widget.indicatorScrollFraction;

    return forward
        ? (currentOffset + step).clamp(0.0, position.maxScrollExtent)
        : (currentOffset - step).clamp(0.0, position.maxScrollExtent);
  }

  /// Updates the current group index by estimating from the scroll offset.
  /// Uses directional bias for more accurate tracking during manual scrolls.
  void _updateCurrentGroupFromOffset(int groupCount, {bool? biasForward}) {
    if (!_scrollController.controller.hasClients || groupCount <= 1) {
      _currentGroupIndex = _currentGroupIndex.clamp(0, groupCount - 1);
      return;
    }

    final position = _scrollController.controller.position;
    final maxExtent = position.maxScrollExtent;
    if (maxExtent <= 0) {
      _currentGroupIndex = 0;
      return;
    }

    final pixels = position.pixels.clamp(0.0, maxExtent);
    final step = maxExtent / (groupCount - 1);
    if (step <= 0) {
      _currentGroupIndex = 0;
      return;
    }

    const edgeEpsilon = 3.0;
    final int estimated;
    if (pixels <= edgeEpsilon) {
      estimated = 0;
    } else if ((maxExtent - pixels) <= edgeEpsilon) {
      estimated = groupCount - 1;
    } else {
      final ratio = pixels / step;
      estimated = biasForward == true
          ? ratio.ceil()
          : biasForward == false
              ? ratio.floor()
              : ratio.round();
    }

    _currentGroupIndex = estimated.clamp(0, groupCount - 1);
  }

  @override
  Widget build(BuildContext context) {
    final gridView = widget.children.isNotEmpty
        ? widget.children.splitInChunks(widget.crossAxisItemCount)
        : <List<Widget>>[];

    int? targetRowIndex;
    if (widget.autoScrollToIndex != null && gridView.isNotEmpty) {
      final clampedIndex =
          widget.autoScrollToIndex!.clamp(0, widget.children.length - 1);
      final derivedRow = clampedIndex ~/ widget.crossAxisItemCount;
      targetRowIndex = derivedRow.clamp(0, gridView.length - 1);
      _currentGroupIndex = targetRowIndex;
    }

    final groupCount = gridView.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateCurrentGroupFromOffset(groupCount);
      }
    });

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topLeft,
      children: [
        NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification &&
                  notification.dragDetails != null) {
                _updateCurrentGroupFromOffset(groupCount,
                    biasForward: _lastIndicatorForward);
              } else if (notification is ScrollEndNotification) {
                final timeSinceLastScroll = _lastProgrammaticScrollTime == null
                    ? const Duration(seconds: 1)
                    : DateTime.now().difference(_lastProgrammaticScrollTime!);

                if (timeSinceLastScroll > const Duration(milliseconds: 500)) {
                  _updateCurrentGroupFromOffset(groupCount,
                      biasForward: _lastIndicatorForward);
                }
              }
              return false;
            },
            child: IndexScrollListViewBuilder(
              controller: _scrollController,
              onScrolledTo: (index) {
                if (!mounted) return;
                updateScrollIndicators();
                _currentGroupIndex = index;
                if (index != targetRowIndex) {
                  targetRowIndex = index;
                }
              },
              scrollDirection: widget.mainAxisDirection,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: Pad.zero,
              itemCount: gridView.length,
              numberOfOffsetedItemsPriorToSelectedItem: 2,
              itemBuilder: (context, i) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: _CrossAxisItems(
                    axisDirection: widget.mainAxisDirection,
                    padding: widget.itemPadding,
                    children: gridView[i],
                  ),
                );
              },
            )),
        if (widget.showScrollIndicators &&
            widget.children.length > widget.crossAxisItemCount * 3)
          ..._buildScrollIndicators(),
      ],
    );
  }

  List<Widget> _buildScrollIndicators() {
    final indicatorColor = widget.indicatorColor ?? Colors.yellow.shade600;
    final isVertical = widget.mainAxisDirection == Axis.vertical;
    return [
      if (_showTopIndicator)
        Positioned(
          top: isVertical ? -5 : 0,
          left: isVertical ? 0 : -5,
          right: isVertical ? 0 : null,
          bottom: isVertical ? null : 0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _lastIndicatorForward = false;
                _scrollByOne(forward: false);
              },
              child: Container(
                height: isVertical ? 24 : null,
                width: isVertical ? null : 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: isVertical
                        ? Alignment.bottomCenter
                        : Alignment.centerRight,
                    end:
                        isVertical ? Alignment.topCenter : Alignment.centerLeft,
                    colors: [
                      Colors.transparent,
                      indicatorColor.withAlpha(50),
                    ],
                  ),
                ),
                child: Icon(
                  isVertical
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_left,
                  color: indicatorColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      if (_showBottomIndicator)
        Positioned(
          bottom: isVertical ? -5 : 0,
          left: isVertical ? 0 : null,
          right: isVertical ? 0 : -5,
          top: isVertical ? null : 0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _lastIndicatorForward = true;
                _scrollByOne(forward: true);
              },
              child: Container(
                height: isVertical ? 24 : null,
                width: isVertical ? null : 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin:
                        isVertical ? Alignment.topCenter : Alignment.centerLeft,
                    end: isVertical
                        ? Alignment.bottomCenter
                        : Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      indicatorColor.withAlpha(50),
                    ],
                  ),
                ),
                child: Icon(
                  isVertical
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  color: indicatorColor,
                  size: 34,
                ),
              ),
            ),
          ),
        ),
    ];
  }
}

class _CrossAxisItems extends StatelessWidget {
  final Axis axisDirection;
  final EdgeInsetsGeometry padding;
  final List<Widget> children;

  const _CrossAxisItems({
    required this.children,
    this.axisDirection = Axis.vertical,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction:
          axisDirection == Axis.vertical ? Axis.horizontal : Axis.vertical,
      alignment: WrapAlignment.spaceEvenly,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < children.length; i++)
          Padding(
            padding: padding,
            child: children[i],
          ),
      ],
    );
  }
}
