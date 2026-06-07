import 'package:flutter/material.dart';
import 'package:s_packages/indexscroll_listview_builder/indexscroll_listview_builder.dart';
import 'package:s_packages/s_sync_scroll_controller/s_sync_scroll_controller.dart';

/// Builds a fixed row-header cell for [rowIndex].
typedef SSpreadsheetRowHeaderBuilder = Widget Function(BuildContext context, int rowIndex);

/// Builds a fixed column-header cell for [columnIndex].
typedef SSpreadsheetColumnHeaderBuilder = Widget Function(BuildContext context, int columnIndex);

/// Builds a body cell for [rowIndex] and [columnIndex].
typedef SSpreadsheetCellBuilder = Widget Function(BuildContext context, int rowIndex, int columnIndex);

/// Resolves a row height for [rowIndex].
typedef SSpreadsheetRowHeightBuilder = double Function(int rowIndex);

/// Resolves a column width for [columnIndex].
typedef SSpreadsheetColumnWidthBuilder = double Function(int columnIndex);

/// Reports synchronized horizontal scroll metrics.
typedef SSpreadsheetHorizontalMetricsChanged = void Function(
  double offset,
  double maxScrollExtent,
  ScrollController controller,
);

/// Immutable snapshot of horizontal scroll state for a spreadsheet.
class SSpreadsheetHorizontalMetrics {
  final double offset;
  final double maxScrollExtent;
  final ScrollController? controller;

  const SSpreadsheetHorizontalMetrics({
    this.offset = 0,
    this.maxScrollExtent = 0,
    this.controller,
  });

  bool canScrollLeft({double threshold = 100}) => offset > threshold;

  bool canScrollRight({double threshold = 100}) => offset < (maxScrollExtent - threshold);
}

/// Shared horizontal synchronization state for [SSpreadsheet].
///
/// Pass one instance to [SSpreadsheet.horizontalSyncController] and to
/// [SSpreadsheetHorizontalScrollButtons] to control scrolling externally.
class SSpreadsheetHorizontalSyncController extends ValueNotifier<SSpreadsheetHorizontalMetrics> {
  SSpreadsheetHorizontalSyncController([SSpreadsheetHorizontalMetrics? initial])
      : super(initial ?? const SSpreadsheetHorizontalMetrics());

  void update(double offset, double maxScrollExtent, ScrollController controller) {
    value = SSpreadsheetHorizontalMetrics(
      offset: offset,
      maxScrollExtent: maxScrollExtent,
      controller: controller,
    );
  }

  Future<void> animateToStart({
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeOutCubic,
  }) async {
    final c = value.controller;
    if (c == null) return;
    await c.animateTo(0, duration: duration, curve: curve);
  }

  Future<void> animateToEnd({
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeOutCubic,
  }) async {
    final c = value.controller;
    if (c == null) return;
    await c.animateTo(value.maxScrollExtent, duration: duration, curve: curve);
  }
}

/// Builder used by [SSpreadsheetHorizontalScrollButtons] to render each arrow button.
typedef SSpreadsheetScrollButtonBuilder = Widget Function(
  BuildContext context, {
  required bool isLeft,
  required bool isEnabled,
  required VoidCallback onTap,
});

/// Ready-to-use horizontal left/right scroll buttons bound to an
/// [SSpreadsheetHorizontalSyncController].
class SSpreadsheetHorizontalScrollButtons extends StatelessWidget {
  final SSpreadsheetHorizontalSyncController controller;
  final EdgeInsetsGeometry padding;
  final double leadingInset;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final Duration animationDuration;
  final Curve animationCurve;
  final double activationThreshold;
  final SSpreadsheetScrollButtonBuilder? buttonBuilder;

  const SSpreadsheetHorizontalScrollButtons({
    super.key,
    required this.controller,
    this.padding = EdgeInsets.zero,
    this.leadingInset = 0,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeOutCubic,
    this.activationThreshold = 100,
    this.buttonBuilder,
  });

