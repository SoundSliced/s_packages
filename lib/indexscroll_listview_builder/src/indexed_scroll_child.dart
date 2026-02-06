import 'package:flutter/material.dart';
import 'package:s_packages/indexscroll_listview_builder/src/indexed_scroll_controller.dart';

/// A widget that tags a child with an index for use with [IndexedScrollController].
///
/// This widget wraps a child widget and registers it with an [IndexedScrollController]
/// using a [GlobalKey]. This registration enables the controller to locate and scroll
/// to this specific item in a list.
///
/// The widget automatically handles the complete lifecycle:
/// - Registration when the widget is first created
/// - Updates when the index or controller changes
/// - Cleanup when the widget is disposed
///
/// This widget is typically used internally by [IndexScrollListViewBuilder] and
/// shouldn't need to be used directly in most cases.
///
/// Example:
/// ```dart
/// IndexedScrollTag(
///   controller: myController,
///   index: 5,
///   child: ListTile(title: Text('Item 5')),
/// )
/// ```
///
/// See also:
///  * [IndexedScrollController], which manages the registered indices
///  * [IndexScrollListViewBuilder], which uses this widget automatically
class IndexedScrollTag extends StatefulWidget {
  /// Creates an [IndexedScrollTag].
  ///
  /// The [controller], [index], and [child] parameters are required.
  ///
  /// * [key]: The widget key (standard Flutter widget key).
  /// * [scrollKey]: Optional custom [GlobalKey] for registration. If not provided,
  ///   a new key is automatically created. Custom keys are rarely needed.
  /// * [controller]: The [IndexedScrollController] to register with.
  /// * [index]: The list index of this item (must be non-negative).
  /// * [child]: The actual widget content to be displayed and scrolled to.
  const IndexedScrollTag({
    super.key,
    this.scrollKey,
    required this.controller,
    required this.index,
    required this.child,
  });

  /// Optional custom [GlobalKey] for this item.
  /// If null, a key is automatically generated.
  final GlobalKey? scrollKey;

  /// The controller that manages scrolling to indexed items.
  final IndexedScrollController controller;

  /// The position of this item in the list.
  final int index;

  /// The child widget that will be wrapped and registered.
  final Widget child;

  @override
  State<IndexedScrollTag> createState() => _IndexedScrollTagState();
}

/// State class for [IndexedScrollTag].
///
/// Manages the lifecycle of the tag's registration with the controller,
/// ensuring proper cleanup and handling of controller/index changes.
class _IndexedScrollTagState extends State<IndexedScrollTag> {
  /// The [GlobalKey] used to identify this widget for scrolling operations.
  /// Either provided via [widget.scrollKey] or automatically generated.
  late final GlobalKey _key = widget.scrollKey ?? GlobalKey();

  @override
  void initState() {
    super.initState();
    // Register this widget's key with the controller at initialization
    widget.controller.registerKey(index: widget.index, key: _key);
  }

  @override
  void didUpdateWidget(covariant IndexedScrollTag oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle controller changes - need to re-register with new controller
    if (!identical(widget.controller, oldWidget.controller)) {
      // Unregister from the old controller
      oldWidget.controller.unregisterKey(_key);
      // Register with the new controller
      widget.controller.registerKey(index: widget.index, key: _key);
      return; // Early return since we've handled the full re-registration
    }

    // Handle index changes - update the registration with the same controller
    if (widget.index != oldWidget.index) {
      widget.controller.updateKeyIndex(
        oldIndex: oldWidget.index,
        newIndex: widget.index,
        key: _key,
      );
    }
  }

  @override
  void dispose() {
    // Clean up by unregistering this key from the controller
    // This prevents memory leaks and keeps the controller's registry clean
    widget.controller.unregisterKey(_key);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the child in a KeyedSubtree to associate the GlobalKey
    // This allows Scrollable.ensureVisible to locate this widget
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}
