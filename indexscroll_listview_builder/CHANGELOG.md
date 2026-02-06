
## 2.2.0

### 🎯 Required Callback & API Refinement

#### Added
* **onScrolledTo callback (required)**: Unified callback that fires for both declarative (`indexToScrollTo`) and imperative (`controller.scrollToIndex()`) scrolls.
  - Provides confirmation when a scroll operation reaches its target index
  - Enables parent widgets to stay in sync with scroll state
  - Required parameter ensures proper state management patterns

#### Enhanced
* **Intelligent tracking**: Builder now distinguishes between programmatic and declarative scroll operations to prevent unwanted cancellations
  - When `onScrolledTo` updates `indexToScrollTo` in response to an imperative scroll, the builder won't trigger a redundant declarative scroll
  - Smoother interaction between imperative control and parent state updates
* **Auto-restore on rebuild**: Automatically detects position mismatches and restores to declarative home position
  - When `indexToScrollTo` is not updated in `onScrolledTo` callback after imperative scrolls
  - After programmatic scroll completes (50ms after onScrolledTo fires), widget marks scroll as complete
  - On next rebuild, widget detects mismatch between controller's position and declarative target
  - Automatically scrolls back to the declarative "home position"
  - Perfect for temporary imperative scrolls that should return to a fixed position on rebuild

#### Technical Improvements
* Post-frame callback deferral for all `onScrolledTo` invocations to prevent setState-during-build errors
* Smart handling of parent state updates during programmatic scrolls with 50ms completion delay
* Better coordination between imperative and declarative scroll modes
* Mismatch detection in `didUpdateWidget` for auto-restore functionality
* Tracking flags distinguish between programmatic scroll sequences and external rebuilds

#### Migration Guide

**All widgets now require the `onScrolledTo` callback:**

```dart
// Before (v2.1.0):
IndexScrollListViewBuilder(
  itemCount: 100,
  indexToScrollTo: 25,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
)

// After (v2.2.0):
IndexScrollListViewBuilder(
  itemCount: 100,
  indexToScrollTo: 25,
  onScrolledTo: (index) {
    // Optional: update your state, log, etc.
    print('Scrolled to index $index');
  },
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
)
```

**For simple cases where you don't need the callback:**
```dart
IndexScrollListViewBuilder(
  itemCount: 100,
  onScrolledTo: (_) {}, // No-op callback
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
)
```

**For advanced state management:**
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int? _currentIndex;

  @override
  Widget build(BuildContext context) {
    return IndexScrollListViewBuilder(
      itemCount: 100,
      indexToScrollTo: _currentIndex,
      onScrolledTo: (index) {
        // Keep state in sync with scroll position
        if (_currentIndex != index) {
          setState(() => _currentIndex = index);
        }
      },
      itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
    );
  }
}
```

**Two modes of operation in v2.2.0:**

*Mode 1: Coordinated (Update indexToScrollTo in callback)*
```dart
class _MyWidgetState extends State<MyWidget> {
  final controller = IndexedScrollController();
  int homePosition = 15;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IndexScrollListViewBuilder(
          itemCount: 100,
          indexToScrollTo: homePosition,
          controller: controller,
          onScrolledTo: (index) {
            // Update home position to match imperative scrolls
            if (homePosition != index) {
              setState(() => homePosition = index);
            }
          },
          itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
        ),
        ElevatedButton(
          onPressed: () => controller.scrollToIndex(75, itemCount: 100),
          child: Text('Scroll to 75'),
        ),
        // Position persists at 75 even on rebuild because homePosition was updated
      ],
    );
  }
}
```

*Mode 2: Auto-Restore (Don't update indexToScrollTo in callback)*
```dart
class _MyWidgetState extends State<MyWidget> {
  final controller = IndexedScrollController();
  final int homePosition = 15; // Fixed home position

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IndexScrollListViewBuilder(
          itemCount: 100,
          indexToScrollTo: homePosition, // Always 15
          controller: controller,
          onScrolledTo: (index) {
            // Don't update homePosition - keep it fixed
            print('Scrolled to $index');
          },
          itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
        ),
        ElevatedButton(
          onPressed: () => controller.scrollToIndex(75, itemCount: 100),
          child: Text('Temporarily scroll to 75'),
        ),
        ElevatedButton(
          onPressed: () => setState(() {}),
          child: Text('Trigger rebuild → auto-restores to 15!'),
        ),
      ],
    );
  }
}
```

### Benefits
* ✅ Explicit state management: Know exactly when scrolls complete
* ✅ Better parent-child coordination: Update parent state in response to scrolls
* ✅ Prevents timing issues: Post-frame callbacks avoid setState-during-build
* ✅ Flexible: Use for logging, analytics, state updates, or leave as no-op
* ✅ Auto-restore: Declarative home position automatically restores when not updated in callback
* ✅ Enhanced example app: Visual badges show **HOME** (declarative position) vs **CONTROLLER INDEX** (imperative position) for clear understanding

## 2.1.0

### 🎯 Improved Declarative Scrolling Behavior (Breaking Change)

#### Changed
* **indexToScrollTo behavior**: Now acts as a **declarative "home position"** that always takes effect on rebuild, regardless of imperative scrolling via `controller.scrollToIndex()`.
  - **Before (v2.0.x)**: `indexToScrollTo` only scrolled when the value changed between rebuilds
  - **After (v2.1.0)**: `indexToScrollTo` scrolls on every rebuild when non-null, overriding imperative scrolls
  - This provides more intuitive, Flutter-idiomatic declarative behavior

#### Removed
* **forceAutoScroll parameter**: No longer needed with the new behavior. The old `forceAutoScroll: true` behavior is now the default when `indexToScrollTo` is non-null.

#### Migration Guide

**Case 1: You want declarative positioning (recommended)**
```dart
// ✅ No changes needed - new behavior is more intuitive
IndexScrollListViewBuilder(
  indexToScrollTo: selectedIndex, // Always restores this position on rebuild
  itemCount: 100,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
)
```

**Case 2: You want imperative scrolling to persist across rebuilds**
```dart
// Before (v2.0.x):
IndexScrollListViewBuilder(
  indexToScrollTo: 25, // Stayed at 25 after initial scroll
  controller: controller,
  // ...
)

