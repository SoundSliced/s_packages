/// A Flutter package providing an enhanced ListView.builder with bidirectional index-based scrolling.
///
/// This library exports the main widget [IndexScrollListViewBuilder] which extends
/// Flutter's standard ListView.builder with the ability to programmatically scroll
/// to any item by its index in both directions, even if that item hasn't been built yet.
///
/// Key features:
/// * **Bidirectional scrolling**: Works perfectly scrolling both up and down the list
/// * **Viewport-based precision**: Direct viewport offset calculations for accurate positioning
/// * **Off-screen item support**: Scroll to items not yet rendered with smart position estimation
/// * **Operation cancellation**: Superseded scroll operations are cancelled to prevent interrupted animations
/// * **Smooth, configurable animations**: Duration and curve customization
/// * **Automatic edge case handling**: Perfect handling of first/last items
/// * **Optional scrollbar support**: Full customization (thumb, track, thickness, radius, orientation)
/// * **Smart constraint handling**: Automatic shrinkWrap for unbounded layouts
/// * **Customizable item alignment**: Position target anywhere in viewport (0.0–1.0)
///
/// Example:
/// ```dart
/// import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';
///
/// // Basic usage with auto-scroll
/// IndexScrollListViewBuilder(
///   itemCount: 100,
///   indexToScrollTo: 50, // Automatically scroll to item 50
///   itemBuilder: (context, index) {
///     return ListTile(title: Text('Item $index'));
///   },
/// )
///
/// // Advanced usage with external controller
/// final controller = IndexedScrollController();
/// final itemCount = 100;
///
/// IndexScrollListViewBuilder(
///   controller: controller,
///   itemCount: itemCount,
///   itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
/// )
///
/// // Later, scroll programmatically
/// await controller.scrollToIndex(75, itemCount: itemCount, alignmentOverride: 0.3);
/// ```
///
/// See also:
///  * [IndexScrollListViewBuilder], the main widget
///  * [IndexedScrollController], for advanced programmatic control
///  * [IndexedScrollTag], internal widget that tags each item for scrolling
library;

export 'src/indexscroll_listview_builder.dart';
export 'src/indexed_scroll_controller.dart';
export 'src/indexed_scroll_child.dart';
