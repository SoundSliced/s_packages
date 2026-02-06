## 2.1.1

- **UPDATED**: Added debug assert to catch missing `Modal.appBuilder` setup

## 2.1.0

- **FIXED**: Widgets requiring an `Overlay` ancestor (like `Slider`, `TextField`, `DropdownButton`) now work correctly inside modals
- **IMPROVED**: Modal content now wrapped with dedicated `Navigator` to provide proper `Overlay` context
- **IMPROVED**: Added `HeroControllerScope.none` wrapper to prevent `HeroController` conflicts with app's main Navigator
- **UPDATED**: Replaced deprecated `onPopPage` with `onDidRemovePage` callback
- **NEW**: Example app now includes "Overlay Widgets Showcase" section demonstrating Slider, TextField, and DropdownButton usage in modals

## 2.0.0

- **BREAKING**: Removed `Modal.activator()` widget wrapper - replaced with `MaterialApp.builder` integration via `Modal.appBuilder()` as the former isn't appropriate and could cause issues
- **BREAKING**: Removed `Modal.initialiseActivator()` method - no longer needed with new installation approach
- **BREAKING**: Removed dependency on `sizer` package - now uses native MediaQuery for responsive sizing
- **BREAKING**: Removed dependency on `dart_helper_utils` package - simplified dependencies
- **BREAKING**: Removed dependency on `soundsliced_tween_animation_builder` package - uses built-in animation solutions
- **NEW**: `Modal.appBuilder()` function for seamless integration with MaterialApp/WidgetsApp builder pattern
- **NEW**: Optional `context` parameter in `Modal.show()` and `Modal.showSnackbar()` for improved first-call reliability
- **NEW**: `showDebugPrints` parameter in `Modal.appBuilder()` to control debug output
- **NEW**: `backgroundColor` parameter in `Modal.appBuilder()` to customize the app canvas color
- **IMPROVED**: Simplified installation - no need to wrap entire app, just use MaterialApp.builder
- **IMPROVED**: Better hot reload support with new architecture
- **IMPROVED**: More reliable modal display on first call without BuildContext juggling
- **IMPROVED**: Cleaner dependency tree with fewer external packages
- **IMPROVED**: All tests updated to use new `Modal.appBuilder()` pattern
- **IMPROVED**: Example app updated to demonstrate new installation method
- **FIXED**: Per-snackbar animation controller management prevents dismissal conflicts
- **FIXED**: Unique animation keys per modal prevent animation state sharing between instances
- **FIXED**: Border radius animation synchronized with background layer for smoother sheet transitions

**Migration Guide:**

Old (v1.x):

```dart
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return Modal.activator(
      child: MaterialApp(
        home: MyHomePage(),
      ),
    );
  }
}
```

New (v2.0):

```dart
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: Modal.appBuilder,  // <-- Just add this line!
      home: MyHomePage(),
    );
  }
}
```

For advanced customization:

```dart
MaterialApp(
  builder: (context, child) => Modal.appBuilder(
    context,
    child,
    backgroundColor: Colors.black,
    borderRadius: BorderRadius.circular(24),
    shouldBounceOnTap: true,
    showDebugPrints: false,  // Set to true for debugging
  ),
  home: MyHomePage(),
)
```

## 1.1.0

- **BREAKING**: Renamed `Modal.showSnackbar()` parameter `isSwipeable` to `isDismissible` for API consistency
- Unified dismissal logic: `Modal.show()` with `modalType: ModalType.snackbar` now respects `isDismissible` consistently
- Enhanced `isDismissible` behavior: when `false`, snackbars now automatically disable auto-dismiss timer
- Improved `Modal.updateParams()` to properly handle `isDismissible` for snackbar updates
- Added `barrierColor` parameter to snackbars with animated fade in/out support
- Updated example app with new snackbar configurator controls (isDismissible toggle and barrierColor selector)
- Updated documentation to reflect new API patterns

## 1.0.2

- README updated

## 1.0.1

- pubspec.yaml package's description updated

# Changelog

All notable changes to the s_modal package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-01

### 🎉 Initial Release

The first stable release of `s_modal` - a comprehensive Flutter package for modal overlays.

#### ✨ Features Added

**Core Modal Types:**

- ✅ **Sheets**: Bottom, top, left, and right edge sheets with drag-to-expand functionality
- ✅ **Dialogs**: Centered modal dialogs with optional draggable and offset positioning
- ✅ **Snackbars**: Smart notifications with multiple display modes and auto-dismiss

**Sheet Features:**

- Expandable sheets with configurable max size (percentage of screen)
- Interactive drag handle for user-friendly interaction
- Support for all four edges (bottom, top, left, right)
- Auto-sizing based on content or fixed dimensions
- Customizable colors, borders, and shadows
- Smooth entrance and exit animations

**Dialog Features:**

- Centered positioning with optional pixel-based offset
- Optional draggable functionality to reposition on screen
- Fade and scale animations
- Customizable background blur and barrier color
- Support for any alignment position

**Snackbar Features:**

