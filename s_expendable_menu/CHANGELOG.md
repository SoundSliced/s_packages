# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-23

### Added

- Initial release of s_expendable_menu package
- `SExpandableMenu` widget with pill-shaped expandable design
- Support for 4 expansion directions: left, right, up, down
- Auto expansion direction mode for screen-aware positioning
- Customizable animation duration and curves
- Scrollable item list with support for unlimited items (max 5 visible at once)
- Staggered animation for menu items with opacity and scale effects
- `SExpandableItem` model for defining menu items with icons and callbacks
- `SExpandableHandles` standalone widget for custom implementations
- Two operation modes for handles:
  - Standalone mode with internal state management
  - Controlled mode for external state management
- Comprehensive customization options:
  - Menu width and height
  - Background color with automatic border darkening
  - Icon color for all icons
  - Optional item container background color
  - Individual item icon size override
- RTL (Right-to-Left) support for vertical menus
- Smooth close button fade-in animation
- BouncingScrollPhysics for natural scrolling feel
- RepaintBoundary optimization for item lists
- Full example app demonstrating all features:
  - Color customization
  - Direction switching
  - Size variants
  - RTL support
  - Handle widget demo with external triggers

### Technical Details

- Built with Flutter SDK >=3.0.0
- Uses AnimatedBuilder for efficient animations
- Leverages SingleTickerProviderStateMixin for animation controllers
- Implements proper widget lifecycle management
- Platform-aware rendering with Directionality support

[1.0.0]: https://github.com/SoundSliced/s_expendable_menu/releases/tag/v1.0.0
