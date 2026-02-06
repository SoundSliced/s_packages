/// SContextMenu – Advanced contextual actions widget
/// --------------------------------------------------
/// Features:
/// - Right-click (desktop) or long-press (touch) to open.
/// - Animated fade + scale panel and arrow.
/// - Automatic smart positioning with arrow corner selection.
/// - Accessible: optional screen reader announcement & semantic labels.
/// - Overflow handling (scrolls when too tall).
/// - Keyboard listener: Captures key presses while menu is active (prints to console).
/// - Theming via [SContextMenuTheme] (panel colors, blur, radii, arrow shape, durations, blur, shadows).
/// - Re-entrant safe (closing old before opening new) with show throttling to prevent accidental spam.
/// - Optional multi-open mode (`allowMultipleMenus: true`) to keep several menus visible at once.
/// - Lifecycle callbacks: [onOpened], [onClosed].
/// - Programmatic control:
///   * Single active helpers: [SContextMenu.closeOpenMenu], [SContextMenu.hasOpenMenu].
///   * Multi-open helpers: [SContextMenu.closeAllOpenMenus], [SContextMenu.hasAnyOpenMenus].
///
/// Basic usage:
/// ```dart
/// SContextMenu(
///   buttons: [
///     SContextMenuItem(label: 'Edit', icon: Icons.edit, onPressed: onEdit),
///     SContextMenuItem(label: 'Delete', icon: Icons.delete, destructive: true, onPressed: onDelete),
///   ],
///   child: YourTargetWidget(),
/// );
/// ```
///
/// Enable multiple concurrent menus:
/// ```dart
/// SContextMenu(
///   allowMultipleMenus: true,
///   buttons: [...],
///   child: widgetA,
/// );
/// SContextMenu(
///   allowMultipleMenus: true,
///   buttons: [...],
///   child: widgetB,
/// );
/// // Later you can close them all:
/// SContextMenu.closeAllOpenMenus();
/// ```
///
/// Theming:
/// ```dart
/// SContextMenu(
///   theme: const SContextMenuTheme(panelBorderRadius: 12, panelBlurSigma: 30),
///   buttons: [...],
///   child: widget,
/// )
/// ```
///
/// Programmatic close (e.g. before route change):
/// ```dart
/// SContextMenu.closeOpenMenu();
/// ```
///
/// Notes:
/// - `followAnchor: true` keeps menu tethered to the child (respects size/metric changes).
/// - Provide an empty `buttons` list to fall back to a default placeholder button.
/// - Long-press duration fixed at 600ms (adjust easily in code if required).
/// - Keyboard events are only captured while the menu is visible and focused.
/// - Press ESC to close the menu via keyboard interaction.
library;
// Advanced context menu implementation with animated overlay, arrow,
// accessibility announcements, throttling, callbacks, theming, overflow scrolling,
// and keyboard event listening.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import 'package:s_packages/s_packages.dart';

export 's_context_menu_types.dart';
export 's_context_menu_controllers.dart';
export 's_context_menu_theme.dart';

import 'package:universal_html/universal_html.dart' as html;

enum _DismissReason { action, escape, outsideTap, programmatic }

class SContextMenu extends StatefulWidget {
  final List<SContextMenuItem> buttons;
  final Widget child;
  final bool followAnchor;
  final Duration showThrottle;
  final bool announceAccessibility;
  final bool shouldPreventWebBrowserContextMenu;
  final String semanticsMenuLabel;
  final VoidCallback? onOpened;
  final VoidCallback? onDismissed; // only for escape key or outside tap
  final void Function(String label)?
      onButtonPressed; // any menu item activated (label provided)
  final SContextMenuTheme? theme;

  /// When true, more than one context menu instance may remain open simultaneously.
  /// Default is false (single-instance mode where opening a new menu dismisses all others).
  final bool allowMultipleMenus;
  final double? backgroundOpacity;
  final Color? highlightColor;

  const SContextMenu({
    super.key,
    required this.child,
    this.buttons = const [],
    this.followAnchor = false,
    this.showThrottle = const Duration(milliseconds: 70),
    this.announceAccessibility = true,
    this.semanticsMenuLabel = 'Context menu',
    this.onOpened,
    this.onDismissed,
    this.onButtonPressed,
    this.theme,
    this.allowMultipleMenus = false,
    this.backgroundOpacity,
    this.highlightColor,
    this.shouldPreventWebBrowserContextMenu = kIsWeb,
  });
  // ---- Global active menu tracking ----------------------------------------
  //disable right click context menu on web for the whole app
  //https://stackoverflow.com/questions/62209594/how-to-disable-right-click-context-menu-in-flutter-web

