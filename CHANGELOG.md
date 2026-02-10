
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
