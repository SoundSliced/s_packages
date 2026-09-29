import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/gestures.dart'
    show PointerScrollEvent, PointerSignalEvent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:s_packages/indexscroll_listview_builder/indexscroll_listview_builder.dart';
import 'package:s_packages/keystroke_listener/keystroke_listener.dart';
import 'package:s_packages/s_ink_button/s_ink_button.dart';
import 'package:s_packages/s_modoverlay/s_modal/s_modal.dart';

import 'package:s_packages/s_sync_scroll_controller/s_sync_scroll_controller.dart';

/// Builds a fixed row-header cell for [rowIndex].
typedef SSpreadsheetRowHeaderBuilder = Widget Function(
    BuildContext context, int rowIndex);

/// Builds a fixed column-header cell for [columnIndex].
typedef SSpreadsheetColumnHeaderBuilder = Widget Function(
    BuildContext context, int columnIndex);

/// Builds a body cell for [rowIndex] and [columnIndex].
typedef SSpreadsheetCellBuilder = Widget Function(
    BuildContext context, int rowIndex, int columnIndex);

/// Resolves a row height for [rowIndex].
typedef SSpreadsheetRowHeightBuilder = double Function(int rowIndex);

/// Resolves a column width for [columnIndex].
typedef SSpreadsheetColumnWidthBuilder = double Function(int columnIndex);

/// Reports synchronized horizontal scroll metrics.
typedef SSpreadsheetHorizontalMetricsChanged = void Function(
    double offset, double maxScrollExtent, ScrollController controller);

/// Immutable snapshot of horizontal scroll state for a spreadsheet.
class SSpreadsheetHorizontalMetrics {
  final double offset;
  final double maxScrollExtent;
  final ScrollController? controller;

  const SSpreadsheetHorizontalMetrics(
      {this.offset = 0, this.maxScrollExtent = 0, this.controller});

  bool canScrollLeft({double threshold = 100}) => offset > threshold;

  bool canScrollRight({double threshold = 100}) {
    final remaining = maxScrollExtent - offset;
    return remaining > 0 && remaining >= threshold;
  }
}

/// Shared horizontal synchronization state for [SSpreadsheet].
///
/// Pass one instance to [SSpreadsheet.horizontalSyncController] and to
/// [SSpreadsheetHorizontalScrollButtons] to control scrolling externally.
///
/// Every horizontal strip inside a spreadsheet — the column header and each
/// mounted (virtualised) body row — owns its own [ScrollController] handed out
/// by the shared sync group, and every one of them reports here. Reports are
/// therefore funnelled through a single elected *owner*, so a body row that
/// scrolls out of view cannot leave a disposed controller behind in [value].
/// The column header is preferred because it is never virtualised; a
/// spreadsheet built with `showColumnHeader: false` falls back to the first
/// live body strip.
///
/// [value] is only replaced when the published tuple actually changes
/// (controller identity included), so a settled layout does not emit an
/// endless notification loop.
class SSpreadsheetHorizontalSyncController
    extends ValueNotifier<SSpreadsheetHorizontalMetrics> {
  SSpreadsheetHorizontalSyncController([SSpreadsheetHorizontalMetrics? initial])
      : super(initial ?? const SSpreadsheetHorizontalMetrics());

  /// Registered strips in registration order, mapped to whether the strip is
  /// the non-virtualised column header (`true`) or a recyclable body row
  /// (`false`). Entries are added when a strip mounts and removed when it is
  /// about to dispose its controller, so lifetime never depends on guessing
  /// whether a controller is still usable.
  final Map<ScrollController, bool> _strips = <ScrollController, bool>{};

  ScrollController? _owner;
  bool _publishScheduled = false;
  bool _disposed = false;

  /// Whether [controller] can currently be read for metrics. Each strip gets
  /// its own controller from the sync group, so exactly one attached position
  /// is the healthy case; an unattached, recycled or disposed strip fails this.
  static bool _isLive(ScrollController? controller) {
    if (controller == null) return false;
    try {
      return controller.hasClients && controller.positions.length == 1;
    } catch (_) {
      // A disposed controller throws rather than answering.
      return false;
    }
  }

  /// Called by [SSpreadsheet] when a strip mounts. [isPrimary] marks the
  /// column-header strip, which outlives every body row.
  void registerStrip(ScrollController controller, {required bool isPrimary}) {
    if (_disposed) return;
    _strips[controller] = isPrimary;
    _electOwner();
    // Deferred: this runs from the strip's initState, i.e. during a build.
    // Notifying listeners synchronously there would mark them dirty mid-build.
    _schedulePublish();
  }

  /// Called by [SSpreadsheet] when a strip is about to dispose its controller,
  /// so ownership moves on while the remaining strips are still usable.
  void unregisterStrip(ScrollController controller) {
    if (_disposed) return;
    _strips.remove(controller);
    if (identical(_owner, controller)) _owner = null;
    _electOwner();
    // Deferred for the same reason as [registerStrip]: dispose runs during a
    // build/teardown pass, and the published controller is already cleared
    // above so nothing reads the dying strip in the meantime.
    _schedulePublish();
  }

  /// Reports a strip's live metrics.
  ///
  /// Kept at its original signature so existing callers and subclasses keep
  /// working; which strip is authoritative is supplied out of band by
  /// [registerStrip] instead of being inferred from whoever reported last.
  void update(
      double offset, double maxScrollExtent, ScrollController controller) {
    if (_disposed) return;
    _strips.putIfAbsent(controller, () => false);
    _electOwner();
    _publishFromOwner();
  }

  /// Re-reads the owning strip and republishes.
  ///
  /// This is what makes a *resize* update dependent UI: the extent changed but
  /// no scroll happened, so a scroll listener alone would never fire.
  void refresh() {
    if (_disposed) return;
    _electOwner();
    _publishFromOwner();
  }

  /// At most one deferred publication per frame, for callers that run inside a
  /// build phase. Coalesces with any other register/unregister in the frame.
  void _schedulePublish() {
    if (_publishScheduled) return;
    _publishScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _publishScheduled = false;
      if (_disposed) return;
      _electOwner();
      _publishFromOwner();
    });
  }

  /// Prefers the live header strip, falls back to a live body strip, and only
  /// replaces a live body owner when a header becomes available or the owner
  /// dies — so ownership does not churn between interchangeable body rows.
  void _electOwner() {
    final ownerIsLive = _isLive(_owner);
    if (ownerIsLive && (_strips[_owner] ?? false)) return;

    ScrollController? primary;
    ScrollController? fallback;
    for (final entry in _strips.entries) {
      if (!_isLive(entry.key)) continue;
      if (entry.value) {
        primary ??= entry.key;
      } else {
        fallback ??= entry.key;
      }
    }

    if (primary != null) {
      _owner = primary;
      return;
    }
    if (ownerIsLive) return;
    _owner = fallback;
  }

  void _publishFromOwner() {
    final owner = _isLive(_owner) ? _owner : null;
    if (owner == null) _owner = null;

    final position = owner?.position;
    final usable = position != null && position.hasContentDimensions;

    final next = SSpreadsheetHorizontalMetrics(
      controller: usable ? owner : null,
      offset: usable ? position.pixels : 0,
      maxScrollExtent: usable ? position.maxScrollExtent : 0,
    );

    // Controller identity is part of the comparison so a replacement strip
    // reporting the same numbers still propagates, while an unchanged tuple
    // from a settled layout is dropped.
    if (identical(value.controller, next.controller) &&
        value.offset == next.offset &&
        value.maxScrollExtent == next.maxScrollExtent) {
      return;
    }
    value = next;
  }

  Future<void> _animate(bool toEnd, Duration duration, Curve curve) async {
    final controller = value.controller;
    if (!_isLive(controller)) return;
    final position = controller!.position;
    if (!position.hasContentDimensions) return;
    try {
      // Read the extent from the position rather than the published snapshot
      // so a scroll issued right after a resize still lands on the real end.
      await controller.animateTo(
        toEnd ? position.maxScrollExtent : position.minScrollExtent,
        duration: duration,
        curve: curve,
      );
    } catch (_) {
      // The strip can be torn down mid-animation; nothing to recover.
    }
  }

  Future<void> animateToStart({
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeOutCubic,
  }) =>
      _animate(false, duration, curve);

  Future<void> animateToEnd({
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeOutCubic,
  }) =>
      _animate(true, duration, curve);

  @override
  void dispose() {
    _disposed = true;
    _strips.clear();
    _owner = null;
    super.dispose();
  }
}

/// Builder used by [SSpreadsheetHorizontalScrollButtons] to render each arrow button.
typedef SSpreadsheetScrollButtonBuilder = Widget Function(BuildContext context,
    {required bool isLeft,
    required bool isEnabled,
    required VoidCallback onTap});