  static void preventBrowserContextMenu() =>
      html.document.onContextMenu.listen((event) => event.preventDefault());

  static _SContextMenuState? _activeMenuState;

  /// Returns true if there is a currently tracked "active" menu (the most recently opened
  /// menu in single-instance mode, or the last one opened in multi-open mode).
  static bool get hasOpenMenu => _activeMenuState?._menuOverlayEntry != null;

  /// Closes only the currently active menu (if any). In multi-open mode other menus stay.
  static void closeOpenMenu() => _activeMenuState?._hide();

  // -------- Multi-open support -------------------------------------------------
  /// Internal set of all open menu states. In single-instance mode this will contain at most one.
  static final Set<_SContextMenuState> _openMenus = <_SContextMenuState>{};

  /// Registry of all SContextMenu instances (mounted or unmounted)
  static final Set<_SContextMenuState> _allInstances = <_SContextMenuState>{};

  /// Returns true if ANY menu is open (works for both single and multi modes).
  static bool get hasAnyOpenMenus => _openMenus.isNotEmpty;

  /// Closes all open menus, regardless of single or multi mode. Safe to call at
  /// app shutdown, navigation changes, or global dismiss gestures.
  static void closeAllOpenMenus() {
    // Copy to avoid concurrent modification.
    for (final m in _openMenus.toList()) {
      m._hide();
    }
  }

  static String get defaultButtonLabel => 'Default button';
  static IconData get defaultButtonIcon => Icons.circle;

  @override
  State<SContextMenu> createState() => _SContextMenuState();
}

class _GestureState {
  bool isPointerDown = false;
  bool longTapFired = false;
  bool dragExceededSlop = false;
  int? activePointerId;
  Offset? downPosition;
  DateTime? pointerDownTime;
  void reset({bool clearDownTime = false}) {
    isPointerDown = false;
    dragExceededSlop = false;
    activePointerId = null;
    downPosition = null;
    if (clearDownTime) pointerDownTime = null;
  }
}

