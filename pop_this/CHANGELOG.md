## 2.0.1

* Documentation updated

## 2.0.0

* **BREAKING CHANGE**: Removed `overlay_support` package dependency
  * Now uses native Flutter overlay system
  * **Automatic Setup**: No manual wrapper required! PopThis automatically sets up the overlay system when first used
  * Simply remove `OverlaySupport.global` wrapper from your MaterialApp - everything works automatically
  * **Migration**: Remove the `OverlaySupport.global` wrapper from your code
* Improved performance by using direct overlay management
* Simplified package dependencies
* Fixed: Automatically wraps overlay content with `Sizer` package to ensure responsive sizing

## 1.0.1

* Updated `s_button` dependancy  

## 1.0.0

* Initial release of `pop_this` package.
* Core features:
  * **Easy Popup Management**: Show any widget as a popup with a single function call
  * **Stacked Popups**: Open multiple popups on top of each other with automatic navigation history
  * **Auto-Dismissal**: Built-in timer support with optional visual countdown timer
  * **Animated Transitions**: Customizable entry and exit animations with configurable duration and curves
  * **Success/Error Overlays**: Pre-styled overlay presets for quick user feedback
  * **Custom Styling**: Extensive customization options for colors, shadows, borders, and background effects
  * **Background Blur**: Optional blur effect for overlay backgrounds
  * **Keyboard Support**: ESC key to dismiss popups
  * **Flexible Positioning**: Custom popup positioning with offset support
  * **State Management**: Built-in methods to check popup state and dismiss programmatically

