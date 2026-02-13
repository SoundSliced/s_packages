import 'package:s_packages/s_packages.dart';

part 's_expendable_handles.dart';

// ---------------------------------------------------------------------------
// PUBLIC API
// ---------------------------------------------------------------------------

/// Direction in which the menu expands.
enum ExpandDirection {
  /// Expands horizontally to the left
  left,

  /// Expands horizontally to the right
  right,

  /// Expands vertically upward
  up,

  /// Expands vertically downward
  down,

  /// Automatically determines direction based on screen position
  auto,
}

/// A pill-shaped expandable menu that reveals a list of icon items.
///
/// The menu starts collapsed showing only a toggle icon. When tapped it expands
/// to display [items] and a close button. Every property is optional except
/// [items].
class SExpandableMenu extends StatefulWidget {
  /// Width used for the collapsed state and as the slot width per visible item.
  final double width;

  /// Height of the menu (also used for the item container height).
  final double height;

  /// Items displayed when the menu is expanded.
  final List<SExpandableItem> items;

  /// Background color of the pill container.
  final Color backgroundColor;

  /// Color applied to all icons (hamburger/arrow and item icons).
  final Color iconColor;

  /// Optional background color for each item container.
  final Color? itemContainerColor;

  /// Duration of expand/collapse animation.
  final Duration animationDuration;

  /// Curve for expand/collapse animation.
  final Curve animationCurve;

  /// Direction in which the menu expands.
  /// Defaults to [ExpandDirection.auto] for screen-aware positioning.
  final ExpandDirection expandDirection;

  /// Callback when the menu expansion state changes.
  final void Function(bool isExpanded)? onExpansionChanged;

  const SExpandableMenu({
    super.key,
    this.width = 50.0,
    this.height = 70.0,
    required this.items,
    this.backgroundColor = const Color(0xFF4B5042),
    this.iconColor = Colors.white,
    this.itemContainerColor,
    this.animationDuration = const Duration(milliseconds: 400),
    this.animationCurve = Curves.easeOutCubic,
    this.expandDirection = ExpandDirection.auto,
    this.onExpansionChanged,
  });

  @override
  State<SExpandableMenu> createState() => _SExpandableMenuState();
}

// ---------------------------------------------------------------------------
// STATE
// ---------------------------------------------------------------------------