class _SContextMenuState extends State<SContextMenu>
    with WidgetsBindingObserver {
  OverlayEntry? _menuOverlayEntry;
  bool _animationForward = false;
  bool _isReverseHiding = false;
  DateTime? _lastShowTime;
  bool _openCallbackFired = false;
  bool _closeCallbackFired = false;
  Offset? _lastGlobalPosition;
  final _GestureState _gestureState = _GestureState();
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _childKey = GlobalKey();
  static const Duration holdDuration = Duration(milliseconds: 600);
  PausableTimer? _holdTimer;
  static const double _dragSlop = kTouchSlop;
  late final WidgetsBinding _binding = WidgetsBinding.instance;

  static SContextMenuItem get _defaultButton => SContextMenuItem(
        label: SContextMenu.defaultButtonLabel,
        icon: SContextMenu.defaultButtonIcon,
        onPressed: () {},
      );

  void _startHoldTimer(int pointerId) {
    _cancelHoldTimer();
    _holdTimer = PausableTimer(holdDuration, () {
      if (!mounted) return;
      if (!_gestureState.longTapFired &&
          !_gestureState.dragExceededSlop &&
          _gestureState.isPointerDown &&
          _gestureState.activePointerId == pointerId &&
          _gestureState.downPosition != null) {
        _gestureState.longTapFired = true;
        _show(_gestureState.downPosition!);
      }
    })
      ..start();
  }

  void _cancelHoldTimer() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  /// Check if a global position is within the child widget's bounds
  bool _isPositionInChildBounds(Offset globalPosition) {
    final RenderBox? box =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return false;

    final childPosition = box.localToGlobal(Offset.zero);
    final childBounds = Rect.fromLTWH(
      childPosition.dx,
      childPosition.dy,
      box.size.width,
      box.size.height,
    );
    return childBounds.contains(globalPosition);
  }

  /// Handle right-click on overlay - searches all SContextMenu instances for the smallest
  /// widget containing the click position. When multiple widgets overlap, the smallest one
  /// wins to ensure precise targeting. Repositions if target is current menu, switches if different.
  void _handleOverlayRightClick(Offset globalPosition) {
    // Safety check: ensure this instance is registered (hot reload recovery)
    if (!SContextMenu._allInstances.contains(this)) {
      SContextMenu._allInstances.add(this);
    }

    // Check all SContextMenu instances and find the smallest one containing the click
    _SContextMenuState? targetMenu;
    double smallestArea = double.infinity;

    for (final instance in SContextMenu._allInstances) {
      if (instance.mounted) {
        final RenderBox? box =
            instance._childKey.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final childPosition = box.localToGlobal(Offset.zero);
          final childBounds = Rect.fromLTWH(
            childPosition.dx,
            childPosition.dy,
            box.size.width,
            box.size.height,
          );
          final area = childBounds.width * childBounds.height;

          if (instance._isPositionInChildBounds(globalPosition)) {
            if (area < smallestArea) {
              targetMenu = instance;
              smallestArea = area;
            }
          }
        }
      }
    }

    if (targetMenu != null) {
      if (identical(targetMenu, this)) {
        // Target is the current widget - reposition
        _show(globalPosition);
      } else {
        // Target is a different widget - switch menus
        _hide(animate: false);
        targetMenu._show(globalPosition);
      }
    } else {
      // Click is outside all menu bounds - dismiss
      _hide(animate: false);
    }
  }

  void _show(Offset globalPosition) {
    if (widget.allowMultipleMenus) {
      // Reposition refresh for same instance.
      if (SContextMenu._openMenus.contains(this)) {
        _hide(animate: false);
      }
      // In multi mode we do NOT close other menus.
    } else {
      // Single-instance mode: close all other open menus first.
      for (final m in SContextMenu._openMenus.toList()) {
        if (m != this) m._hide(animate: false);
      }
      if (SContextMenu._openMenus.contains(this)) {
        _hide(animate: false);
      }
      SContextMenu._activeMenuState = this;
    }
    final now = DateTime.now();
    if (_lastShowTime != null &&
        now.difference(_lastShowTime!) < widget.showThrottle) {
      return;
    }
    _lastShowTime = now;
    _openCallbackFired = false;
    _closeCallbackFired = false;
    _lastGlobalPosition = globalPosition;
    final overlay = Overlay.of(context);
    final overlayBox = overlay.context.findRenderObject() as RenderBox;
    final overlaySize = overlayBox.size;

    _menuOverlayEntry = OverlayEntry(
      maintainState: true,
      builder: (ctx) {
        // Build buttons inside the builder so they update on markNeedsBuild()
        final rawButtons =
            widget.buttons.isEmpty ? [_defaultButton] : widget.buttons;
        final theme = widget.theme ?? const SContextMenuTheme();
        final baseStyle =
            Theme.of(context).textTheme.labelLarge ?? const TextStyle();
        final textStyle =
            baseStyle.copyWith(fontSize: 13, fontWeight: FontWeight.w500);
        final targetWidth = SContextMenuControllers.computeTargetWidth(
            rawButtons, textStyle, overlaySize.width);
        final int buttonLen = rawButtons.length;

        // Build activator list so keyboard navigation can trigger them by index.
        final List<VoidCallback> activators = [];
        final List<Widget> buttonWidgets = List.generate(buttonLen, (i) {
          final item = rawButtons[i];
          void activator() {
            item.onPressed();
            widget.onButtonPressed?.call(item.label);
            if (!item.keepMenuOpen) {
              _hide(reason: _DismissReason.action);
            }
          }

          activators.add(activator);
          return _ToolbarIconTextButton(
            icon: item.icon ?? Icons.circle,
            label: item.label,
            onPressed: activator,
            semanticsLabel: item.semanticsLabel,
            destructive: item.destructive,
            expand: true,
            itemIndex: i,
            menuTheme: theme,
          );
        });

        final layout = SContextMenuControllers.computeMenuLayout(
          context: context,
          globalPosition: globalPosition,
          targetWidth: targetWidth,
          buttonCount: buttonWidgets.length,
          overlaySize: overlaySize,
          followAnchor: widget.followAnchor,
          childKey: _childKey,
        );
        final panelRect = layout.panelRect;
        final arrowConfig = layout.arrowConfig;
        final pointerOffset = layout.pointerOffset;
        final followerOffset = layout.followerOffset;
        final contentHeight =
            SContextMenuControllers.computeContentHeight(buttonWidgets.length);
        final constrainedHeight = panelRect.height;

        final panel = _ContextMenuPanel(
          width: targetWidth,
          maxHeight: constrainedHeight,
          contentHeight: contentHeight,
          semanticsMenuLabel: widget.semanticsMenuLabel,
          theme: theme,
          activators: activators,
          children: buttonWidgets,
        );
        final t = widget.theme ?? const SContextMenuTheme();
        final shell = _AnimatedMenuShell(
          animationForward: _animationForward,
          showDuration: t.showDuration,
          hideDuration: t.hideDuration,
          onDismissOutsideTap: () => _hide(reason: _DismissReason.outsideTap),
          onEscapeDismiss: () => _hide(reason: _DismissReason.escape),
          onOverlayRightClick: _handleOverlayRightClick,
          overlaySize: overlaySize,
          pointer: pointerOffset,
          panelRect: panelRect,
          arrowConfig: arrowConfig.copyWith(
            baseWidth: theme.arrowBaseWidth,
            cornerRadius: theme.arrowCornerRadius,
            tipGap: theme.arrowTipGap,
            maxLength: theme.arrowMaxLength,
            shape: theme.arrowShape,
            tipRoundness: theme.arrowTipRoundness,
          ),
          buttonCount: buttonLen,
          requestActivate: (index) {
            if (index >= 0 && index < activators.length) {
              activators[index]();
            }
          },
          theme: theme,
          child: panel,
        );
        return widget.followAnchor
            ? CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: followerOffset,
                child: shell,
              )
            : shell;
      },
    );
    overlay.insert(_menuOverlayEntry!);
    // Register in global tracking sets.
    SContextMenu._openMenus.add(this);
    SContextMenu._activeMenuState =
        this; // most recently opened (even in multi mode)
    setState(() => _animationForward = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //****** */
      FocusScope.of(context).requestFocus();
      //****** */

      if (widget.announceAccessibility) {
        try {
          final rawButtons =
              widget.buttons.isEmpty ? [_defaultButton] : widget.buttons;
          SemanticsService.sendAnnouncement(
            WidgetsBinding.instance.platformDispatcher.views.first,
            '${widget.semanticsMenuLabel}, ${rawButtons.length} options',
            Directionality.of(context),
          );
        } catch (_) {}
      }
      if (!_openCallbackFired) {
        _openCallbackFired = true;
        widget.onOpened?.call();
      }
    });
  }

  void _hide(
      {bool animate = true,
      _DismissReason reason = _DismissReason.programmatic}) {
    if (_menuOverlayEntry == null) return;
    final bool wasActive = identical(SContextMenu._activeMenuState, this);
    if (!animate) {
      _menuOverlayEntry?.remove();
      _menuOverlayEntry = null;
      _animationForward = false;
      _isReverseHiding = false;
      SContextMenu._openMenus.remove(this);
      if (wasActive) {
        SContextMenu._activeMenuState = SContextMenu._openMenus.isNotEmpty
            ? SContextMenu._openMenus.first
            : null;
      }
      if (!_closeCallbackFired) {
        _closeCallbackFired = true;
        widget.onDismissed?.call();
      }
      return;
    }
    if (_isReverseHiding) {
      _menuOverlayEntry?.remove();
      _menuOverlayEntry = null;
      SContextMenu._openMenus.remove(this);
      if (wasActive) {
        SContextMenu._activeMenuState = SContextMenu._openMenus.isNotEmpty
            ? SContextMenu._openMenus.first
            : null;
      }
      if (!_closeCallbackFired) {
        _closeCallbackFired = true;
        widget.onDismissed?.call();
      }
      return;
    }
    _isReverseHiding = true;
    setState(() => _animationForward = false);

    // Wait for animation to complete before removing overlay
    final t = widget.theme ?? const SContextMenuTheme();
    Future.delayed(t.hideDuration, () {
      if (mounted && _isReverseHiding) {
        _menuOverlayEntry?.remove();
        _menuOverlayEntry = null;
        _isReverseHiding = false;
        if (!_closeCallbackFired) {
          _closeCallbackFired = true;
          widget.onDismissed?.call();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _binding.addObserver(this);
    if (widget.shouldPreventWebBrowserContextMenu) {
      SContextMenu.preventBrowserContextMenu();
    }

    SContextMenu._allInstances.add(this);
  }

  @override
  void reassemble() {
    super.reassemble();
    // Re-register after hot reload
    if (!SContextMenu._allInstances.contains(this)) {
      SContextMenu._allInstances.add(this);
    }
  }

  @override
  void didUpdateWidget(covariant SContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the menu is open and buttons changed, schedule overlay rebuild for next frame
    if (_menuOverlayEntry != null && widget.buttons != oldWidget.buttons) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _menuOverlayEntry != null) {
          _menuOverlayEntry!.markNeedsBuild();
        }
      });
    }
  }

  @override
  void dispose() {
    _cancelHoldTimer();
    _hide(animate: false);
    _binding.removeObserver(this);
    SContextMenu._allInstances.remove(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (_lastGlobalPosition != null && _menuOverlayEntry != null) {
      _binding.addPostFrameCallback((_) {
        if (mounted && _lastGlobalPosition != null) {
          _show(_lastGlobalPosition!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final childWrapped = widget.followAnchor
        ? CompositedTransformTarget(
            link: _layerLink,
            child: KeyedSubtree(key: _childKey, child: widget.child))
        : KeyedSubtree(key: _childKey, child: widget.child);
    return Listener(
      onPointerDown: (event) {
        if (event.buttons == kSecondaryMouseButton) {
          _show(event.position);
          return;
        }
        _gestureState.pointerDownTime = DateTime.now();
        _gestureState.longTapFired = false;
        _gestureState.activePointerId = event.pointer;
        _gestureState.isPointerDown = true;
        _gestureState.downPosition = event.position;
        _gestureState.dragExceededSlop = false;
        _cancelHoldTimer();
        _startHoldTimer(event.pointer);
      },
      onPointerMove: (event) {
        if (!_gestureState.isPointerDown) return;
        if (_gestureState.activePointerId != event.pointer) return;
        if (_gestureState.downPosition == null) return;
        final moved = (event.position - _gestureState.downPosition!).distance;
        if (!_gestureState.dragExceededSlop && moved > _dragSlop) {
          _gestureState.dragExceededSlop = true;
          _cancelHoldTimer();
        }
      },
      onPointerUp: (event) {
        if (_gestureState.pointerDownTime == null) return;
        _cancelHoldTimer();
        _gestureState.isPointerDown = false;
        _gestureState.dragExceededSlop = false;
        final duration =
            DateTime.now().difference(_gestureState.pointerDownTime!);
        if (!_gestureState.longTapFired && duration < holdDuration) {
          // Only dismiss if menu is open and tap was a quick tap on the child
          if (_menuOverlayEntry != null) {
            _hide(reason: _DismissReason.outsideTap);
          }
        }
        _gestureState.reset(clearDownTime: true);
      },
      onPointerCancel: (event) {
        _cancelHoldTimer();
        _gestureState.reset(clearDownTime: true);
      },
      behavior: HitTestBehavior.deferToChild,
      child: childWrapped,
    );
  }
}

class _ToolbarIconTextButton extends StatelessWidget {
  const _ToolbarIconTextButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.semanticsLabel,
    this.destructive = false,
    this.expand = false,
    this.itemIndex,
    this.menuTheme,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final String? semanticsLabel;
  final bool destructive;
  final bool expand;
  final int? itemIndex; // used only for debug / identification
  final SContextMenuTheme? menuTheme;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseTextStyle = theme.textTheme.labelLarge
            ?.copyWith(fontSize: 13, fontWeight: FontWeight.w500) ??
        CupertinoTheme.of(context)
            .textTheme
            .textStyle
            .copyWith(fontSize: 13, fontWeight: FontWeight.w500);
    final Color fallbackPrimary = CupertinoTheme.of(context).primaryColor;
    final bool isDark = theme.brightness == Brightness.dark;

    // Use theme colors if provided, otherwise fall back to defaults
    final Color primary =
        menuTheme?.resolveIconColor(fallbackPrimary) ?? fallbackPrimary;
    final Color danger =
        menuTheme?.resolveDestructiveColor() ?? Colors.red.shade600;
    final Color? hoverColor = menuTheme?.hoverColor;

    return _MenuButtonVisual(
      icon: icon,
      label: label,
      onPressed: onPressed,
      destructive: destructive,
      expand: expand,
      semanticsLabel: semanticsLabel,
      baseTextStyle: baseTextStyle,
      primary: primary,
      danger: danger,
      isDark: isDark,
      itemIndex: itemIndex,
      hoverColor: hoverColor,
    );
  }
}

class _MenuButtonVisual extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool destructive;
  final bool expand;
  final String? semanticsLabel;
  final TextStyle baseTextStyle;
  final Color primary;
  final Color danger;
  final bool isDark;
  final int? itemIndex;
  final Color? hoverColor;
  const _MenuButtonVisual({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.destructive,
    required this.expand,
    required this.baseTextStyle,
    required this.primary,
    required this.danger,
    required this.isDark,
    this.semanticsLabel,
    this.itemIndex,
    this.hoverColor,
  });
  @override
  State<_MenuButtonVisual> createState() => _MenuButtonVisualState();
}

class _MenuButtonVisualState extends State<_MenuButtonVisual> {
  bool _hovered = false;
  bool _pressed = false;
  void _setHovered(bool v) => setState(() => _hovered = v);
  void _setPressed(bool v) => setState(() => _pressed = v);
  @override
  Widget build(BuildContext context) {
    final inheritedIndex = _InheritedHoveredIndex.maybeOf(context);
    final bool keyboardHover =
        inheritedIndex != null && (widget.itemIndex == inheritedIndex);
    final bool interactive = _hovered || _pressed || keyboardHover;
    final Color accent = widget.destructive ? widget.danger : widget.primary;
    final Color textColor =
        widget.destructive ? widget.danger : accent.withValues(alpha: 0.92);
    final Color defaultHover = widget.isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.05);
    final Color bg =
        interactive ? (widget.hoverColor ?? defaultHover) : Colors.transparent;
    final double barOpacity = (_hovered || keyboardHover) ? 0.55 : 0.0;
    final double scale = _pressed ? 0.97 : 1.0;
    final row = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(widget.icon, size: 16, color: textColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(widget.label,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: widget.baseTextStyle.copyWith(color: textColor)),
        ),
      ],
    );
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      transform: Matrix4.diagonal3Values(scale, scale, 1.0),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(0)),
      child: Stack(children: [
        Positioned(
          left: 0,
          top: 2,
          bottom: 2,
          width: 3,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: barOpacity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: accent, borderRadius: BorderRadius.circular(2)),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(left: 4), child: row),
      ]),
    );
    return Semantics(
      button: true,
      label: widget.semanticsLabel ?? widget.label,
      onTapHint: 'Activate',
      child: MouseRegion(
        onEnter: (_) {
          _setHovered(true);
          if (widget.itemIndex != null) {
            _HoveredIndexController.of(context)?.setIndex(widget.itemIndex!);
          }
        },
        onExit: (_) => _setHovered(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          onTap: widget.onPressed,
          child: child,
        ),
      ),
    );
  }
}

