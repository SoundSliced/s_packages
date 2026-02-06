import 'package:flutter/material.dart';

/// Custom decoration class for SDropdown widget
///
/// This class provides comprehensive styling options for the dropdown widget
/// without depending on external packages.
class SDropdownDecoration {
  /// Dropdown field color (closed state)
  final Color? closedFillColor;

  /// Dropdown overlay color (opened/expanded state)
  final Color? expandedFillColor;

  /// Color for the header when expanded
  final Color? headerExpandedColor;

  /// Dropdown box shadow (closed state)
  final List<BoxShadow>? closedShadow;

  /// Dropdown box shadow (opened/expanded state)
  final List<BoxShadow>? expandedShadow;

  /// Suffix icon for closed state of dropdown
  final Widget? closedSuffixIcon;

  /// Suffix icon for opened/expanded state of dropdown
  final Widget? expandedSuffixIcon;

  /// Dropdown header prefix icon
  final Widget? prefixIcon;

  /// Border for closed state of dropdown
  final BoxBorder? closedBorder;

  /// Border radius for closed state of dropdown
  final BorderRadius? closedBorderRadius;

  /// Error border for closed state of dropdown
  final BoxBorder? closedErrorBorder;

  /// Error border radius for closed state of dropdown
  final BorderRadius? closedErrorBorderRadius;

  /// Border for opened/expanded state of dropdown
  final BoxBorder? expandedBorder;

  /// Border radius for opened/expanded state of dropdown
  final BorderRadius? expandedBorderRadius;

  /// The style to use for the dropdown header hint
  final TextStyle? hintStyle;

  /// The style to use for the dropdown header text
  final TextStyle? headerStyle;

  /// The style to use for the dropdown no result found area
  final TextStyle? noResultFoundStyle;

  /// The style to use for the string returning from validator
  final TextStyle? errorStyle;

  /// The style to use for the dropdown list item text
  final TextStyle? listItemStyle;

  /// Dropdown scrollbar decoration (opened/expanded state)
  final ScrollbarThemeData? overlayScrollbarDecoration;

  /// Padding for the closed header
  final EdgeInsets? closedHeaderPadding;

  /// Padding for the expanded header
  final EdgeInsets? expandedHeaderPadding;

  /// Padding for the items list
  final EdgeInsets? itemsListPadding;

  /// Padding for each list item
  final EdgeInsets? listItemPadding;

  /// Height of the dropdown overlay
  final double? overlayHeight;

  /// Width of the dropdown overlay
  final double? overlayWidth;

  /// Maximum lines for text display
  final int? maxLines;

  const SDropdownDecoration({
    this.closedFillColor,
    this.expandedFillColor,
    this.headerExpandedColor,
    this.closedShadow,
    this.expandedShadow,
    this.closedSuffixIcon,
    this.expandedSuffixIcon,
    this.prefixIcon,
    this.closedBorder,
    this.closedBorderRadius,
    this.closedErrorBorder,
    this.closedErrorBorderRadius,
    this.expandedBorder,
    this.expandedBorderRadius,
    this.hintStyle,
    this.headerStyle,
    this.noResultFoundStyle,
    this.errorStyle,
    this.listItemStyle,
    this.overlayScrollbarDecoration,
    this.closedHeaderPadding,
    this.expandedHeaderPadding,
    this.itemsListPadding,
    this.listItemPadding,
    this.overlayHeight,
    this.overlayWidth,
    this.maxLines,
  });

  /// Default decoration for SDropdown
  static SDropdownDecoration defaultDecoration = SDropdownDecoration(
    closedFillColor: Colors.white,
    expandedFillColor: Colors.white,
    headerExpandedColor: Colors.grey.shade200,
    closedBorder: Border.fromBorderSide(BorderSide(color: Colors.grey)),
    expandedBorder: Border.fromBorderSide(BorderSide(color: Colors.grey)),
    closedBorderRadius: BorderRadius.all(Radius.circular(8)),
    expandedBorderRadius: BorderRadius.all(Radius.circular(8)),
    closedSuffixIcon: Icon(Icons.keyboard_arrow_down, size: 20),
    expandedSuffixIcon: Icon(Icons.keyboard_arrow_down, size: 20),
    headerStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
    listItemStyle: TextStyle(fontSize: 14),
    closedHeaderPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    expandedHeaderPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    itemsListPadding: EdgeInsets.all(4),
    listItemPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    maxLines: 1,
  );