- 9 standard alignment positions + custom offset positioning
- 4 display modes: staggered, notification bubble, queued, replace
- Auto-dismiss with optional duration
- Visual duration indicator with left-to-right or right-to-left animation
- Swipe-to-dismiss (horizontal and vertical)
- Customizable icons, colors, and action buttons
- Smart stacking with configurable max stack size

**Advanced Features:**

- **Independent Lifecycles**: Each modal type (sheet, dialog, snackbar) has its own controller for conflict-free operation
- **Live Updates**: `Modal.updateParams()` for real-time property changes without recreation
- **ID-Based Management**: Assign IDs to modals for precise control and tracking
- **Hot Reload Support**: `ModalBuilder` widget preserves state during development
- **Type-Safe API**: Comprehensive enums for all configurations
- **Background Effects**: Customizable blur amount (0-20) and barrier colors
- **Callbacks**: `onDismissed`, `onExpanded`, and `onTap` hooks
- **Smart Dismissal**: Tap outside, swipe gestures, or programmatic control

**Developer Experience:**

- Comprehensive example app with interactive configurators
- Extensive test coverage (unit and integration tests)
- Detailed inline documentation
- Hot reload support for rapid development
- Type-safe APIs with helpful IDE autocomplete

**State Management:**

- Built on states_rebuilder_extended for reactive state
- Separate controllers for each modal type prevent conflicts
- Global registry tracks all active modals
- Per-snackbar animation controllers for independent lifecycles

**API Methods:**

- `Modal.show()` - Display any modal type with full customization
- `Modal.showSnackbar()` - Convenient pre-styled snackbar
- `Modal.dismiss()` / `dismissDialog()` / `dismissBottomSheet()` - Type-specific dismissal
- `Modal.dismissById()` - Dismiss by unique identifier
- `Modal.dismissAll()` - Clear all modals
- `Modal.dismissByType()` - Dismiss all modals of a specific type
- `Modal.dismissAllSnackbars()` - Clear all snackbars
- `Modal.updateParams()` - Live property updates
- `Modal.isModalActiveById()` - Check if specific modal is showing
- `ModalBuilder` / `ModalBuilder.dialog` / `ModalBuilder.snackbar` - Hot-reload-friendly widgets

**State Checks:**

- `Modal.isActive` - Check if any modal is showing
- `Modal.isDialogActive` / `isSheetActive` / `isSnackbarActive` - Type-specific checks
- `Modal.isDialogDismissing` / `isSheetDismissing` / `isSnackbarDismissing` - Animation state
- `Modal.activeModalId` - Get current modal's ID
- `Modal.allActiveModalIds` - List all active modal IDs
- `Modal.getActiveIdsByType()` - Filter by modal type

#### 🎨 Customization Options

**Sheet Customization:**

- Size (height for bottom/top, width for left/right)
- Expandable with max percentage size
- Background color
- Borders and border radius
- Content padding
- Drag handle visibility and styling

**Dialog Customization:**

- Position (any Alignment + custom Offset)
- Size constraints
- Draggable behavior
- Background blur and barrier color
- Border radius and shadows
- Animation types (fade, scale, slide, rotate)

**Snackbar Customization:**

- Position (9 alignments + custom offset)
- Width (percentage or fixed pixels)
- Display mode (staggered, bubble, queued, replace)
- Auto-dismiss duration
- Duration indicator (color, direction)
- Swipe-to-dismiss (horizontal/vertical)
- Icons (prefix and suffix)
- Colors (background, text, icons)
- Tap callback

**Global Options:**

- Background blur (enabled/disabled, intensity 0-20)
- Barrier color (any color with opacity)
- Dismissable on tap outside (true/false)
- Block background interaction (true/false)

#### 📦 Dependencies

- Flutter SDK >=3.0.0
- dart_helper_utils ^5.4.1
- states_rebuilder_extended ^1.0.3
- assorted_layout_widgets ^11.0.0
- sizer ^3.1.3
- flutter_animate ^4.5.2
- soundsliced_dart_extensions ^1.0.1
- s_bounceable ^2.0.0
- soundsliced_tween_animation_builder ^1.2.0
- s_ink_button ^1.1.0

#### 🐛 Known Issues

None at this time. Please report any issues on [GitHub](https://github.com/1.0.2/s_modal/issues).

#### 📝 Notes

- This is the first stable release ready for production use
- All core features are fully tested and documented
- Comprehensive example app included
- MIT License

---

## Future Plans (Roadmap)

Potential features for future releases:

- [ ] Custom modal types beyond sheet/dialog/snackbar
- [ ] Additional animation presets
- [ ] Theme system for consistent styling across app
- [ ] Accessibility improvements (screen reader support, focus management)
- [ ] Performance optimizations for large modal counts
- [ ] More snackbar templates (success, error, warning, info)
- [ ] Gesture customization options
- [ ] Modal transition animations between types
- [ ] Nested modal support
- [ ] Modal history/stack management

---

For more information, see the [README](README.md) or visit the [GitHub repository](https://github.com/1.0.2/s_modal).
