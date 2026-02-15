
## 1.4.1
- **`s_connectivity` sub-package BREAKING improvements**:
  - **BREAKING:** Renamed `AppInternetConnectivity` class to `SConnectivity` — all call sites must be updated (e.g. `AppInternetConnectivity.listenable` → `SConnectivity.listenable`)
  - **BREAKING:** Renamed source file from `s_connection.dart` to `s_connectivity.dart` — direct imports must be updated
  - Made `toggleConnectivitySnackbar()` private (`_toggleConnectivitySnackbar`) — use the `showNoInternetSnackbar` setter instead for manual snackbar control


## 1.4.0
- **`s_modal` sub-package improvements**:
  - Added `Modal.isAppBuilderInstalled` public getter — allows other packages to check whether `Modal.appBuilder` has already been installed in the widget tree
  - Made `Modal.appBuilder` idempotent — calling it more than once now safely returns the child as-is instead of double-nesting the internal `_ActivatorWidget`
- **`s_connectivity` sub-package improvements**:
  - Added `SConnectivityOverlay` widget — a convenience wrapper that sets up the Modal overlay system so the "No Internet" snackbar works without requiring users to know about or manually call `Modal.appBuilder`
  - Added `SConnectivityOverlay.appBuilder` static method — drop-in replacement for `Modal.appBuilder` that can be passed directly to `MaterialApp(builder: ...)`
  - Safe to use alongside an existing `Modal.appBuilder` call — double-wrapping is prevented automatically thanks to the idempotent `appBuilder`

## 1.3.0
- **`pop_overlay` sub-package improvements**:
  - `PopOverlay.dismissAllPops` added with optional `includeInvisible` and `except` parameters
  - `PopOverlay.replacePop` for atomically replacing an overlay with a new one
  - Added query helpers: `isVisibleById`, `getVisiblePops`, `getInvisiblePops`, `visibleCount`, `invisibleCount`
  - Added `shouldDismissOnEscapeKey` flag on `PopOverlayContent` to opt out of Escape key dismissal per overlay
  - Added `onMadeVisible` callback on `PopOverlayContent` (counterpart to `onMadeInvisible`)
  - Added `onDragStart` and `onDragEnd` callbacks on `PopOverlayContent`
  - Added `dragBounds` on `PopOverlayContent` to constrain dragging within a `Rect`
  - **`FrameDesign` additions**:
    - `subtitle` property for secondary text below the title
    - `titleBarColor` and `bottomBarColor` for per-popup color customization
    - `headerTrailingWidgets` for extra action widgets in the header
- **`bubble_label` sub-package improvements**:
  - Added `animationDuration` for custom show/dismiss timing
  - Added `showCurve` and `dismissCurve` for independent animation curves
  - Added `horizontalOffset` for horizontal positioning control
  - Added `showOnHover` flag to trigger label display on mouse hover
- **`s_bounceable` sub-package improvements**:
  - Added `onLongPress` callback
  - Added `curve` for custom bounce animation curve
  - Added `enableHapticFeedback` flag for tactile feedback on tap
- **`s_disabled` sub-package improvements**:
  - Added `applyGrayscale` flag to apply a grayscale filter when disabled
  - Added `disabledSemanticLabel` for custom accessibility label when disabled
  - Added `disabledChild` to show an alternative widget when disabled
- **`s_banner` sub-package improvements**:
  - Added `onTap` callback
  - Added `gradient` for gradient background support
  - Added `animateVisibility` to animate show/hide transitions
- **`s_glow` sub-package improvements**:
  - Added `onAnimationComplete` callback to Glow1 and Glow2
  - Added `gradient` support for multi-color glow effects in Glow1
- **`shaker` sub-package improvements**:
  - Added `ShakeController` for programmatic shake triggering via `controller.shake()`
- **`s_maintenance_button` sub-package improvements**:
  - Added `icon` for custom button icon
  - Added `showConfirmation` flag and `confirmationMessage` for confirmation dialog before action
