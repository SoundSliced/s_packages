import 'package:flutter/material.dart';

import 's_context_menu_types.dart';

/// Theme and styling configuration for [SContextMenu].
///
/// You can provide an instance to the `theme:` parameter of `SContextMenu`
/// to override colors, radii, elevation/shadow, blur, padding and arrow style.
/// Missing values fall back to adaptive defaults derived from current
/// [ThemeData]/[CupertinoTheme].
class SContextMenuTheme {
  final double panelBorderRadius;
  final double panelBlurSigma;
  final EdgeInsets panelPadding;
  final Color? panelBackgroundColor;
  final Color? panelBorderColor;
  final List<BoxShadow>? panelShadows;
  final ArrowShape arrowShape;
  final double arrowBaseWidth;
  final double arrowCornerRadius;
  final double arrowTipGap;
  final double arrowMaxLength;
  final double arrowTipRoundness;
  final Duration showDuration;
  final Duration hideDuration;

  /// Color for menu item icons and text. Falls back to theme primary color.
  final Color? iconColor;

  /// Color for destructive menu item icons and text. Falls back to red.
  final Color? destructiveColor;

  /// Background color for hovered/pressed menu items.
  final Color? hoverColor;

  /// Color for the arrow pointer. Falls back to panel background color.

  /// Color for the arrow pointer. Falls back to panel background color.
  final Color? arrowColor;

  const SContextMenuTheme({
    this.panelBorderRadius = 8,
    this.panelBlurSigma = 20,
    this.panelPadding = const EdgeInsets.symmetric(vertical: 0),
    this.panelBackgroundColor,
    this.panelBorderColor,
    this.panelShadows,
    this.arrowShape = ArrowShape.smallTriangle,
    this.arrowBaseWidth = 10,
    this.arrowCornerRadius = 4,
    this.arrowTipGap = 2,
    this.arrowMaxLength = 2,
    this.arrowTipRoundness = 5,
    this.showDuration = const Duration(milliseconds: 200),
    this.hideDuration = const Duration(milliseconds: 150),
    this.iconColor,
    this.destructiveColor,
    this.hoverColor,
    this.arrowColor,
  });

  SContextMenuTheme copyWith({
    double? panelBorderRadius,
    double? panelBlurSigma,
    EdgeInsets? panelPadding,
    Color? panelBackgroundColor,
    Color? panelBorderColor,
    List<BoxShadow>? panelShadows,
    ArrowShape? arrowShape,
    double? arrowBaseWidth,
    double? arrowCornerRadius,
    double? arrowTipGap,
    double? arrowMaxLength,
    double? arrowTipRoundness,
    Duration? showDuration,
    Duration? hideDuration,
    Color? iconColor,
    Color? destructiveColor,
    Color? hoverColor,
    Color? arrowColor,
  }) =>
      SContextMenuTheme(
        panelBorderRadius: panelBorderRadius ?? this.panelBorderRadius,
        panelBlurSigma: panelBlurSigma ?? this.panelBlurSigma,
        panelPadding: panelPadding ?? this.panelPadding,
        panelBackgroundColor: panelBackgroundColor ?? this.panelBackgroundColor,
        panelBorderColor: panelBorderColor ?? this.panelBorderColor,
        panelShadows: panelShadows ?? this.panelShadows,
        arrowShape: arrowShape ?? this.arrowShape,
        arrowBaseWidth: arrowBaseWidth ?? this.arrowBaseWidth,
        arrowCornerRadius: arrowCornerRadius ?? this.arrowCornerRadius,
        arrowTipGap: arrowTipGap ?? this.arrowTipGap,
        arrowMaxLength: arrowMaxLength ?? this.arrowMaxLength,
        arrowTipRoundness: arrowTipRoundness ?? this.arrowTipRoundness,
        showDuration: showDuration ?? this.showDuration,
        hideDuration: hideDuration ?? this.hideDuration,
        iconColor: iconColor ?? this.iconColor,
        destructiveColor: destructiveColor ?? this.destructiveColor,
        hoverColor: hoverColor ?? this.hoverColor,
        arrowColor: arrowColor ?? this.arrowColor,
      );

  /// Resolve a background color if none provided based on brightness.
  Color resolveBackground(Brightness brightness) =>
      panelBackgroundColor ??
      (brightness == Brightness.dark
          ? const Color(0xCC1E1E1E)
          : const Color(0xCCFFFFFF));

  Color resolveBorder(Brightness brightness) =>
      panelBorderColor ??
      (brightness == Brightness.dark ? Colors.white24 : Colors.black12);

  List<BoxShadow> resolveShadows(Brightness brightness) =>
      panelShadows ??
      [
        BoxShadow(
          color: Colors.black
              .withValues(alpha: brightness == Brightness.dark ? 0.35 : 0.25),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ];

  /// Resolve icon/text color. Falls back to primary color from context.
  Color resolveIconColor(Color fallbackPrimary) => iconColor ?? fallbackPrimary;

  /// Resolve destructive color. Falls back to red.
  Color resolveDestructiveColor() => destructiveColor ?? Colors.red.shade600;

  /// Resolve hover background color based on brightness.
  Color resolveHoverColor(bool isDark) =>
      hoverColor ??
      (isDark
          ? Colors.white.withValues(alpha: 0.07)
          : Colors.black.withValues(alpha: 0.05));

  /// Resolve arrow color. Falls back to panel background color.
  Color resolveArrowColor(Brightness brightness) =>
      arrowColor ?? resolveBackground(brightness);
}
