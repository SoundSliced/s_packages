import 'package:flutter/scheduler.dart';
import 'package:s_packages/s_packages.dart';

class SDropdownController {
  _SDropdownState? _state;

  /// Unique tap region group ID generated when controller is created.
  /// Available immediately without needing state attachment.
  final Object tapRegionGroupId = Object();

  void _attach(_SDropdownState state) {
    _state = state;
    // Share the controller's tapRegionGroupId with the state
    state.tapRegionID = tapRegionGroupId;
  }

  void _detach(_SDropdownState state) {
    if (_state == state) {
      _state = null;
    }
  }

  bool get isExpanded => _state?._isExpanded ?? false;

  /// Get the tap region group ID used by this dropdown.
  /// Use this ID to group control buttons with the dropdown so they won't trigger
  /// the onTapOutside handler. Wrap your buttons with TapRegion(groupId: tapRegionGroupId, ...)
  /// This ID is available immediately and doesn't require state attachment.
  // Object? get tapRegionGroupId => _state?.tapRegionID;

  void open() {
    _state?._openFromController();
  }

  void close() {
    _state?._closeFromController();
  }

  void toggle() {
    _state?._toggleDropdown();
  }

  void highlightNext() {
    _state?._moveHighlight(1);
  }

  void highlightPrevious() {
    _state?._moveHighlight(-1);
  }

  /// Highlight the item at the given original index (index in the `items` list)
  void highlightAtIndex(int index) {
    if ((_state?._isExpanded == false)) {
      _state?._openFromController();
    }

    /// Highlight the item at `index` where `index` represents
    /// the index in the original `items` list passed to `SDropdown`.
    /// If the overlay is not open, this will open it and then highlight the item.
    _state?._setHighlightAtIndex(index);
  }

  /// Highlight the item with the given value
  void highlightItem(String value) {
    /// Highlight the item that has the given string `value`.
    /// If the overlay is not open, this will open it and then highlight the item.
    _state?._setHighlightForValue(value);
  }

  /// Select (and highlight) the item at the given original index (index in the `items` list)
  void selectIndex(int index) {
    /// Select an item using its original index in the `items` list.
    /// This will also trigger `onChanged` and close the overlay.
    _state?._selectByIndex(index);
  }

  /// Select (and highlight) the item with the given value
  void selectItem(String value) {
    /// Select an item using its string value. This will trigger `onChanged` and close the overlay.
    _state?._selectByValue(value);
  }

  void selectHighlighted() {
    _state?._selectHighlightedItem();
  }

  /// Select the next item in the list. If none is selected, selects the first item.
  void selectNext() {
    _state?._selectNextItem();
  }

  /// Select the previous item in the list. If none is selected, selects the first item.
  void selectPrevious() {
    _state?._selectPreviousItem();
  }

  void closeWithoutSelection() {
    _state?._closeWithoutSelection();
  }

  void ensureHighlightInitialized() {
    _state?._ensureHighlightInitialized();
  }
}

/// A fully custom dropdown widget built from scratch for String items with complete control over dimensions and behavior.
/// This widget provides a native Flutter dropdown implementation with:
/// - Full control over widget width and height
/// - Simplified API focused on String items only
/// - Custom overlay system using CompositedTransformTarget/Follower
/// - Minimal external dependencies: uses a small set of helper packages for responsive sizing, indexed lists, and animation helpers
/// - Comprehensive styling through SDropdownDecoration
/// - Support for item-specific text styles
/// - Scroll controller support for precise positioning
/// - Native Flutter performance and behavior
/// - Smooth roll-up/down animations with fade effects
class SDropdown extends StatefulWidget {
  /// The width of the dropdown widget
  final double? width;

  /// The height of the dropdown widget
  final double? height;

  /// The height of the dropdown overlay when expanded
  final double? overlayHeight;

  /// The width of the dropdown overlay when expanded
  final double? overlayWidth;

  /// Scale factor for the entire widget
  final double? scale;

  /// The list of string items to display
  final List<String> items, customItemsNamesDisplayed;

  /// The currently selected item
  final String? selectedItem, selectedItemText;

  /// Initial selected item (if no controller is used)
  final String? initialItem;

  /// Hint text to display when no item is selected
  final String? hintText;

  /// Callback when selection changes
  final Function(String?)? onChanged;

  /// Text style for dropdown items
  final TextStyle? itemTextStyle;

  /// Text style for the header (selected item)
  final TextStyle? headerTextStyle;

  /// Text style for the hint text
  final TextStyle? hintTextStyle;

  /// Map of item-specific text styles
  final Map<String, TextStyle>? itemSpecificStyles;

  /// Background color of the closed dropdown
  final Color? closedFillColor;

  /// Background color of the expanded dropdown overlay
  final Color? expandedFillColor;

  /// Color for the header when expanded
  final Color? headerExpandedColor;

  /// Border for the closed dropdown
  final Border? closedBorder;

  /// Border for the expanded dropdown overlay
  final Border? expandedBorder;

