import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:s_packages/s_packages.dart';

/// A customizable and responsive sidebar widget for Flutter applications.
///
/// The SSideBar provides a beautiful, animated sidebar with extensive customization
/// options including collapsible design, badge support, tooltips, and adaptive layouts.
///
/// ## Features
///
/// - **Collapsible**: Toggle between expanded and minimized states
/// - **Adaptive Layout**: Automatically adjusts button size based on available space
/// - **Badge Support**: Display notifications and counts on menu items
/// - **Tooltips**: Show helpful tooltips when minimized
/// - **Smooth Animations**: Configurable animation curves and durations
/// - **Accessibility**: Built-in semantics and keyboard navigation
/// - **Customizable**: Extensive styling options for colors, sizes, and spacing
///
/// ## Basic Usage
///
/// ```dart
/// SSideBar(
///   sidebarItems: [
///     SSideBarItem(
///       iconSelected: Icons.home,
///       iconUnselected: Icons.home_outlined,
///       title: 'Home',
///     ),
///     SSideBarItem(
///       iconSelected: Icons.settings,
///       iconUnselected: Icons.settings_outlined,
///       title: 'Settings',
///     ),
///   ],
///   onTapForAllTabButtons: (index) {
///     print('Selected item: $index');
///   },
/// )
/// ```
///
/// ## Adaptive Layout
///
/// The sidebar intelligently adapts to available space:
/// - **Plenty of space**: Minimize button expands to fill remaining vertical space
/// - **Constrained space**: Minimize button takes minimal space at bottom
/// - **Items scrolling**: Sidebar items scroll when content exceeds height
///
/// ## Customization
///
/// ```dart
/// SSideBar(
///   // Colors
///   sideBarColor: Color(0xff1D1D1D),
///   selectedIconColor: Colors.white,
///   unselectedIconColor: Color(0xffA0A5A9),
///   selectedTextColor: Colors.white,
///   unSelectedTextColor: Color(0xffA0A5A9),
///   selectedIconBackgroundColor: Color(0xff323232),
///
///   // Dimensions
///   sideBarWidth: 240,
///   sideBarSmallWidth: 84,
///   sideBarHeight: 600, // null for full height
///   borderRadius: 20,
///   sideBarItemHeight: 48,
///
///   // Behavior
///   isMinimized: false,
///   compactMode: false,
///   settingsDivider: true,
///   showTooltipsWhenMinimized: true,
///   preSelectedItemIndex: 0,
///
///   // Callbacks
///   minimizeButtonOnTap: (isMinimized) {
///     print('Sidebar minimized: $isMinimized');
///   },
/// )
/// ```
class SSideBar extends StatefulWidget {
  /// Called when a sidebar item is tapped, providing its index.
  final ValueChanged<int>? onTapForAllTabButtons;

  /// Animation durations for the sidebar resize and floating effects.
  final Duration sideBarAnimationDuration, floatingAnimationDuration;

  /// Colors used to style the sidebar and its interactive states.
  final Color sideBarColor,
      selectedIconBackgroundColor,
      selectedIconColor,
      unselectedIconColor,
      dividerColor,
      hoverColor,
      splashColor,
      highlightColor,
      unSelectedTextColor,
      selectedTextColor;

  /// Optional color for the minimize button; defaults to a semi-transparent blue if not provided.
  final Color? minimizeButtonColor;

  /// Size and shape configuration for the sidebar container and items.
  final double borderRadius, sideBarWidth, sideBarSmallWidth, sideBarItemHeight;

  /// Optional fixed height for the sidebar; defaults to full available height.
  final double? sideBarHeight;

  /// Optional custom border for the sidebar container.
  final BoxBorder? sideBarBorder;

  /// Items displayed in the sidebar menu.
  final List<SSideBarItem> sidebarItems;

  /// Per-item enablement flags for tap handling.
  final List<bool> shouldTapItems;

  /// Whether to show a divider before the last items and start minimized.
  final bool settingsDivider, isMinimized, ignoreDifferenceOnFlutterWeb;

  /// Whether to use compact spacing and smaller item heights.
  final bool compactMode;

  /// Whether to show tooltips while the sidebar is minimized.
  final bool showTooltipsWhenMinimized;

  /// Curve used for width/position animations.
  final Curve curve;

  /// Text style for sidebar item labels.
  final TextStyle textStyle;

  /// Optional logo widget displayed at the top of the sidebar.
  final Widget? logo;

  /// Optional custom header widget displayed below the logo.
  final Widget? header;

  /// Optional custom footer widget displayed at the bottom of the sidebar (above collapse button).
  final Widget? footer;

