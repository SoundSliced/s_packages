// The bridge has to read the legacy theme, so it is the one place in the
// package that still imports `package:flutter/material.dart`.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as legacy;
import 'package:material_ui/material_ui.dart';

/// Bridges an app built on `package:flutter/material.dart` to the
/// `package:material_ui` widgets of `s_packages`.
///
/// `package:material_ui` is not an alias of `package:flutter/material.dart`:
/// it ships its own `Theme`, `MaterialLocalizations`, `Material` and
/// `ScaffoldMessenger`. A `MaterialApp` from `package:flutter/material.dart`
/// provides only the legacy ones, so `s_packages` widgets beneath it would
/// fall back to default colours, assert `No MaterialLocalizations found` or
/// `No Material widget found`, and could not show snack bars.
///
/// This widget provides, from the legacy ones above it:
/// * a `material_ui` [Theme] mapped from the legacy theme (colours, text,
///   density and the common component themes);
/// * `material_ui` and `cupertino_ui` localizations for the current locale;
/// * a [ScaffoldMessenger] with a transparent [Scaffold], which is also the
///   [Material] that ink and text fields need.
///
/// Wrap the app once, inside `MaterialApp.builder`, so routes, dialogs and
/// overlays are all below it:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => SMaterialUiBridge(child: child!),
///   home: const HomePage(),
/// );
/// ```
///
/// An app built on `package:material_ui` does not need it.
class SMaterialUiBridge extends StatelessWidget {
  /// Creates a bridge around [child].
  const SMaterialUiBridge({super.key, required this.child});