/// Builds a custom HUD overlay widget.
///
/// Receives a human-readable [shortcutLabel] (e.g. "⌘D" or "Ctrl+D")
/// and [actionLabel] (e.g. "New Dept Booking") for the triggered keystroke.
typedef SSpreadsheetKeystrokeHudBuilder = Widget Function(
    BuildContext context, String shortcutLabel, String actionLabel);

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
              border: Border.all(
                  color: Colors.blue.shade700.withValues(alpha: 0.5),
                  width: 0.5),
            ),
            alignment: Alignment.center,
            child: Icon(isLeft ? Icons.chevron_left : Icons.chevron_right,
                color: Colors.blue.shade900, size: 18),
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
                final leftEnabled =
                    metrics.canScrollLeft(threshold: activationThreshold);
                final rightEnabled =
                    metrics.canScrollRight(threshold: activationThreshold);

                void leftOnTap() {
                  controller.animateToStart(
                      duration: animationDuration, curve: animationCurve);
                }

                void rightOnTap() {
                  controller.animateToEnd(
                      duration: animationDuration, curve: animationCurve);
                }

                return Row(
                  mainAxisAlignment: mainAxisAlignment,
                  crossAxisAlignment: crossAxisAlignment,
                  children: [
                    buttonBuilder?.call(context,
                            isLeft: true,
                            isEnabled: leftEnabled,
                            onTap: leftOnTap) ??
                        _defaultButton(context,
                            isLeft: true,
                            isEnabled: leftEnabled,
                            onTap: leftOnTap),
                    buttonBuilder?.call(context,
                            isLeft: false,
                            isEnabled: rightEnabled,
                            onTap: rightOnTap) ??
                        _defaultButton(context,
                            isLeft: false,
                            isEnabled: rightEnabled,
                            onTap: rightOnTap),
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

/// Which part of a zoom control a built part represents.
enum SSpreadsheetZoomAction {
  /// Step the factor down by [SSpreadsheetZoomController.step].
  zoomOut,

  /// The current factor — tapping it returns to 100%.
  reset,

  /// Step the factor up by [SSpreadsheetZoomController.step].
  zoomIn,
}

/// Builds one part of an [SSpreadsheetZoomControls].
///
/// [label] is the factor rendered as a percentage (e.g. `125%`), ready for the
/// `reset` part to show; the other actions ignore it. [onTap] is only ever
/// wired when [isEnabled]; a builder may render the disabled state however it
/// likes.
typedef SSpreadsheetZoomControlBuilder = Widget Function(
  BuildContext context, {
  required SSpreadsheetZoomAction action,
  required bool isEnabled,
  required String label,
  required VoidCallback onTap,
});

/// Ready-to-use zoom control bound to an [SSpreadsheetZoomController].
///
/// Three parts, in order: step down, the current factor as a percentage, step
/// up. Tapping the percentage returns to 100% — it stays tappable there so the
/// readout does not look broken, and resetting when already at 100% is a
/// no-op. The two buttons are disabled at the end of the range they would
/// cross, so the control can be dropped into a toolbar with no extra state.
///
/// Pass [builder] to render the parts in the host app's own visual language;
/// the default rendering mirrors the default of
/// [SSpreadsheetHorizontalScrollButtons].
class SSpreadsheetZoomControls extends StatelessWidget {
  /// The zoom state this control drives. Held, not owned: nothing here
  /// disposes it.
  final SSpreadsheetZoomController controller;

  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  /// Gap between the three parts.
  final double spacing;

  /// Optional replacement for the default part rendering.
  final SSpreadsheetZoomControlBuilder? builder;

  const SSpreadsheetZoomControls({
    super.key,
    required this.controller,
    this.padding = EdgeInsets.zero,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.spacing = 4,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ValueListenableBuilder<double>(
        valueListenable: controller,
        builder: (context, zoom, _) {
          // Rounded, because equal steps accumulate floating-point error and a
          // readout of "99.99999999999999%" is not what anybody set.
          final label = '${(zoom * 100).round()}%';

          Widget part(SSpreadsheetZoomAction action) {
            final isEnabled = switch (action) {
              SSpreadsheetZoomAction.zoomOut => controller.canZoomOut,
              SSpreadsheetZoomAction.zoomIn => controller.canZoomIn,
              SSpreadsheetZoomAction.reset => true,
            };
            final onTap = switch (action) {
              SSpreadsheetZoomAction.zoomOut => controller.zoomOut,
              SSpreadsheetZoomAction.zoomIn => controller.zoomIn,
              SSpreadsheetZoomAction.reset => controller.reset,
            };

            return builder?.call(context,
                    action: action,
                    isEnabled: isEnabled,
                    label: label,
                    onTap: onTap) ??
                _defaultPart(context,
                    action: action,
                    isEnabled: isEnabled,
                    onTap: onTap,
                    label: label);
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: [
              part(SSpreadsheetZoomAction.zoomOut),
              SizedBox(width: spacing),
              part(SSpreadsheetZoomAction.reset),
              SizedBox(width: spacing),
              part(SSpreadsheetZoomAction.zoomIn),
            ],
          );
        },
      ),
    );
  }

  Widget _defaultPart(
    BuildContext context, {
    required SSpreadsheetZoomAction action,
    required bool isEnabled,
    required VoidCallback onTap,
    required String label,
  }) {
    final Widget content = switch (action) {
      SSpreadsheetZoomAction.zoomIn =>
        Icon(Icons.add, size: 14, color: Colors.blue.shade900),
      SSpreadsheetZoomAction.zoomOut =>
        Icon(Icons.remove, size: 14, color: Colors.blue.shade900),
      SSpreadsheetZoomAction.reset => Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade900,
          ),
        ),
    };

    return Opacity(
      opacity: isEnabled ? 1 : 0.45,
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Container(
            height: 20,
            constraints: const BoxConstraints(minWidth: 30),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade500.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: Colors.blue.shade700.withValues(alpha: 0.5),
                  width: 0.5),
            ),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Result of a spreadsheet hit-test: maps a viewport-local position to a
/// grid cell and provides visibility context for edge-triggered auto-scroll.
///
/// Returned by [SSpreadsheetState.hitTest].
class SSpreadsheetHitResult {
  /// The data row index at the hit position, or `null` if the position is
  /// in the header, column-header, or beyond the last row.
  final int? rowIndex;

  /// Normalised progress within the hit row: `0.0` = top edge, `1.0` = bottom edge.
  ///
  /// Useful for proximity-based scroll speed curves when [isFirstVisibleRow]
  /// or [isLastVisibleRow] is true.
  final double rowProgress;

  /// The body column index at the hit position, or `null` if the position is
  /// in the row-header or beyond the last column.
  final int? columnIndex;

  /// Normalised progress within the hit column: `0.0` = left edge, `1.0` = right edge.
  final double columnProgress;

  /// Whether this position maps to an actual data cell (both [rowIndex] and
  /// [columnIndex] are non-null).
  final bool isInDataArea;

  /// Total number of data rows in the spreadsheet.
  final int totalRows;

  /// Total number of body columns in the spreadsheet.
  final int totalColumns;

  // ---- Visibility context for auto-scroll ----

  /// Whether the hit row is the first data row visible in the viewport.
  final bool isFirstVisibleRow;

  /// Whether the hit row is the last data row visible in the viewport.
  final bool isLastVisibleRow;

  /// Whether the user can scroll upward (scrollOffset > minScrollExtent).
  final bool canScrollUp;

  /// Whether there are more rows below the visible area.
  final bool canScrollDown;

  /// Whether the hit column is the first body column visible in the viewport.
  final bool isFirstVisibleColumn;

  /// Whether the hit column is the last body column visible in the viewport.
  final bool isLastVisibleColumn;

  /// Whether the user can scroll left (hOffset > minScrollExtent).
  final bool canScrollLeft;

  /// Whether there are more columns to the right of the visible area.
  final bool canScrollRight;

  const SSpreadsheetHitResult({
    this.rowIndex,
    this.rowProgress = 0.0,
    this.columnIndex,
    this.columnProgress = 0.0,
    this.isInDataArea = false,
    this.totalRows = 0,
    this.totalColumns = 0,
    this.isFirstVisibleRow = false,
    this.isLastVisibleRow = false,
    this.canScrollUp = false,
    this.canScrollDown = false,
    this.isFirstVisibleColumn = false,
    this.isLastVisibleColumn = false,
    this.canScrollLeft = false,
    this.canScrollRight = false,
  });
}

/// Manages row/column selection + dimming state for [SSpreadsheet].
///
/// Selection is tracked by an opaque **identity key** — resolved per row via
/// [SSpreadsheet.rowKeyBuilder] and per column via
/// [SSpreadsheet.columnKeyBuilder] (both default to the raw index when
/// omitted) — rather than by raw index. This means a selection survives row
/// filtering/reordering that shifts indices: as long as the same key still
/// exists somewhere in the grid, it stays highlighted at its new position.
///
/// Pass an instance to [SSpreadsheet.selectionController] to enable
/// selection. When [SSpreadsheet.dimUnselectedOpacity] is less than `1.0`,
/// the spreadsheet automatically dims every header/cell that doesn't belong
/// to the selected row/column. When
/// [SSpreadsheet.enableTapToSelectRowHeader] /
/// [SSpreadsheet.enableTapToSelectColumnHeader] are `true`, tapping a header
/// toggles that row's/column's selection, and tapping anywhere else in the
/// grid outside the selected row/column (another header, another cell)
/// automatically clears the selection.
class SSpreadsheetSelectionController extends ChangeNotifier {
  SSpreadsheetSelectionController({this.exclusive = true});

  /// When `true` (default), selecting a row clears any active column
  /// selection and vice versa, so at most one axis is ever selected at once.
  /// Set to `false` to allow a row and a column to be selected
  /// simultaneously (e.g. to highlight their intersection cell yourself).
  final bool exclusive;

  Object? _selectedRowKey;
  Object? _selectedColumnKey;

  /// The identity key of the currently selected row, or `null`.
  Object? get selectedRowKey => _selectedRowKey;

  /// The identity key of the currently selected column, or `null`.
  Object? get selectedColumnKey => _selectedColumnKey;

  /// Whether either axis currently has a selection.
  bool get hasSelection =>
      _selectedRowKey != null || _selectedColumnKey != null;

  /// Selects the row identified by [key]. Selecting the already-selected row
  /// toggles it off (matching how the built-in header tap handling behaves).
  /// Pass `null` to explicitly clear the row selection.
  void selectRow(Object? key) {
    if (key == null) {
      clearRow();
      return;
    }
    if (_selectedRowKey == key) {
      clearRow();
      return;
    }
    _selectedRowKey = key;
    if (exclusive) _selectedColumnKey = null;
    notifyListeners();
  }

  /// Selects the column identified by [key]. Mirrors [selectRow].
  void selectColumn(Object? key) {
    if (key == null) {
      clearColumn();
      return;
    }
    if (_selectedColumnKey == key) {
      clearColumn();
      return;
    }
    _selectedColumnKey = key;
    if (exclusive) _selectedRowKey = null;
    notifyListeners();
  }

  /// Clears the row selection only.
  void clearRow() {
    if (_selectedRowKey == null) return;
    _selectedRowKey = null;
    notifyListeners();
  }

  /// Clears the column selection only.
  void clearColumn() {
    if (_selectedColumnKey == null) return;
    _selectedColumnKey = null;
    notifyListeners();
  }

  /// Clears both the row and column selection.
  void clear() {
    if (_selectedRowKey == null && _selectedColumnKey == null) return;
    _selectedRowKey = null;
    _selectedColumnKey = null;
    notifyListeners();
  }
}

/// Shared zoom state for [SSpreadsheet].
///
/// Holds the zoom factor together with the policy around it — the range it is
/// clamped to and the increments a button press or a wheel notch applies — so a
/// toolbar control, the keyboard shortcuts and the widget's own wheel handling
/// can never disagree about what "zoom in" means.
///
/// The increments are **absolute** additions to the factor, not multipliers:
/// within a 50%–200% range that makes every press the same size, so pressing
/// "zoom in" from 50% and from 200% moves the sheet by the same amount.
///
/// Pass one instance to [SSpreadsheet.zoomController] to drive zoom from
/// outside — a toolbar control, a settings row, an app-level bridge.
/// Ownership follows [SSpreadsheetHorizontalSyncController]: a caller-supplied
/// controller is only ever listened to, with the listener attached when the
/// spreadsheet mounts and detached when it unmounts, and is *never* disposed by
/// the spreadsheet; a controller the spreadsheet had to create for itself is
/// disposed with it. [SSpreadsheetSelectionController] is borrowed the same
/// way.
///
/// The zoom is deliberately not persisted: it lives and dies with this
/// controller, so a fresh app start is back at [defaultZoom] (100%).
class SSpreadsheetZoomController extends ValueNotifier<double> {
  /// The factor the sheet is shown at with no zoom applied, i.e. 100%.
  ///
  /// Everything that means "zoom out goes here": [reset] returns to it, and it
  /// is the value a spreadsheet uses when no controller is supplied.
  static const double defaultZoom = 1.0;

  /// The range and increments a default-configured controller uses.
  ///
  /// Exposed so [SSpreadsheet.minZoom] / [SSpreadsheet.maxZoom] can default to
  /// the same numbers rather than restating them.
  static const double defaultMinZoom = 0.5;

  /// Largest factor a default-configured controller clamps to — 200%.
  static const double defaultMaxZoom = 2.0;

  /// Increment a default-configured controller applies per button press.
  static const double defaultStep = 0.10;

  /// Increment a default-configured controller applies per wheel notch.
  static const double defaultWheelStep = 0.05;

  /// Smallest factor [setZoom] clamps to — 50%.
  final double minZoom;

  /// Largest factor [setZoom] clamps to — 200%.
  final double maxZoom;

  /// Increment applied by [zoomIn] / [zoomOut]: one button press or one
  /// keystroke, i.e. 10% of 100%.
  final double step;

  /// Increment applied by one wheel notch (or one trackpad pinch tick).
  ///
  /// Half of [step]: a wheel emits a stream of events where a button emits one
  /// discrete press, so the same increment per event would feel twice as fast.
  final double wheelStep;

  SSpreadsheetZoomController({
    double zoom = defaultZoom,
    this.minZoom = defaultMinZoom,
    this.maxZoom = defaultMaxZoom,
    this.step = defaultStep,
    this.wheelStep = defaultWheelStep,
  })  : assert(minZoom > 0, 'minZoom must be > 0'),
        assert(maxZoom >= minZoom, 'maxZoom must be >= minZoom'),
        assert(step > 0, 'step must be > 0'),
        assert(wheelStep > 0, 'wheelStep must be > 0'),
        super(zoom.clamp(minZoom, maxZoom).toDouble());

  /// The current factor, where `1.0` is 100%.
  double get zoom => value;

  /// Whether [zoomIn] would change anything — `false` at [maxZoom].
  bool get canZoomIn => value < maxZoom;

  /// Whether [zoomOut] would change anything — `false` at [minZoom].
  bool get canZoomOut => value > minZoom;

  /// Sets the factor to [next], clamped to [minZoom]..[maxZoom].
  ///
  /// Returns whether the factor actually changed. A request that clamps back
  /// onto the current value is a no-op and notifies no listeners, so callers
  /// can drive this straight from a scroll wheel or a stream of button taps
  /// without guarding against the ends of the range.
  ///
  /// [anchor] is the point — in the *viewport's* coordinates, i.e. the box the
  /// sheet is painted into — that should stay put while the factor changes. It
  /// is held for whoever applies the change, which is the only layer that can
  /// see the scroll positions, and read back through [takeAnchor]. Passing
  /// `null` means "keep the origin still", which is what a toolbar button
  /// wants: the offsets the sheet tracks are content-space and do not change,
  /// so the top-left row and column simply stay where they are.
  bool setZoom(double next, {Offset? anchor}) {
    final clamped = next.clamp(minZoom, maxZoom).toDouble();
    if (clamped == value) return false;
    _pendingAnchor = anchor;
    value = clamped;
    return true;
  }

  /// One [step] larger, clamped. See [setZoom] for the return value.
  bool zoomIn({Offset? anchor}) => setZoom(value + step, anchor: anchor);

  /// One [step] smaller, clamped. See [setZoom] for the return value.
  bool zoomOut({Offset? anchor}) => setZoom(value - step, anchor: anchor);

  /// [notches] wheel notches worth of [wheelStep], positive to zoom in.
  ///
  /// See [setZoom] for the return value.
  bool zoomByWheelNotches(double notches, {Offset? anchor}) =>
      setZoom(value + wheelStep * notches, anchor: anchor);

  /// Back to [defaultZoom] (100%), clamped like any other [setZoom].
  bool reset({Offset? anchor}) => setZoom(defaultZoom, anchor: anchor);

  Offset? _pendingAnchor;

  /// The [anchor] of the most recent zoom that changed the factor, or `null`.
  ///
  /// Cleared as it is read, so an anchor from one gesture can never be applied
  /// a second time — to a later, unrelated change, or after the sheet has been
  /// scrolled since.
  Offset? takeAnchor() {
    final anchor = _pendingAnchor;
    _pendingAnchor = null;
    return anchor;
  }
}

/// Renders [child] inside a logical viewport of `incoming size / zoom` and
/// paints it at `zoom`.
///
/// This is the primitive [SSpreadsheet.zoom] is built from, exposed so that
/// any layer sharing the sheet's coordinate space — an overlay positioned from
/// the same row/column dimensions, a HUD pinned to the grid — can be scaled by
/// exactly the same amount and stay aligned with the sheet.
///
/// Scaling **down** enlarges the logical viewport rather than shrinking the
/// content into a corner, so zooming out reveals more rows and columns instead
/// of leaving empty space around a smaller copy of the sheet; scaling **up**
/// shrinks the logical viewport, so fewer of them fit — which is what zooming
/// in means for a scrollable grid.
///
/// Two cases pass [child] through unwrapped, so they cost nothing and cannot
/// regress an existing layout:
/// - `zoom == 1.0`, the default everywhere;
/// - unbounded incoming constraints, where there is no viewport to divide —
///   the child is then laid out as it would have been, rather than unbounded
///   or with a meaningless logical size.
class SSpreadsheetZoomViewport extends StatelessWidget {
  /// Scale factor applied to [child]. Must be greater than zero; `1.0` leaves
  /// the child untouched.
  final double zoom;

  /// Alignment for both the resized logical box and the [Transform.scale] that
  /// paints it. Top-left keeps the sheet's origin — its row-header corner —
  /// pinned, so the scroll offsets the sheet already tracks stay meaningful.
  final AlignmentGeometry alignment;

  /// The content to lay out at `size / zoom` and paint at `zoom`.
  final Widget child;

  const SSpreadsheetZoomViewport({
    super.key,
    required this.zoom,
    this.alignment = Alignment.topLeft,
    required this.child,
  }) : assert(zoom > 0, 'zoom must be > 0');

  @override
  Widget build(BuildContext context) {
    if (zoom == 1.0) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
          return child;
        }

        return ClipRect(
          child: OverflowBox(
            alignment: alignment,
            minWidth: 0,
            maxWidth: double.infinity,
            minHeight: 0,
            maxHeight: double.infinity,
            child: Transform.scale(
              scale: zoom,
              alignment: alignment,
              // An explicit box, not just "let the child fill": at zoom < 1 the
              // logical box is larger than the incoming constraints, and only a
              // tight size makes the OverflowBox hand the child that much room.
              child: SizedBox(
                width: constraints.maxWidth / zoom,
                height: constraints.maxHeight / zoom,
                child: child,
              ),
            ),
          ),
        );
      },
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

  /// Whether to animate rows when they are inserted or removed.
  ///
  /// When `true` (default), the internal [IndexScrollListViewBuilder] uses
  /// [AnimatedList] so rows fade+slide in/out as [rowCount] changes.
  /// Pass a [rowKeyBuilder] for correct identity tracking across filter changes.
  final bool enableRowAnimations;

  /// Optional key builder that gives each row a stable identity across rebuilds.
  ///
  /// When [enableRowAnimations] is true, providing a key that reflects
  /// the underlying data (e.g., a time slot timestamp) lets [AnimatedList]
  /// correctly map old rows to new rows even when their indices shift.
  ///
  /// If `null`, keys are index-based — animations work correctly only
  /// for items appended/removed at the end.
  final Key Function(int rowIndex)? rowKeyBuilder;

  /// Duration of the insert/remove row animation.
  /// Defaults to 400ms.
  final Duration rowAnimationDuration;

  // ======= Row/Column Selection Params =======

  /// Optional controller enabling row/column selection + dimming.
  /// See [SSpreadsheetSelectionController].
  final SSpreadsheetSelectionController? selectionController;

  /// Optional key builder that gives each column a stable identity for
  /// [selectionController]. Mirrors [rowKeyBuilder]. If `null`, the raw
  /// column index is used as the identity key.
  final Object Function(int columnIndex)? columnKeyBuilder;

  /// Opacity applied (via [AnimatedOpacity]) to every header/cell that does
  /// not belong to the selected row/column. Defaults to `1.0`, which
  /// disables dimming entirely even when [selectionController] is set.
  final double dimUnselectedOpacity;

  /// Duration of the dim/undim opacity animation. Defaults to 250ms.
  final Duration dimAnimationDuration;

  /// When `true`, tapping a row-header cell toggles that row's selection on
  /// [selectionController]. The tap target wraps whatever [rowHeaderBuilder]
  /// renders as its ancestor (translucent, so interactive elements inside
  /// the header — e.g. an icon button — still take priority for their own
  /// bounds). Requires [selectionController] to be set.
  final bool enableTapToSelectRowHeader;

  /// When `true`, tapping a column-header cell toggles that column's
  /// selection on [selectionController]. Mirrors
  /// [enableTapToSelectRowHeader]. Requires [selectionController] to be set.
  final bool enableTapToSelectColumnHeader;

  /// Splash/hover color for [enableTapToSelectRowHeader]'s tap target.
  /// Defaults to fully transparent (no visible feedback beyond the
  /// dimming/selection state itself) to preserve prior behavior. Pass `null`
  /// to fall back to `SInkButton`'s own default (currently `Colors.purple`)
  /// for a visible ripple, or any other color to match your header's theme.
  final Color? rowHeaderTapSplashColor;

  /// Splash/hover color for [enableTapToSelectColumnHeader]'s tap target.
  /// Mirrors [rowHeaderTapSplashColor].
  final Color? columnHeaderTapSplashColor;

  /// Called after a row header tap changes [selectionController]'s row
  /// selection (including when it toggles the selection off, in which case
  /// [key] is `null`). Only fires when [enableTapToSelectRowHeader] is true.
  final void Function(int rowIndex, Object? key)? onRowHeaderSelected;

  /// Called after a column header tap changes [selectionController]'s
  /// column selection. Mirrors [onRowHeaderSelected]. Only fires when
  /// [enableTapToSelectColumnHeader] is true.
  final void Function(int columnIndex, Object? key)? onColumnHeaderSelected;

  /// Called whenever a tap outside the selected row/column clears
  /// [selectionController]'s selection (either axis).
  final VoidCallback? onSelectionCleared;

  /// Optional callback fired when a body cell is tapped. Wraps the built
  /// cell in a translucent [GestureDetector] so it doesn't interfere with
  /// interactive widgets the cell itself renders (bookings, buttons, etc.).
  final void Function(int rowIndex, int columnIndex)? onCellTap;

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

  // ======= Keystroke / Keyboard Shortcut Params =======

  /// When true, wraps the spreadsheet content in a [KeystrokeListener] so
  /// that keyboard shortcuts are detected and dispatched to
  /// [keystrokeActionHandlers].  Defaults to `false` (backward compatible).
  final bool enableKeystrokes;

  /// When true and [enableKeystrokes] is true, every detected keystroke is
  /// printed via [debugPrint].  No action handlers fire in this mode.
  final bool keystrokeDebugLogs;

  /// Maps an [Intent] type to a callback that implements the action.
  ///
  /// Callbacks are only invoked when [shouldPauseKeystrokes] returns `false`.
  /// If a matching label exists in [keystrokeActionLabels] and
  /// [keystrokeHudBuilder] is provided, the HUD is shown automatically
  /// before the callback runs.
  final Map<Type, VoidCallback>? keystrokeActionHandlers;

  /// Maps an [Intent] type to a human-readable action label (e.g.
  /// "New Dept Booking").  Used together with the auto-derived shortcut
  /// label to populate the HUD overlay via [keystrokeHudBuilder].
  final Map<Type, String>? keystrokeActionLabels;

  /// Custom shortcut bindings scoped to this spreadsheet.  Merged after
  /// the built-in default shortcuts (unless [includeDefaultKeystrokeShortcuts]
  /// is `false`).  Use this with custom [Intent] subclasses to detect key
  /// combinations not covered by the defaults.
  final Map<ShortcutActivator, Intent>? keystrokeShortcuts;

  /// Whether the built-in navigation/editing shortcuts (ESC, Ctrl+S,
  /// Ctrl+Z, etc.) should be registered.  Defaults to `true`.
  final bool includeDefaultKeystrokeShortcuts;

  /// Raw [KeyDownEvent] callback for custom handling beyond the Intent
  /// system.  Fires for every key event that reaches the internal
  /// [KeystrokeListener].
  final void Function(KeyDownEvent)? onKeystrokeEvent;

  /// External [FocusNode] for the internal [KeystrokeListener].  When
  /// provided, callers can call [FocusNode.requestFocus] externally to
  /// re-acquire keystroke focus after overlays dismiss.
  final FocusNode? keystrokeFocusNode;

  /// When true, the internal [KeystrokeListener] requests autofocus on
  /// init, giving the hidden [TextField] the HTML `autofocus` attribute
  /// on Flutter Web.  Defaults to `true` when [enableKeystrokes] is true.
  final bool keystrokeRequestFocusOnInit;

  /// When provided and returns `true`, all keystroke intent handlers are
  /// suppressed and the auto-refocus is paused.  Use this when descendant
  /// text inputs need exclusive keyboard access (e.g. a search bar inside
  /// the spreadsheet).
  final bool Function()? shouldPauseKeystrokes;

  /// Custom HUD widget builder.  When provided, the HUD is shown
  /// automatically before each [keystrokeActionHandlers] callback runs
  /// (provided a label exists in [keystrokeActionLabels]).
  final SSpreadsheetKeystrokeHudBuilder? keystrokeHudBuilder;

  /// How long the HUD overlay remains visible before auto-dismissing.
  /// Defaults to 1 second.
  final Duration keystrokeHudDuration;

  // ======= Zoom Params =======

  /// The factor the sheet is painted at, where `1.0` is 100%.
  ///
  /// Zooming changes only how much of the sheet is *visible*: content keeps its
  /// natural dimensions, so a taller logical viewport at 50% reveals more rows
  /// rather than stretching them, and [rowHeightBuilder] /
  /// [columnWidthBuilder] are never asked for scaled sizes. A builder that
  /// wants to react to zoom can read [zoomController] instead.
  ///
  /// Ignored when [zoomController] is supplied.
  final double zoom;

  /// Optional external zoom state — e.g. one controller shared by a toolbar
  /// control, a menu item and the sheet itself.
  ///
  /// When supplied the sheet reads the factor from it and listens to it, and
  /// never disposes it; [zoom], [minZoom] and [maxZoom] are then ignored,
  /// because the controller carries its own range and increments. When omitted
  /// the sheet creates a controller from [zoom] / [minZoom] / [maxZoom] and
  /// owns it, disposing it with itself.
  final SSpreadsheetZoomController? zoomController;

  /// Smallest factor the sheet's own controller clamps to.
  ///
  /// Ignored when [zoomController] is supplied. Defaults to
  /// [SSpreadsheetZoomController.defaultMinZoom], i.e. 50%.
  final double minZoom;

  /// Largest factor the sheet's own controller clamps to.
  ///
  /// Ignored when [zoomController] is supplied. Defaults to
  /// [SSpreadsheetZoomController.defaultMaxZoom], i.e. 200%.
  final double maxZoom;

  /// Called with the new factor whenever the zoom changes, whoever changed it —
  /// the sheet's own wheel handling, a keystroke, or an external
  /// [zoomController].
  final ValueChanged<double>? onZoomChanged;

  /// Whether Ctrl/Cmd + wheel over the sheet zooms it.
  ///
  /// This is also what a trackpad pinch arrives as: the platform reports the
  /// pinch as a scroll stream carrying the primary modifier, so a single
  /// handler covers both. A wheel with no modifier keeps scrolling the sheet,
  /// untouched. Defaults to `false` so a sheet that never asked for zoom
  /// behaves exactly as it did before this existed — mirroring
  /// [enableKeystrokes].
  ///
  /// Enabling it also registers the zoom keyboard shortcuts (Ctrl/Cmd + '=',
  /// '+', '-' and '0'), which are delivered by the keystroke listener and so
  /// additionally need [enableKeystrokes]. Passing a [zoomController] enables
  /// them too, since the caller clearly intends the sheet to be zoomable.
  final bool enableZoomGestures;

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
    this.enableRowAnimations = true,
    this.rowKeyBuilder,
    this.rowAnimationDuration = const Duration(milliseconds: 400),
    // Selection params
    this.selectionController,
    this.columnKeyBuilder,
    this.dimUnselectedOpacity = 1.0,
    this.dimAnimationDuration = const Duration(milliseconds: 250),
    this.enableTapToSelectRowHeader = false,
    this.enableTapToSelectColumnHeader = false,
    this.rowHeaderTapSplashColor = Colors.transparent,
    this.columnHeaderTapSplashColor = Colors.transparent,
    this.onRowHeaderSelected,
    this.onColumnHeaderSelected,
    this.onSelectionCleared,
    this.onCellTap,
    // Keystroke params
    this.enableKeystrokes = false,
    this.keystrokeDebugLogs = false,
    this.keystrokeActionHandlers,
    this.keystrokeActionLabels,
    this.keystrokeShortcuts,
    this.includeDefaultKeystrokeShortcuts = true,
    this.onKeystrokeEvent,
    this.keystrokeFocusNode,
    this.keystrokeRequestFocusOnInit = true,
    this.shouldPauseKeystrokes,
    this.keystrokeHudBuilder,
    this.keystrokeHudDuration = const Duration(seconds: 1),
    // Zoom params
    this.zoom = SSpreadsheetZoomController.defaultZoom,
    this.zoomController,
    this.minZoom = SSpreadsheetZoomController.defaultMinZoom,
    this.maxZoom = SSpreadsheetZoomController.defaultMaxZoom,
    this.onZoomChanged,
    this.enableZoomGestures = false,
  })  : assert(rowCount >= 0, 'rowCount must be >= 0'),
        assert(columnCount >= 0, 'columnCount must be >= 0'),
        assert(rowHeaderWidth >= 0, 'rowHeaderWidth must be >= 0'),
        assert(headerHeight >= 0, 'headerHeight must be >= 0'),
        assert(zoom > 0, 'zoom must be > 0'),
        assert(minZoom > 0, 'minZoom must be > 0'),
        assert(maxZoom >= minZoom, 'maxZoom must be >= minZoom');

  /// Builds all columns and the requested rows at their natural dimensions.
  ///
  /// This eager, non-interactive layout is intended for bounded exports, not
  /// live scrolling. It reuses cell builders without mounting spreadsheet
  /// controllers, selection effects or animations. Builders must not reuse
  /// GlobalKeys attached to another tree. [rowIndices] preserves supplied order.
  ///
  /// Zoom is deliberately **not** applied: an export is the sheet at 100%, at
  /// [exportSize]'s natural dimensions, so a PDF or a screenshot never inherits
  /// the factor someone set on screen. Only the live widget scales.
  Widget buildExport(BuildContext context, {List<int>? rowIndices}) {
    final indices = rowIndices ?? List<int>.generate(rowCount, (i) => i);
    for (final index in indices) {
      if (index < 0 || index >= rowCount) {
        throw RangeError.range(index, 0, rowCount - 1, 'rowIndex');
      }
    }
    final outerPadding = padding.resolve(Directionality.of(context));
    final innerPadding = rowPadding.resolve(Directionality.of(context));
    final widths = List<double>.generate(
        columnCount, (i) => columnWidthBuilder?.call(i) ?? 180);
    final headerWidth = rowHeaderBuilder == null ? 0.0 : rowHeaderWidth;
    final width = headerWidth +
        widths.fold(0.0, (a, b) => a + b) +
        innerPadding.horizontal;
    Widget strip(int? row) => SizedBox(
          height:
              row == null ? headerHeight : rowHeightBuilder?.call(row) ?? 92,
          child: Padding(
            padding: row == null ? EdgeInsets.zero : innerPadding,
            child: Row(children: [
              if (rowHeaderBuilder != null)
                SizedBox(
                    width: rowHeaderWidth,
                    child: row == null
                        ? cornerBuilder?.call(context)
                        : rowHeaderBuilder!(context, row)),
              for (var col = 0; col < columnCount; col++)
                SizedBox(
                    width: widths[col],
                    height: double.infinity,
                    child: row == null
                        ? columnHeaderBuilder?.call(context, col)
                        : cellBuilder(context, row, col)),
            ]),
          ),
        );
    return IgnorePointer(
        child: Container(
      color: backgroundColor,
      padding: outerPadding,
      width: width + outerPadding.horizontal,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (showColumnHeader) strip(null),
        for (final row in indices) strip(row),
      ]),
    ));
  }

  /// Natural dimensions of [buildExport], before screenshot/PDF scaling.
  ///
  /// Like [buildExport], these are the 100% dimensions: zoom applies to the
  /// live sheet only.
  Size exportSize(BuildContext context, {List<int>? rowIndices}) {
    final indices = rowIndices ?? List<int>.generate(rowCount, (i) => i);
    final outer = padding.resolve(Directionality.of(context));
    final inner = rowPadding.resolve(Directionality.of(context));
    var width = rowHeaderBuilder == null ? 0.0 : rowHeaderWidth;
    for (var col = 0; col < columnCount; col++) {
      width += columnWidthBuilder?.call(col) ?? 180;
    }
    var height = showColumnHeader ? headerHeight : 0.0;
    for (final row in indices) {
      if (row < 0 || row >= rowCount) throw RangeError.index(row, indices);
      height += rowHeightBuilder?.call(row) ?? 92;
    }
    return Size(
        width + outer.horizontal + inner.horizontal, height + outer.vertical);
  }

  @override
  State<SSpreadsheet> createState() => SSpreadsheetState();
}

