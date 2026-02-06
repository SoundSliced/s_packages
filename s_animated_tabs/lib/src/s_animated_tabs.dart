import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundsliced_tween_animation_builder/soundsliced_tween_animation_builder.dart';

/// A professional, highly customizable animated tab switcher widget
/// that follows Material Design 3 principles and provides smooth animations.
class SAnimatedTabs extends StatefulWidget {
  /// Callback function when tab is selected
  final void Function(int index) onTabSelected;

  /// List of tab titles
  final List<String> tabTitles;

  /// Active tab text style
  final TextStyle? activeTextStyle;

  /// Inactive tab text style
  final TextStyle? inactiveTextStyle;

  /// Tab container height
  final double? height;

  /// Tab container width (defaults to full width if null)
  final double? width;

  /// Background color of the tab container
  final Color? backgroundColor;

  /// Color of the active tab indicator
  final Color? activeColor;

  /// Border radius of the tab container
  final double borderRadius;

  /// Animation duration
  final Duration animationDuration;

  /// Animation curve
  final Curve animationCurve;

  /// Initial selected tab index
  final int initialIndex;

  /// Padding inside the tab container
  final EdgeInsets padding;

  /// Enable haptic feedback on tap
  final bool enableHapticFeedback;

  /// Enable elevation shadow
  final bool enableElevation;

  /// Custom elevation for the container
  final double elevation;

  /// Tab text size preset
  final TabTextSize textSize;

  /// Professional color scheme preset
  final TabColorScheme? colorScheme;

  /// Enable enhanced animations with bounce and scale effects
  final bool enableEnhancedAnimations;

  /// Animation style preset
  final TabAnimationStyle animationStyle;

  const SAnimatedTabs({
    super.key,
    required this.onTabSelected,
    required this.tabTitles,
    this.activeTextStyle,
    this.inactiveTextStyle,
    this.height,
    this.width,
    this.backgroundColor,
    this.activeColor,
    this.borderRadius = 8.0, // Slightly more rounded for modern look
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutQuart,
    this.initialIndex = 0,
    this.padding = const EdgeInsets.all(3.0), // Better spacing
    this.enableHapticFeedback = true,
    this.enableElevation = false,
    this.elevation = 1.0,
    this.textSize = TabTextSize.medium,
    this.colorScheme,
    this.enableEnhancedAnimations = true,
    this.animationStyle = TabAnimationStyle.smooth,
  })  : assert(tabTitles.length > 0, 'Tab titles cannot be empty'),
        assert(initialIndex >= 0 && initialIndex < tabTitles.length,
            'Initial index out of range');

  @override
  State<SAnimatedTabs> createState() => _SAnimatedTabsState();
}

/// Text size presets for professional appearance
enum TabTextSize {
  small(12.0, 0.3),
  medium(14.0, 0.25),
  large(15.0, 0.2);

  const TabTextSize(this.fontSize, this.letterSpacing);
  final double fontSize;
  final double letterSpacing;
}

/// Professional color scheme presets
enum TabColorScheme {
  primary,
  secondary,
  surface,
  outline,
  tertiary,
}

/// Animation style presets for different feels
enum TabAnimationStyle {
  /// Smooth, professional animations
  smooth,

  /// Bouncy, playful animations
  bouncy,

  /// Quick, snappy animations
  snappy,

  /// Elastic, springy animations
  elastic,
}

/// Internal class to hold color information
class _TabColors {
  final Color background;
  final Color activeIndicator;
  final Color activeText;
  final Color inactiveText;

  const _TabColors({
    required this.background,
    required this.activeIndicator,
    required this.activeText,
    required this.inactiveText,
  });
}

/// Internal class to hold animation curve information
class _AnimationCurves {
  final Curve scaleCurve;
  final Curve textCurve;

  const _AnimationCurves({
    required this.scaleCurve,
    required this.textCurve,
  });
}

class _SAnimatedTabsState extends State<SAnimatedTabs> {
  late int _selectedIndex;
  int _animationKey = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  _AnimationCurves _getAnimationCurves() {
    switch (widget.animationStyle) {
      case TabAnimationStyle.smooth:
        return _AnimationCurves(
          scaleCurve: Curves.easeOutCubic,
          textCurve: Curves.easeOutCubic,
        );
      case TabAnimationStyle.bouncy:
        return _AnimationCurves(
          scaleCurve: Curves.bounceOut,
          textCurve: Curves.easeOutBack,
        );
      case TabAnimationStyle.snappy:
        return _AnimationCurves(
          scaleCurve: Curves.easeOutQuart,
          textCurve: Curves.easeOutExpo,
        );
      case TabAnimationStyle.elastic:
        return _AnimationCurves(
          scaleCurve: Curves.elasticOut,
          textCurve: Curves.easeOutBack,
        );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _selectTab(int index) async {
    if (index == _selectedIndex) return;

    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _selectedIndex = index;
      _animationKey++;
    });

    widget.onTabSelected.call(index);
  }

  /// Gets the appropriate color scheme based on widget configuration
  _TabColors _getTabColors(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.colorScheme != null) {
      switch (widget.colorScheme!) {
        case TabColorScheme.primary:
          return _TabColors(
            background: colorScheme.surface,
            activeIndicator: colorScheme.primary,
            activeText: colorScheme.onPrimary,
            inactiveText: colorScheme.onSurfaceVariant,
          );
        case TabColorScheme.secondary:
          return _TabColors(
            background: colorScheme.surface,
            activeIndicator: colorScheme.secondary,
            activeText: colorScheme.onSecondary,
            inactiveText: colorScheme.onSurfaceVariant,
          );
        case TabColorScheme.surface:
          return _TabColors(
            background: colorScheme.surfaceContainerLow,
            activeIndicator: colorScheme.onSurface,
            activeText: colorScheme.surface,
            inactiveText: colorScheme.onSurfaceVariant,
          );
        case TabColorScheme.outline:
          return _TabColors(
            background: Colors.transparent,
            activeIndicator: colorScheme.outline,
            activeText: colorScheme.onSurface,
            inactiveText: colorScheme.onSurfaceVariant,
          );
        case TabColorScheme.tertiary:
          return _TabColors(
            background: colorScheme.surface,
            activeIndicator: colorScheme.tertiary,
            activeText: colorScheme.onTertiary,
            inactiveText: colorScheme.onSurfaceVariant,
          );
      }
    }