  /// Border radius for the closed dropdown
  final BorderRadius? closedBorderRadius;

  /// Border radius for the expanded dropdown overlay
  final BorderRadius? expandedBorderRadius;

  /// Padding for the closed header
  final EdgeInsets? closedHeaderPadding;

  /// Padding for the expanded header
  final EdgeInsets? expandedHeaderPadding;

  /// Padding for the items list
  final EdgeInsets? itemsListPadding;

  /// Padding for each list item
  final EdgeInsets? listItemPadding;

  /// Scroll controller for the items list (wrapped internally by an IndexedScrollController)
  final ScrollController? itemsScrollController;

  /// Whether to exclude the selected item from the dropdown list
  final bool excludeSelected;

  /// Whether the dropdown can be closed by tapping outside
  final bool canCloseOutsideBounds;

  /// Whether the dropdown is enabled
  final bool enabled;

  /// Alignment of the widget within its parent
  final AlignmentGeometry? alignment;

  /// Maximum lines for text display
  final int maxLines;

  /// Suffix icon for the closed dropdown
  final Widget? suffixIcon;

  /// Prefix icon for the closed dropdown
  final Widget? prefixIcon;

  /// Validator function
  final String? Function(String?)? validator;

  /// Whether to validate on change
  final bool validateOnChange;

  /// Custom decoration for the dropdown
  final SDropdownDecoration? decoration;

  /// Controller used to manage the dropdown programmatically
  final SDropdownController? controller;

  final int? autoScrollMaxFrameDelay;
  final int? autoScrollEndOfFrameDelay;

  /// Whether to enable keyboard navigation (arrow keys, enter, escape)
  final bool useKeyboardNavigation;

  /// Optional FocusNode for keyboard navigation. If not provided and useKeyboardNavigation is true, an internal FocusNode will be created.
  final FocusNode? focusNode;

  /// Whether to request focus on initialization when useKeyboardNavigation is true
  final bool requestFocusOnInit;

  const SDropdown({
    super.key,
    required this.items,
    this.customItemsNamesDisplayed = const [],
    this.width,
    this.height,
    this.overlayHeight,
    this.overlayWidth,
    this.scale,
    this.selectedItem,
    this.initialItem,
    this.hintText,
    this.onChanged,
    this.itemTextStyle,
    this.headerTextStyle,
    this.hintTextStyle,
    this.itemSpecificStyles,
    this.closedFillColor,
    this.expandedFillColor,
    this.closedBorder,
    this.expandedBorder,
    this.closedBorderRadius,
    this.expandedBorderRadius,
    this.closedHeaderPadding,
    this.expandedHeaderPadding,
    this.itemsListPadding,
    this.listItemPadding,
    this.itemsScrollController,
    this.excludeSelected = true,
    this.canCloseOutsideBounds = true,
    this.enabled = true,
    this.alignment,
    this.maxLines = 1,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.validateOnChange = true,
    this.decoration,
    this.headerExpandedColor,
    this.selectedItemText,
    this.controller,
    this.autoScrollMaxFrameDelay,
    this.autoScrollEndOfFrameDelay,
    this.useKeyboardNavigation = true,
    this.focusNode,
    this.requestFocusOnInit = false,
  }) : assert(
          initialItem == null,
          'Use selectedItem instead of initialItem',
        );

  @override
  State<SDropdown> createState() => _SDropdownState();
}

class _SDropdownState extends State<SDropdown> {
  Object? tapRegionID;
  String? _currentSelection;
  bool _isExpanded = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  IndexedScrollController? _itemsScrollController;
  int? _scrollTargetIndex;

  List<_DropdownOption> _visibleOptions = const [];
  int? _highlightedIndex;
  bool _keyboardNavigationActive = false;

  FocusNode? _internalFocusNode;

  FocusNode? get _effectiveFocusNode {
    if (!widget.useKeyboardNavigation) return null;
    return widget.focusNode ?? _internalFocusNode;
  }

  static const double _itemExtent = 35.0;

  // Animation trigger - toggle to start expand/collapse animation
  bool _animationTrigger = false;

  bool get _canMutateStateNow {
    final SchedulerPhase phase = SchedulerBinding.instance.schedulerPhase;
    return phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks;
  }