class _ContextMenuPanel extends StatefulWidget {
  final List<Widget> children;
  final double width;
  final double? maxHeight;
  final double? contentHeight;
  final String? semanticsMenuLabel;
  final Color? hoverColor;
  final SContextMenuTheme theme;
  final List<VoidCallback> activators;
  const _ContextMenuPanel({
    required this.children,
    required this.width,
    this.maxHeight,
    this.contentHeight,
    this.semanticsMenuLabel,
    // ignore: unused_element_parameter
    this.hoverColor,
    required this.theme,
    required this.activators,
  });
  @override
  State<_ContextMenuPanel> createState() => _ContextMenuPanelState();
}

class _ContextMenuPanelState extends State<_ContextMenuPanel> {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = widget.theme.resolveBackground(brightness);
    final border = widget.theme.resolveBorder(brightness);
    final bool needsScroll = widget.maxHeight != null &&
        widget.contentHeight != null &&
        widget.contentHeight! > widget.maxHeight!;
    final inheritedIndex = _InheritedHoveredIndex.maybeOf(context);
    final listContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < widget.children.length; i++) ...[
          if (i > 0)
            Divider(
                height: 1,
                thickness: 0.6,
                color: border.withValues(alpha: border.a * 0.55)),
          _KeyboardHoverWrapper(
            index: i,
            hovered: inheritedIndex == i,
            tint: widget.hoverColor,
            child: widget.children[i],
          ),
        ],
      ],
    );
    final maybeScrollable = needsScroll
        ? ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: widget.maxHeight!,
                minWidth: widget.width,
                maxWidth: widget.width),
            child: ScrollConfiguration(
              behavior: const ScrollBehavior()
                  .copyWith(overscroll: false, scrollbars: false),
              child: PrimaryScrollController(
                controller: ScrollController(),
                child: SingleChildScrollView(
                    padding: EdgeInsets.zero, child: listContent),
              ),
            ),
          )
        : listContent;
    return Semantics(
      container: true,
      label: widget.semanticsMenuLabel ?? 'Context menu',
      explicitChildNodes: true,
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: widget.width),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.theme.panelBorderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: widget.theme.panelBlurSigma,
                sigmaY: widget.theme.panelBlurSigma),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                border:
                    Border.all(color: /* border */ Colors.black, width: 0.5),
                borderRadius:
                    BorderRadius.circular(widget.theme.panelBorderRadius),
                boxShadow: widget.theme.resolveShadows(brightness),
              ),
              child: maybeScrollable,
            ),
          ),
        ),
      ),
    );
  }
}

