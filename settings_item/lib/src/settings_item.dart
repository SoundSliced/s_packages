// ignore: unnecessary_import
import 'package:flutter/material.dart';
import 'package:s_bounceable/s_bounceable.dart';
import 'package:s_toggle/s_toggle.dart';

/// A customizable expandable menu widget for settings pages.
///
/// Supports three modes:
/// 1. Switch mode: `isSwitch: true` - Shows a toggle switch
/// 2. Expandable mode: `isExpandeable: true` - Shows expandable content with up arrow and rotation
/// 3. Button mode: `isExpandeable: false` - Shows left arrow with rotation but no content expansion
///
/// State Management:
/// - If [isActive] is provided, the widget operates in controlled mode (external state)
/// - If [isActive] is null, the widget manages its own state internally (uncontrolled mode)
/// - [initialState] sets the initial value when using internal state management (defaults to false)
class SettingsItem extends StatefulWidget {
  final ExpandableParameters parameters;
  final bool? isActive;
  final bool initialState;
  final Function(bool state)? onChange;

  const SettingsItem({
    super.key,
    this.parameters = const ExpandableParameters(),
    this.isActive,
    this.initialState = false,
    this.onChange,
  });

  @override
  State<SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem> {
  late bool _internalState;
  double _expandedHeight = 0;
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _internalState = widget.initialState;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateExpandedHeight();
    });
  }

  @override
  void didUpdateWidget(SettingsItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recalculate height if parameters changed
    if (widget.parameters != oldWidget.parameters) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateExpandedHeight();
      });
    }
  }

  /// Get the current active state (either from parent or internal state)
  bool get _currentState => widget.isActive ?? _internalState;

  void _calculateExpandedHeight() {
    final context = _contentKey.currentContext;
    if (context?.mounted == true) {
      final renderObject = context!.findRenderObject();
      if (renderObject is RenderBox && renderObject.hasSize && mounted) {
        setState(() {
          _expandedHeight = renderObject.size.height;
        });
      }
    }
  }

  void _handleTap() {
    final newState = !_currentState;

    // Update internal state if not controlled by parent
    if (widget.isActive == null) {
      setState(() {
        _internalState = newState;
      });
    }

    // Notify parent of change
    widget.onChange?.call(newState);

    // Call toggle callback for non-switch items
    if (!widget.parameters.isSwitch) {
      widget.parameters.onExpandedSectionToggle?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Offstage widget for height measurement
        Offstage(
          child: Container(
            key: _contentKey,
            child:
                widget.parameters.expandedWidget ?? const SizedBox(height: 80),
          ),
        ),

        // Main expandable container
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header bar
              _buildHeaderBar(theme, colorScheme),

              // Expandable content - only animate height if isExpandeable is true
              if (!widget.parameters.isSwitch)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  height: _currentState && widget.parameters.isExpandeable
                      ? _expandedHeight + 32
                      : 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: widget.parameters.isExpandeable
                            ? SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: widget.parameters.expandedWidget,
                              )
                            : const SizedBox(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBar(ThemeData theme, ColorScheme colorScheme) {
    final headerContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _currentState && !widget.parameters.isSwitch
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(
          _currentState &&
                  !widget.parameters.isSwitch &&
                  widget.parameters.isExpandeable
              ? 0
              : 12,
        ),
      ),
      child: Row(
        children: [
          // Prefix Icon
          if (widget.parameters.prefixIcon != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.parameters.prefixIcon,
                size: 22,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
          ],

          // Title
          Expanded(
            child: Text(
              widget.parameters.title ?? "Settings Item",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          // Suffix Widget
          _buildSuffixWidget(colorScheme),
        ],
      ),
    );

    return SBounceable(
      onTap: _handleTap,
      isBounceEnabled: !widget.parameters.isExpandeable,
      scaleFactor: 0.95,
      child: headerContent,
    );
  }

  Widget _buildSuffixWidget(ColorScheme colorScheme) {
    // Custom suffix widget takes priority
    if (widget.parameters.suffixWidget != null) {
      return widget.parameters.suffixWidget!;
    }

    // Switch widget
    if (widget.parameters.isSwitch) {
      return SToggle(
        size: 36,
        onColor: colorScheme.primary,
        offColor: colorScheme.outline.withValues(alpha: 0.3),
        value: _currentState,
        onChange: (value) => widget.onChange?.call(value),
      );
    }

    // Default expandable arrow
    return AnimatedRotation(
      turns: _currentState ? 0.5 : 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          widget.parameters.isExpandeable
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_left_rounded,
          size: 20,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

//*************************************************** */

/// Configuration parameters for SettingsExpendableMenu
///
/// [isSwitch]: When true, shows a toggle switch instead of expandable content
/// [isExpandeable]: When true, allows content expansion; when false, only rotates arrow without expanding content
/// [expandedWidget]: Content to show when expanded (only used when isExpandeable is true)
class ExpandableParameters {
  final IconData? prefixIcon;
  final String? title;
  final bool isSwitch;
  final bool isExpandeable;
  final Widget? expandedWidget;
  final Widget? suffixWidget;
  final VoidCallback? onExpandedSectionToggle;

  const ExpandableParameters({
    this.prefixIcon,
    this.title,
    this.isSwitch = false,
    this.isExpandeable = true,
    this.expandedWidget,
    this.suffixWidget,
    this.onExpandedSectionToggle,
  });

  ExpandableParameters copyWith({
    IconData? prefixIcon,
    String? title,
    bool? isSwitch,
    bool? isExpandeable,
    Widget? expandedWidget,
    Widget? suffixWidget,
    VoidCallback? onExpandedSectionToggle,
  }) {
    return ExpandableParameters(
      prefixIcon: prefixIcon ?? this.prefixIcon,
      title: title ?? this.title,
      isSwitch: isSwitch ?? this.isSwitch,
      isExpandeable: isExpandeable ?? this.isExpandeable,
      expandedWidget: expandedWidget ?? this.expandedWidget,
      suffixWidget: suffixWidget ?? this.suffixWidget,
      onExpandedSectionToggle:
          onExpandedSectionToggle ?? this.onExpandedSectionToggle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpandableParameters &&
        other.prefixIcon == prefixIcon &&
        other.title == title &&
        other.isSwitch == isSwitch &&
        other.isExpandeable == isExpandeable &&
        other.expandedWidget == expandedWidget &&
        other.suffixWidget == suffixWidget;
  }

  @override
  int get hashCode {
    return Object.hash(
      prefixIcon,
      title,
      isSwitch,
      isExpandeable,
      expandedWidget,
      suffixWidget,
    );
  }
}