/// Public state class for [SSpreadsheet].
///
/// Use a [GlobalKey<SSpreadsheetState>] to access:
/// - [hitTest] — map viewport coordinates to grid cell with auto-scroll context.
class SSpreadsheetState extends State<SSpreadsheet> {
  late final SyncScrollControllerGroup _horizontalSyncGroup;
  IndexedScrollController? _ownedVerticalIndexedController;

  IndexedScrollController get _verticalIndexedController {
    if (widget.verticalIndexedController != null) {
      return widget.verticalIndexedController!;
    }
    _ownedVerticalIndexedController ??= IndexedScrollController();
    return _ownedVerticalIndexedController!;
  }

  // --- Zoom management ---

  /// The controller this sheet creates when the caller supplies none.
  SSpreadsheetZoomController? _ownedZoomController;

  /// The zoom state in force: the caller's controller when one was given,
  /// otherwise one owned by this sheet and built from [SSpreadsheet.zoom],
  /// [SSpreadsheet.minZoom] and [SSpreadsheet.maxZoom].
  SSpreadsheetZoomController get _zoomController {
    final provided = widget.zoomController;
    if (provided != null) return provided;

    var owned = _ownedZoomController;
    if (owned == null) {
      owned = SSpreadsheetZoomController(
        zoom: widget.zoom,
        minZoom: widget.minZoom,
        maxZoom: widget.maxZoom,
      );
      owned.addListener(_onZoomChanged);
      _ownedZoomController = owned;
    }
    return owned;
  }