  Widget _defaultButton(
    BuildContext context, {
    required bool isLeft,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: isEnabled ? 1 : 0.45,
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Container(
            width: 30,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue.shade500.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.shade700.withValues(alpha: 0.5), width: 0.5),
            ),
            alignment: Alignment.center,
            child: Icon(
              isLeft ? Icons.chevron_left : Icons.chevron_right,
              color: Colors.blue.shade900,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (leadingInset > 0) SizedBox(width: leadingInset),
          Expanded(
            child: ValueListenableBuilder<SSpreadsheetHorizontalMetrics>(
              valueListenable: controller,
              builder: (context, metrics, _) {
                final leftEnabled = metrics.canScrollLeft(threshold: activationThreshold);
                final rightEnabled = metrics.canScrollRight(threshold: activationThreshold);

                void leftOnTap() {
                  controller.animateToStart(
                    duration: animationDuration,
                    curve: animationCurve,
                  );
                }

                void rightOnTap() {
                  controller.animateToEnd(
                    duration: animationDuration,
                    curve: animationCurve,
                  );
                }

                return Row(
                  mainAxisAlignment: mainAxisAlignment,
                  crossAxisAlignment: crossAxisAlignment,
                  children: [
                    buttonBuilder?.call(
                          context,
                          isLeft: true,
                          isEnabled: leftEnabled,
                          onTap: leftOnTap,
                        ) ??
                        _defaultButton(
                          context,
                          isLeft: true,
                          isEnabled: leftEnabled,
                          onTap: leftOnTap,
                        ),
                    buttonBuilder?.call(
                          context,
                          isLeft: false,
                          isEnabled: rightEnabled,
                          onTap: rightOnTap,
                        ) ??
                        _defaultButton(
                          context,
                          isLeft: false,
                          isEnabled: rightEnabled,
                          onTap: rightOnTap,
                        ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A reusable, spreadsheet-like 2D table composed of:
/// - a fixed top header row
/// - an optional fixed left row-header column
/// - vertically virtualized body rows ([ListView.builder])
/// - synchronized horizontal scrolling for all rows and headers
///
/// This first engine intentionally mirrors the proven sync-scroll architecture
/// used in heavy custom schedulers, while exposing reusable builders.
class SSpreadsheet extends StatefulWidget {
  /// Number of body rows.
  final int rowCount;

  /// Number of body columns (horizontally scrollable columns).
  final int columnCount;

  /// Builds each body cell.
  final SSpreadsheetCellBuilder cellBuilder;

  /// Optional builder for the left fixed row-header cells.
  final SSpreadsheetRowHeaderBuilder? rowHeaderBuilder;

  /// Optional builder for the top fixed column-header cells.
  final SSpreadsheetColumnHeaderBuilder? columnHeaderBuilder;

  /// Optional builder for the top-left corner (intersection of row/column headers).
  final WidgetBuilder? cornerBuilder;

  /// Width of the fixed left row-header column.
  final double rowHeaderWidth;

  /// Height of the top header row.
  final double headerHeight;

  /// Height resolver for each body row.
  final SSpreadsheetRowHeightBuilder? rowHeightBuilder;

  /// Width resolver for each body column.
  final SSpreadsheetColumnWidthBuilder? columnWidthBuilder;

  /// Padding applied around the whole spreadsheet.
  final EdgeInsetsGeometry padding;

  /// Padding applied inside each body row container.
  final EdgeInsetsGeometry rowPadding;

  /// Vertical list physics.
  final ScrollPhysics? verticalPhysics;

  /// Horizontal row/header physics.
  final ScrollPhysics? horizontalPhysics;

  /// Optional background color behind the sheet.
  final Color? backgroundColor;

  /// Whether to draw the top header row.
  final bool showColumnHeader;

  /// Optional callback exposing synchronized horizontal scroll metrics.
  final SSpreadsheetHorizontalMetricsChanged? onHorizontalMetricsChanged;

  /// Optional external horizontal sync controller that tracks shared
  /// horizontal metrics and allows external scroll controls.
  final SSpreadsheetHorizontalSyncController? horizontalSyncController;

  /// Whether to wrap each built body row in a [RepaintBoundary].
  final bool repaintBoundaryPerRow;

  /// Optional animation duration for row height changes.
  final Duration rowExtentAnimationDuration;

  /// Whether to keep body rows alive.
  final bool addAutomaticKeepAlives;

  /// Optional [IndexedScrollController] for vertical (row) index-based scrolling.
  ///
  /// When provided, the body list uses [IndexScrollListViewBuilder] enabling
  /// programmatic scrolling to a specific row via
  /// [IndexedScrollController.scrollToIndex]. The raw [ScrollController] is
  /// accessible via [IndexedScrollController.controller].
  ///
  /// When omitted, an internal [IndexedScrollController] is created
  /// automatically wrapping a new [ScrollController].
  final IndexedScrollController? verticalIndexedController;

  const SSpreadsheet({
    super.key,
    required this.rowCount,
    required this.columnCount,
    required this.cellBuilder,
    this.rowHeaderBuilder,
    this.columnHeaderBuilder,
    this.cornerBuilder,
    this.rowHeaderWidth = 100,
    this.headerHeight = 48,
    this.rowHeightBuilder,
    this.columnWidthBuilder,
    this.padding = EdgeInsets.zero,
    this.rowPadding = EdgeInsets.zero,
    this.verticalIndexedController,
    this.verticalPhysics,
    this.horizontalPhysics,
    this.backgroundColor,
    this.showColumnHeader = true,
    this.onHorizontalMetricsChanged,
    this.horizontalSyncController,
    this.repaintBoundaryPerRow = false,
    this.rowExtentAnimationDuration = Duration.zero,
    this.addAutomaticKeepAlives = false,
  })  : assert(rowCount >= 0, 'rowCount must be >= 0'),
        assert(columnCount >= 0, 'columnCount must be >= 0'),
        assert(rowHeaderWidth >= 0, 'rowHeaderWidth must be >= 0'),
        assert(headerHeight >= 0, 'headerHeight must be >= 0');

  @override
  State<SSpreadsheet> createState() => _SSpreadsheetState();
}

class _SSpreadsheetState extends State<SSpreadsheet> {
  late final SyncScrollControllerGroup _horizontalSyncGroup;
  IndexedScrollController? _ownedVerticalIndexedController;

  IndexedScrollController get _verticalIndexedController {
    if (widget.verticalIndexedController != null) {
      return widget.verticalIndexedController!;
    }
    _ownedVerticalIndexedController ??= IndexedScrollController();
    return _ownedVerticalIndexedController!;
  }

  @override
  void initState() {
    super.initState();
    _horizontalSyncGroup = SyncScrollControllerGroup();
  }

  @override
  void dispose() {
    _ownedVerticalIndexedController?.dispose();
    _horizontalSyncGroup.dispose();
    super.dispose();
  }

  double _rowHeightAt(int rowIndex) => widget.rowHeightBuilder?.call(rowIndex) ?? 92;

  double _columnWidthAt(int columnIndex) => widget.columnWidthBuilder?.call(columnIndex) ?? 180;

  void _notifyHorizontalMetrics(
    double offset,
    double maxScrollExtent,
    ScrollController controller,
  ) {
    widget.horizontalSyncController?.update(offset, maxScrollExtent, controller);
    widget.onHorizontalMetricsChanged?.call(offset, maxScrollExtent, controller);
  }

  Widget _buildHeaderRow() {
    return SizedBox(
      height: widget.headerHeight,
      child: Row(
        children: [
          if (widget.rowHeaderBuilder != null)
            SizedBox(
              width: widget.rowHeaderWidth,
              child: widget.cornerBuilder?.call(context) ?? const SizedBox.shrink(),
            ),
          Expanded(
            child: _SyncedHorizontalStrip(
              syncGroup: _horizontalSyncGroup,
              itemCount: widget.columnCount,
              itemWidthBuilder: _columnWidthAt,
              physics: widget.horizontalPhysics,
              onMetricsChanged: _notifyHorizontalMetrics,
              itemBuilder: (context, columnIndex) {
                final builder = widget.columnHeaderBuilder;
                if (builder == null) return const SizedBox.shrink();
                return SizedBox(
                  width: _columnWidthAt(columnIndex),
                  height: widget.headerHeight,
                  child: builder(context, columnIndex),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyRow(BuildContext context, int rowIndex) {
    final row = SizedBox(
      height: _rowHeightAt(rowIndex),
      child: Padding(
        padding: widget.rowPadding,
        child: Row(
          children: [
            if (widget.rowHeaderBuilder != null)
              SizedBox(width: widget.rowHeaderWidth, child: widget.rowHeaderBuilder!(context, rowIndex)),
            Expanded(
              child: _SyncedHorizontalStrip(
                syncGroup: _horizontalSyncGroup,
                itemCount: widget.columnCount,
                itemWidthBuilder: _columnWidthAt,
                physics: widget.horizontalPhysics,
                onMetricsChanged: _notifyHorizontalMetrics,
                itemBuilder: (context, columnIndex) => SizedBox(
                  width: _columnWidthAt(columnIndex),
                  height: _rowHeightAt(rowIndex),
                  child: widget.cellBuilder(context, rowIndex, columnIndex),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final maybeAnimated = widget.rowExtentAnimationDuration > Duration.zero
        ? AnimatedContainer(
            duration: widget.rowExtentAnimationDuration,
            curve: Curves.easeOutCubic,
            height: _rowHeightAt(rowIndex),
            child: row,
          )
        : row;

    if (!widget.repaintBoundaryPerRow) return maybeAnimated;
    return RepaintBoundary(child: maybeAnimated);
  }

  @override
  Widget build(BuildContext context) {
    final body = widget.rowCount == 0
        ? const SizedBox.shrink()
        : IndexScrollListViewBuilder(
            controller: _verticalIndexedController,
            itemCount: widget.rowCount,
            physics: widget.verticalPhysics,
            padding: EdgeInsets.zero,
            itemBuilder: _buildBodyRow,
            onScrolledTo: (_) {},
          );

    return Container(
      color: widget.backgroundColor,
      padding: widget.padding,
      child: Column(
        children: [
          if (widget.showColumnHeader) _buildHeaderRow(),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _SyncedHorizontalStrip extends StatefulWidget {
  final SyncScrollControllerGroup syncGroup;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double Function(int index) itemWidthBuilder;
  final ScrollPhysics? physics;
  final SSpreadsheetHorizontalMetricsChanged? onMetricsChanged;

  const _SyncedHorizontalStrip({
    required this.syncGroup,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemWidthBuilder,
    this.physics,
    this.onMetricsChanged,
  });

  @override
  State<_SyncedHorizontalStrip> createState() => _SyncedHorizontalStripState();
}

class _SyncedHorizontalStripState extends State<_SyncedHorizontalStrip> {
  late final ScrollController _controller;
  late final IndexedScrollController _indexedController;

  @override
  void initState() {
    super.initState();
    _controller = widget.syncGroup.addAndGet();
    _controller.addListener(_onScroll);
    _indexedController = IndexedScrollController(
      scrollController: _controller,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      widget.onMetricsChanged?.call(_controller.position.pixels, _controller.position.maxScrollExtent, _controller);
    });
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    widget.onMetricsChanged?.call(_controller.position.pixels, _controller.position.maxScrollExtent, _controller);
  }

  @override
  void dispose() {
    _indexedController.dispose();
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IndexScrollListViewBuilder(
      controller: _indexedController,
      itemCount: widget.itemCount,
      scrollDirection: Axis.horizontal,
      physics: widget.physics,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return SizedBox(width: widget.itemWidthBuilder(index), child: widget.itemBuilder(context, index));
      },
      onScrolledTo: (_) {},
    );
  }
}
