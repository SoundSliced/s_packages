## 2.0.1

* README updated to show example GIF

## 2.0.0

### 🎉 Major Features
- **Tappable Scroll Indicators**: Indicators are now interactive! Tap the top/left indicator to scroll backward, or bottom/right indicator to scroll forward.
- **Configurable Scroll Distance**: New `indicatorScrollFraction` parameter (0.1 to 2.0) allows users to control how far each indicator tap scrolls as a fraction of the viewport (e.g., 0.5 = half viewport, 1.0 = full viewport, 2.0 = two viewports).
- **Smart Edge Behavior**: New `initialIndicatorJump` parameter provides intuitive navigation at list edges - configurable initial jump when tapping forward from the start or backward from the end.
- **Viewport-Aligned Scrolling**: Smooth, gradual scrolling based on viewport dimensions rather than discrete item jumps.

### 🛠️ Improvements
- **Production Optimizations**: Removed debug logging, improved documentation, refactored code for better maintainability.
- **Flutter Web Support**: Comprehensive mounted checks to prevent disposed view errors during hot reload.
- **Manual Scroll Tracking**: Indicators now accurately track position after user drag/scroll gestures.
- **Tap Debouncing**: Prevents rapid-fire taps from causing conflicting scroll animations.

### 📝 Breaking Changes
- Indicator tap behavior is now enabled by default. Set `showScrollIndicators: false` to disable if needed.
- Scroll animations are now viewport-aligned instead of item-based (provides smoother UX).

### 🐛 Bug Fixes
- Fixed double-tap requirement on first indicator press at startup.
- Fixed indicator position tracking after manual scrolls.
- Fixed disposed view rendering errors on Flutter web hot reload.

## 1.0.2
- `README.md` updated 

## 1.0.1

- Added detailed documentation, README polish, and an interactive example that demonstrates orientation changes, indicator toggles, auto-scroll, and programmatic controller usage.
- Documented the exported API so pub.dev recognizes the library, class, constructor, and key setters.
- Stabilized widget tests by executing `jumpTo` manually instead of awaiting `scrollToIndex`, and noted the rationale in the test comments.

## 1.0.0

* Version 1.0.0

### Added
- Public `SGridView` widget with customizable cross-axis item count and layout
- Index-based scrolling using `IndexedScrollController` (via `indexscroll_listview_builder`)
- Optional scroll indicators when more rows are present for improved UX
- Support for custom padding, scroll controller injection, and automatic scroll-to-index

### Fixed
- Initial release; no bug fixes yet

## 0.0.1

* Initial release