  /// The factor the sheet is currently painted at, where `1.0` is 100%.
  double get zoom => _zoomController.zoom;

  /// One [SSpreadsheetZoomController.step] larger, clamped to the range.
  ///
  /// Returns whether the factor changed, so a caller can tell a press that hit
  /// the ceiling from one that actually moved the sheet.
  bool zoomIn({Offset? anchor}) => _zoomController.zoomIn(anchor: anchor);

  /// One [SSpreadsheetZoomController.step] smaller, clamped to the range.
  bool zoomOut({Offset? anchor}) => _zoomController.zoomOut(anchor: anchor);

  /// Back to 100% (`SSpreadsheetZoomController.defaultZoom`), clamped.
  bool resetZoom({Offset? anchor}) => _zoomController.reset(anchor: anchor);

  /// Keeps a caller-supplied controller's lifetime decoupled from this sheet,
  /// and rebuilds the owned one when the requested policy or factor changes —
  /// a controller's range and increments are immutable once constructed.
  void _configureZoomController(SSpreadsheet oldWidget) {
    final provided = widget.zoomController;
    final hadProvided = oldWidget.zoomController != null;

    if (provided != null) {
      if (oldWidget.zoomController != provided) {
        oldWidget.zoomController?.removeListener(_onZoomChanged);
        _disposeOwnedZoomController();
        provided.addListener(_onZoomChanged);
        _appliedZoom = provided.zoom;
      }
      return;
    }

    // Switched from a caller-supplied controller to none: the owned one is
    // made fresh below, so the old listener comes off with it.
    final needsFreshController = _ownedZoomController == null ||
        hadProvided ||
        oldWidget.minZoom != widget.minZoom ||
        oldWidget.maxZoom != widget.maxZoom ||
        oldWidget.zoom != widget.zoom;

    if (!needsFreshController) return;

    _disposeOwnedZoomController();
    _ownedZoomController = SSpreadsheetZoomController(
      zoom: widget.zoom,
      minZoom: widget.minZoom,
      maxZoom: widget.maxZoom,
    )..addListener(_onZoomChanged);
  }