// After (v2.1.0):
IndexScrollListViewBuilder(
  indexToScrollTo: null, // Set to null to let controller scrolling persist
  controller: controller,
  // ...
)
// Now controller.scrollToIndex() persists across rebuilds
```

**Case 3: You were using forceAutoScroll**
```dart
// Before (v2.0.3):
IndexScrollListViewBuilder(
  indexToScrollTo: 25,
  forceAutoScroll: true, // Forced re-scroll on rebuild
  // ...
)

// After (v2.1.0):
IndexScrollListViewBuilder(
  indexToScrollTo: 25, // Now always scrolls on rebuild by default
  // forceAutoScroll removed - no longer needed
  // ...
)
```

### Benefits
* ✅ More intuitive: `indexToScrollTo` behaves as expected declarative state
* ✅ Cleaner API: One less parameter to understand
* ✅ Better Flutter patterns: Matches how `value` works in TextField and similar widgets
* ✅ Simpler mental model: Declarative always wins, imperative requires `null`

## 2.0.3

**Note**: Version 2.0.3 was deprecated in favor of the improved 2.1.0 design.

### Added
* **forceAutoScroll parameter** (deprecated): Temporarily added, then removed in v2.1.0 in favor of better default behavior.

## 2.0.2

* IndexedScrollController's scrollToIndex method now requires the itemCount property

## 2.0.1

* Version 2.0.1: README file updated

## 2.0.0

### 🚀 Major Improvements

#### Fixed
* **Bidirectional auto-scrolling**: Fixed critical bug where scrolling only worked downward (to lower indices). Now works perfectly in both directions.
* **External controller scrolling**: Fixed issue where external controller buttons (First, Last, +10, -10) would scroll the outer page instead of the inner ListView.
* **Last item visibility**: Improved handling to ensure the last item in the list is fully visible when scrolled to.
* **Rapid scroll cancellation**: Added operation versioning to cancel superseded scroll operations, preventing "short scrolls" during rapid slider drags.

#### Enhanced
* **Viewport-based scrolling**: Replaced `Scrollable.ensureVisible` with direct viewport offset calculations using `RenderAbstractViewport.getOffsetToReveal` for precise control and to prevent scrolling ancestor scrollables.
* **Off-screen item handling**: Implemented smart position estimation for items not yet rendered, enabling smooth scrolling to any index.
* **Performance optimization**: Added fast-path optimization in index resolution that checks exact index existence before building the full available list.
* **Production-ready code**: Updated all documentation to accurately reflect the viewport-based implementation, improved edge case handling.

#### Added
* `itemCount` parameter to `scrollToIndex()` method for better off-screen position estimation.
* Comprehensive inline documentation improvements across all source files.
* Better error handling and edge case documentation.

### 🛠 Technical Details
* Controller now uses scroll position's `maxScrollExtent` for reliable last-item scrolling
* Operation versioning mechanism prevents interrupted scroll animations
* Smart extremes handling: index 0 → offset 0.0, last index → maxScrollExtent

### 📦 Example App
* Updated example app with proper `pubspec.yaml` to enable hot reload/restart
* All external controller buttons now work correctly with itemCount parameter
* Demonstrates all new improvements in action

### ⚠️ Breaking Changes
**Minor**: The `scrollToIndex()` method now requires an `itemCount` parameter for optimal off-screen scrolling. Existing code needs to be updated:

```dart
// Before (v1.x)
controller.scrollToIndex(50);

// After (v2.0.0)
controller.scrollToIndex(50, itemCount: totalItems);
```

## 1.0.0

### Added
* Comprehensive inline documentation for all public APIs.
* Exported controller (`IndexedScrollController`) and tag widget (`IndexedScrollTag`) from root library.
* Example application demonstrating basic usage, auto-scroll, offset, and external controller patterns.
* Widget tests for build, auto-scroll triggering, and external controller scrolling.
* MIT License file.

### Improved
* README with full feature list, installation, usage snippets, API overview, and parameters table.
* Pubspec description and metadata (repository, issue tracker).

### Notes
* Stable 1.0.0 release – API considered ready for production use.

## 0.0.1

* Initial release