// Wraps each item to provide a tinted background when keyboard-hovered.
class _KeyboardHoverWrapper extends StatelessWidget {
  final Widget child;
  final bool hovered;
  final int index;
  final Color? tint;
  const _KeyboardHoverWrapper({
    required this.child,
    required this.hovered,
    required this.index,
    this.tint,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final tempTint = hovered
        ? (isDark
            ? Colors.white.withValues(alpha: 0.08)
            : tint ?? Colors.purple.shade400.withValues(alpha: 0.1))
        : null;
    final decorated = tempTint == null
        ? child
        : DecoratedBox(
            decoration: BoxDecoration(color: tempTint),
            position: DecorationPosition.background,
            child: child,
          );
    return MouseRegion(
      onEnter: (_) => _HoveredIndexController.of(context)?.setIndex(index),
      child: decorated,
    );
  }
}

class _AnimatedMenuShell extends StatefulWidget {
  final bool animationForward;
  final Duration showDuration;
  final Duration hideDuration;
  final VoidCallback onDismissOutsideTap;
  final VoidCallback onEscapeDismiss;
  final void Function(Offset globalPosition) onOverlayRightClick;
  final Widget child;
  final Offset pointer;
  final Rect panelRect;
  final Size overlaySize;
  final ArrowConfig arrowConfig;
  final int buttonCount;
  final void Function(int index) requestActivate; // called on ENTER/SPACE
  final SContextMenuTheme theme;
  const _AnimatedMenuShell({
    required this.animationForward,
    required this.showDuration,
    required this.hideDuration,
    required this.onDismissOutsideTap,
    required this.onEscapeDismiss,
    required this.onOverlayRightClick,
    required this.child,
    required this.pointer,
    required this.panelRect,
    required this.overlaySize,
    required this.arrowConfig,
    required this.buttonCount,
    required this.requestActivate,
    required this.theme,
  });
  @override
  State<_AnimatedMenuShell> createState() => _AnimatedMenuShellState();
}

class _AnimatedMenuShellState extends State<_AnimatedMenuShell> {
  int _hovered = 0;

