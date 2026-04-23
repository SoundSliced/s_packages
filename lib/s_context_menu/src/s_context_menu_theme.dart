import 'package:flutter/material.dart';

import 's_context_menu_types.dart';

/// Theme and styling configuration for [SContextMenu].
///
/// You can provide an instance to the `theme:` parameter of `SContextMenu`
/// to override colors, radii, elevation/shadow, blur, padding and arrow style.
/// Missing values fall back to adaptive defaults derived from current
/// [ThemeData]/[CupertinoTheme].
class SContextMenuTheme {
  /// Whether to render the arrow pointer.
  ///
  /// Set to false for a clean floating panel style.
  final bool showArrow;

  /// Default modern preset used by the package.
  static const SContextMenuTheme modern = SContextMenuTheme();

  /// Compact preset for dense UIs / data-heavy tools.
  static const SContextMenuTheme compact = SContextMenuTheme(
    showArrow: false,
    panelBorderRadius: 10,
    panelBlurSigma: 10,
    panelPadding: EdgeInsets.symmetric(vertical: 2),
    arrowBaseWidth: 10,
    arrowCornerRadius: 5,
    arrowMaxLength: 2,
    showDuration: Duration(milliseconds: 150),
    hideDuration: Duration(milliseconds: 110),
  );

  /// Desktop-oriented preset (clean floating panel, crisp borders, lower blur).
  static const SContextMenuTheme desktop = SContextMenuTheme(
    showArrow: false,
    panelBorderRadius: 11,
    panelBlurSigma: 8,
    panelPadding: EdgeInsets.symmetric(vertical: 4),
    panelBackgroundColor: Color(0xFFFDFEFF),
    panelBorderColor: Color(0xFFD8E2EE),
    showDuration: Duration(milliseconds: 140),
    hideDuration: Duration(milliseconds: 100),
  );

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
    this.showArrow = false,
    this.panelBorderRadius = 12,
    this.panelBlurSigma = 14,
    this.panelPadding = const EdgeInsets.symmetric(vertical: 6),
    this.panelBackgroundColor,
    this.panelBorderColor,
    this.panelShadows,
    this.arrowShape = ArrowShape.curved,
    this.arrowBaseWidth = 12,
    this.arrowCornerRadius = 6,
    this.arrowTipGap = 2,
    this.arrowMaxLength = 3,
    this.arrowTipRoundness = 2,
    this.showDuration = const Duration(milliseconds: 170),
    this.hideDuration = const Duration(milliseconds: 120),
    this.iconColor,
    this.destructiveColor,
    this.hoverColor,
    this.arrowColor,
  });

  SContextMenuTheme copyWith({
    bool? showArrow,
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
        showArrow: showArrow ?? this.showArrow,
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
      panelBackgroundColor ?? (brightness == Brightness.dark ? const Color(0xF5222936) : const Color(0xFDFEFFff));

  Color resolveBorder(Brightness brightness) =>
      panelBorderColor ?? (brightness == Brightness.dark ? const Color(0x336B7280) : const Color(0xFFDDE5F0));

  List<BoxShadow> resolveShadows(Brightness brightness) =>
      panelShadows ??
      [
        BoxShadow(
          color: Colors.black.withValues(alpha: brightness == Brightness.dark ? 0.34 : 0.16),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: (brightness == Brightness.dark ? const Color(0xFF0F172A) : const Color(0xFF1D4ED8))
              .withValues(alpha: brightness == Brightness.dark ? 0.16 : 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// Resolve icon/text color. Falls back to primary color from context.
  Color resolveIconColor(Color fallbackPrimary) => iconColor ?? fallbackPrimary.withValues(alpha: 0.92);

  /// Resolve destructive color. Falls back to red.
  Color resolveDestructiveColor() => destructiveColor ?? const Color(0xFFDC2626);

  /// Resolve hover background color based on brightness.
  Color resolveHoverColor(bool isDark) =>
      hoverColor ?? (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0x1A2563EB));

  /// Resolve arrow color. Falls back to panel background color.
  Color resolveArrowColor(Brightness brightness) => arrowColor ?? resolveBackground(brightness);
}