  /// Creates a copy of this decoration with modified properties
  SDropdownDecoration copyWith({
    Color? closedFillColor,
    Color? expandedFillColor,
    Color? headerExpandedColor,
    List<BoxShadow>? closedShadow,
    List<BoxShadow>? expandedShadow,
    Widget? closedSuffixIcon,
    Widget? expandedSuffixIcon,
    Widget? prefixIcon,
    BoxBorder? closedBorder,
    BorderRadius? closedBorderRadius,
    BoxBorder? closedErrorBorder,
    BorderRadius? closedErrorBorderRadius,
    BoxBorder? expandedBorder,
    BorderRadius? expandedBorderRadius,
    TextStyle? hintStyle,
    TextStyle? headerStyle,
    TextStyle? noResultFoundStyle,
    TextStyle? errorStyle,
    TextStyle? listItemStyle,
    ScrollbarThemeData? overlayScrollbarDecoration,
    EdgeInsets? closedHeaderPadding,
    EdgeInsets? expandedHeaderPadding,
    EdgeInsets? itemsListPadding,
    EdgeInsets? listItemPadding,
    double? overlayHeight,
    double? overlayWidth,
    int? maxLines,
  }) {
    return SDropdownDecoration(
      closedFillColor: closedFillColor ?? this.closedFillColor,
      expandedFillColor: expandedFillColor ?? this.expandedFillColor,
      headerExpandedColor: headerExpandedColor ?? this.headerExpandedColor,
      closedShadow: closedShadow ?? this.closedShadow,
      expandedShadow: expandedShadow ?? this.expandedShadow,
      closedSuffixIcon: closedSuffixIcon ?? this.closedSuffixIcon,
      expandedSuffixIcon: expandedSuffixIcon ?? this.expandedSuffixIcon,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      closedBorder: closedBorder ?? this.closedBorder,
      closedBorderRadius: closedBorderRadius ?? this.closedBorderRadius,
      closedErrorBorder: closedErrorBorder ?? this.closedErrorBorder,
      closedErrorBorderRadius:
          closedErrorBorderRadius ?? this.closedErrorBorderRadius,
      expandedBorder: expandedBorder ?? this.expandedBorder,
      expandedBorderRadius: expandedBorderRadius ?? this.expandedBorderRadius,
      hintStyle: hintStyle ?? this.hintStyle,
      headerStyle: headerStyle ?? this.headerStyle,
      noResultFoundStyle: noResultFoundStyle ?? this.noResultFoundStyle,
      errorStyle: errorStyle ?? this.errorStyle,
      listItemStyle: listItemStyle ?? this.listItemStyle,
      overlayScrollbarDecoration:
          overlayScrollbarDecoration ?? this.overlayScrollbarDecoration,
      closedHeaderPadding: closedHeaderPadding ?? this.closedHeaderPadding,
      expandedHeaderPadding:
          expandedHeaderPadding ?? this.expandedHeaderPadding,
      itemsListPadding: itemsListPadding ?? this.itemsListPadding,
      listItemPadding: listItemPadding ?? this.listItemPadding,
      overlayHeight: overlayHeight ?? this.overlayHeight,
      overlayWidth: overlayWidth ?? this.overlayWidth,
      maxLines: maxLines ?? this.maxLines,
    );
  }