  void _handleKey(KeyDownEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onEscapeDismiss();
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() => _hovered = (_hovered + 1) % widget.buttonCount);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() =>
          _hovered = (_hovered - 1 + widget.buttonCount) % widget.buttonCount);
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      widget.requestActivate(_hovered);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brightness = Theme.of(context).brightness;
    final Color fillColor = widget.theme.resolveArrowColor(brightness);
    final Color borderColor = widget.theme.resolveBorder(brightness);
    final Color shadowColor =
        Colors.black.withValues(alpha: isDark ? 0.35 : 0.25);
    final arrow = _MenuArrow(
      pointer: widget.pointer,
      fillColor: fillColor,
      borderColor: borderColor,
      shadowColor: shadowColor,
      panelRect: widget.panelRect,
      overlaySize: widget.overlaySize,
      config: widget.arrowConfig,
    );
    final Alignment scaleAlignment = switch (widget.arrowConfig.corner) {
      ArrowCorner.topLeft => Alignment.topLeft,
      ArrowCorner.topRight => Alignment.topRight,
      ArrowCorner.bottomLeft => Alignment.bottomLeft,
      ArrowCorner.bottomRight => Alignment.bottomRight,
    };
    return KeystrokeListener(
      onKeyEvent: _handleKey,
      child: _HoveredIndexController(
        getIndex: () => _hovered,
        setIndex: (i) {
          if (i < 0 || i >= widget.buttonCount) return;
          if (i == _hovered) return;
          setState(() => _hovered = i);
        },
        child: STweenAnimationBuilder<double>(
          key: ValueKey(widget.animationForward),
          tween: Tween<double>(
              begin: 0.0, end: widget.animationForward ? 1.0 : 0.0),
          duration: widget.animationForward
              ? widget.showDuration
              : widget.hideDuration,
          curve: widget.animationForward
              ? Curves.easeOutCubic
              : Curves.easeInCubic,
          builder: (context, fadeValue, child) {
            return Opacity(
              opacity: fadeValue,
              child: Transform.scale(
                alignment: scaleAlignment,
                scale: 0.983 + (fadeValue * 0.017), // 0.983 to 1.0
                child: child!,
              ),
            );
          },
          child: Stack(children: [
            // Background tap detector - but we need to exclude the menu area
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (event) {
                  if (event.buttons == kSecondaryMouseButton) {
                    widget.onOverlayRightClick(event.position);
                  } else {
                    // Check if tap is outside the panel rect
                    if (!widget.panelRect.contains(event.localPosition)) {
                      widget.onDismissOutsideTap();
                    }
                  }
                },
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: widget.panelRect.left,
              top: widget.panelRect.top,
              width: widget.panelRect.width,
              child: _InheritedHoveredIndex(
                hoveredIndex: _hovered,
                child: widget.child,
              ),
            ),
            arrow,
          ]),
        ),
      ),
    );
  }
}