  /// Selection indicator style for active item.
  final SideBarIndicatorStyle indicatorStyle;

  /// Style of the minimize toggle button.
  final SideBarMinimizeButtonStyle minimizeButtonStyle;

  /// Whether to show a modern shadow around the sidebar.
  final bool showShadow;

  /// Whether to animate translation and scale on hover.
  final bool hoverAnimation;

  /// Custom decoration for the active selected item.
  final Decoration? selectedItemDecoration;

  /// Custom decoration for unselected items.
  final Decoration? unselectedItemDecoration;

  /// Optional custom padding for each item.
  final EdgeInsetsGeometry? itemPadding;

  /// Optional initial selection index.
  final int? preSelectedItemIndex;

  /// Optional size for the minimize button icon; defaults to 60.
  final double? minimizeButtonIconSize;

  /// Callback invoked when the minimize button is tapped.
  final Function(bool isMinimized)? minimizeButtonOnTap;

  /// Horizontal padding inside each sidebar item.
  final double itemHorizontalPadding;

  /// Spacing between the icon and the label text.
  final double itemIconTextSpacing;

  /// Corner radius for item highlight/selection background.
  final double itemBorderRadius;

  /// Creates a configurable sidebar widget.
  const SSideBar({
    super.key,
    this.sideBarColor = const Color(0xff1D1D1D),
    this.selectedIconBackgroundColor = const Color(0xff323232),
    this.unSelectedTextColor = const Color(0xffA0A5A9),
    this.selectedTextColor = Colors.white,
    this.selectedIconColor = Colors.white,
    this.unselectedIconColor = const Color(0xffA0A5A9),
    this.hoverColor = Colors.black38,
    this.splashColor = Colors.black87,
    this.highlightColor = Colors.black,
    this.minimizeButtonColor,
    this.borderRadius = 20,
    this.sideBarWidth = 240,
    this.sideBarHeight,
    this.sideBarSmallWidth = 84,
    this.settingsDivider = true,
    this.isMinimized = false,
    this.compactMode = false,
    this.showTooltipsWhenMinimized = true,
    this.curve = Curves.easeOutExpo,
    this.sideBarAnimationDuration = const Duration(milliseconds: 700),
    this.floatingAnimationDuration = const Duration(milliseconds: 300),
    this.dividerColor = const Color(0xff929292),
    this.textStyle =
        const TextStyle(fontFamily: "SFPro", fontSize: 16, color: Colors.white),
    this.sideBarItemHeight = 48,
    this.itemHorizontalPadding = 10,
    this.itemIconTextSpacing = 12,
    this.itemBorderRadius = 10,
    this.minimizeButtonIconSize,
    this.sideBarBorder,
    required this.sidebarItems,
    required this.onTapForAllTabButtons,
    this.logo,
    this.header,
    this.footer,
    this.indicatorStyle = SideBarIndicatorStyle.leftLine,
    this.minimizeButtonStyle = SideBarMinimizeButtonStyle.bottomRow,
    this.showShadow = true,
    this.hoverAnimation = true,
    this.selectedItemDecoration,
    this.unselectedItemDecoration,
    this.itemPadding,
    this.preSelectedItemIndex,
    this.ignoreDifferenceOnFlutterWeb = false,
    this.minimizeButtonOnTap,
    this.shouldTapItems = const [],
  });

  @override
  State<SSideBar> createState() => _SSideBarState();
}

class _SSideBarState extends State<SSideBar> {
  int selectedItemIndex = 0;
  bool minimize = true;

  List<bool> shouldTapItems = [];