  void _setStateSafely(VoidCallback mutation, {bool rebuildOverlay = false}) {
    if (!mounted) {
      return;
    }

    setState(mutation);

    void run() {
      if (!mounted) {
        return;
      }
      setState(mutation);
      if (rebuildOverlay) {
        _scheduleOverlayRebuild();
      }
    }

    if (_canMutateStateNow) {
      run();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => run());
    }
  }

  void _scheduleOverlayRebuild() {
    if (_overlayEntry == null) {
      return;
    }

    void mark() {
      if (_overlayEntry == null) {
        return;
      }
      _overlayEntry!.markNeedsBuild();
    }

    if (_canMutateStateNow) {
      mark();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => mark());
    }
  }

  void _requestFocusIfNeeded() {
    if (!mounted || !widget.enabled) return;
    final FocusNode? fn = _effectiveFocusNode;
    if (fn != null && !fn.hasFocus) {
      FocusScope.of(context).requestFocus(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.initialItem ?? widget.selectedItem;

    if (widget.itemsScrollController != null) {
      _itemsScrollController = IndexedScrollController(
        scrollController: widget.itemsScrollController,
        alignment: 0.2,
      );
    }

    widget.controller?._attach(this);

    _visibleOptions = _computeVisibleOptions();

    _syncInternalFocusNode();
  }

  void _syncInternalFocusNode() {
    final bool needsInternal =
        widget.useKeyboardNavigation && widget.focusNode == null;
    if (needsInternal) {
      _internalFocusNode ??= FocusNode(debugLabel: 'SDropdownInternal');
    } else {
      if (_internalFocusNode != null && !needsInternal) {
        _internalFocusNode!.dispose();
        _internalFocusNode = null;
      }
    }
  }

  @override
  void didUpdateWidget(SDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool selectionChanged = widget.selectedItem != oldWidget.selectedItem;
    if (selectionChanged) {
      _currentSelection = widget.selectedItem;
    }

    if (widget.itemsScrollController != oldWidget.itemsScrollController) {
      if (widget.itemsScrollController != null) {
        _itemsScrollController = IndexedScrollController(
          scrollController: widget.itemsScrollController,
          alignment: 0.2,
        );
      } else {
        _itemsScrollController = null;
      }
    }

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }

    _syncInternalFocusNode();

    if (!widget.enabled && _isExpanded) {
      _closeWithoutSelection();
    }

    if (!widget.useKeyboardNavigation &&
        oldWidget.useKeyboardNavigation &&
        _isExpanded) {
      _closeWithoutSelection();
    }

    final bool itemsChanged = !_stringListEquals(widget.items, oldWidget.items);
    final bool namesChanged = !_stringListEquals(
        widget.customItemsNamesDisplayed, oldWidget.customItemsNamesDisplayed);
    final bool excludeChanged =
        widget.excludeSelected != oldWidget.excludeSelected;

    if (selectionChanged || itemsChanged || namesChanged || excludeChanged) {
      final bool keepHighlight = _isExpanded && !selectionChanged;
      _refreshVisibleOptions(keepHighlight: keepHighlight);

      if (_isExpanded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _ensureHighlightInitialized();
          }
        });
      }
    } else if (_isExpanded) {
      _scheduleOverlayRebuild();
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);

    _overlayEntry?.remove();
    _overlayEntry = null;

    _internalFocusNode?.dispose();

    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown) {
      if (!_isExpanded) {
        _showOverlay();
      } else {
        _moveHighlight(1);
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      if (!_isExpanded) {
        _showOverlay();
      } else {
        _moveHighlight(-1);
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      if (_isExpanded) {
        _selectHighlightedItem();
      } else {
        _showOverlay();
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.tab) {
      if (_isExpanded) {
        _closeWithoutSelection();
      }
      return KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.backspace) {
      if (_isExpanded) {
        _closeWithoutSelection();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final double effectiveScale = widget.scale ?? 1.0;

    Widget buildCore({required bool hasFocus}) {
      return CompositedTransformTarget(
        link: _layerLink,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          decoration: widget.useKeyboardNavigation
              ? BoxDecoration(
                  borderRadius:
                      widget.closedBorderRadius ?? BorderRadius.circular(8),
                  boxShadow: hasFocus
                      ? [
                          BoxShadow(
                            color: Colors.blue.shade600.withValues(alpha: 0.45),
                            blurRadius: 6 * effectiveScale,
                            spreadRadius: 0.5 * effectiveScale,
                          ),
                        ]
                      : null,
                  border: Border.all(
                    width: (hasFocus ? 1 : 0.5) * effectiveScale,
                    color: hasFocus
                        ? Colors.blue.shade600
                        : (widget.closedBorder?.top.color ??
                            Colors.transparent),
                  ),
                )
              : null,
          child: _buildDropdownButton(),
        ),
      );
    }

    final dropdownWidget = SizedBox(
      width: widget.width,
      height: widget.height,
      child: Transform.scale(
        scale: effectiveScale,
        alignment: widget.alignment ?? Alignment.center,
        child: widget.useKeyboardNavigation
            ? Focus(
                focusNode: _effectiveFocusNode,
                autofocus: widget.requestFocusOnInit,
                canRequestFocus: widget.enabled,
                onKeyEvent: _handleKeyEvent,
                child: Builder(
                  builder: (context) {
                    final hasFocus = Focus.of(context).hasFocus;
                    return Listener(
                      onPointerDown: (_) {
                        if (!hasFocus && _effectiveFocusNode != null) {
                          FocusScope.of(context)
                              .requestFocus(_effectiveFocusNode);
                        }
                      },
                      child: buildCore(hasFocus: hasFocus),
                    );
                  },
                ),
              )
            : buildCore(hasFocus: false),
      ),
    );

    return dropdownWidget;
  }

  void _toggleDropdown() {
    if (!widget.enabled) {
      return;
    }

    if (_isExpanded) {
      _closeWithoutSelection();
    } else {
      _requestFocusIfNeeded();
      _showOverlay();
    }
  }

  void _openFromController() {
    if (!widget.enabled || _isExpanded) {
      return;
    }
    // Ensure the dropdown gains focus when opened programmatically so that
    // keyboard navigation works immediately without requiring a tap.
    _requestFocusIfNeeded();
    _showOverlay();
  }

  void _closeFromController() {
    if (!_isExpanded) {
      return;
    }
    _closeWithoutSelection();
  }

  void _closeWithoutSelection() {
    _removeOverlay();
  }

  void _showOverlay() {
    if (_overlayEntry != null || !mounted) {
      return;
    }

    // Ensure focus when showing overlay from any path (tap, keyboard, or controller)
    _requestFocusIfNeeded();

    _refreshVisibleOptions(keepHighlight: false);

    // Calculate initial highlight and scroll target BEFORE building overlay
    int? initialHighlight;
    if (_visibleOptions.isNotEmpty) {
      if (_currentSelection != null) {
        final int selectedIndex = _visibleOptions
            .indexWhere((option) => option.value == _currentSelection);
        if (selectedIndex != -1) {
          initialHighlight = selectedIndex;
        }
      }
      initialHighlight ??= 0;
    }

    final OverlayState? overlayState = Overlay.maybeOf(context);
    if (overlayState == null) {
      return;
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    // Set state BEFORE building the overlay so IndexScrollListViewBuilder has the correct initial values
    setState(() {
      _isExpanded = true;
      _keyboardNavigationActive = true;
      _animationTrigger = true;
      _highlightedIndex = initialHighlight;
      _scrollTargetIndex = initialHighlight;
    });

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildOverlay(size),
    );

    overlayState.insert(_overlayEntry!);

    // Ensure scroll happens after the list is built and controller is attached
    if (initialHighlight != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollTargetIndex != initialHighlight) {
          setState(() {
            _scrollTargetIndex = initialHighlight;
          });
          _scheduleOverlayRebuild();
        }
      });
    }
  }

  Future<void> _removeOverlay() async {
    if (_overlayEntry == null) {
      return;
    }

    // Trigger reverse animation
    if (mounted) {
      _setStateSafely(() {
        _animationTrigger = false;
      });
      // Wait for animation to complete
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _overlayEntry?.remove();
    _overlayEntry = null;

    if (mounted) {
      _setStateSafely(() {
        _isExpanded = false;
        _keyboardNavigationActive = false;
        _highlightedIndex = null;
        _scrollTargetIndex = null;
      });
    } else {
      _isExpanded = false;
      _keyboardNavigationActive = false;
      _highlightedIndex = null;
      _scrollTargetIndex = null;
    }
  }

  void _selectItem(String value) {
    final bool valueChanged = _currentSelection != value;

    if (valueChanged) {
      _setStateSafely(() {
        _currentSelection = value;
      });
    }

    if (widget.validateOnChange) {
      widget.validator?.call(value);
    }

    widget.onChanged?.call(value);

    _closeWithoutSelection();
  }

  void _refreshVisibleOptions({required bool keepHighlight}) {
    final List<_DropdownOption> next = _computeVisibleOptions();
    final bool highlightOutOfRange =
        _highlightedIndex != null && _highlightedIndex! >= next.length;
    final bool shouldResetHighlight = !keepHighlight || highlightOutOfRange;

    if (_isExpanded) {
      final bool optionsChanged = _optionsDiffer(next) || shouldResetHighlight;

      if (optionsChanged) {
        _setStateSafely(() {
          _visibleOptions = next;
          if (shouldResetHighlight) {
            _highlightedIndex = null;
            _scrollTargetIndex = null;
          }
        }, rebuildOverlay: true);
      } else {
        _visibleOptions = next;
        _scheduleOverlayRebuild();
      }
    } else {
      _visibleOptions = next;
      if (shouldResetHighlight) {
        _highlightedIndex = null;
        _keyboardNavigationActive = false;
        _scrollTargetIndex = null;
      }
    }
  }

  List<_DropdownOption> _computeVisibleOptions() {
    final List<_DropdownOption> result = [];
    final List<String> items = widget.items;
    final List<String> customNames = widget.customItemsNamesDisplayed;

    for (int i = 0; i < items.length; i++) {
      final String value = items[i];

      if (widget.excludeSelected && value == _currentSelection) {
        continue;
      }

      final String displayText =
          customNames.length > i && customNames[i].isNotEmpty
              ? customNames[i]
              : value;

      result.add(
        _DropdownOption(
          value: value,
          displayText: displayText,
          originalIndex: i,
        ),
      );
    }

    return result;
  }

  bool _optionsDiffer(List<_DropdownOption> next) {
    if (next.length != _visibleOptions.length) {
      return true;
    }

    for (int i = 0; i < next.length; i++) {
      final _DropdownOption previous = _visibleOptions[i];
      final _DropdownOption current = next[i];
      if (previous.value != current.value ||
          previous.displayText != current.displayText ||
          previous.originalIndex != current.originalIndex) {
        return true;
      }
    }

    return false;
  }

  bool _stringListEquals(List<String> a, List<String> b) {
    if (identical(a, b)) {
      return true;
    }

    if (a.length != b.length) {
      return false;
    }

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }

    return true;
  }

  void _ensureHighlightInitialized() {
    if (!_isExpanded || _visibleOptions.isEmpty) {
      return;
    }

    int? nextHighlight = _highlightedIndex;

    if (nextHighlight == null || nextHighlight >= _visibleOptions.length) {
      if (_currentSelection != null) {
        final int selectedIndex = _visibleOptions
            .indexWhere((option) => option.value == _currentSelection);
        if (selectedIndex != -1) {
          nextHighlight = selectedIndex;
        }
      }

      nextHighlight ??= 0;
    }

    if (_highlightedIndex != nextHighlight || !_keyboardNavigationActive) {
      _setStateSafely(() {
        _highlightedIndex = nextHighlight;
        _keyboardNavigationActive = true;
        // Set scrollTargetIndex to trigger scroll
        _scrollTargetIndex = nextHighlight;
      }, rebuildOverlay: true);
    } else if (_scrollTargetIndex != nextHighlight) {
      // If highlight didn't change but scroll target is different, update it
      _setStateSafely(() {
        _scrollTargetIndex = nextHighlight;
      }, rebuildOverlay: true);
    }
  }

  void _moveHighlight(int step) {
    // If focus was lost, ensure it is requested before handling navigation
    _requestFocusIfNeeded();
    if (!_isExpanded) {
      _openFromController();
      // After opening, schedule the highlight move for the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isExpanded && _visibleOptions.isNotEmpty) {
          final int currentIndex = _highlightedIndex ?? 0;
          int nextIndex = (currentIndex + step) % _visibleOptions.length;
          if (nextIndex < 0) {
            nextIndex += _visibleOptions.length;
          }
          _setStateSafely(() {
            _keyboardNavigationActive = true;
            _highlightedIndex = nextIndex;
            _scrollTargetIndex = nextIndex;
          }, rebuildOverlay: true);
        }
      });
      return;
    }

    if (_visibleOptions.isEmpty) {
      return;
    }

    final int currentIndex = _highlightedIndex ?? 0;
    int nextIndex = (currentIndex + step) % _visibleOptions.length;
    if (nextIndex < 0) {
      nextIndex += _visibleOptions.length;
    }

    _setStateSafely(() {
      _keyboardNavigationActive = true;
      _highlightedIndex = nextIndex;
      _scrollTargetIndex = nextIndex;
    }, rebuildOverlay: true);
  }

  void _selectHighlightedItem() {
    _requestFocusIfNeeded();
    if (!_isExpanded || _visibleOptions.isEmpty) {
      return;
    }

    final int index = _highlightedIndex ?? 0;
    if (index < 0 || index >= _visibleOptions.length) {
      return;
    }

    _selectItem(_visibleOptions[index].value);
  }

  void _setHighlightAtIndex(int originalIndex) {
    _requestFocusIfNeeded();
    // Map original index (index in widget.items) to visible overlay index
    final int visibleIndex =
        _visibleOptions.indexWhere((o) => o.originalIndex == originalIndex);
    if (visibleIndex == -1) {
      // Item not visible (could be excluded). If overlay is closed, open it to recompute.
      if (!_isExpanded) {
        _openFromController();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final int idx = _visibleOptions
              .indexWhere((o) => o.originalIndex == originalIndex);
          if (idx != -1) {
            _setStateSafely(() {
              _keyboardNavigationActive = true;
              _highlightedIndex = idx;
              _scrollTargetIndex = idx;
            }, rebuildOverlay: true);
          }
        });
      }
      return;
    }

    if (!_isExpanded) {
      _openFromController();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setStateSafely(() {
          _keyboardNavigationActive = true;
          _highlightedIndex = visibleIndex;
          _scrollTargetIndex = visibleIndex;
        }, rebuildOverlay: true);
      });
      return;
    }

    _setStateSafely(() {
      _keyboardNavigationActive = true;
      _highlightedIndex = visibleIndex;
      _scrollTargetIndex = visibleIndex;
    }, rebuildOverlay: true);
  }

  void _setHighlightForValue(String value) {
    _requestFocusIfNeeded();
    final int visibleIndex =
        _visibleOptions.indexWhere((o) => o.value == value);
    if (visibleIndex == -1) {
      if (!_isExpanded) {
        _openFromController();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final int idx = _visibleOptions.indexWhere((o) => o.value == value);
          if (idx != -1) {
            _setStateSafely(() {
              _keyboardNavigationActive = true;
              _highlightedIndex = idx;
              _scrollTargetIndex = idx;
            }, rebuildOverlay: true);
          }
        });
      }
      return;
    }

    if (!_isExpanded) {
      _openFromController();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setStateSafely(() {
          _keyboardNavigationActive = true;
          _highlightedIndex = visibleIndex;
          _scrollTargetIndex = visibleIndex;
        }, rebuildOverlay: true);
      });
      return;
    }

    _setStateSafely(() {
      _keyboardNavigationActive = true;
      _highlightedIndex = visibleIndex;
      _scrollTargetIndex = visibleIndex;
    }, rebuildOverlay: true);
  }

  void _selectByIndex(int originalIndex) {
    if (originalIndex < 0 || originalIndex >= widget.items.length) {
      return;
    }
    final String value = widget.items[originalIndex];
    _selectItem(value);
  }

  void _selectByValue(String value) {
    if (!widget.items.contains(value)) {
      return;
    }
    _selectItem(value);
  }

  void _selectNextItem() {
    final int currentIndex = _currentSelection != null
        ? widget.items.indexOf(_currentSelection!)
        : -1;
    final int nextIndex =
        currentIndex == -1 ? 0 : (currentIndex + 1) % widget.items.length;
    _selectItem(widget.items[nextIndex]);
  }

  void _selectPreviousItem() {
    final int currentIndex = _currentSelection != null
        ? widget.items.indexOf(_currentSelection!)
        : -1;
    int previousIndex = currentIndex == -1 ? 0 : currentIndex - 1;
    if (previousIndex < 0) {
      previousIndex = widget.items.length - 1;
    }
    _selectItem(widget.items[previousIndex]);
  }

  void _setPointerHighlight(int index) {
    if (!_isExpanded || index < 0 || index >= _visibleOptions.length) {
      return;
    }

    if (_highlightedIndex == index && _keyboardNavigationActive) {
      return;
    }

    _setStateSafely(() {
      _keyboardNavigationActive = true;
      _highlightedIndex = index;
      // Don't update _scrollTargetIndex on hover - only keyboard navigation should trigger autoscroll
    }, rebuildOverlay: true);
  }

  Widget _buildDropdownButton() {
    final SDropdownDecoration effectiveDecoration =
        SDropdownDecoration.defaultDecoration.merge(
      widget.decoration,
    );

    final SDropdownDecoration finalDecoration = effectiveDecoration.copyWith(
      closedFillColor:
          widget.closedFillColor ?? effectiveDecoration.closedFillColor,
      expandedFillColor:
          widget.expandedFillColor ?? effectiveDecoration.expandedFillColor,
      closedBorder: widget.closedBorder ?? effectiveDecoration.closedBorder,
      expandedBorder:
          widget.expandedBorder ?? effectiveDecoration.expandedBorder,
      closedBorderRadius:
          widget.closedBorderRadius ?? effectiveDecoration.closedBorderRadius,
      expandedBorderRadius: widget.expandedBorderRadius ??
          effectiveDecoration.expandedBorderRadius,
      headerStyle: widget.headerTextStyle ?? effectiveDecoration.headerStyle,
      hintStyle: widget.hintTextStyle ?? effectiveDecoration.hintStyle,
      listItemStyle: widget.itemTextStyle ?? effectiveDecoration.listItemStyle,
      closedSuffixIcon:
          widget.suffixIcon ?? effectiveDecoration.closedSuffixIcon,
      prefixIcon: widget.prefixIcon ?? effectiveDecoration.prefixIcon,
      closedHeaderPadding:
          widget.closedHeaderPadding ?? effectiveDecoration.closedHeaderPadding,
      expandedHeaderPadding: widget.expandedHeaderPadding ??
          effectiveDecoration.expandedHeaderPadding,
      itemsListPadding:
          widget.itemsListPadding ?? effectiveDecoration.itemsListPadding,
      listItemPadding:
          widget.listItemPadding ?? effectiveDecoration.listItemPadding,
      overlayHeight: widget.overlayHeight ?? effectiveDecoration.overlayHeight,
      maxLines: widget.maxLines,
    );

    return GestureDetector(
      onTap: _toggleDropdown,
      child: Container(
        padding: finalDecoration.closedHeaderPadding,
        decoration: BoxDecoration(
          color: _isExpanded
              ? finalDecoration.headerExpandedColor
              : finalDecoration.closedFillColor,
          border: _isExpanded
              ? finalDecoration.expandedBorder
              : finalDecoration.closedBorder,
          borderRadius: _isExpanded
              ? finalDecoration.expandedBorderRadius
              : finalDecoration.closedBorderRadius,
          boxShadow: _isExpanded
              ? finalDecoration.expandedShadow
              : finalDecoration.closedShadow,
        ),
        child: Row(
          children: [
            if (finalDecoration.prefixIcon != null) ...[
              finalDecoration.prefixIcon!,
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                widget.selectedItemText ??
                    _currentSelection ??
                    widget.hintText ??
                    'Select an option',
                style: _currentSelection != null
                    ? finalDecoration.headerStyle
                    : finalDecoration.hintStyle,
                maxLines: finalDecoration.maxLines ?? 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: _isExpanded ? 0.5 : 0.0,
              child: _isExpanded
                  ? (finalDecoration.expandedSuffixIcon ??
                      const Icon(Icons.keyboard_arrow_down, size: 20))
                  : (finalDecoration.closedSuffixIcon ??
                      const Icon(Icons.keyboard_arrow_down, size: 20)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay(Size buttonSize) {
    final SDropdownDecoration effectiveDecoration =
        SDropdownDecoration.defaultDecoration.merge(
      widget.decoration,
    );

    final SDropdownDecoration finalDecoration = effectiveDecoration.copyWith(
      overlayHeight: widget.overlayHeight ?? effectiveDecoration.overlayHeight,
      overlayWidth: widget.overlayWidth ?? effectiveDecoration.overlayWidth,
      expandedFillColor:
          widget.expandedFillColor ?? effectiveDecoration.expandedFillColor,
      expandedBorder:
          widget.expandedBorder ?? effectiveDecoration.expandedBorder,
      expandedBorderRadius: widget.expandedBorderRadius ??
          effectiveDecoration.expandedBorderRadius,
      itemsListPadding:
          widget.itemsListPadding ?? effectiveDecoration.itemsListPadding,
      listItemPadding:
          widget.listItemPadding ?? effectiveDecoration.listItemPadding,
      listItemStyle: widget.itemTextStyle ?? effectiveDecoration.listItemStyle,
      maxLines: widget.maxLines,
    );

    final double overlayWidth =
        widget.overlayWidth ?? widget.width ?? buttonSize.width;

    const double itemHeight = _itemExtent;
    final double topBottomPadding =
        finalDecoration.itemsListPadding?.vertical ?? 16.0;
    final double calculatedHeight =
        (_visibleOptions.length * itemHeight) + topBottomPadding;

    double overlayHeightValue;
    if (widget.overlayHeight != null) {
      overlayHeightValue = widget.overlayHeight!;
    } else if (finalDecoration.overlayHeight != null) {
      overlayHeightValue = finalDecoration.overlayHeight!;
    } else {
      overlayHeightValue = calculatedHeight;
    }

    if (overlayHeightValue > 170) {
      overlayHeightValue = 170;
    }

    return
        //Center widget to ensure TapRegion covers the entire screen
        //and to ensure the overlay maintains correct dimensions given
        Center(
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: Offset(0, buttonSize.height + 4),
        child: STweenAnimationBuilder<double>(
          key: ValueKey(_animationTrigger),
          tween: Tween<double>(begin: 0.0, end: _animationTrigger ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          builder: (context, animValue, child) {
            return Opacity(
              opacity: animValue,
              child: ClipRect(
                child: SizedBox(
                  width: overlayWidth,
                  height: overlayHeightValue * animValue,
                  child: Material(
                    color: Colors.transparent,
                    child: TapRegion(
                      groupId: tapRegionID,
                      onTapOutside: (event) {
                        // debugPrint('SDropdown: Tap outside detected');
                        if (widget.canCloseOutsideBounds) {
                          _closeWithoutSelection();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: finalDecoration.expandedFillColor,
                          border: finalDecoration.expandedBorder,
                          borderRadius: finalDecoration.expandedBorderRadius,
                          boxShadow: finalDecoration.expandedShadow ??
                              [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                        ),
                        child: IndexScrollListViewBuilder(
                          controller: _itemsScrollController,
                          padding: finalDecoration.itemsListPadding,
                          shrinkWrap: true,
                          itemCount: _visibleOptions.length,
                          indexToScrollTo: _scrollTargetIndex,
                          scrollAnimationDuration:
                              const Duration(milliseconds: 300),
                          onScrolledTo: (index) {
                            if (_scrollTargetIndex != index) {
                              _scrollTargetIndex = index;
                            }
                          },
                          autoScrollMaxFrameDelay:
                              widget.autoScrollMaxFrameDelay,
                          autoScrollEndOfFrameDelay:
                              widget.autoScrollEndOfFrameDelay,
                          physics: const BouncingScrollPhysics(),
                          showScrollbar: true,
                          scrollbarThumbVisibility: true,
                          scrollbarTrackVisibility: true,
                          suppressPlatformScrollbars: true,
                          scrollAlignment: 0.2,
                          itemBuilder: (context, index) {
                            final _DropdownOption option =
                                _visibleOptions[index];
                            final bool isSelected =
                                option.value == _currentSelection;
                            final bool isHighlighted =
                                _keyboardNavigationActive &&
                                    _highlightedIndex == index;

                            final TextStyle itemStyle =
                                widget.itemSpecificStyles?[option.value] ??
                                    finalDecoration.listItemStyle ??
                                    const TextStyle(fontSize: 14);

                            final ColorScheme colorScheme =
                                Theme.of(context).colorScheme;
                            final bool isActiveSelection =
                                isSelected && isHighlighted;
                            final Color highlightColor = colorScheme.primary
                                .withValues(
                                    alpha: isActiveSelection ? 0.3 : 0.22);
                            final Color selectedColor = colorScheme.primary
                                .withValues(
                                    alpha: isActiveSelection ? 0.18 : 0.08);
                            final Color resolvedBackground = isSelected
                                ? highlightColor
                                : isHighlighted
                                    ? selectedColor
                                    : Colors.transparent;
                            final Color resolvedBorder = isSelected
                                ? colorScheme.primary.withValues(
                                    alpha: isActiveSelection ? 0.75 : 0.55)
                                : Colors.transparent;

                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) => _setPointerHighlight(index),
                              onHover: (_) => _setPointerHighlight(index),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _selectItem(option.value),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 120),
                                  curve: Curves.easeOut,
                                  padding: finalDecoration.listItemPadding,
                                  decoration: BoxDecoration(
                                    color: resolvedBackground,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: resolvedBorder,
                                      width: isSelected ? 1 : 0,
                                    ),
                                  ),
                                  child: Text(
                                    option.displayText,
                                    style: itemStyle.copyWith(
                                      fontWeight: isSelected || isHighlighted
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                    maxLines: finalDecoration.maxLines ?? 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Extension to provide additional utility methods
extension SDropdownExtension on SDropdown {
  /// Creates a copy of this dropdown with modified properties
  SDropdown copyWith({
    double? width,
    double? height,
    double? overlayHeight,
    double? overlayWidth,
    double? scale,
    List<String>? items,
    String? selectedItem,
    String? initialItem,
    String? hintText,
    Function(String?)? onChanged,
    TextStyle? itemTextStyle,
    TextStyle? headerTextStyle,
    TextStyle? hintTextStyle,
    Map<String, TextStyle>? itemSpecificStyles,
    Color? closedFillColor,
    Color? expandedFillColor,
    Border? closedBorder,
    Border? expandedBorder,
    BorderRadius? closedBorderRadius,
    BorderRadius? expandedBorderRadius,
    EdgeInsets? closedHeaderPadding,
    EdgeInsets? expandedHeaderPadding,
    EdgeInsets? itemsListPadding,
    EdgeInsets? listItemPadding,
    ScrollController? itemsScrollController,
    bool? excludeSelected,
    bool? canCloseOutsideBounds,
    bool? enabled,
    AlignmentGeometry? alignment,
    int? maxLines,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? Function(String?)? validator,
    bool? validateOnChange,
    SDropdownDecoration? decoration,
    SDropdownController? controller,
    bool? useKeyboardNavigation,
    FocusNode? focusNode,
    bool? requestFocusOnInit,
  }) {
    return SDropdown(
      key: key,
      items: items ?? this.items,
      width: width ?? this.width,
      height: height ?? this.height,
      overlayHeight: overlayHeight ?? this.overlayHeight,
      overlayWidth: overlayWidth ?? this.overlayWidth,
      scale: scale ?? this.scale,
      selectedItem: selectedItem ?? this.selectedItem,
      initialItem: initialItem ?? this.initialItem,
      hintText: hintText ?? this.hintText,
      onChanged: onChanged ?? this.onChanged,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
      itemSpecificStyles: itemSpecificStyles ?? this.itemSpecificStyles,
      closedFillColor: closedFillColor ?? this.closedFillColor,
      expandedFillColor: expandedFillColor ?? this.expandedFillColor,
      closedBorder: closedBorder ?? this.closedBorder,
      expandedBorder: expandedBorder ?? this.expandedBorder,
      closedBorderRadius: closedBorderRadius ?? this.closedBorderRadius,
      expandedBorderRadius: expandedBorderRadius ?? this.expandedBorderRadius,
      closedHeaderPadding: closedHeaderPadding ?? this.closedHeaderPadding,
      expandedHeaderPadding:
          expandedHeaderPadding ?? this.expandedHeaderPadding,
      itemsListPadding: itemsListPadding ?? this.itemsListPadding,
      listItemPadding: listItemPadding ?? this.listItemPadding,
      itemsScrollController:
          itemsScrollController ?? this.itemsScrollController,
      excludeSelected: excludeSelected ?? this.excludeSelected,
      canCloseOutsideBounds:
          canCloseOutsideBounds ?? this.canCloseOutsideBounds,
      enabled: enabled ?? this.enabled,
      alignment: alignment ?? this.alignment,
      maxLines: maxLines ?? this.maxLines,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      validator: validator ?? this.validator,
      validateOnChange: validateOnChange ?? this.validateOnChange,
      decoration: decoration ?? this.decoration,
      controller: controller ?? this.controller,
      headerExpandedColor: headerExpandedColor,
      selectedItemText: selectedItemText,
      customItemsNamesDisplayed: customItemsNamesDisplayed,
      useKeyboardNavigation:
          useKeyboardNavigation ?? this.useKeyboardNavigation,
      focusNode: focusNode ?? this.focusNode,
      requestFocusOnInit: requestFocusOnInit ?? this.requestFocusOnInit,
    );
  }
}

class _DropdownOption {
  const _DropdownOption({
    required this.value,
    required this.displayText,
    required this.originalIndex,
  });

  final String value;
  final String displayText;
  final int originalIndex;
}