// Inherited widget so nested buttons can know the keyboard hovered index if they want to adapt visuals.
class _InheritedHoveredIndex extends InheritedWidget {
  final int hoveredIndex;
  const _InheritedHoveredIndex(
      {required this.hoveredIndex, required super.child});
  static int? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_InheritedHoveredIndex>()
      ?.hoveredIndex;
  @override
  bool updateShouldNotify(covariant _InheritedHoveredIndex oldWidget) =>
      oldWidget.hoveredIndex != hoveredIndex;
}

class _HoveredIndexController extends InheritedWidget {
  final int Function() getIndex;
  final void Function(int) setIndex;
  const _HoveredIndexController(
      {required this.getIndex, required this.setIndex, required super.child});
  static _HoveredIndexController? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HoveredIndexController>();
  @override
  bool updateShouldNotify(covariant _HoveredIndexController oldWidget) => false;
}

class _MenuArrow extends StatelessWidget {
  final Offset pointer;
  final Rect panelRect;
  final Size overlaySize;
  final ArrowConfig config;
  final Color fillColor;
  final Color borderColor;
  final Color shadowColor;
  const _MenuArrow({
    required this.pointer,
    required this.panelRect,
    required this.overlaySize,
    required this.config,
    required this.fillColor,
    required this.borderColor,
    required this.shadowColor,
  });
  @override
  Widget build(BuildContext context) {
    final g = SContextMenuControllers.computeGeometry(
        pointer, panelRect, overlaySize, config);
    final path = SContextMenuControllers.createArrowPath(g, config);
    final bounds = path.getBounds();
    final localPath = path.shift(-bounds.topLeft);
    return Positioned(
      left: bounds.left,
      top: bounds.top,
      width: bounds.width,
      height: bounds.height,
      child: IgnorePointer(
        child: ClipPath(
          clipper: _StaticPathClipper(localPath),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: CustomPaint(
              size: bounds.size,
              painter: _ArrowPainter(
                path: localPath,
                fillColor: fillColor,
                borderColor: borderColor,
                shadowColor: shadowColor,
                cornerRadius: config.cornerRadius,
                shadowBlur: config.shape == ArrowShape.smallTriangle ? 2.5 : 5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Path path;
  final Color fillColor;
  final Color borderColor;
  final Color shadowColor;
  final double cornerRadius;
  final double shadowBlur;
  const _ArrowPainter({
    required this.path,
    required this.fillColor,
    required this.borderColor,
    required this.shadowColor,
    this.cornerRadius = 6.0,
    this.shadowBlur = 6.0,
  });
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawShadow(path, shadowColor, shadowBlur, true);
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(path, fillPaint);
    final strokeAlpha = math.min(borderColor.a * 1.35, 1.0);
    final strokePaint = Paint()
      ..color = borderColor.withValues(alpha: strokeAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..isAntiAlias = true;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter old) =>
      old.path != path ||
      old.fillColor != fillColor ||
      old.borderColor != borderColor ||
      old.shadowColor != shadowColor ||
      old.cornerRadius != cornerRadius;
}

class _StaticPathClipper extends CustomClipper<Path> {
  final Path _path;
  _StaticPathClipper(this._path);
  @override
  Path getClip(Size size) => _path;
  @override
  bool shouldReclip(covariant _StaticPathClipper oldClipper) =>
      oldClipper._path != _path;
}