  /// The subtree that uses `s_packages` widgets.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: mapLegacyTheme(legacy.Theme.of(context)),
      child: Localizations.override(
        context: context,
        delegates: GlobalMaterialLocalizations.delegates,
        child: ScaffoldMessenger(
          child: Scaffold(
            backgroundColor: const Color(0x00000000),
            resizeToAvoidBottomInset: false,
            body: child,
          ),
        ),
      ),
    );
  }

  /// Maps a `package:flutter/material.dart` theme to a `package:material_ui`
  /// one. Colours, text, density and the common component themes carry
  /// over; theme extensions do not, as their classes extend the legacy
  /// `ThemeExtension`.
  static ThemeData mapLegacyTheme(legacy.ThemeData t) {
    return ThemeData(
      useMaterial3: t.useMaterial3,
      platform: t.platform,
      visualDensity: VisualDensity(
        horizontal: t.visualDensity.horizontal,
        vertical: t.visualDensity.vertical,
      ),
      materialTapTargetSize:
          MaterialTapTargetSize.values[t.materialTapTargetSize.index],
      colorScheme: _colorScheme(t.colorScheme),
      textTheme: _textTheme(t.textTheme),
      primaryTextTheme: _textTheme(t.primaryTextTheme),
      iconTheme: t.iconTheme,
      primaryIconTheme: t.primaryIconTheme,
      primaryColor: t.primaryColor,
      primaryColorLight: t.primaryColorLight,
      primaryColorDark: t.primaryColorDark,
      scaffoldBackgroundColor: t.scaffoldBackgroundColor,
      canvasColor: t.canvasColor,
      cardColor: t.cardColor,
      dividerColor: t.dividerColor,
      disabledColor: t.disabledColor,
      hintColor: t.hintColor,
      focusColor: t.focusColor,
      hoverColor: t.hoverColor,
      highlightColor: t.highlightColor,
      splashColor: t.splashColor,
      shadowColor: t.shadowColor,
      unselectedWidgetColor: t.unselectedWidgetColor,
      secondaryHeaderColor: t.secondaryHeaderColor,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: t.textSelectionTheme.cursorColor,
        selectionColor: t.textSelectionTheme.selectionColor,
        selectionHandleColor: t.textSelectionTheme.selectionHandleColor,
      ),
      tooltipTheme: TooltipThemeData(
        constraints: t.tooltipTheme.constraints,
        padding: t.tooltipTheme.padding,
        margin: t.tooltipTheme.margin,
        verticalOffset: t.tooltipTheme.verticalOffset,
        preferBelow: t.tooltipTheme.preferBelow,
        excludeFromSemantics: t.tooltipTheme.excludeFromSemantics,
        decoration: t.tooltipTheme.decoration,
        textStyle: t.tooltipTheme.textStyle,
        textAlign: t.tooltipTheme.textAlign,
        waitDuration: t.tooltipTheme.waitDuration,
        showDuration: t.tooltipTheme.showDuration,
        exitDuration: t.tooltipTheme.exitDuration,
        enableFeedback: t.tooltipTheme.enableFeedback,
      ),
      dividerTheme: DividerThemeData(
        color: t.dividerTheme.color,
        space: t.dividerTheme.space,
        thickness: t.dividerTheme.thickness,
        indent: t.dividerTheme.indent,
        endIndent: t.dividerTheme.endIndent,
        radius: t.dividerTheme.radius,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.dialogTheme.backgroundColor,
        elevation: t.dialogTheme.elevation,
        shadowColor: t.dialogTheme.shadowColor,
        surfaceTintColor: t.dialogTheme.surfaceTintColor,
        shape: t.dialogTheme.shape,
        alignment: t.dialogTheme.alignment,
        iconColor: t.dialogTheme.iconColor,
        titleTextStyle: t.dialogTheme.titleTextStyle,
        contentTextStyle: t.dialogTheme.contentTextStyle,
        actionsPadding: t.dialogTheme.actionsPadding,
        barrierColor: t.dialogTheme.barrierColor,
        insetPadding: t.dialogTheme.insetPadding,
        clipBehavior: t.dialogTheme.clipBehavior,
        constraints: t.dialogTheme.constraints,
      ),
      cardTheme: CardThemeData(
        clipBehavior: t.cardTheme.clipBehavior,
        color: t.cardTheme.color,
        surfaceTintColor: t.cardTheme.surfaceTintColor,
        shadowColor: t.cardTheme.shadowColor,
        elevation: t.cardTheme.elevation,
        margin: t.cardTheme.margin,
        shape: t.cardTheme.shape,
      ),
      chipTheme: ChipThemeData(
        color: t.chipTheme.color,
        backgroundColor: t.chipTheme.backgroundColor,
        deleteIconColor: t.chipTheme.deleteIconColor,
        disabledColor: t.chipTheme.disabledColor,
        selectedColor: t.chipTheme.selectedColor,
        secondarySelectedColor: t.chipTheme.secondarySelectedColor,
        shadowColor: t.chipTheme.shadowColor,
        surfaceTintColor: t.chipTheme.surfaceTintColor,
        selectedShadowColor: t.chipTheme.selectedShadowColor,
        showCheckmark: t.chipTheme.showCheckmark,
        checkmarkColor: t.chipTheme.checkmarkColor,
        labelPadding: t.chipTheme.labelPadding,
        padding: t.chipTheme.padding,
        side: t.chipTheme.side,
        shape: t.chipTheme.shape,
        labelStyle: t.chipTheme.labelStyle,
        secondaryLabelStyle: t.chipTheme.secondaryLabelStyle,
        brightness: t.chipTheme.brightness,
        elevation: t.chipTheme.elevation,
        pressElevation: t.chipTheme.pressElevation,
        iconTheme: t.chipTheme.iconTheme,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: t.scrollbarTheme.thumbVisibility,
        thickness: t.scrollbarTheme.thickness,
        trackVisibility: t.scrollbarTheme.trackVisibility,
        radius: t.scrollbarTheme.radius,
        thumbColor: t.scrollbarTheme.thumbColor,
        trackColor: t.scrollbarTheme.trackColor,
        trackBorderColor: t.scrollbarTheme.trackBorderColor,
        crossAxisMargin: t.scrollbarTheme.crossAxisMargin,
        mainAxisMargin: t.scrollbarTheme.mainAxisMargin,
        minThumbLength: t.scrollbarTheme.minThumbLength,
        interactive: t.scrollbarTheme.interactive,
      ),
      inputDecorationTheme: _inputDecorationTheme(t.inputDecorationTheme),
      iconButtonTheme: IconButtonThemeData(
        style: _buttonStyle(t.iconButtonTheme.style),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonStyle(t.elevatedButtonTheme.style),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _buttonStyle(t.filledButtonTheme.style),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonStyle(t.outlinedButtonTheme.style),
      ),
      textButtonTheme: TextButtonThemeData(
        style: _buttonStyle(t.textButtonTheme.style),
      ),
    );
  }

  static ColorScheme _colorScheme(legacy.ColorScheme s) => ColorScheme(
    brightness: s.brightness,
    primary: s.primary,
    onPrimary: s.onPrimary,
    primaryContainer: s.primaryContainer,
    onPrimaryContainer: s.onPrimaryContainer,
    primaryFixed: s.primaryFixed,
    primaryFixedDim: s.primaryFixedDim,
    onPrimaryFixed: s.onPrimaryFixed,
    onPrimaryFixedVariant: s.onPrimaryFixedVariant,
    secondary: s.secondary,
    onSecondary: s.onSecondary,
    secondaryContainer: s.secondaryContainer,
    onSecondaryContainer: s.onSecondaryContainer,
    secondaryFixed: s.secondaryFixed,
    secondaryFixedDim: s.secondaryFixedDim,
    onSecondaryFixed: s.onSecondaryFixed,
    onSecondaryFixedVariant: s.onSecondaryFixedVariant,
    tertiary: s.tertiary,
    onTertiary: s.onTertiary,
    tertiaryContainer: s.tertiaryContainer,
    onTertiaryContainer: s.onTertiaryContainer,
    tertiaryFixed: s.tertiaryFixed,
    tertiaryFixedDim: s.tertiaryFixedDim,
    onTertiaryFixed: s.onTertiaryFixed,
    onTertiaryFixedVariant: s.onTertiaryFixedVariant,
    error: s.error,
    onError: s.onError,
    errorContainer: s.errorContainer,
    onErrorContainer: s.onErrorContainer,
    surface: s.surface,
    onSurface: s.onSurface,
    surfaceDim: s.surfaceDim,
    surfaceBright: s.surfaceBright,
    surfaceContainerLowest: s.surfaceContainerLowest,
    surfaceContainerLow: s.surfaceContainerLow,
    surfaceContainer: s.surfaceContainer,
    surfaceContainerHigh: s.surfaceContainerHigh,
    surfaceContainerHighest: s.surfaceContainerHighest,
    onSurfaceVariant: s.onSurfaceVariant,
    outline: s.outline,
    outlineVariant: s.outlineVariant,
    shadow: s.shadow,
    scrim: s.scrim,
    inverseSurface: s.inverseSurface,
    onInverseSurface: s.onInverseSurface,
    inversePrimary: s.inversePrimary,
    surfaceTint: s.surfaceTint,
  );

  static TextTheme _textTheme(legacy.TextTheme t) => TextTheme(
    displayLarge: t.displayLarge,
    displayMedium: t.displayMedium,
    displaySmall: t.displaySmall,
    headlineLarge: t.headlineLarge,
    headlineMedium: t.headlineMedium,
    headlineSmall: t.headlineSmall,
    titleLarge: t.titleLarge,
    titleMedium: t.titleMedium,
    titleSmall: t.titleSmall,
    bodyLarge: t.bodyLarge,
    bodyMedium: t.bodyMedium,
    bodySmall: t.bodySmall,
    labelLarge: t.labelLarge,
    labelMedium: t.labelMedium,
    labelSmall: t.labelSmall,
  );

  static ButtonStyle? _buttonStyle(legacy.ButtonStyle? s) {
    if (s == null) return null;
    final tapTargetSize = s.tapTargetSize;
    final visualDensity = s.visualDensity;
    return ButtonStyle(
      textStyle: s.textStyle,
      backgroundColor: s.backgroundColor,
      foregroundColor: s.foregroundColor,
      overlayColor: s.overlayColor,
      shadowColor: s.shadowColor,
      surfaceTintColor: s.surfaceTintColor,
      elevation: s.elevation,
      padding: s.padding,
      minimumSize: s.minimumSize,
      fixedSize: s.fixedSize,
      maximumSize: s.maximumSize,
      iconColor: s.iconColor,
      iconSize: s.iconSize,
      side: s.side,
      shape: s.shape,
      mouseCursor: s.mouseCursor,
      visualDensity: visualDensity == null
          ? null
          : VisualDensity(
              horizontal: visualDensity.horizontal,
              vertical: visualDensity.vertical,
            ),
      tapTargetSize: tapTargetSize == null
          ? null
          : MaterialTapTargetSize.values[tapTargetSize.index],
      animationDuration: s.animationDuration,
      enableFeedback: s.enableFeedback,
      alignment: s.alignment,
    );
  }

  static InputDecorationThemeData _inputDecorationTheme(
    legacy.InputDecorationThemeData d,
  ) {
    return InputDecorationThemeData(
      labelStyle: d.labelStyle,
      floatingLabelStyle: d.floatingLabelStyle,
      helperStyle: d.helperStyle,
      helperMaxLines: d.helperMaxLines,
      hintStyle: d.hintStyle,
      hintFadeDuration: d.hintFadeDuration,
      errorStyle: d.errorStyle,
      errorMaxLines: d.errorMaxLines,
      floatingLabelBehavior:
          FloatingLabelBehavior.values[d.floatingLabelBehavior.index],
      isDense: d.isDense,
      contentPadding: d.contentPadding,
      isCollapsed: d.isCollapsed,
      iconColor: d.iconColor,
      prefixStyle: d.prefixStyle,
      prefixIconColor: d.prefixIconColor,
      prefixIconConstraints: d.prefixIconConstraints,
      suffixStyle: d.suffixStyle,
      suffixIconColor: d.suffixIconColor,
      suffixIconConstraints: d.suffixIconConstraints,
      counterStyle: d.counterStyle,
      filled: d.filled,
      fillColor: d.fillColor,
      activeIndicatorBorder: d.activeIndicatorBorder,
      outlineBorder: d.outlineBorder,
      focusColor: d.focusColor,
      hoverColor: d.hoverColor,
      errorBorder: _inputBorder(d.errorBorder),
      focusedBorder: _inputBorder(d.focusedBorder),
      focusedErrorBorder: _inputBorder(d.focusedErrorBorder),
      disabledBorder: _inputBorder(d.disabledBorder),
      enabledBorder: _inputBorder(d.enabledBorder),
      border: _inputBorder(d.border),
      alignLabelWithHint: d.alignLabelWithHint,
      constraints: d.constraints,
    );
  }

  /// Maps a `package:flutter/material.dart` [legacy.InputDecoration], for
  /// example one an app builds for its own text fields, so it can be given
  /// to an `s_packages` field such as `TimeInput`.
  static InputDecoration mapInputDecoration(legacy.InputDecoration d) {
    final floatingLabelBehavior = d.floatingLabelBehavior;
    final visualDensity = d.visualDensity;
    return InputDecoration(
      icon: d.icon,
      iconColor: d.iconColor,
      label: d.label,
      labelText: d.labelText,
      labelStyle: d.labelStyle,
      floatingLabelStyle: d.floatingLabelStyle,
      helper: d.helper,
      helperText: d.helperText,
      helperStyle: d.helperStyle,
      helperMaxLines: d.helperMaxLines,
      hintText: d.hintText,
      hint: d.hint,
      hintStyle: d.hintStyle,
      hintTextDirection: d.hintTextDirection,
      hintMaxLines: d.hintMaxLines,
      hintFadeDuration: d.hintFadeDuration,
      maintainHintSize: d.maintainHintSize,
      error: d.error,
      errorText: d.errorText,
      errorStyle: d.errorStyle,
      errorMaxLines: d.errorMaxLines,
      floatingLabelBehavior: floatingLabelBehavior == null
          ? null
          : FloatingLabelBehavior.values[floatingLabelBehavior.index],
      floatingLabelAlignment:
          d.floatingLabelAlignment == legacy.FloatingLabelAlignment.center
          ? FloatingLabelAlignment.center
          : d.floatingLabelAlignment == null
          ? null
          : FloatingLabelAlignment.start,
      isCollapsed: d.isCollapsed,
      isDense: d.isDense,
      contentPadding: d.contentPadding,
      prefixIcon: d.prefixIcon,
      prefixIconConstraints: d.prefixIconConstraints,
      prefix: d.prefix,
      prefixText: d.prefixText,
      prefixStyle: d.prefixStyle,
      prefixIconColor: d.prefixIconColor,
      suffixIcon: d.suffixIcon,
      suffix: d.suffix,
      suffixText: d.suffixText,
      suffixStyle: d.suffixStyle,
      suffixIconColor: d.suffixIconColor,
      suffixIconConstraints: d.suffixIconConstraints,
      counter: d.counter,
      counterText: d.counterText,
      counterStyle: d.counterStyle,
      filled: d.filled,
      fillColor: d.fillColor,
      focusColor: d.focusColor,
      hoverColor: d.hoverColor,
      errorBorder: _inputBorder(d.errorBorder),
      focusedBorder: _inputBorder(d.focusedBorder),
      focusedErrorBorder: _inputBorder(d.focusedErrorBorder),
      disabledBorder: _inputBorder(d.disabledBorder),
      enabledBorder: _inputBorder(d.enabledBorder),
      border: _inputBorder(d.border),
      enabled: d.enabled,
      semanticCounterText: d.semanticCounterText,
      alignLabelWithHint: d.alignLabelWithHint,
      constraints: d.constraints,
      visualDensity: visualDensity == null
          ? null
          : VisualDensity(
              horizontal: visualDensity.horizontal,
              vertical: visualDensity.vertical,
            ),
    );
  }

  /// Maps the legacy input borders the framework ships; any other border
  /// subclass falls back to the `material_ui` default.
  static InputBorder? _inputBorder(legacy.InputBorder? b) => switch (b) {
    legacy.OutlineInputBorder() => OutlineInputBorder(
      borderSide: b.borderSide,
      borderRadius: b.borderRadius,
      gapPadding: b.gapPadding,
    ),
    legacy.UnderlineInputBorder() => UnderlineInputBorder(
      borderSide: b.borderSide,
      borderRadius: b.borderRadius,
    ),
    legacy.InputBorder()
        when b.isOutline == false && b.borderSide == BorderSide.none =>
      InputBorder.none,
    _ => null,
  };
}
