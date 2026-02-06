import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:pop_overlay/pop_overlay.dart';
import 'package:s_button/s_button.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';
import 'package:states_rebuilder_extended/states_rebuilder_extended.dart';

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

    ///using animated container for the side bar for smooth responsive
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the provided height or the maximum available height
        final double effectiveHeight = sidebarHeight ?? constraints.maxHeight;

        // Calculate estimated height needed for all items
        final int itemCount = widget.sidebarItems.length;
        final double separatorHeight = widget.compactMode ? 4 : 8;
        final double dividerHeight =
            widget.settingsDivider && itemCount > 2 ? 12 : 0;
        final double topPadding = 20.0;
        final double logoHeight = widget.logo != null ? 60.0 : 0.0; // estimate
        final double buttonMinHeight = 50.0; // minimum height for button

        final double estimatedItemsHeight = (itemCount * effectiveItemHeight) +
            ((itemCount - 1) * separatorHeight) +
            dividerHeight +
            topPadding +
            (itemCount > 0 ? (widget.compactMode ? 14 : 20) : 0);

        final double totalNeededHeight =
            logoHeight + estimatedItemsHeight + buttonMinHeight;
        final bool hasExtraSpace = effectiveHeight > totalNeededHeight;

        return AnimatedContainer(
          duration: widget.sideBarAnimationDuration,
          curve: widget.curve,
          alignment: Alignment.topCenter,
          transformAlignment: Alignment.centerRight,
          height: effectiveHeight,
          constraints: BoxConstraints(
            maxWidth:
                !minimize ? widget.sideBarWidth : widget.sideBarSmallWidth,
            minWidth:
                !minimize ? widget.sideBarWidth : widget.sideBarSmallWidth,
          ),
          decoration: BoxDecoration(
            color: widget.sideBarColor,
            border: widget.sideBarBorder ??
                Border.all(color: widget.sideBarColor.darken(0.1)),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //logo
              if (widget.logo != null)
                Align(
                  child: Padding(
                    padding: Pad(top: 20),
                    child: widget.logo ?? SizedBox(),
                  ),
                ),

              //the sidebar items - wrapped in Expanded for scrolling
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: minimize ? Pad.zero : Pad(left: 20, right: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: index ==
                                            widget.sidebarItems.length - 1
                                        ? Pad(top: widget.compactMode ? 14 : 20)
                                        : Pad.zero,
                                    child: _sSideBarItem(
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
                                      icon: widget.sidebarItems[index]
                                              .iconUnselected ??
                                          widget
                                              .sidebarItems[index].iconSelected,
                                      text: widget.sidebarItems[index].title,
                                      tooltip:
                                          widget.sidebarItems[index].tooltip,
                                      badgeText:
                                          widget.sidebarItems[index].badgeText,
                                      badgeColor:
                                          widget.sidebarItems[index].badgeColor,
                                      badgeTextStyle: widget
                                          .sidebarItems[index].badgeTextStyle,
                                      showTooltipWhenMinimized:
                                          widget.showTooltipsWhenMinimized,
                                      itemHorizontalPadding:
                                          widget.itemHorizontalPadding,
                                      itemIconTextSpacing:
                                          widget.itemIconTextSpacing,
                                      itemBorderRadius: widget.itemBorderRadius,
                                      onTap: () {
                                        final canTap = shouldTapItems.isEmpty ||
                                            shouldTapItems.length !=
                                                widget.sidebarItems.length ||
                                            shouldTapItems[index] == true;

                                        if (canTap) {
                                          moveToNewIndex(index);
                                        }
                                      },
                                      onTappedCallbackOffsetPosition: (offset) {
                                        if (widget.sidebarItems[index].onTap !=
                                            null) {
                                          widget.sidebarItems[index]
                                              .onTap!(offset);
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

              //the button to widden or minimize the sideBar width - always visible at bottom
              if (hasExtraSpace)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: SButton(
                      splashColor: Colors.black87,
                      onTap: (position) => setState(() {
                        minimize = !minimize;
                        SideBarController.setMinimizedState(minimize);
                        widget.minimizeButtonOnTap?.call(minimize);
                      }),
                      child: Box(
                        width: !minimize
                            ? widget.sideBarWidth
                            : widget.sideBarSmallWidth,
                        child: AnimatedAlign(
                          duration: 0.5.sec,
                          alignment: Alignment.centerRight,
                          curve: Curves.easeOutExpo,
                          child: Icon(
                            key:
                                ValueKey("SSideBar MinimizeButton + $minimize"),
                            minimize
                                ? Icons.arrow_right_rounded
                                : Icons.arrow_left_rounded,
                            color: widget.minimizeButtonColor ??
                                Colors.blue.shade800.withValues(alpha: 0.8),
                            size: widget.minimizeButtonIconSize ?? 60,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: SButton(
                    splashColor: Colors.black87,
                    onTap: (position) => setState(() {
                      minimize = !minimize;
                      SideBarController.setMinimizedState(minimize);
                      widget.minimizeButtonOnTap?.call(minimize);
                    }),
                    child: Box(
                      width: !minimize
                          ? widget.sideBarWidth
                          : widget.sideBarSmallWidth,
                      child: AnimatedAlign(
                        duration: 0.5.sec,
                        alignment: Alignment.centerRight,
                        curve: Curves.easeOutExpo,
                        child: Icon(
                          key: ValueKey("SSideBar MinimizeButton + $minimize"),
                          minimize
                              ? Icons.arrow_right_rounded
                              : Icons.arrow_left_rounded,
                          color: widget.minimizeButtonColor ??
                              Colors.blue.shade800.withValues(alpha: 0.8),
                          size: widget.minimizeButtonIconSize ?? 60,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Sidebar model Widget the we used it inside the ListView with inkwell to make each item clickable

/// Builds a single sidebar item widget with animations and interactions.
///
/// This internal function creates the visual representation of a sidebar menu item,
/// handling selection states, animations, badges, tooltips, and tap interactions.
Widget _sSideBarItem({
  required IconData icon,
  required String text,
  required bool minimize,
  required double height,
  required Color hoverColor,
  required Color unselectedIconColor,
  required Color unSelectedTextColor,
  required Color selectedIconColor,
  required Color selectedTextColor,
  required Color splashColor,
  required Color highlightColor,
  required Function() onTap,
  required TextStyle textStyle,
  required int selectedItemIndex,
  required int itemIndex,
  required Color selectedIconBackgroundColor,
  required bool showTooltipWhenMinimized,
  required double itemHorizontalPadding,
  required double itemIconTextSpacing,
  required double itemBorderRadius,
  String? tooltip,
  String? badgeText,
  Color? badgeColor,
  TextStyle? badgeTextStyle,
  void Function(Offset? offset)? onTappedCallbackOffsetPosition,
}) {
  final bool isSelected = selectedItemIndex == itemIndex;
  final Color effectiveBadgeColor = badgeColor ?? Colors.redAccent;

  Widget content = Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(itemBorderRadius),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    child: InkWell(
      onTap: onTap,
      onTapDown: (details) {
        if (onTappedCallbackOffsetPosition != null) {
          onTappedCallbackOffsetPosition(details.globalPosition);
        }
      },
      hoverColor: hoverColor,
      splashColor: splashColor,
      highlightColor: highlightColor,
      child: Stack(
        children: [
          Padding(
            padding: minimize ? Pad(left: 5, right: 5) : Pad.zero,
            child: AnimatedContainer(
              duration: 0.3.sec,
              height: height,
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isSelected
                    ? selectedIconBackgroundColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(itemBorderRadius),
              ),
            ),
          ),
          if (isSelected)
            Positioned(
              left: 0,
              top: 6,
              bottom: 6,
              child: AnimatedContainer(
                duration: 0.3.sec,
                width: 3,
                decoration: BoxDecoration(
                  color: selectedIconColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          Box(
            height: height,
            // color: yellow,
            alignment: minimize ? Alignment.center : Alignment.centerLeft,
            child: Padding(
              padding: Pad(left: minimize ? 0 : itemHorizontalPadding),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          icon,
                          color: isSelected
                              ? selectedIconColor
                              : unselectedIconColor,
                        ),
                        if (badgeText != null && minimize)
                          Positioned(
                            right: -12,
                            top: -10,
                            child: _badgeChip(
                              badgeText: badgeText,
                              badgeColor: effectiveBadgeColor,
                              badgeTextStyle: badgeTextStyle,
                            ),
                          ),
                      ],
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: minimize
                          ? const SizedBox.shrink(key: ValueKey("min"))
                          : Padding(
                              key: const ValueKey("text"),
                              padding: EdgeInsets.only(
                                left: itemIconTextSpacing,
                              ),
                              child: Text(
                                text,
                                overflow: isSelected
                                    ? TextOverflow.ellipsis
                                    : TextOverflow.clip,
                                style: textStyle.copyWith(
                                  color: isSelected
                                      ? selectedTextColor
                                      : unSelectedTextColor,
                                ),
                                textAlign: isSelected
                                    ? TextAlign.center
                                    : TextAlign.left,
                              ),
                            ),
                    ),
                    if (badgeText != null && !minimize)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: _badgeChip(
                          badgeText: badgeText,
                          badgeColor: effectiveBadgeColor,
                          badgeTextStyle: badgeTextStyle,
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
    label: tooltip ?? text,
    child: content,
  );

  if (minimize && showTooltipWhenMinimized) {
    content = Tooltip(
      message: tooltip ?? text,
      child: content,
    );
  }

  return content;
}

/// Creates a notification badge widget for sidebar items.
///
/// Displays a small, rounded badge with text (typically for counts or status).
/// Used internally by [_sSideBarItem] to show badges on menu items.
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
class SSideBarItem {
  final IconData iconSelected;
  final IconData? iconUnselected;
  final String title;
  final String? tooltip;
  final String? badgeText;
  final Color? badgeColor;
  final TextStyle? badgeTextStyle;

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
    this.onTap,
  });
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
  static void activateSideBar(
      {Widget? sSideBar, Offset? offset, BorderRadius? borderRadius}) {
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
        dismissBarrierColor: Colors.black.withValues(alpha: 0.3),
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        // frameColor: Colors.transparent,

        popPositionOffset: offset ?? Offset(15, 30),
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