- **`s_ink_button` sub-package improvements**:
  - Added `onHover` and `onFocusChange` callbacks
  - Added `hoverColor` for custom hover state color
  - Added `splashDuration` for custom splash animation timing
- **`settings_item` sub-package improvements**:
  - Added `subtitle`, `description`, and `trailing` to `ExpandableParameters`
  - Updated `copyWith`, `==`, and `hashCode` accordingly
- **`s_error_widget` sub-package improvements**:
  - Converted to `StatefulWidget` for expandable stack trace state
  - Added `errorCode`, `stackTrace` (expandable monospace view), `showCopyButton`, and `actions`
  - Copy button copies full error details to clipboard
- **`keystroke_listener` sub-package improvements**:
  - Added `actionHandlers` map for customizable intent callbacks per intent type
- **`s_context_menu` sub-package improvements**:
  - Added `disabled` and `shortcutHint` fields to `SContextMenuItem`
  - Disabled items render at reduced opacity with forbidden cursor
  - Shortcut hints display as right-aligned secondary text in menu items
- **`s_animated_tabs` sub-package improvements**:
  - Added `tabIcons` list for optional per-tab icons
  - Added `tabBadges` list for optional per-tab badge pills
- **`s_expendable_menu` sub-package improvements**:
  - Added `onExpansionChanged` callback to `SExpandableMenu`
  - Added `tooltip` and `disabled` fields to `SExpandableItem`
  - Disabled items render at reduced opacity with null tap handler
- **`s_future_button` sub-package improvements**:
  - Added `successDuration` and `errorDuration` for configurable state display timing
  - Added `loadingWidget` for custom loading indicator replacement
- **`s_gridview` sub-package improvements**:
  - Added `emptyStateWidget` to display when children list is empty
- **`ticker_free_circular_progress_indicator` sub-package improvements**:
  - Added `size` parameter (replaces hardcoded 36.0 diameter)
- **`soundsliced_tween_animation_builder` sub-package improvements**:
  - Added `delay` for pre-animation delay
  - Added `repeatCount` to limit number of auto-repeat cycles
- **`week_calendar` sub-package improvements**:
  - Added `minDate` and `maxDate` for date boundary constraints
  - Added `eventIndicatorDates` and `eventIndicatorColor` for event dot indicators on days
- **`s_client` sub-package improvements**:
  - Added `putJson<T>()` typed variant for PUT requests with JSON deserialization
  - Added `patchJson<T>()` typed variant for PATCH requests with JSON deserialization
  - Added `deleteJson<T>()` typed variant for DELETE requests with JSON deserialization
- **`soundsliced_dart_extensions` sub-package improvements**:
  - Added `String.truncate(maxLength, {ellipsis})` extension
  - Added `List<T>.groupBy<K>(keyOf)` extension for grouping elements by key
- **`s_liquid_pull_to_refresh` sub-package improvements**:
  - Added `triggerDistance` for customizable drag threshold
  - Added `onDragProgress` callback reporting drag progress (0.0 to 1.0)