  /// Merges this decoration with another decoration
  /// Properties from [other] will override properties from this decoration
  SDropdownDecoration merge(SDropdownDecoration? other) {
    if (other == null) return this;

    return copyWith(
      closedFillColor: other.closedFillColor,
      expandedFillColor: other.expandedFillColor,
      headerExpandedColor: other.headerExpandedColor,
      closedShadow: other.closedShadow,
      expandedShadow: other.expandedShadow,
      closedSuffixIcon: other.closedSuffixIcon,
      expandedSuffixIcon: other.expandedSuffixIcon,
      prefixIcon: other.prefixIcon,
      closedBorder: other.closedBorder,
      closedBorderRadius: other.closedBorderRadius,
      closedErrorBorder: other.closedErrorBorder,
      closedErrorBorderRadius: other.closedErrorBorderRadius,
      expandedBorder: other.expandedBorder,
      expandedBorderRadius: other.expandedBorderRadius,
      hintStyle: other.hintStyle,
      headerStyle: other.headerStyle,
      noResultFoundStyle: other.noResultFoundStyle,
      errorStyle: other.errorStyle,
      listItemStyle: other.listItemStyle,
      overlayScrollbarDecoration: other.overlayScrollbarDecoration,
      closedHeaderPadding: other.closedHeaderPadding,
      expandedHeaderPadding: other.expandedHeaderPadding,
      itemsListPadding: other.itemsListPadding,
      listItemPadding: other.listItemPadding,
      overlayHeight: other.overlayHeight,
      overlayWidth: other.overlayWidth,
      maxLines: other.maxLines,
    );
  }
}

/// Utility class for creating common dropdown decorations
class SDropdownDecorations {
  /// Material design style decoration
  static SDropdownDecoration material = SDropdownDecoration(
    closedFillColor: Colors.white,
    expandedFillColor: Colors.white,
    headerExpandedColor: Colors.grey.shade200,
    closedBorder: Border.fromBorderSide(BorderSide(color: Colors.grey)),
    expandedBorder: Border.fromBorderSide(BorderSide(color: Colors.blue)),
    closedBorderRadius: BorderRadius.all(Radius.circular(4)),
    expandedBorderRadius: BorderRadius.all(Radius.circular(4)),
    closedSuffixIcon: Icon(Icons.arrow_drop_down, size: 24),
    expandedSuffixIcon: Icon(Icons.arrow_drop_up, size: 24),
    headerStyle: TextStyle(fontSize: 16, color: Colors.black87),
    hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
    listItemStyle: TextStyle(fontSize: 16, color: Colors.black87),
  );

  /// Rounded style decoration
  static SDropdownDecoration rounded = SDropdownDecoration(
    closedFillColor: Color(0xFFF5F5F5),
    expandedFillColor: Colors.white,
    headerExpandedColor: Colors.grey.shade200,
    closedBorder: Border.fromBorderSide(BorderSide.none),
    expandedBorder: Border.fromBorderSide(BorderSide(color: Colors.grey)),
    closedBorderRadius: BorderRadius.all(Radius.circular(25)),
    expandedBorderRadius: BorderRadius.all(Radius.circular(12)),
    closedSuffixIcon: Icon(Icons.keyboard_arrow_down, size: 20),
    expandedSuffixIcon: Icon(Icons.keyboard_arrow_up, size: 20),
    headerStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
    listItemStyle: TextStyle(fontSize: 14),
  );

  /// Outlined style decoration
  static SDropdownDecoration outlined = SDropdownDecoration(
    closedFillColor: Colors.transparent,
    expandedFillColor: Colors.white,
    headerExpandedColor: Colors.grey.shade200,
    closedBorder:
        Border.fromBorderSide(BorderSide(color: Colors.grey, width: 1.5)),
    expandedBorder:
        Border.fromBorderSide(BorderSide(color: Colors.blue, width: 1.5)),
    closedBorderRadius: BorderRadius.all(Radius.circular(8)),
    expandedBorderRadius: BorderRadius.all(Radius.circular(8)),
    closedSuffixIcon: Icon(Icons.expand_more, size: 20),
    expandedSuffixIcon: Icon(Icons.expand_less, size: 20),
    headerStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
    listItemStyle: TextStyle(fontSize: 14),
  );
}