    // Default corporate scheme
    return _TabColors(
      background: widget.backgroundColor ?? colorScheme.surface,
      activeIndicator: widget.activeColor ?? colorScheme.primary,
      activeText: colorScheme.onPrimary,
      inactiveText: colorScheme.onSurfaceVariant,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabColors = _getTabColors(context);
    final tabCount = widget.tabTitles.length;
    const defaultHeight = 48.0; // Increased for better proportions

    // Clean, corporate text styles with better typography
    final activeTextStyle = widget.activeTextStyle ??
        TextStyle(
          color: tabColors.activeText,
          fontSize: widget.textSize.fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: widget.textSize.letterSpacing,
          height: 1.1,
          fontFeatures: const [FontFeature.tabularFigures()],
        );

    final inactiveTextStyle = widget.inactiveTextStyle ??
        TextStyle(
          color: tabColors.inactiveText,
          fontSize: widget.textSize.fontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: widget.textSize.letterSpacing,
          height: 1.1,
          fontFeatures: const [FontFeature.tabularFigures()],
        );

    return Container(
      height: widget.height ?? defaultHeight,
      width: widget.width,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: tabColors.background,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.08),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth =
              constraints.maxWidth - widget.padding.horizontal;
          final tabWidth = availableWidth / tabCount;
          final indicatorLeft = _selectedIndex * tabWidth;

          // Get animation curves based on style
          final curves = _getAnimationCurves();

          return STweenAnimationBuilder<double>(
            key: ValueKey(_animationKey),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: widget.animationDuration,
            curve: curves.scaleCurve,
            builder: (context, animationProgress, child) {
              // Scale animation: 70% of total duration (0.0 - 0.7)
              final scaleProgress = (animationProgress * 1.428).clamp(0.0, 1.0);
              final scale = 0.95 + (0.05 * scaleProgress);

              return Stack(
                children: [
                  // Enhanced animated indicator with scale and slide
                  AnimatedPositioned(
                    duration: widget.animationDuration,
                    curve: widget.animationCurve,
                    left: indicatorLeft,
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: tabColors.activeIndicator,
                          borderRadius:
                              BorderRadius.circular(widget.borderRadius - 2),
                          boxShadow: [
                            // Primary shadow for depth
                            BoxShadow(
                              color: tabColors.activeIndicator.withValues(
                                alpha: 0.25 * scale,
                              ),
                              blurRadius: 6 * scale,
                              offset: Offset(0, 2 * scale),
                              spreadRadius: 0,
                            ),
                            // Secondary shadow for softness
                            BoxShadow(
                              color: tabColors.activeIndicator.withValues(
                                alpha: 0.12 * scale,
                              ),
                              blurRadius: 12 * scale,
                              offset: Offset(0, 4 * scale),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Enhanced tab buttons with improved animations - positioned explicitly on top
                  Positioned.fill(
                    child: Row(
                      children: List.generate(tabCount, (index) {
                        final isSelected = index == _selectedIndex;

                        return Expanded(
                          child: _EnhancedTabButton(
                            isSelected: isSelected,
                            title: widget.tabTitles[index],
                            activeStyle: activeTextStyle,
                            inactiveStyle: inactiveTextStyle,
                            animationDuration: widget.animationDuration,
                            animationCurve: widget.animationCurve,
                            textFadeValue: 1.0, // Always full opacity for text
                            onTap: () => _selectTab(index),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Enhanced tab button with improved animations and feedback
class _EnhancedTabButton extends StatefulWidget {
  final bool isSelected;
  final String title;
  final TextStyle activeStyle;
  final TextStyle inactiveStyle;
  final Duration animationDuration;
  final Curve animationCurve;
  final double textFadeValue;
  final VoidCallback onTap;

  const _EnhancedTabButton({
    required this.isSelected,
    required this.title,
    required this.activeStyle,
    required this.inactiveStyle,
    required this.animationDuration,
    required this.animationCurve,
    required this.textFadeValue,
    required this.onTap,
  });

  @override
  State<_EnhancedTabButton> createState() => _EnhancedTabButtonState();
}

class _EnhancedTabButtonState extends State<_EnhancedTabButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  double get _targetScale {
    if (_isPressed) return 0.98;
    if (_isHovered && !widget.isSelected) return 1.02;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _targetScale,
      duration: const Duration(milliseconds: 200),
      curve: _isPressed ? Curves.easeInCubic : Curves.easeOutCubic,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: double.infinity,
            alignment: Alignment.center,
            decoration: _isHovered && !widget.isSelected
                ? BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.06),
                      width: 0.5,
                    ),
                  )
                : null,
            child: AnimatedOpacity(
              duration: widget.animationDuration,
              opacity: widget.textFadeValue,
              child: AnimatedDefaultTextStyle(
                duration: widget.animationDuration,
                curve: widget.animationCurve,
                style: widget.isSelected
                    ? widget.activeStyle
                    : widget.inactiveStyle,
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: widget.isSelected
                      ? TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          inherit: false,
                        )
                      : null, // Let inactive style take precedence
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