- **`s_screenshot` sub-package performance improvements**:
  - Fixed `ui.Image` memory leak — native GPU resources are now properly disposed after byte extraction
  - Base64 encoding is now offloaded to a separate isolate via `compute()` on native platforms to avoid blocking the UI thread (falls back to main thread on web where isolates aren't available)
  - Replaced `Future.microtask(() {})` with `WidgetsBinding.instance.endOfFrame` for more reliable rendering pipeline synchronization
  - Fixed `ByteData` buffer view to use precise `offsetInBytes`/`lengthInBytes` instead of unbounded `asUint8List()`
- **`s_connectivity` sub-package improvements**:
  - **BREAKING:** Removed `NoInternetConnectionPopup` widget; connectivity warnings now use the Modal snackbar system
  - Added `showNoInternetSnackbar` static property to auto-show/dismiss a staggered snackbar on connectivity changes
  - Added `noInternetSnackbarMessage` parameter to `initialiseInternetConnectivityListener()` for custom messages
  - Added `toggleConnectivitySnackbar()` static method for manual snackbar control
  - Removed dependencies on `assorted_layout_widgets` and `sizer`
- **`s_modal` sub-package improvements**:
  - **BREAKING:** Renamed `showSuffixIcon` parameter to `showCloseIcon` in `Modal.showSnackbar()`
  - Replaced barrier `SBounceable` with `SInkButton` for ink-splash feedback and long-press dismiss support
  - Improved snackbar default layout: text uses `Flexible` instead of `Expanded`, consistent spacing/alignment
- **`signals_watch` sub-package improvements**:
  - Metadata is now always stored for signals created via `SignalsWatch.signal()`, ensuring `.reset()` works even without lifecycle callbacks
  - `onValueUpdated` callback now supports zero-parameter signatures (fallback invocation if one-parameter call fails)


## 1.2.7

- **`s_sidebar` sub-package improvements**:
  - Enhanced `SideBarController.activateSideBar` with additional customization options:
    - Added `dismissBarrierColor` parameter for custom barrier colors
    - Added `shouldBlurDismissBarrier` parameter for optional blur effect on barrier
    - Added `initState` callback for initialization logic
    - Added `onDismissed` callback to handle sidebar dismissal events

## 1.2.6

- **`pop_overlay` sub-package animation improvements**:
  - Added smooth fade-in animations to all popup types; fixes flash issue in `FrameDesign` popups by smoothly animating appearance during auto dynamic dimension calculation time
  - Extended animation durations for smoother transitions: blur background (400ms → 600ms), barrier fade (0.4-0.5s → 0.8-1.0s), and animated size (300ms → 500ms)
  - Added `borderRadius` support to example demos for better visual consistency
  - Optimized popup entrance animations with `Curves.fastEaseInToSlowEaseOut` for more natural motion

## 1.2.5

- **`pop_overlay` sub-package improvements**:
  - Replaced `pop_overlay`'s use of `MediaQuery.of(context).size` with `Size(100.w, 100.h)` for better responsive sizing using the `sizer` package throughout the overlay system
  - Improved cross-platform compatibility and responsive behavior
- **Example app enhancements**:
  - Wrapped `MaterialApp` with `ForcePhoneSizeOnWeb` for better web demo experience with consistent phone-sized viewport
  - Added comprehensive Pop Overlay Demo section in `s_widgets_example_screen.dart` showcasing draggable popup with blur effects, custom styling, and interactive features

## 1.2.4

- **`s_sidebar` & `pop_overlay` sub-packages upgrades**:
  - `s_sidebar`: Added default left alignment for sidebar activation, allowing the sidebar to stay anchored to the left while minimizing.
  - `pop_overlay`: Added `alignment` property to `PopOverlayContent` (defaulting to `Alignment.center`) and updated `_PopOverlayActivator` to support popup alignment.

## 1.2.3

- No longer exporting web exclusive packages (`universal_html`, `web`...)

## 1.2.2

- SDK constraint upgrade

## 1.2.1

- no longer depending on `web` ^1.1.1

## 1.2.0

- **`s_sidebar` & `pop_overlay` sub-packages upgrades**:
  - Added `animateFromOffset` to `activateSideBar` to allow animating the sidebar popup from a specific screen position (e.g., button tap location).
  - Added `curve` parameter to customize the animation curve.
  - Added `animationDuration` parameter to control the popup animation speed.
  - Added `useGlobalPosition` parameter to `activateSideBar` and `PopOverlay`, simplifying coordinate handling by automatically converting global tap positions.
  - Fixed an issue where `SSideBar` could error with infinite height constraints when used in an overlay.
  - Example app's showcases updated accordingly for both `s_sidebar` & `pop_overlay` sub-packages
- `README` updated

## 1.1.4

- removed some conflicting dependencies

## 1.1.3

- dependencies upgraded
- new dependencies added not used in this package but included for export convenience, so users don't have to add them separately when using the widgets that depend on them.

## 1.1.2

* all Flutter platforms made enabled

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [1.1.1] - 2026-02-06
- README updated

## [1.1.0] - 2026-02-06
- full restructure of the package and subpackages + subpackages are exported so to be accessible by the `s_packages` users

## [1.0.3] - 2026-02-06
- s_packages.dart placed in the root folder, and its exports URLs fixed

## [1.0.2] - 2026-02-06
- s_packages.dart created, that exports all included sub packages

## [1.0.1] - 2026-02-06
- README and example gif updated

## [1.0.0] - 2026-02-05

### Added

#### Initial Release
This is the first public release of **s_packages**, a comprehensive collection of 43 Flutter packages designed to accelerate development and provide reusable UI components, utilities, and tools.

#### Package Categories

**UI Components (20 packages)**
- `bubble_label` - A bubble label widget for displaying tags and labels
- `s_animated_tabs` - Animated tab bar with smooth transitions
- `s_banner` - Customizable banner widget for notifications
- `s_button` - Custom button widget with advanced styling
- `s_context_menu` - Context menu widget for right-click interactions
- `s_disabled` - Widget wrapper for disabled state management
- `s_dropdown` - Dropdown widget with advanced features
- `s_error_widget` - Error display widget with customizable UI
- `s_expendable_menu` - Expandable menu widget for hierarchical navigation
- `s_future_button` - Button with Future-based async operations
- `s_ink_button` - Button with ink ripple effects
- `s_liquid_pull_to_refresh` - Liquid-style pull to refresh animation
- `s_maintenance_button` - Button for maintenance mode states
- `s_modal` - Modal dialog system with overlay management
- `s_standby` - Standby state widget for loading states
- `s_toggle` - Toggle switch widget
- `s_widgets` - Collection of reusable widgets
- `settings_item` - Settings item widget for configuration screens
- `ticker_free_circular_progress_indicator` - Progress indicator without ticker dependency

**Lists and Collections (2 packages)**
- `indexscroll_listview_builder` - ListView with index scrolling capabilities
- `s_gridview` - Enhanced grid view widget

**Animations (3 packages)**
- `s_bounceable` - Bounceable animation effects for interactive widgets
- `s_glow` - Glow effects and visual enhancements
- `shaker` - Shake animations for attention-grabbing effects
- `soundsliced_tween_animation_builder` - Custom tween animation builder

**Navigation (3 packages)**
- `pop_overlay` - Overlay management for navigation
- `pop_this` - Navigation utilities and helpers
- `s_sidebar` - Sidebar navigation component

**Networking (2 packages)**
- `s_client` - HTTP client utilities and helpers
- `s_connectivity` - Connectivity monitoring and status

**State Management (2 packages)**
- `signals_watch` - Signal watching utilities for reactive programming
- `states_rebuilder_extended` - Extended state management solutions

**Input & Interaction (1 package)**
- `keystroke_listener` - Keyboard event listener and handler

**Layout (1 package)**
- `s_offstage` - Offstage widget utilities for conditional rendering

**Platform Integration (1 package)**
- `s_webview` - WebView integration for embedded web content

**Utilities (4 packages)**
- `post_frame` - Post-frame callbacks for timing control
- `s_screenshot` - Screenshot capture utilities
- `s_time` - Time utilities and formatters
- `soundsliced_dart_extensions` - Dart language extensions

**Calendar (1 package)**
- `week_calendar` - Week-based calendar widget

#### Example Application
- Comprehensive example app showcasing all 43 packages
- Material Design 3 UI with light/dark theme support
- Package browser with search and category filtering
- Interactive demos for each package
- Example assets including GIF demonstrations

#### Documentation
- Complete README with installation and usage instructions
- Individual package documentation
- Code examples for basic and advanced usage
- GitHub repository with issue tracking

### Features
- ✨ 43 production-ready packages
- 📦 Unified package management
- 🎨 Material Design 3 support
- 🌓 Light and dark theme compatibility
- 📱 Cross-platform support (iOS, Android, Web, Desktop)
- 🔍 Comprehensive example app
- 📚 Extensive documentation
- ⚡ Performance optimized
- 🧪 Tested and validated

[1.0.0]: https://github.com/SoundSliced/s_packages/releases/tag/v1.0.0