  /// Drops a controller this sheet created. A caller-supplied controller is
  /// only ever unsubscribed from, never disposed.
  void _disposeOwnedZoomController() {
    _ownedZoomController?.removeListener(_onZoomChanged);
    _ownedZoomController?.dispose();
    _ownedZoomController = null;
  }

  /// The factor in force as of the last change we processed, so an anchored
  /// zoom can map the pointer's content position across the change. Kept here
  /// rather than read back from the controller, which has already moved on by
  /// the time the listener runs.
  double? _appliedZoom;

  /// Ctrl/Cmd + wheel — which is also how a trackpad pinch arrives — zooms the
  /// sheet, anchored under the pointer. A wheel with no modifier is left alone,
  /// so it keeps scrolling the sheet exactly as it always has.
  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!_isZoomModifierPressed) return;

    final notches = _wheelNotchesFor(event.scrollDelta.dy);
    if (notches == 0) return;

    _zoomController.zoomByWheelNotches(notches, anchor: event.localPosition);
  }

  /// Ctrl on Windows/Linux, Cmd on macOS — and a trackpad pinch, which the
  /// platform reports as a scroll stream carrying the primary modifier.
  bool get _isZoomModifierPressed {
    final keys = HardwareKeyboard.instance;
    return keys.isControlPressed || keys.isMetaPressed;
  }

  /// How many wheel notches [deltaY] is worth: negative delta (wheel up)
  /// zooms in, one canonical notch is 120 logical pixels.
  ///
  /// A pinch sends a stream of much smaller deltas, so this returns fractions;
  /// the clamp keeps a single flick from crossing the whole 50%–200% range in
  /// one event.
  static double _wheelNotchesFor(double deltaY) =>
      (-deltaY / 120).clamp(-3.0, 3.0);

  void _onZoomChanged() {
    final newZoom = _zoomController.zoom;
    final oldZoom = _appliedZoom ?? newZoom;
    _appliedZoom = newZoom;

    final anchor = _zoomController.takeAnchor();
    if (anchor != null && oldZoom != newZoom) {
      _preserveAnchorUnderPointer(anchor, oldZoom, newZoom);
    }

    widget.onZoomChanged?.call(newZoom);
    // The sheet has to lay out again: a different factor means a different
    // logical viewport, hence a different number of visible rows and columns.
    if (mounted) setState(() {});
  }

  /// Keeps whatever sits under [anchor] pinned there while the factor changes.
  ///
  /// [anchor] is in the widget's painted box, so the content position under it
  /// is `anchor / zoom` in logical space, less the fixed header, plus the
  /// scroll offset already in force; re-seating the offset for the new factor
  /// keeps that same content position under the pointer.
  ///
  /// The offsets are content-space and therefore unchanged by the factor, so
  /// they are read once, before the frame that applies the new layout — the
  /// correction itself waits for that frame, because the new viewport
  /// dimensions only exist after it.
  void _preserveAnchorUnderPointer(
      Offset anchor, double oldZoom, double newZoom) {
    final headerH = widget.showColumnHeader ? widget.headerHeight : 0.0;
    final rowHeaderW = widget.rowHeaderWidth;

    final vController = _verticalIndexedController.controller;
    final hController = widget.horizontalSyncController?.value.controller;

    final vOffset = vController.hasClients ? vController.offset : null;
    final hOffset = (hController != null && hController.hasClients)
        ? hController.offset
        : null;
    if (vOffset == null && hOffset == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (vOffset != null) {
        final contentY = (anchor.dy / oldZoom) - headerH + vOffset;
        _jumpTo(vController, contentY + headerH - (anchor.dy / newZoom));
      }
      if (hOffset != null) {
        final contentX = (anchor.dx / oldZoom) - rowHeaderW + hOffset;
        _jumpTo(hController!, contentX + rowHeaderW - (anchor.dx / newZoom));
      }
    });
  }

  /// Jumps [controller] to [target], clamped to what it can actually reach.
  static void _jumpTo(ScrollController controller, double target) {
    if (!controller.hasClients) return;
    final position = controller.position;
    if (!position.hasContentDimensions) return;
    try {
      controller.jumpTo(
        target.clamp(position.minScrollExtent, position.maxScrollExtent),
      );
    } catch (_) {
      // A virtualised strip can be torn down between the two frames.
    }
  }

  // --- Keystroke / Focus management ---
  FocusNode? _keystrokeFocusNode;
  bool _ownsKeystrokeFocusNode = false;

  FocusNode get _effectiveKeystrokeFocusNode {
    assert(_keystrokeFocusNode != null,
        '_keystrokeFocusNode should never be null when build() is called');
    return _keystrokeFocusNode!;
  }

  @override
  void initState() {
    super.initState();
    _horizontalSyncGroup = SyncScrollControllerGroup();
    // Seed the pre-change factor so the very first anchored zoom has a
    // starting point to map the pointer's content position from.
    _appliedZoom = _zoomController.zoom;
    // A caller-supplied controller is not owned here, so it never reaches the
    // owned-controller listener path; subscribe to it explicitly, otherwise a
    // change made through the supplied controller would never relayout the
    // sheet.
    widget.zoomController?.addListener(_onZoomChanged);
    if (widget.enableKeystrokes) {
      _configureKeystrokeFocusNode(widget.keystrokeFocusNode);
    }
  }

  @override
  void didUpdateWidget(SSpreadsheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    _configureZoomController(oldWidget);
    if (!widget.enableKeystrokes) return;
    if (oldWidget.keystrokeFocusNode != widget.keystrokeFocusNode) {
      _configureKeystrokeFocusNode(widget.keystrokeFocusNode);
    }
  }

  void _configureKeystrokeFocusNode(FocusNode? provided) {
    if (provided == null &&
        _ownsKeystrokeFocusNode &&
        _keystrokeFocusNode != null) {
      return;
    }
    if (_keystrokeFocusNode == provided && provided != null) return;

    if (_keystrokeFocusNode != null && _ownsKeystrokeFocusNode) {
      _keystrokeFocusNode!.dispose();
    }

    if (provided != null) {
      _keystrokeFocusNode = provided;
      _ownsKeystrokeFocusNode = false;
    } else {
      _keystrokeFocusNode = FocusNode();
      _ownsKeystrokeFocusNode = true;
    }
  }

  @override
  void dispose() {
    _ownedVerticalIndexedController?.dispose();
    widget.zoomController?.removeListener(_onZoomChanged);
    _disposeOwnedZoomController();
    _horizontalSyncGroup.dispose();
    if (_ownsKeystrokeFocusNode) {
      _keystrokeFocusNode?.dispose();
    }
    super.dispose();
  }

  double _rowHeightAt(int rowIndex) =>
      widget.rowHeightBuilder?.call(rowIndex) ?? 92;

  double _columnWidthAt(int columnIndex) =>
      widget.columnWidthBuilder?.call(columnIndex) ?? 180;

  // ======= Selection helpers =======

  Object _rowKeyAt(int rowIndex) =>
      widget.rowKeyBuilder?.call(rowIndex) ?? rowIndex;

  Object _columnKeyAt(int columnIndex) =>
      widget.columnKeyBuilder?.call(columnIndex) ?? columnIndex;

  /// TapRegion groupId shared by a row header and every body cell on that
  /// row. Records compare structurally in Dart, so two calls with an equal
  /// [rowKey] always produce an equal groupId without any string building.
  Object _rowTapRegionGroupId(Object rowKey) =>
      (axis: 'sspreadsheet_row', key: rowKey);

  /// TapRegion groupId shared by a column header and every body cell in
  /// that column. Mirrors [_rowTapRegionGroupId].
  Object _columnTapRegionGroupId(Object columnKey) =>
      (axis: 'sspreadsheet_column', key: columnKey);

  /// Wraps a built row-header cell with dimming, tap-to-select, and the
  /// TapRegion membership that lets [SSpreadsheetSelectionController]
  /// deselect on an outside tap. No-ops (returns [content] unchanged) when
  /// [SSpreadsheet.selectionController] is not set.
  Widget _wrapRowHeaderCell(int rowIndex, Widget content) {
    final controller = widget.selectionController;
    if (controller == null) return content;
    final rowKey = _rowKeyAt(rowIndex);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isDimmed = controller.selectedRowKey != null &&
            controller.selectedRowKey != rowKey;

        Widget dimmed = AnimatedOpacity(
          duration: widget.dimAnimationDuration,
          opacity: isDimmed ? widget.dimUnselectedOpacity : 1.0,
          child: content,
        );

        if (widget.enableTapToSelectRowHeader) {
          // Wraps `dimmed` as its ancestor (not a sibling behind it in a
          // Stack) so it's always the outermost hit-testable layer: a
          // Stack's hit test stops at the first (topmost) child whose
          // subtree claims the tap, so a same-level sibling catcher placed
          // behind the header content can be silently blocked by anything
          // in that content that hit-tests positively — even
          // non-interactive widgets, depending on what they wrap. Wrapping
          // as an ancestor makes SInkButton itself the first (and only)
          // thing tested, and its `translucent` hit-test behavior still lets
          // interactive descendants (e.g. a lock icon button) win their own
          // taps.
          dimmed = SInkButton(
            color: widget.rowHeaderTapSplashColor,
            enableHapticFeedback: false,
            onTap: (_) {
              controller.selectRow(rowKey);
              widget.onRowHeaderSelected
                  ?.call(rowIndex, controller.selectedRowKey);
              if (controller.selectedRowKey == null) {
                widget.onSelectionCleared?.call();
              }
            },
            child: dimmed,
          );
        }

        return TapRegion(
          groupId: _rowTapRegionGroupId(rowKey),
          onTapOutside: (_) {
            if (controller.selectedRowKey == rowKey) {
              controller.clearRow();
              widget.onSelectionCleared?.call();
            }
          },
          child: dimmed,
        );
      },
    );
  }

  /// Mirrors [_wrapRowHeaderCell] for a built column-header cell.
  Widget _wrapColumnHeaderCell(int columnIndex, Widget content) {
    final controller = widget.selectionController;
    if (controller == null) return content;
    final columnKey = _columnKeyAt(columnIndex);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isDimmed = controller.selectedColumnKey != null &&
            controller.selectedColumnKey != columnKey;

        Widget dimmed = AnimatedOpacity(
          duration: widget.dimAnimationDuration,
          opacity: isDimmed ? widget.dimUnselectedOpacity : 1.0,
          child: content,
        );

        if (widget.enableTapToSelectColumnHeader) {
          // See the matching comment in _wrapRowHeaderCell: wrapping as an
          // ancestor (rather than a same-level Stack sibling behind the
          // content) avoids the tap being silently blocked by the header's
          // own content.
          dimmed = SInkButton(
            color: widget.columnHeaderTapSplashColor,
            enableHapticFeedback: false,
            onTap: (_) {
              controller.selectColumn(columnKey);
              widget.onColumnHeaderSelected
                  ?.call(columnIndex, controller.selectedColumnKey);
              if (controller.selectedColumnKey == null) {
                widget.onSelectionCleared?.call();
              }
            },
            child: dimmed,
          );
        }

        return TapRegion(
          groupId: _columnTapRegionGroupId(columnKey),
          onTapOutside: (_) {
            if (controller.selectedColumnKey == columnKey) {
              controller.clearColumn();
              widget.onSelectionCleared?.call();
            }
          },
          child: dimmed,
        );
      },
    );
  }

  /// Wraps a built body cell with dimming + row/column TapRegion membership
  /// (so tapping it never counts as "outside" the selected row/column) and,
  /// when [SSpreadsheet.onCellTap] is set, a translucent tap handler.
  /// No-ops when [SSpreadsheet.selectionController] is not set.
  Widget _wrapBodyCell(int rowIndex, int columnIndex, Widget content) {
    final controller = widget.selectionController;
    if (controller == null) return content;
    final rowKey = _rowKeyAt(rowIndex);
    final columnKey = _columnKeyAt(columnIndex);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final rowMismatch = controller.selectedRowKey != null &&
            controller.selectedRowKey != rowKey;
        final columnMismatch = controller.selectedColumnKey != null &&
            controller.selectedColumnKey != columnKey;

        Widget dimmed = AnimatedOpacity(
          duration: widget.dimAnimationDuration,
          opacity: (rowMismatch || columnMismatch)
              ? widget.dimUnselectedOpacity
              : 1.0,
          child: widget.onCellTap == null
              ? content
              : GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => widget.onCellTap!(rowIndex, columnIndex),
                  child: content,
                ),
        );

        dimmed = TapRegion(
          groupId: _rowTapRegionGroupId(rowKey),
          child: dimmed,
        );
        dimmed = TapRegion(
          groupId: _columnTapRegionGroupId(columnKey),
          child: dimmed,
        );
        return dimmed;
      },
    );
  }

  void _notifyHorizontalMetrics(
      double offset, double maxScrollExtent, ScrollController controller) {
    widget.horizontalSyncController
        ?.update(offset, maxScrollExtent, controller);
    widget.onHorizontalMetricsChanged
        ?.call(offset, maxScrollExtent, controller);
  }

  /// A horizontal strip has mounted. The column header is the preferred
  /// metrics source because it is never virtualised away mid-scroll.
  void _attachHorizontalStrip(ScrollController controller,
          {required bool isPrimary}) =>
      widget.horizontalSyncController
          ?.registerStrip(controller, isPrimary: isPrimary);

  /// A horizontal strip is about to dispose its controller, so hand ownership
  /// on before it becomes unreadable.
  void _detachHorizontalStrip(ScrollController controller) =>
      widget.horizontalSyncController?.unregisterStrip(controller);

  // ======= Keystroke helpers =======

  /// Build a reverse-map from Intent type → ShortcutActivator so we can
  /// derive shortcut labels for HUD display. Merges built-in defaults
  /// with user-provided [keystrokeShortcuts], preferring meta-based
  /// activators on macOS and control-based elsewhere.
  Map<Type, ShortcutActivator> _buildIntentActivatorMap() {
    final result = <Type, ShortcutActivator>{};
    final isMac = defaultTargetPlatform == TargetPlatform.macOS;

    void addAll(Map<ShortcutActivator, Intent> map) {
      for (final entry in map.entries) {
        final intentType = entry.value.runtimeType;
        final existing = result[intentType];
        if (existing == null) {
          result[intentType] = entry.key;
          continue;
        }
        // Prefer meta-based on macOS, control-based elsewhere.
        final entryIsPreferred = _activatorPrefers(entry.key, isMac);
        final existingIsPreferred = _activatorPrefers(existing, isMac);
        if (entryIsPreferred && !existingIsPreferred) {
          result[intentType] = entry.key;
        }
      }
    }

    if (widget.includeDefaultKeystrokeShortcuts) {
      addAll(_defaultShortcuts);
    }
    if (_zoomShortcutsEnabled) {
      addAll(_zoomShortcuts);
    }
    if (widget.keystrokeShortcuts != null) {
      addAll(widget.keystrokeShortcuts!);
    }
    return result;
  }

  /// Returns `true` if [activator] has the modifier we prefer for the
  /// current platform (meta → macOS, control → other).
  static bool _activatorPrefers(ShortcutActivator activator, bool isMac) {
    if (activator is SingleActivator) {
      return isMac ? activator.meta : activator.control;
    }
    return false;
  }

  /// Derives a human-readable shortcut label from a [ShortcutActivator].
  /// On macOS uses symbol keys (⌘⌃⌥⇧); elsewhere uses written modifiers.
  static String _shortcutLabelFromActivator(ShortcutActivator activator) {
    if (activator is! SingleActivator) return activator.toString();

    final isMac = defaultTargetPlatform == TargetPlatform.macOS;
    final parts = <String>[];
    if (activator.control) parts.add(isMac ? '⌃' : 'Ctrl');
    if (activator.meta) parts.add(isMac ? '⌘' : 'Win');
    if (activator.alt) parts.add(isMac ? '⌥' : 'Alt');
    if (activator.shift) parts.add(isMac ? '⇧' : 'Shift');
    parts.add(activator.trigger.keyLabel);

    return isMac ? parts.join('') : parts.join('+');
  }

  /// Show the HUD overlay for the given intent type, then auto-dismiss.
  void _showKeystrokeHudForIntent(Type intentType, String shortcutLabel) {
    final hudBuilder = widget.keystrokeHudBuilder;
    final actionLabel = _effectiveActionLabels?[intentType];
    if (hudBuilder == null || actionLabel == null) return;

    final id = 'sspreadsheet_hud_${DateTime.now().microsecondsSinceEpoch}';
    Modal.show(
      id: id,
      modalType: ModalType.dialog,
      modalPosition: Alignment.center,
      blockBackgroundInteraction: false,
      isDismissable: true,
      shouldBlurBackground: false,
      barrierColor: Colors.transparent,
      builder: () => hudBuilder(context, shortcutLabel, actionLabel),
    );
    Future.delayed(widget.keystrokeHudDuration, () {
      Modal.dismissById(id);
      if (mounted) _effectiveKeystrokeFocusNode.requestFocus();
    });
  }

  /// Wraps a keystroke action handler with pause gating + optional HUD.
  VoidCallback _wrapKeystrokeHandler(Type intentType, VoidCallback inner) {
    return () {
      if (widget.shouldPauseKeystrokes?.call() == true) return;

      // Show HUD if builder + labels are configured.
      final activatorMap = _buildIntentActivatorMap();
      final activator = activatorMap[intentType];
      if (activator != null) {
        _showKeystrokeHudForIntent(
            intentType, _shortcutLabelFromActivator(activator));
      }

      inner();
    };
  }

  /// [SSpreadsheet.keystrokeActionLabels] plus built-in labels for the zoom
  /// shortcuts, so a consumer that enables zoom without naming these actions
  /// still gets a HUD. A caller's own label always wins.
  Map<Type, String>? get _effectiveActionLabels {
    final labels = widget.keystrokeActionLabels;
    if (!_zoomShortcutsEnabled) return labels;
    return {
      ZoomInIntent: 'Zoom In',
      ZoomOutIntent: 'Zoom Out',
      ResetZoomIntent: 'Reset Zoom',
      ...?labels,
    };
  }

  /// Build the action handler map that wraps each user callback with
  /// pause gating and optional HUD display.
  Map<Type, VoidCallback> _buildActionHandlerMap() {
    final handlers = widget.keystrokeActionHandlers;
    if (handlers == null) return const {};

    return handlers
        .map((type, cb) => MapEntry(type, _wrapKeystrokeHandler(type, cb)));
  }

  /// [_buildActionHandlerMap] plus built-in handlers for the zoom shortcuts, so
  /// Ctrl/Cmd + '=' / '-' / '0' work without the caller wiring anything up.
  ///
  /// A caller-supplied handler for the same intent wins — that is how an app
  /// routes the shortcut through its own state instead of directly into the
  /// sheet's zoom.
  Map<Type, VoidCallback> _buildZoomAwareActionHandlerMap() {
    final handlers = Map<Type, VoidCallback>.of(_buildActionHandlerMap());
    if (!_zoomShortcutsEnabled) return handlers;

    handlers.putIfAbsent(ZoomInIntent,
        () => _wrapKeystrokeHandler(ZoomInIntent, () => zoomIn()));
    handlers.putIfAbsent(ZoomOutIntent,
        () => _wrapKeystrokeHandler(ZoomOutIntent, () => zoomOut()));
    handlers.putIfAbsent(ResetZoomIntent,
        () => _wrapKeystrokeHandler(ResetZoomIntent, () => resetZoom()));
    return handlers;
  }

  /// The default shortcuts from KeystrokeListener, copied here so we can
  /// derive labels for built-in intents.
  static const Map<ShortcutActivator, Intent> _defaultShortcuts = {
    SingleActivator(LogicalKeyboardKey.escape): EscapeIntent(),
    SingleActivator(LogicalKeyboardKey.keyS, control: true): SaveIntent(),
    SingleActivator(LogicalKeyboardKey.keyS, meta: true): SaveIntent(),
    SingleActivator(LogicalKeyboardKey.keyZ, control: true): UndoIntent(),
    SingleActivator(LogicalKeyboardKey.keyZ, meta: true): UndoIntent(),
    SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true):
        RedoIntent(),
    SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true):
        RedoIntent(),
    SingleActivator(LogicalKeyboardKey.keyY, control: true): RedoIntent(),
    SingleActivator(LogicalKeyboardKey.keyY, meta: true): RedoIntent(),
    SingleActivator(LogicalKeyboardKey.keyA, control: true): SelectAllIntent(),
    SingleActivator(LogicalKeyboardKey.keyA, meta: true): SelectAllIntent(),
    SingleActivator(LogicalKeyboardKey.keyC, control: true): CopyIntent(),
    SingleActivator(LogicalKeyboardKey.keyC, meta: true): CopyIntent(),
    SingleActivator(LogicalKeyboardKey.keyV, control: true): PasteIntent(),
    SingleActivator(LogicalKeyboardKey.keyV, meta: true): PasteIntent(),
    SingleActivator(LogicalKeyboardKey.keyX, control: true): CutIntent(),
    SingleActivator(LogicalKeyboardKey.keyX, meta: true): CutIntent(),
    SingleActivator(LogicalKeyboardKey.slash, control: true):
        ToggleCommentIntent(),
    SingleActivator(LogicalKeyboardKey.slash, meta: true):
        ToggleCommentIntent(),
    SingleActivator(LogicalKeyboardKey.f1): HelpIntent(),
  };

  /// Whether the zoom shortcuts below are registered at all.
  ///
  /// Zooming is opt-in, so a sheet that never asks for it keeps exactly the
  /// shortcut set it had before these existed. Keyboard shortcuts still need
  /// [SSpreadsheet.enableKeystrokes], since they are delivered by the sheet's
  /// keystroke listener.
  bool get _zoomShortcutsEnabled =>
      widget.enableZoomGestures || widget.zoomController != null;

  /// Ctrl/Cmd + '=' / '+' / '-' / '0', on the main key row and, where the SDK
  /// names one, on the keypad.
  ///
  /// Merged in on top of [SSpreadsheet.keystrokeShortcuts] and the built-in
  /// shortcuts only when [_zoomShortcutsEnabled], so binding these keys is not
  /// a behaviour change for every other consumer of the widget. '=' is bound
  /// with and without Shift because '+' is what Shift produces on most layouts.
  ///
  /// The keypad has no logical key for '-' in this SDK (only `add`, `numpad0`
  /// and their neighbours), so zoom out is the main-row '-' alone.
  static const Map<ShortcutActivator, Intent> _zoomShortcuts = {
    SingleActivator(LogicalKeyboardKey.equal, control: true): ZoomInIntent(),
    SingleActivator(LogicalKeyboardKey.equal, meta: true): ZoomInIntent(),
    SingleActivator(LogicalKeyboardKey.equal, control: true, shift: true):
        ZoomInIntent(),
    SingleActivator(LogicalKeyboardKey.equal, meta: true, shift: true):
        ZoomInIntent(),
    SingleActivator(LogicalKeyboardKey.add, control: true): ZoomInIntent(),
    SingleActivator(LogicalKeyboardKey.add, meta: true): ZoomInIntent(),
    SingleActivator(LogicalKeyboardKey.numpadAdd, control: true):
        ZoomInIntent(),
    SingleActivator(LogicalKeyboardKey.numpadAdd, meta: true): ZoomInIntent(),
    SingleActivator(LogicalKeyboardKey.minus, control: true): ZoomOutIntent(),
    SingleActivator(LogicalKeyboardKey.minus, meta: true): ZoomOutIntent(),
    SingleActivator(LogicalKeyboardKey.digit0, control: true):
        ResetZoomIntent(),
    SingleActivator(LogicalKeyboardKey.digit0, meta: true): ResetZoomIntent(),
    SingleActivator(LogicalKeyboardKey.numpad0, control: true):
        ResetZoomIntent(),
    SingleActivator(LogicalKeyboardKey.numpad0, meta: true): ResetZoomIntent(),
  };

  // ======= End keystroke helpers =======

  /// Indices of complete rows intersecting the current vertical viewport.
  /// Includes partially visible rows and is independent of horizontal scrolling.
  /// Read after row insertion/extent animations have settled.
  ///
  /// Already expressed in logical space, so it needs no zoom adjustment: it
  /// reads the scroll position's viewport dimension, which zooming shrinks or
  /// grows, and reports exactly the rows on screen — a zoomed-in sheet simply
  /// has fewer of them.
  List<int> get visibleRowIndices {
    final controller = _verticalIndexedController.controller;
    if (!controller.hasClients) return const [];
    final start = controller.offset;
    final end = start + controller.position.viewportDimension;
    if (end <= start) return const [];
    var top = 0.0;
    final indices = <int>[];
    for (var row = 0; row < widget.rowCount; row++) {
      final bottom = top + _rowHeightAt(row);
      if (bottom > start && top < end) indices.add(row);
      if (top >= end) break;
      top = bottom;
    }
    return indices;
  }

  /// Maps a viewport-local position to a spreadsheet grid cell.
  ///
  /// [viewportLocalX] and [viewportLocalY] are coordinates relative to the
  /// top-left corner of this spreadsheet widget's bounding box.
  /// [viewportWidth] and [viewportHeight] are the widget's visible dimensions.
  ///
  /// All four are measured in the widget's own box — the box it *paints* into —
  /// so a caller can keep converting pointers against the sheet's [RenderBox]
  /// without knowing the zoom: at a factor `z` the sheet's logical content is
  /// laid out at `1/z` of that box, so these are mapped back into logical space
  /// before any row/column arithmetic begins, and the cell returned is the one
  /// under the pointer.
  ///
  /// Returns an [SSpreadsheetHitResult] with grid cell indices, progress
  /// within the hit cell, and visibility context for edge-triggered auto-scroll.
  SSpreadsheetHitResult hitTest(
    double viewportLocalX,
    double viewportLocalY,
    double viewportWidth,
    double viewportHeight,
  ) {
    final totalRows = widget.rowCount;
    final totalColumns = widget.columnCount;
    final headerH = widget.showColumnHeader ? widget.headerHeight : 0.0;
    final rowHeaderW = widget.rowHeaderWidth;

    // Undo the zoom, so everything below stays in the logical space the row
    // heights, column widths and scroll offsets are expressed in.
    final zoomFactor = _zoomController.zoom;
    final localX =
        zoomFactor == 1.0 ? viewportLocalX : viewportLocalX / zoomFactor;
    final localY =
        zoomFactor == 1.0 ? viewportLocalY : viewportLocalY / zoomFactor;
    final boxWidth =
        zoomFactor == 1.0 ? viewportWidth : viewportWidth / zoomFactor;
    final boxHeight =
        zoomFactor == 1.0 ? viewportHeight : viewportHeight / zoomFactor;

    // --- Vertical: find hit row ---
    final vController = _verticalIndexedController.controller;
    final vOffset = vController.hasClients ? vController.offset : 0.0;
    final vMinExtent =
        vController.hasClients ? vController.position.minScrollExtent : 0.0;

    // Content-space Y = viewport Y minus header, plus scroll offset.
    final contentY = localY - headerH + vOffset;
    final dataViewportHeight = boxHeight - headerH;

    int? rowIndex;
    double rowProgress = 0.0;
    bool isFirstVisibleRow = false;
    bool isLastVisibleRow = false;
    bool canScrollUp = false;
    bool canScrollDown = false;
    int? firstVisible;
    int? lastVisible;

    if (contentY >= 0 && totalRows > 0) {
      double cumulative = 0.0;
      for (int i = 0; i < totalRows; i++) {
        final h = _rowHeightAt(i);
        if (firstVisible == null && cumulative + h > vOffset) {
          firstVisible = i;
        }
        if (firstVisible != null &&
            lastVisible == null &&
            cumulative + h > vOffset + dataViewportHeight) {
          lastVisible = i > 0 ? i - 1 : i;
          // Handle the edge case where the last visible row is the very first row
          // that is partially visible at the bottom
          if (lastVisible < firstVisible) {
            lastVisible = firstVisible;
          }
        }
        if (contentY < cumulative + h) {
          rowIndex = i;
          rowProgress = ((contentY - cumulative) / h).clamp(0.0, 1.0);
          break;
        }
        cumulative += h;
      }
      // If we never found a "last visible" because content fits entirely,
      // the last visible is the last existing row.
      if (firstVisible != null && lastVisible == null) {
        lastVisible = totalRows - 1;
      }
      // If contentY is beyond the last row, clamp to last row
      if (rowIndex == null && totalRows > 0 && contentY >= 0) {
        rowIndex = totalRows - 1;
        rowProgress = 1.0;
      }

      canScrollUp = vOffset > vMinExtent;
      canScrollDown = lastVisible != null && lastVisible < totalRows - 1;
      if (rowIndex != null) {
        isFirstVisibleRow = firstVisible != null && rowIndex == firstVisible;
        isLastVisibleRow = lastVisible != null && rowIndex == lastVisible;
      }
    }

    // --- Horizontal: find hit column ---
    final hMetrics = widget.horizontalSyncController?.value;
    final hOffset = hMetrics?.offset ?? 0.0;
    final hController = hMetrics?.controller;
    final hMinExtent = (hController != null && hController.hasClients)
        ? hController.position.minScrollExtent
        : 0.0;

    // Content-space X = viewport X minus row-header, plus horizontal offset.
    final contentX = localX - rowHeaderW + hOffset;
    final dataViewportWidth = boxWidth - rowHeaderW;

    int? columnIndex;
    double columnProgress = 0.0;
    bool isFirstVisibleColumn = false;
    bool isLastVisibleColumn = false;
    bool canScrollLeft = false;
    bool canScrollRight = false;
    int? firstVisibleCol;
    int? lastVisibleCol;

    if (contentX >= 0 && totalColumns > 0) {
      double cumulative = 0.0;
      for (int j = 0; j < totalColumns; j++) {
        final w = _columnWidthAt(j);
        if (firstVisibleCol == null && cumulative + w > hOffset) {
          firstVisibleCol = j;
        }
        if (firstVisibleCol != null &&
            lastVisibleCol == null &&
            cumulative + w > hOffset + dataViewportWidth) {
          lastVisibleCol = j > 0 ? j - 1 : j;
          if (lastVisibleCol < firstVisibleCol) {
            lastVisibleCol = firstVisibleCol;
          }
        }
        if (contentX < cumulative + w) {
          columnIndex = j;
          columnProgress = ((contentX - cumulative) / w).clamp(0.0, 1.0);
          break;
        }
        cumulative += w;
      }
      if (firstVisibleCol != null && lastVisibleCol == null) {
        lastVisibleCol = totalColumns - 1;
      }
      if (columnIndex == null && totalColumns > 0 && contentX >= 0) {
        columnIndex = totalColumns - 1;
        columnProgress = 1.0;
      }

      canScrollLeft = hOffset > hMinExtent;
      canScrollRight =
          lastVisibleCol != null && lastVisibleCol < totalColumns - 1;
      if (columnIndex != null) {
        isFirstVisibleColumn =
            firstVisibleCol != null && columnIndex == firstVisibleCol;
        isLastVisibleColumn =
            lastVisibleCol != null && columnIndex == lastVisibleCol;
      }
    }

    return SSpreadsheetHitResult(
      rowIndex: rowIndex,
      rowProgress: rowProgress,
      columnIndex: columnIndex,
      columnProgress: columnProgress,
      isInDataArea: rowIndex != null && columnIndex != null,
      totalRows: totalRows,
      totalColumns: totalColumns,
      isFirstVisibleRow: isFirstVisibleRow,
      isLastVisibleRow: isLastVisibleRow,
      canScrollUp: canScrollUp,
      canScrollDown: canScrollDown,
      isFirstVisibleColumn: isFirstVisibleColumn,
      isLastVisibleColumn: isLastVisibleColumn,
      canScrollLeft: canScrollLeft,
      canScrollRight: canScrollRight,
    );
  }

  Widget _buildHeaderRow() {
    return SizedBox(
      height: widget.headerHeight,
      child: Row(
        children: [
          if (widget.rowHeaderBuilder != null)
            SizedBox(
              width: widget.rowHeaderWidth,
              child: widget.cornerBuilder?.call(context) ??
                  const SizedBox.shrink(),
            ),
          Expanded(
            child: _SyncedHorizontalStrip(
              syncGroup: _horizontalSyncGroup,
              itemCount: widget.columnCount,
              itemWidthBuilder: _columnWidthAt,
              physics: widget.horizontalPhysics,
              onMetricsChanged: _notifyHorizontalMetrics,
              isPrimary: true,
              onStripAttached: _attachHorizontalStrip,
              onStripDetached: _detachHorizontalStrip,
              itemBuilder: (context, columnIndex) {
                final builder = widget.columnHeaderBuilder;
                if (builder == null) return const SizedBox.shrink();
                return SizedBox(
                  width: _columnWidthAt(columnIndex),
                  height: widget.headerHeight,
                  child: _wrapColumnHeaderCell(
                      columnIndex, builder(context, columnIndex)),
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
              SizedBox(
                  width: widget.rowHeaderWidth,
                  child: _wrapRowHeaderCell(
                      rowIndex, widget.rowHeaderBuilder!(context, rowIndex))),
            Expanded(
              child: _SyncedHorizontalStrip(
                syncGroup: _horizontalSyncGroup,
                itemCount: widget.columnCount,
                itemWidthBuilder: _columnWidthAt,
                physics: widget.horizontalPhysics,
                onMetricsChanged: _notifyHorizontalMetrics,
                isPrimary: false,
                onStripAttached: _attachHorizontalStrip,
                onStripDetached: _detachHorizontalStrip,
                itemBuilder: (context, columnIndex) => SizedBox(
                  width: _columnWidthAt(columnIndex),
                  height: _rowHeightAt(rowIndex),
                  child: _wrapBodyCell(rowIndex, columnIndex,
                      widget.cellBuilder(context, rowIndex, columnIndex)),
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

  /// Builds the vanilla spreadsheet content (no keystroke wrapping).
  Widget _buildSpreadsheetContent() {
    final body = widget.rowCount == 0
        ? const SizedBox.shrink()
        : IndexScrollListViewBuilder(
            controller: _verticalIndexedController,
            itemCount: widget.rowCount,
            physics: widget.verticalPhysics,
            padding: EdgeInsets.zero,
            enableRowAnimations: widget.enableRowAnimations,
            itemKeyBuilder: widget.rowKeyBuilder,
            rowAnimationDuration: widget.rowAnimationDuration,
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

  /// Wraps the spreadsheet content in [Listener] + [KeystrokeListener] for
  /// keyboard shortcut detection and web focus forcing.
  Widget _buildWithKeystrokes() {
    final actionHandlers = _buildZoomAwareActionHandlerMap();

    Map<ShortcutActivator, Intent>? mergedShortcuts;
    if (widget.keystrokeShortcuts != null) {
      mergedShortcuts = Map.of(widget.keystrokeShortcuts!);
    }
    if (_zoomShortcutsEnabled) {
      mergedShortcuts = {...?mergedShortcuts, ..._zoomShortcuts};
    }

    Widget spreadsheetContent = KeystrokeListener(
      focusNode: _effectiveKeystrokeFocusNode,
      requestFocusOnInit: widget.keystrokeRequestFocusOnInit,
      autoFocus: true,
      enableVisualDebug: widget.keystrokeDebugLogs,
      shouldSuppressAutoRefocus: widget.shouldPauseKeystrokes,
      shortcuts: mergedShortcuts,
      includeDefaultShortcuts: widget.includeDefaultKeystrokeShortcuts,
      actionHandlers: actionHandlers.isNotEmpty ? actionHandlers : null,
      onKeyEvent: widget.onKeystrokeEvent,
      child: _buildSpreadsheetContent(),
    );

    // Web focus forcing: on every pointer-down, unfocus then refocus to
    // prime the DOM <input> connection for web browsers.
    spreadsheetContent = Listener(
      onPointerDown: (_) {
        if (widget.shouldPauseKeystrokes?.call() == true) return;
        _effectiveKeystrokeFocusNode.unfocus();
        _effectiveKeystrokeFocusNode.requestFocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && (widget.shouldPauseKeystrokes?.call() != true)) {
            _effectiveKeystrokeFocusNode.requestFocus();
          }
        });
      },
      behavior: HitTestBehavior.translucent,
      child: spreadsheetContent,
    );

    return spreadsheetContent;
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.enableKeystrokes
        ? _buildWithKeystrokes()
        : _buildSpreadsheetContent();
    return _buildWithZoom(content);
  }

  /// Lays the sheet out at `viewport / zoom` and paints it at `zoom`, so the
  /// whole grid — headers, rows, cells — magnifies together and zooming out
  /// genuinely reveals more of it.
  ///
  /// At the default 100%, and for every sheet that never touches zoom, the
  /// viewport hands [content] straight through: an existing layout is
  /// unchanged.
  ///
  /// With [SSpreadsheet.enableZoomGestures] the pointer signal listener sits
  /// *outside* the viewport, so the positions it reports are in the widget's
  /// painted box — the same space [SSpreadsheetZoomController] anchors are
  /// expressed in.
  Widget _buildWithZoom(Widget content) {
    final zoomed = SSpreadsheetZoomViewport(
      zoom: _zoomController.zoom,
      child: content,
    );
    if (!widget.enableZoomGestures) return zoomed;
    return Listener(onPointerSignal: _onPointerSignal, child: zoomed);
  }
}

/// Reports that a horizontal strip has mounted ([isPrimary] marks the
/// non-virtualised column header) or is about to dispose its controller.
typedef _StripAttached = void Function(ScrollController controller,
    {required bool isPrimary});
typedef _StripDetached = void Function(ScrollController controller);

class _SyncedHorizontalStrip extends StatefulWidget {
  final SyncScrollControllerGroup syncGroup;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double Function(int index) itemWidthBuilder;
  final ScrollPhysics? physics;
  final SSpreadsheetHorizontalMetricsChanged? onMetricsChanged;

  /// True for the column-header strip. Body rows are virtualised and can be
  /// recycled at any time, so they are only a fallback metrics source.
  final bool isPrimary;
  final _StripAttached? onStripAttached;
  final _StripDetached? onStripDetached;

  const _SyncedHorizontalStrip({
    required this.syncGroup,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemWidthBuilder,
    this.physics,
    this.onMetricsChanged,
    this.isPrimary = false,
    this.onStripAttached,
    this.onStripDetached,
  });

  @override
  State<_SyncedHorizontalStrip> createState() => _SyncedHorizontalStripState();
}

class _SyncedHorizontalStripState extends State<_SyncedHorizontalStrip> {
  late final ScrollController _controller;
  late final IndexedScrollController _indexedController;
  bool _flushScheduled = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.syncGroup.addAndGet();
    _controller.addListener(_onScroll);
    _indexedController = IndexedScrollController(scrollController: _controller);

    widget.onStripAttached?.call(_controller, isPrimary: widget.isPrimary);
    _scheduleMetricsFlush();
  }

  /// Coalesces every trigger in a frame into a single report, taken after
  /// layout has settled so offset and extent are the values that will actually
  /// be painted. No timers and no polling: one post-frame callback at most.
  void _scheduleMetricsFlush() {
    if (_flushScheduled) return;
    _flushScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _flushScheduled = false;
      if (!mounted || !_controller.hasClients) return;
      final position = _controller.position;
      if (!position.hasContentDimensions) return;
      widget.onMetricsChanged
          ?.call(position.pixels, position.maxScrollExtent, _controller);
    });
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    if (!position.hasContentDimensions) return;
    widget.onMetricsChanged
        ?.call(position.pixels, position.maxScrollExtent, _controller);
  }

  @override
  void dispose() {
    // Hand ownership on while the other strips are still usable, before this
    // controller becomes unreadable.
    widget.onStripDetached?.call(_controller);
    _indexedController.dispose();
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A resize changes maxScrollExtent without moving the offset, so the
    // scroll listener above never fires for it. ScrollMetricsNotification is
    // dispatched by the Scrollable precisely for that case — viewport or
    // content dimensions changing — and it is read here from the strip's own
    // controller rather than resolved from the notification's context.
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (notification) {
        // Vertical scrollables nested inside cells must not be mistaken for
        // this strip; their reports are simply ignored.
        if (notification.metrics.axis == Axis.horizontal) {
          _scheduleMetricsFlush();
        }
        return false;
      },
      child: IndexScrollListViewBuilder(
        controller: _indexedController,
        itemCount: widget.itemCount,
        scrollDirection: Axis.horizontal,
        physics: widget.physics,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return SizedBox(
              width: widget.itemWidthBuilder(index),
              child: widget.itemBuilder(context, index));
        },
        onScrolledTo: (_) {},
      ),
    );
  }
}
