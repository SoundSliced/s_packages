import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:s_packages/indexscroll_listview_builder/indexscroll_listview_builder.dart';
import 'package:s_packages/keystroke_listener/keystroke_listener.dart';
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

  bool canScrollRight({double threshold = 100}) =>
      offset < (maxScrollExtent - threshold);
}

/// Shared horizontal synchronization state for [SSpreadsheet].
///
/// Pass one instance to [SSpreadsheet.horizontalSyncController] and to
/// [SSpreadsheetHorizontalScrollButtons] to control scrolling externally.
class SSpreadsheetHorizontalSyncController
    extends ValueNotifier<SSpreadsheetHorizontalMetrics> {
  SSpreadsheetHorizontalSyncController([SSpreadsheetHorizontalMetrics? initial])
      : super(initial ?? const SSpreadsheetHorizontalMetrics());

  void update(
      double offset, double maxScrollExtent, ScrollController controller) {
    value = SSpreadsheetHorizontalMetrics(
        offset: offset,
        maxScrollExtent: maxScrollExtent,
        controller: controller);
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
    if (widget.enableKeystrokes) {
      _configureKeystrokeFocusNode(widget.keystrokeFocusNode);
    }
  }

  @override
  void didUpdateWidget(SSpreadsheet oldWidget) {
    super.didUpdateWidget(oldWidget);
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

  void _notifyHorizontalMetrics(
      double offset, double maxScrollExtent, ScrollController controller) {
    widget.horizontalSyncController
        ?.update(offset, maxScrollExtent, controller);
    widget.onHorizontalMetricsChanged
        ?.call(offset, maxScrollExtent, controller);
  }

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
    final actionLabel = widget.keystrokeActionLabels?[intentType];
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

  /// Build the action handler map that wraps each user callback with
  /// pause gating and optional HUD display.
  Map<Type, VoidCallback> _buildActionHandlerMap() {
    final handlers = widget.keystrokeActionHandlers;
    if (handlers == null) return const {};

    return handlers
        .map((type, cb) => MapEntry(type, _wrapKeystrokeHandler(type, cb)));
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

  // ======= End keystroke helpers =======

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
              SizedBox(
                  width: widget.rowHeaderWidth,
                  child: widget.rowHeaderBuilder!(context, rowIndex)),
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
    final actionHandlers = _buildActionHandlerMap();

    Map<ShortcutActivator, Intent>? mergedShortcuts;
    if (widget.keystrokeShortcuts != null) {
      mergedShortcuts = widget.keystrokeShortcuts!;
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
    if (widget.enableKeystrokes) {
      return _buildWithKeystrokes();
    }
    return _buildSpreadsheetContent();
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
    _indexedController = IndexedScrollController(scrollController: _controller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      widget.onMetricsChanged?.call(_controller.position.pixels,
          _controller.position.maxScrollExtent, _controller);
    });
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    widget.onMetricsChanged?.call(_controller.position.pixels,
        _controller.position.maxScrollExtent, _controller);
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
        return SizedBox(
            width: widget.itemWidthBuilder(index),
            child: widget.itemBuilder(context, index));
      },
      onScrolledTo: (_) {},
    );
  }
}