  @override
  void initState() {
    assert(widget.sidebarItems.isNotEmpty, "Side bar items can't be empty");
    if (widget.sidebarItems.isEmpty) {
      throw ArgumentError("Side bar items can't be empty");
    }

    minimize = widget.isMinimized;
    selectedItemIndex = _safeIndex(widget.preSelectedItemIndex);
    shouldTapItems = widget.shouldTapItems;

    super.initState();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Compare oldWidget to widget and respond to changes
    minimize = widget.isMinimized;
    selectedItemIndex = _safeIndex(widget.preSelectedItemIndex);
    shouldTapItems = widget.shouldTapItems;
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _safeIndex(int? index) {
    final maxIndex = widget.sidebarItems.length - 1;
    if (index == null) {
      return 0;
    }

    if (index < 0) {
      return 0;
    }

    if (index > maxIndex) {
      return maxIndex;
    }

    return index;
  }

  ///Animation creator function
  void moveToNewIndex(int index) {
    if (index == selectedItemIndex) {
      return;
    }

    setState(() {
      selectedItemIndex = index;
    });

    widget.onTapForAllTabButtons?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final double? sidebarHeight = widget.sideBarHeight;
    final double effectiveItemHeight = widget.compactMode
        ? (widget.sideBarItemHeight - 4)
            .clamp(24.0, widget.sideBarItemHeight)
            .toDouble()
        : widget.sideBarItemHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate estimated height needed for all items
        final int itemCount = widget.sidebarItems.length;
        final double separatorHeight = widget.compactMode ? 4 : 8;
        final double dividerHeight =
            widget.settingsDivider && itemCount > 2 ? 12 : 0;
        final double topPadding = 20.0;
        final double logoHeight = widget.logo != null ? 60.0 : 0.0;
        final double headerHeight = widget.header != null ? 50.0 : 0.0;
        final double footerHeight = widget.footer != null ? 60.0 : 0.0;
        final double buttonMinHeight = 50.0;

        final double estimatedItemsHeight = (itemCount * effectiveItemHeight) +
            ((itemCount - 1) * separatorHeight) +
            dividerHeight +
            topPadding +
            (itemCount > 0 ? (widget.compactMode ? 14 : 20) : 0);

        final double totalNeededHeight =
            logoHeight + headerHeight + estimatedItemsHeight + footerHeight + buttonMinHeight;

        // Use the provided height or the maximum available height
        double effectiveHeight = sidebarHeight ?? constraints.maxHeight;
        if (effectiveHeight.isInfinite) {
          effectiveHeight = totalNeededHeight;
        }

        final bool hasExtraSpace = effectiveHeight > totalNeededHeight;

        Widget bottomMinimizeButton;
        if (widget.minimizeButtonStyle == SideBarMinimizeButtonStyle.legacy) {
          bottomMinimizeButton = _buildLegacyMinimizeButton(hasExtraSpace);
        } else {
          bottomMinimizeButton = _buildModernBottomMinimizeButton();
        }

        Widget sidebarBody = AnimatedContainer(
          duration: widget.sideBarAnimationDuration,
          curve: widget.curve,
          alignment: Alignment.topCenter,
          transformAlignment: Alignment.centerRight,
          height: effectiveHeight,
          constraints: BoxConstraints(
            maxWidth: !minimize ? widget.sideBarWidth : widget.sideBarSmallWidth,
            minWidth: !minimize ? widget.sideBarWidth : widget.sideBarSmallWidth,
          ),
          decoration: BoxDecoration(
            color: widget.sideBarColor,
            border: widget.sideBarBorder ??
                Border.all(color: widget.sideBarColor.darken(0.1)),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.showShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Logo
              if (widget.logo != null)
                Align(
                  child: Padding(
                    padding: Pad(top: 20),
                    child: widget.logo,
                  ),
                ),

              // Header
              if (widget.header != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: _buildCollapsibleSection(widget.header!),
                ),

              // Sidebar Items
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: minimize ? Pad.zero : Pad(left: 20, right: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = widget.sidebarItems[index];
                              return Column(
                                children: [
                                  Padding(
                                    padding: index == widget.sidebarItems.length - 1
                                        ? Pad(top: widget.compactMode ? 14 : 20)
                                        : Pad.zero,
                                    child: _SideBarItemWidget(
                                      itemIndex: index,
                                      selectedItemIndex: selectedItemIndex,
                                      textStyle: widget.textStyle,
                                      selectedIconBackgroundColor:
                                          widget.selectedIconBackgroundColor,
                                      unselectedIconColor:
                                          widget.unselectedIconColor,
                                      unSelectedTextColor:
                                          widget.unSelectedTextColor,
                                      selectedTextColor:
                                          widget.selectedTextColor,
                                      minimize: minimize,
                                      height: effectiveItemHeight,
                                      hoverColor: widget.hoverColor,
                                      splashColor: widget.splashColor,
                                      highlightColor: widget.highlightColor,
                                      selectedIconColor:
                                          widget.selectedIconColor,
                                      icon: item.iconUnselected ?? item.iconSelected,
                                      text: item.title,
                                      tooltip: item.tooltip,
                                      badgeText: item.badgeText,
                                      badgeColor: item.badgeColor,
                                      badgeTextStyle: item.badgeTextStyle,
                                      showTooltipWhenMinimized:
                                          widget.showTooltipsWhenMinimized,
                                      itemHorizontalPadding:
                                          widget.itemHorizontalPadding,
                                      itemIconTextSpacing:
                                          widget.itemIconTextSpacing,
                                      itemBorderRadius: widget.itemBorderRadius,
                                      hoverAnimation: widget.hoverAnimation,
                                      indicatorStyle: widget.indicatorStyle,
                                      selectedItemDecoration: widget.selectedItemDecoration,
                                      unselectedItemDecoration: widget.unselectedItemDecoration,
                                      itemPadding: widget.itemPadding,
                                      isHeader: item.isHeader,
                                      isDivider: item.isDivider,
                                      dividerColor: widget.dividerColor,
                                      onTap: () {
                                        final canTap = shouldTapItems.isEmpty ||
                                            shouldTapItems.length !=
                                                widget.sidebarItems.length ||
                                            shouldTapItems[index] == true;

                                        if (canTap && !item.isHeader && !item.isDivider) {
                                          moveToNewIndex(index);
                                        }
                                      },
                                      onTappedCallbackOffsetPosition: (offset) {
                                        if (item.onTap != null && !item.isHeader && !item.isDivider) {
                                          item.onTap!(offset);
                                        }
                                      },
                                    ),
                                  ),
                                  if (index < widget.sidebarItems.length - 1)
                                    widget.sidebarItems.length > 2 &&
                                            index ==
                                                widget.sidebarItems.length -
                                                    2 &&
                                            widget.settingsDivider
                                        ? Divider(
                                            height: 12,
                                            thickness: 0.5,
                                            color: widget.dividerColor,
                                          )
                                        : SizedBox(
                                            height: widget.compactMode ? 4 : 8),
                                ],
                              );
                            },
                            childCount: widget.sidebarItems.length,
                          ),
                        ),
                      ),
                      if (hasExtraSpace)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),
              ),

              // Footer
              if (widget.footer != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: _buildCollapsibleSection(widget.footer!),
                ),

              // Bottom Minimize Button
              if (widget.minimizeButtonStyle != SideBarMinimizeButtonStyle.floating)
                bottomMinimizeButton,

              if (widget.minimizeButtonStyle == SideBarMinimizeButtonStyle.floating)
                const SizedBox(height: 16),
            ],
          ),
        );

        if (widget.minimizeButtonStyle == SideBarMinimizeButtonStyle.floating) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              sidebarBody,
              Positioned(
                right: -14,
                bottom: 30,
                child: _buildFloatingMinimizeButton(),
              ),
            ],
          );
        } else {
          return sidebarBody;
        }
      },
    );
  }

  Widget _buildCollapsibleSection(Widget child) {
    return AnimatedCrossFade(
      firstChild: child,
      secondChild: const SizedBox.shrink(),
      crossFadeState: minimize ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
      firstCurve: Curves.easeOut,
      secondCurve: Curves.easeIn,
      sizeCurve: Curves.easeOutExpo,
    );
  }

  Widget _buildLegacyMinimizeButton(bool hasExtraSpace) {
    Widget buttonContent = SButton(
      splashColor: Colors.black87,
      onTap: (position) => setState(() {
        minimize = !minimize;
        SideBarController.setMinimizedState(minimize);
        widget.minimizeButtonOnTap?.call(minimize);
      }),
      child: Box(
        width: !minimize ? widget.sideBarWidth : widget.sideBarSmallWidth,
        child: AnimatedAlign(
          duration: 0.5.sec,
          alignment: Alignment.centerRight,
          curve: Curves.easeOutExpo,
          child: Icon(
            key: ValueKey("SSideBar MinimizeButton + $minimize"),
            minimize ? Icons.arrow_right_rounded : Icons.arrow_left_rounded,
            color: widget.minimizeButtonColor ?? Colors.blue.shade800.withValues(alpha: 0.8),
            size: widget.minimizeButtonIconSize ?? 60,
          ),
        ),
      ),
    );

    if (hasExtraSpace) {
      return Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: buttonContent,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: buttonContent,
      );
    }
  }

  Widget _buildModernBottomMinimizeButton() {
    return Padding(
      padding: minimize
          ? const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0)
          : EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: widget.itemHorizontalPadding + 10.0,
            ),
      child: SInkButton(
        color: widget.splashColor,
        hoverColor: widget.hoverColor,
        hoverAndSplashBorderRadius: BorderRadius.circular(widget.itemBorderRadius),
        enableHapticFeedback: false,
        onTap: (position) => setState(() {
          minimize = !minimize;
          SideBarController.setMinimizedState(minimize);
          widget.minimizeButtonOnTap?.call(minimize);
        }),
        child: Container(
          height: widget.compactMode ? 40 : 44,
          alignment: minimize ? Alignment.center : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: minimize ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                minimize ? Icons.keyboard_double_arrow_right_rounded : Icons.keyboard_double_arrow_left_rounded,
                color: widget.minimizeButtonColor ?? widget.unselectedIconColor,
                size: 20,
              ),
              if (!minimize) ...[
                SizedBox(width: widget.itemIconTextSpacing),
                Expanded(
                  child: Text(
                     "Collapse",
                     style: widget.textStyle.copyWith(
                       color: widget.unSelectedTextColor,
                       fontSize: 14,
                       fontWeight: FontWeight.w500,
                     ),
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingMinimizeButton() {
    return SButton(
      splashColor: widget.splashColor,
      shouldBounce: true,
      bounceScale: 0.9,
      borderRadius: BorderRadius.circular(100),
      onTap: (position) => setState(() {
        minimize = !minimize;
        SideBarController.setMinimizedState(minimize);
        widget.minimizeButtonOnTap?.call(minimize);
      }),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.sideBarColor,
          border: Border.all(
            color: widget.sideBarColor.darken(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            minimize ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
            color: widget.minimizeButtonColor ?? widget.unselectedIconColor,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _SideBarItemWidget extends StatefulWidget {
  final IconData icon;
  final String text;
  final bool minimize;
  final double height;
  final Color hoverColor;
  final Color unselectedIconColor;
  final Color unSelectedTextColor;
  final Color selectedIconColor;
  final Color selectedTextColor;
  final Color splashColor;
  final Color highlightColor;
  final Function() onTap;
  final TextStyle textStyle;
  final int selectedItemIndex;
  final int itemIndex;
  final Color selectedIconBackgroundColor;
  final bool showTooltipWhenMinimized;
  final double itemHorizontalPadding;
  final double itemIconTextSpacing;
  final double itemBorderRadius;
  final String? tooltip;
  final String? badgeText;
  final Color? badgeColor;
  final TextStyle? badgeTextStyle;
  final void Function(Offset? offset)? onTappedCallbackOffsetPosition;

  final bool hoverAnimation;
  final SideBarIndicatorStyle indicatorStyle;
  final Decoration? selectedItemDecoration;
  final Decoration? unselectedItemDecoration;
  final EdgeInsetsGeometry? itemPadding;
  final bool isHeader;
  final bool isDivider;
  final Color dividerColor;

  const _SideBarItemWidget({
    required this.icon,
    required this.text,
    required this.minimize,
    required this.height,
    required this.hoverColor,
    required this.unselectedIconColor,
    required this.unSelectedTextColor,
    required this.selectedIconColor,
    required this.selectedTextColor,
    required this.splashColor,
    required this.highlightColor,
    required this.onTap,
    required this.textStyle,
    required this.selectedItemIndex,
    required this.itemIndex,
    required this.selectedIconBackgroundColor,
    required this.showTooltipWhenMinimized,
    required this.itemHorizontalPadding,
    required this.itemIconTextSpacing,
    required this.itemBorderRadius,
    this.tooltip,
    this.badgeText,
    this.badgeColor,
    this.badgeTextStyle,
    this.onTappedCallbackOffsetPosition,
    required this.hoverAnimation,
    required this.indicatorStyle,
    this.selectedItemDecoration,
    this.unselectedItemDecoration,
    this.itemPadding,
    required this.isHeader,
    required this.isDivider,
    required this.dividerColor,
  });

  @override
  State<_SideBarItemWidget> createState() => _SideBarItemWidgetState();
}

class _SideBarItemWidgetState extends State<_SideBarItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isDivider) {
      return Padding(
        padding: widget.minimize
            ? const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0)
            : const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        child: Divider(
          height: 1,
          thickness: 0.5,
          color: widget.dividerColor.withValues(alpha: 0.5),
        ),
      );
    }

    if (widget.isHeader) {
      if (widget.minimize) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Center(
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.unSelectedTextColor.withValues(alpha: 0.4),
              ),
            ),
          ),
        );
      }
      return Padding(
        padding: EdgeInsets.only(
          left: widget.itemHorizontalPadding + 4,
          right: widget.itemHorizontalPadding,
          top: 14,
          bottom: 6,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.text.toUpperCase(),
            style: widget.textStyle.copyWith(
              color: widget.unSelectedTextColor.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    final bool isSelected = widget.selectedItemIndex == widget.itemIndex;
    final Color effectiveBadgeColor = widget.badgeColor ?? Colors.redAccent;

    Decoration? itemDecoration = isSelected
        ? widget.selectedItemDecoration ??
            BoxDecoration(
              color: widget.selectedIconBackgroundColor,
              borderRadius: BorderRadius.circular(widget.itemBorderRadius),
            )
        : widget.unselectedItemDecoration;

    if (!isSelected && _isHovered) {
      itemDecoration = BoxDecoration(
        color: widget.hoverColor,
        borderRadius: BorderRadius.circular(widget.itemBorderRadius),
      );
    }

    itemDecoration ??= BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(widget.itemBorderRadius),
    );

    final double leftShift = (widget.hoverAnimation && _isHovered && !widget.minimize) ? 4.0 : 0.0;

    Widget content = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: SInkButton(
        color: widget.splashColor,
        hoverColor: Colors.transparent,
        hoverAndSplashBorderRadius: BorderRadius.circular(widget.itemBorderRadius),
        enableHapticFeedback: false,
        onTap: (position) {
          widget.onTap();
          widget.onTappedCallbackOffsetPosition?.call(position);
        },
        child: Stack(
          children: [
            Padding(
              padding: widget.minimize ? const EdgeInsets.symmetric(horizontal: 5) : EdgeInsets.zero,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: widget.height,
                curve: Curves.easeInOut,
                decoration: itemDecoration,
              ),
            ),
            if (isSelected) ...[
              if (widget.indicatorStyle == SideBarIndicatorStyle.leftLine)
                Positioned(
                  left: 0,
                  top: 8,
                  bottom: 8,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 3.5,
                    decoration: BoxDecoration(
                      color: widget.selectedIconColor.withValues(alpha: 0.95),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(2)),
                    ),
                  ),
                ),
              if (widget.indicatorStyle == SideBarIndicatorStyle.rightLine)
                Positioned(
                  right: widget.minimize ? 5 : 0,
                  top: 8,
                  bottom: 8,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 3.5,
                    decoration: BoxDecoration(
                      color: widget.selectedIconColor.withValues(alpha: 0.95),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(2)),
                    ),
                  ),
                ),
            ],
            Box(
              height: widget.height,
              alignment: widget.minimize ? Alignment.center : Alignment.centerLeft,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: widget.itemPadding ??
                    EdgeInsets.only(
                      left: (widget.minimize ? 0 : widget.itemHorizontalPadding) + leftShift,
                    ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedScale(
                            scale: _isHovered ? 1.08 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              widget.icon,
                              color: isSelected
                                  ? widget.selectedIconColor
                                  : widget.unselectedIconColor,
                            ),
                          ),
                          if (widget.badgeText != null && widget.minimize)
                            Positioned(
                              right: -8,
                              top: -8,
                              child: _badgeChip(
                                badgeText: widget.badgeText!,
                                badgeColor: effectiveBadgeColor,
                                badgeTextStyle: widget.badgeTextStyle,
                              ),
                            ),
                        ],
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: widget.minimize
                            ? const SizedBox.shrink(key: ValueKey("min"))
                            : Padding(
                                key: const ValueKey("text"),
                                padding: EdgeInsets.only(
                                  left: widget.itemIconTextSpacing,
                                ),
                                child: Text(
                                  widget.text,
                                  overflow: TextOverflow.ellipsis,
                                  style: widget.textStyle.copyWith(
                                    color: isSelected
                                        ? widget.selectedTextColor
                                        : widget.unSelectedTextColor,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                      ),
                      if (widget.badgeText != null && !widget.minimize)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: _badgeChip(
                            badgeText: widget.badgeText!,
                            badgeColor: effectiveBadgeColor,
                            badgeTextStyle: widget.badgeTextStyle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    content = Semantics(
      button: true,
      selected: isSelected,
      label: widget.tooltip ?? widget.text,
      child: content,
    );

    if (widget.minimize && widget.showTooltipWhenMinimized) {
      content = Tooltip(
        message: widget.tooltip ?? widget.text,
        child: content,
      );
    }

    return content;
  }
}

Widget _badgeChip({
  required String badgeText,
  required Color badgeColor,
  TextStyle? badgeTextStyle,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: badgeColor,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      badgeText,
      style: badgeTextStyle ??
          const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
    ),
  );
}

///Sidebar model contains two icon data and string for the text main Icon can't be null but unselected icon can be null and in this case it will be the main Icon

/// Sidebar model
/// Represents a single item in the sidebar menu.
///
/// Each SSideBarItem defines a menu option with icons, text, optional badges,
/// tooltips, and tap callbacks. Items can display different icons when selected
/// vs unselected, and support notification badges.
///
/// ## Basic Usage
///
/// ```dart
/// SSideBarItem(
///   iconSelected: Icons.home,
///   iconUnselected: Icons.home_outlined,
///   title: 'Home',
///   tooltip: 'Go to Home',
///   badgeText: '3', // Optional notification badge
///   badgeColor: Colors.red,
///   onTap: (offset) {
///     print('Home tapped at position: $offset');
///   },
/// )
/// ```
///
/// ## Badge Support
///
/// Items can display notification badges to show counts or status:
///
/// ```dart
/// SSideBarItem(
///   iconSelected: Icons.notifications,
///   title: 'Notifications',
///   badgeText: '5',
///   badgeColor: Colors.red.shade400,
///   badgeTextStyle: TextStyle(
///     color: Colors.white,
///     fontSize: 10,
///     fontWeight: FontWeight.bold,
///   ),
/// )
/// ```
///
/// ## Icon States
///
/// Use different icons for selected and unselected states:
///
/// ```dart
/// SSideBarItem(
///   iconSelected: Icons.favorite,        // Filled when selected
///   iconUnselected: Icons.favorite_border, // Outlined when not selected
///   title: 'Favorites',
/// )
/// ```
/// Style of the active item selection indicator in the sidebar.
enum SideBarIndicatorStyle {
  /// No vertical line indicator, relies on background highlighting.
  none,

  /// Vertical indicator line on the left edge.
  leftLine,

  /// Vertical indicator line on the right edge.
  rightLine,

  /// No line, but uses a full pill-shaped highlighted background.
  pill,
}

/// Style of the expand/collapse toggle button.
enum SideBarMinimizeButtonStyle {
  /// The legacy style: a large full-width button with a giant arrow.
  legacy,

  /// Modern style: a sleek bottom row with a small chevron and a "Collapse" label that hides when minimized.
  bottomRow,

  /// Floating style: a circular button overlapping the right border of the sidebar.
  floating,
}

class SSideBarItem {
  final IconData iconSelected;
  final IconData? iconUnselected;
  final String title;
  final String? tooltip;
  final String? badgeText;
  final Color? badgeColor;
  final TextStyle? badgeTextStyle;
  final bool isHeader;
  final bool isDivider;

  final Function(Offset? offset)? onTap;

  /// Creates a sidebar item with optional tooltip, badge, and tap callback.
  SSideBarItem({
    required this.iconSelected,
    required this.title,
    this.iconUnselected,
    this.tooltip,
    this.badgeText,
    this.badgeColor,
    this.badgeTextStyle,
    this.isHeader = false,
    this.isDivider = false,
    this.onTap,
  });

  /// Creates a section header item. Section headers display small, uppercase,
  /// muted text, are not interactive, and do not show icons.
  SSideBarItem.header({
    required this.title,
    this.tooltip,
  })  : iconSelected = Icons.linear_scale, // Dummy icon
        iconUnselected = null,
        badgeText = null,
        badgeColor = null,
        badgeTextStyle = null,
        isHeader = true,
        isDivider = false,
        onTap = null;

  /// Creates a horizontal divider item to separate sections.
  SSideBarItem.divider({
    this.badgeText,
    this.badgeColor,
    this.badgeTextStyle,
  })  : iconSelected = Icons.linear_scale, // Dummy icon
        title = '',
        iconUnselected = null,
        tooltip = null,
        isHeader = false,
        isDivider = true,
        onTap = null;
}

//****************************************** */

/// Controller for managing sidebar state and popup functionality.
///
/// The SideBarController provides static methods for programmatic control
/// of sidebar behavior, including popup/overlay sidebars and state management.
///
/// ## Popup Sidebars
///
/// Create overlay sidebars that float above content:
///
/// ```dart
/// // Show a popup sidebar
/// SideBarController.activateSideBar(
///   SSideBar(
///     sidebarItems: [
///       SSideBarItem(iconSelected: Icons.favorite, title: 'Favorites'),
///       SSideBarItem(iconSelected: Icons.history, title: 'Recent'),
///     ],
///     onTapForAllTabButtons: (index) {},
///   ),
/// );
///
/// // Dismiss the popup
/// SideBarController.deactivateSideBar();
/// ```
///
/// ## State Management
///
/// Check and control sidebar state:
///
/// ```dart
/// // Check if popup sidebar is active
/// bool isActive = SideBarController.isSideBarActive();
///
/// // Check if sidebar is minimized
/// bool isMinimized = SideBarController.isSideBarMinimized();
///
/// // Set minimized state
/// SideBarController.setMinimizedState(true);
///
/// // Get controller instance for advanced usage
/// final controller = SideBarController.getController();
/// ```
///
/// ## Use Cases
///
/// - **Context Menus**: Show temporary sidebars for quick actions
/// - **Floating Navigation**: Overlay sidebars for mobile/desktop
/// - **Programmatic Control**: Control sidebar state from anywhere in the app
/// - **State Persistence**: Maintain sidebar state across navigation
class SideBarController {
  bool isActive = false;
  bool isMinimized = false;

  PausableTimer? timer;

  /// Check if the sidebar is active or minimized
  static bool isSideBarActive() => _sideBarController.state.isActive;

  /// Check if the sidebar is minimized
  static bool isSideBarMinimized() => _sideBarController.state.isMinimized;

  /// Activate the sidebar by showing it in a pop overlay
  ///
  /// Creates a popup/overlay sidebar that floats above the current content.
  /// The sidebar can be dismissed by tapping outside (barrier dismiss) or
  /// programmatically calling [deactivateSideBar].
  ///
  /// Parameters:
  /// - [sSideBar]: Custom SSideBar widget to display. If null, uses default sidebar
  /// - [offset]: Position offset for the popup (default: Offset(15, 30))
  /// - [borderRadius]: Border radius for the popup overlay
  ///
  /// Example:
  /// ```dart
  /// SideBarController.activateSideBar(
  ///   SSideBar(
  ///     sidebarItems: [
  ///       SSideBarItem(iconSelected: Icons.favorite, title: 'Favorites'),
  ///     ],
  ///     onTapForAllTabButtons: (index) {},
  ///   ),
  /// );
  /// ```
  static void activateSideBar({
    Widget? sSideBar,
    Offset? offset,
    BorderRadius? borderRadius,
    Offset? animateFromOffset,
    Curve? curve,
    Color? popFrameColor,
    Color? dismissBarrierColor,
    Duration? animationDuration,
    bool useGlobalPosition = false,
    bool shouldBlurDismissBarrier = false,
    Alignment? alignment,
    Function? initState,
    Function? onDismissed,
  }) {
    _sideBarController
        .update<SideBarController>((newState) => newState.isActive = true);

    PopOverlay.addPop(
      PopOverlayContent(
        widget: sSideBar ??
            SSideBar(
              sidebarItems: [
                SSideBarItem(
                  iconSelected: Icons.home_filled,
                  iconUnselected: Icons.home_outlined,
                  title: "home",
                )
              ],
              onTapForAllTabButtons: (index) {},
            ),
        id: 'activate_sidebar',
        dismissBarrierColor:
            dismissBarrierColor ?? Colors.black.withValues(alpha: 0.3),
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        frameColor: popFrameColor ?? Colors.black,
        popPositionOffset: offset ?? Offset(15, 30),
        offsetToPopFrom: animateFromOffset,
        popPositionAnimationCurve: curve,
        popPositionAnimationDuration: animationDuration,
        useGlobalPosition: useGlobalPosition,
        alignment: alignment ?? Alignment.centerLeft,
        shouldBlurBackground: shouldBlurDismissBarrier,
        initState: initState,
        onDismissed: onDismissed,
      ),
    );
  }

  /// Deactivate the sidebar by dismissing the pop overlay
  ///
  /// Dismisses the currently active popup sidebar overlay. This method
  /// resets the controller state and removes the overlay from the screen.
  ///
  /// The [shouldCallToDismissPopOverlay] parameter is kept for compatibility
  /// but is always true in the current implementation.
  static void deactivateSideBar({bool shouldCallToDismissPopOverlay = true}) {
    _sideBarController.refresh();
    PopOverlay.dismissPop('activate_sidebar');
  }

  /// Set the minimized state of the sidebar
  ///
  /// Controls whether the sidebar should be in minimized (icon-only) or
  /// expanded (full) state. This affects all active sidebars.
  ///
  /// Parameters:
  /// - [minimize]: true to minimize, false to expand
  ///
  /// Example:
  /// ```dart
  /// // Minimize the sidebar
  /// SideBarController.setMinimizedState(true);
  ///
  /// // Expand the sidebar
  /// SideBarController.setMinimizedState(false);
  /// ```
  static void setMinimizedState(bool minimize) {
    _sideBarController.update<SideBarController>(
        (newState) => newState.isMinimized = minimize);
  }

  /// Get the SideBarController instance
  ///
  /// Returns the underlying Injected controller for advanced state management.
  /// This is useful for direct state manipulation or reactive programming.
  ///
  /// Returns: The `Injected<SideBarController>` instance
  ///
  /// Example:
  /// ```dart
  /// final controller = SideBarController.getController();
  /// // Use with states_rebuilder for reactive updates
  /// ```
  static Injected<SideBarController> getController() => _sideBarController;
}

//***************************************** */

/// Injected SideBarController for global state management
final _sideBarController = RM.inject<SideBarController>(
  () => SideBarController(),
  autoDisposeWhenNotUsed: false,
);

//***************************************** */