class _SExpandableMenuState extends State<SExpandableMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  bool _isExpanded = false;
  bool? _shouldReverseHandleAnimation;
  ExpandDirection _computedDirection = ExpandDirection.left;

  // Scroll controller for the item list.
  final ScrollController _scrollController = ScrollController();

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  /// Maximum number of visible item slots before scrolling is needed.
  static const int _maxVisibleSlots = 5;

  /// Number of visible item slots (uses actual item count, capped at max).
  int get _slotCount => widget.items.length.clamp(1, _maxVisibleSlots);

  /// Full width when expanded (handle + items + close button).
  double get _expandedWidth =>
      widget.width + ((_itemSize + 6) * _slotCount) + widget.width;

  /// Size of each item icon container.
  double get _itemSize => widget.height * 0.75;

  /// Border width of the container.
  static const double _borderWidth = 1.0;

  /// Internal width accounting for border.
  double get _innerWidth => widget.width - (_borderWidth * 2);

  /// Internal height accounting for border.
  double get _innerHeight => widget.height - (_borderWidth * 2);

  /// Whether the menu expands horizontally.
  bool get _isHorizontal =>
      _computedDirection == ExpandDirection.left ||
      _computedDirection == ExpandDirection.right;

  /// Compute the best expansion direction based on screen position.
  ExpandDirection _computeDirection(BuildContext context) {
    if (widget.expandDirection != ExpandDirection.auto) {
      return widget.expandDirection;
    }

    // Auto mode always defaults to left
    return ExpandDirection.left;
  }

  /// Full height when expanded vertically (handle + items + close button).
  double get _expandedHeight =>
      widget.height + ((_itemSize + 6) * _slotCount) + widget.height;

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
      reverseCurve: widget.animationCurve.flipped,
    );
  }

  @override
  void didUpdateWidget(covariant SExpandableMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationDuration != oldWidget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }
    // If expand direction changes, update computed direction and collapse if expanded
    if (widget.expandDirection != oldWidget.expandDirection) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _computedDirection = _computeDirection(context);
          if (_isExpanded) {
            _controller.reverse();
            _isExpanded = false;
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  void _toggle() {
    setState(() {
      if (!_isExpanded) {
        _computedDirection = _computeDirection(context);
      }

      _isExpanded = !_isExpanded;
      _controller.toggle();
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  void _collapse() {
    if (_isExpanded) {
      _toggle();
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, _) {
        final double t = _expandAnimation.value;

        if (_isHorizontal) {
          return _HorizontalExpandableMenu(
            width: widget.width,
            height: widget.height,
            backgroundColor: widget.backgroundColor,
            iconColor: widget.iconColor,
            itemContainerColor: widget.itemContainerColor,
            items: widget.items,
            innerWidth: _innerWidth,
            innerHeight: _innerHeight,
            expandedWidth: _expandedWidth,
            itemSize: _itemSize,
            isExpanded: _isExpanded,
            computedDirection: _computedDirection,
            shouldReverseHandleAnimation: _shouldReverseHandleAnimation,
            scrollController: _scrollController,
            animationProgress: t,
            onHamburgerStateAnimationCompleted: (_) {
              setState(() => _shouldReverseHandleAnimation = null);
            },
            onToggle: _toggle,
            onCollapse: _collapse,
          );
        } else {
          return _VerticalExpandableMenu(
            width: widget.width,
            height: widget.height,
            backgroundColor: widget.backgroundColor,
            iconColor: widget.iconColor,
            itemContainerColor: widget.itemContainerColor,
            items: widget.items,
            innerWidth: _innerWidth,
            innerHeight: _innerHeight,
            expandedHeight: _expandedHeight,
            itemSize: _itemSize,
            isExpanded: _isExpanded,
            computedDirection: _computedDirection,
            shouldReverseHandleAnimation: _shouldReverseHandleAnimation,
            scrollController: _scrollController,
            animationProgress: t,
            onHamburgerStateAnimationCompleted: (_) {
              setState(() => _shouldReverseHandleAnimation = null);
            },
            onToggle: _toggle,
            onCollapse: _collapse,
          );
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// INTERNAL WIDGETS
// ---------------------------------------------------------------------------

class _HorizontalExpandableMenu extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color iconColor;
  final Color? itemContainerColor;
  final List<SExpandableItem> items;
  final double innerWidth;
  final double innerHeight;
  final double expandedWidth;
  final double itemSize;
  final bool isExpanded;
  final ExpandDirection computedDirection;
  final bool? shouldReverseHandleAnimation;
  final ScrollController scrollController;
  final double animationProgress;
  final Function(bool?) onHamburgerStateAnimationCompleted;
  final VoidCallback onToggle;
  final VoidCallback onCollapse;

  const _HorizontalExpandableMenu({
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.iconColor,
    this.itemContainerColor,
    required this.items,
    required this.innerWidth,
    required this.innerHeight,
    required this.expandedWidth,
    required this.itemSize,
    required this.isExpanded,
    required this.computedDirection,
    this.shouldReverseHandleAnimation,
    required this.scrollController,
    required this.animationProgress,
    required this.onHamburgerStateAnimationCompleted,
    required this.onToggle,
    required this.onCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final double containerWidth =
        width + (expandedWidth - width) * animationProgress;
    final bool expandsRight = computedDirection == ExpandDirection.right;

    return Container(
      width: containerWidth,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height),
        border: Border.all(
          color: backgroundColor.darken(),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        textDirection: expandsRight ? TextDirection.rtl : TextDirection.ltr,
        children: [
          // Handle (left for expandsLeft, right for expandsRight)
          _ExpandableHandle(
            innerWidth: innerWidth,
            innerHeight: innerHeight,
            iconColor: iconColor,
            isExpanded: isExpanded,
            expandsRight: expandsRight,
            shouldReverseHandleAnimation: shouldReverseHandleAnimation,
            onHamburgerStateAnimationCompleted:
                onHamburgerStateAnimationCompleted,
            onTap: onToggle,
          ),

          // Item list (only when animating or expanded)
          if (animationProgress > 0)
            Expanded(
              child: _ExpandableItemList(
                innerWidth: innerWidth,
                innerHeight: innerHeight,
                items: items,
                itemSize: itemSize,
                iconColor: iconColor,
                itemContainerColor: itemContainerColor,
                scrollController: scrollController,
                isHorizontal: true,
                animationProgress: animationProgress,
              ),
            ),

          // Close button (fades in at the end of the animation)
          if (animationProgress > 0.85)
            _ExpandableCloseButton(
              innerWidth: innerWidth,
              innerHeight: innerHeight,
              iconColor: iconColor,
              animationProgress: animationProgress,
              expandsRight: expandsRight,
              onTap: onCollapse,
            ),
        ],
      ),
    );
  }
}

class _VerticalExpandableMenu extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color iconColor;
  final Color? itemContainerColor;
  final List<SExpandableItem> items;
  final double innerWidth;
  final double innerHeight;
  final double expandedHeight;
  final double itemSize;
  final bool isExpanded;
  final ExpandDirection computedDirection;
  final bool? shouldReverseHandleAnimation;
  final ScrollController scrollController;
  final double animationProgress;
  final Function(bool?) onHamburgerStateAnimationCompleted;
  final VoidCallback onToggle;
  final VoidCallback onCollapse;

  const _VerticalExpandableMenu({
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.iconColor,
    this.itemContainerColor,
    required this.items,
    required this.innerWidth,
    required this.innerHeight,
    required this.expandedHeight,
    required this.itemSize,
    required this.isExpanded,
    required this.computedDirection,
    this.shouldReverseHandleAnimation,
    required this.scrollController,
    required this.animationProgress,
    required this.onHamburgerStateAnimationCompleted,
    required this.onToggle,
    required this.onCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final double containerHeight =
        height + (expandedHeight - height) * animationProgress;
    final bool expandsDown = computedDirection == ExpandDirection.down;

    return Container(
      width: width,
      height: containerHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(width),
        border: Border.all(
          color: backgroundColor.darken(),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        verticalDirection:
            expandsDown ? VerticalDirection.down : VerticalDirection.up,
        children: [
          // Close button (fades in at the end of the animation)
          if (animationProgress > 0.85)
            _ExpandableCloseButton(
              innerWidth: innerWidth,
              innerHeight: innerHeight,
              iconColor: iconColor,
              animationProgress: animationProgress,
              expandsDown: expandsDown,
              onTap: onCollapse,
            ),

          // Item list (only when animating or expanded)
          if (animationProgress > 0)
            Expanded(
              child: _ExpandableItemList(
                innerWidth: innerWidth,
                innerHeight: innerHeight,
                items: items,
                itemSize: itemSize,
                iconColor: iconColor,
                itemContainerColor: itemContainerColor,
                scrollController: scrollController,
                isHorizontal: false,
                animationProgress: animationProgress,
              ),
            ),

          // Handle
          _ExpandableHandle(
            innerWidth: innerWidth,
            innerHeight: innerHeight,
            iconColor: iconColor,
            isExpanded: isExpanded,
            expandsDown: expandsDown,
            shouldReverseHandleAnimation: shouldReverseHandleAnimation,
            onHamburgerStateAnimationCompleted:
                onHamburgerStateAnimationCompleted,
            onTap: onToggle,
          ),
        ],
      ),
    );
  }
}

class _ExpandableHandle extends StatelessWidget {
  final double innerWidth;
  final double innerHeight;
  final Color iconColor;
  final bool isExpanded;
  final bool? expandsRight;
  final bool? expandsDown;
  final bool? shouldReverseHandleAnimation;
  final Function(bool?) onHamburgerStateAnimationCompleted;
  final VoidCallback onTap;

  const _ExpandableHandle({
    required this.innerWidth,
    required this.innerHeight,
    required this.iconColor,
    required this.isExpanded,
    this.expandsRight,
    this.expandsDown,
    this.shouldReverseHandleAnimation,
    required this.onHamburgerStateAnimationCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: innerWidth,
      height: innerHeight,
      child: SExpandableHandles(
        width: innerWidth,
        height: innerHeight,
        iconColor: iconColor,
        isExpanded: isExpanded,
        expandsRight: expandsRight,
        expandsDown: expandsDown,
        shoulAutodReverseHamburgerAnimationWhenComplete:
            shouldReverseHandleAnimation,
        onHamburgerStateAnimationCompleted: onHamburgerStateAnimationCompleted,
        onTap: onTap,
      ),
    );
  }
}

class _ExpandableItemList extends StatelessWidget {
  final double innerWidth;
  final double innerHeight;
  final List<SExpandableItem> items;
  final double itemSize;
  final Color iconColor;
  final Color? itemContainerColor;
  final ScrollController scrollController;
  final bool isHorizontal;
  final double animationProgress;

  const _ExpandableItemList({
    required this.innerWidth,
    required this.innerHeight,
    required this.items,
    required this.itemSize,
    required this.iconColor,
    this.itemContainerColor,
    required this.scrollController,
    required this.isHorizontal,
    required this.animationProgress,
  });

  @override
  Widget build(BuildContext context) {
    // For vertical layouts, reverse items when RTL is active
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;
    final List<SExpandableItem> displayItems =
        (!isHorizontal && isRTL) ? items.reversed.toList() : items;

    if (isHorizontal) {
      return SizedBox(
        height: innerHeight,
        child: Directionality(
          textDirection: Directionality.of(context),
          child: RepaintBoundary(
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: displayItems.length,
              itemBuilder: (context, index) => _ExpandableMenuItem(
                item: displayItems[index],
                index: index,
                itemSize: itemSize,
                iconColor: iconColor,
                itemContainerColor: itemContainerColor,
                isHorizontal: isHorizontal,
                animationProgress: animationProgress,
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: innerWidth,
        child: Directionality(
          textDirection: Directionality.of(context),
          child: RepaintBoundary(
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: displayItems.length,
              itemBuilder: (context, index) => _ExpandableMenuItem(
                item: displayItems[index],
                index: index,
                itemSize: itemSize,
                iconColor: iconColor,
                itemContainerColor: itemContainerColor,
                isHorizontal: isHorizontal,
                animationProgress: animationProgress,
              ),
            ),
          ),
        ),
      );
    }
  }
}

class _ExpandableMenuItem extends StatelessWidget {
  final SExpandableItem item;
  final int index;
  final double itemSize;
  final Color iconColor;
  final Color? itemContainerColor;
  final bool isHorizontal;
  final double animationProgress;

  const _ExpandableMenuItem({
    required this.item,
    required this.index,
    required this.itemSize,
    required this.iconColor,
    this.itemContainerColor,
    required this.isHorizontal,
    required this.animationProgress,
  });

  @override
  Widget build(BuildContext context) {
    // Stagger each item's appearance.
    final double start = 0.15 + index * 0.06;
    final double end = (start + 0.35).clamp(0.0, 1.0);
    final double rawT =
        ((animationProgress - start) / (end - start)).clamp(0.0, 1.0);
    final double itemT = Curves.easeOutCubic.transform(rawT);

    final Color containerColor =
        itemContainerColor ?? Colors.white.withValues(alpha: 0.4);

    Widget child = Opacity(
      opacity: itemT,
      child: Transform.scale(
        scale: 0.92 + 0.08 * itemT,
        alignment: Alignment.center,
        child: SButton(
          onTap: item.disabled ? null : (pos) => item.onTap?.call(pos),
          splashColor: containerColor,
          child: Center(
            child: Container(
              width: itemSize,
              height: itemSize,
              margin: isHorizontal
                  ? const EdgeInsets.symmetric(horizontal: 3)
                  : const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Icon(
                item.icon,
                color: item.disabled
                    ? iconColor.withValues(alpha: 0.38)
                    : iconColor,
                size: item.size ?? itemSize * 0.9,
              ),
            ),
          ),
        ),
      ),
    );

    if (item.tooltip != null) {
      child = Tooltip(message: item.tooltip!, child: child);
    }

    return child;
  }
}

class _ExpandableCloseButton extends StatelessWidget {
  final double innerWidth;
  final double innerHeight;
  final Color iconColor;
  final double animationProgress;
  final bool? expandsRight;
  final bool? expandsDown;
  final VoidCallback onTap;

  const _ExpandableCloseButton({
    required this.innerWidth,
    required this.innerHeight,
    required this.iconColor,
    required this.animationProgress,
    this.expandsRight,
    this.expandsDown,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Fade in during the last 15 % of the animation.
    final double opacity = ((animationProgress - 0.85) / 0.15).clamp(0.0, 1.0);

    IconData icon;
    if (expandsRight != null) {
      icon = expandsRight!
          ? Icons.keyboard_arrow_right_rounded
          : Icons.keyboard_arrow_left_rounded;
    } else if (expandsDown != null) {
      icon = expandsDown!
          ? Icons.keyboard_arrow_down_rounded
          : Icons.keyboard_arrow_up_rounded;
    } else {
      icon = Icons.keyboard_arrow_right_rounded;
    }

    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: innerWidth,
        height: innerHeight,
        child: SButton(
          delay: const Duration(milliseconds: 200),
          splashColor: Colors.amber,
          isCircleButton: true,
          onTap: (_) => onTap(),
          child: Icon(
            icon,
            color: iconColor,
            size: innerHeight * 0.7,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ITEM MODEL
// ---------------------------------------------------------------------------

/// Represents an icon item in [SExpandableMenu].
class SExpandableItem {
  /// The icon to display.
  final IconData icon;

  /// Optional size override for the icon.
  final double? size;

  /// Callback invoked when the item is tapped.
  final void Function(Offset position)? onTap;

  /// Optional tooltip shown on long press or hover.
  final String? tooltip;

  /// Whether this item is disabled (grayed out, non-interactive).
  final bool disabled;

  SExpandableItem({
    required this.icon,
    this.size,
    this.onTap,
    this.tooltip,
    this.disabled = false,
  });
}
