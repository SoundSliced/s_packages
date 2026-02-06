# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-29

### Added
- Initial release of `settings_item` package
- Customizable expandable menu widget for settings pages
- Three operational modes:
  - **Switch mode**: Toggle switch for on/off settings
  - **Expandable mode**: Expandable content with smooth animations
  - **Button mode**: Arrow rotation without content expansion
- **Flexible state management**: Support for both controlled (external state) and uncontrolled (internal state) modes
  - `isActive` parameter is optional - when provided, widget uses external state management
  - `initialState` parameter for setting initial value when using internal state management
- Smooth animations with configurable durations and curves
- Comprehensive customization options:
  - Custom prefix icons
  - Custom title text
  - Custom suffix widgets
  - Custom expanded content
  - Callback for state changes
  - Callback for expansion toggle events
- Material Design 3 styling with theme integration
- Responsive design with automatic height calculation
- Built with `s_bounceable` for interactive feedback
- Built with `s_toggle` for elegant switch controls
- Full example app demonstrating all features
- Comprehensive test coverage

[1.0.0]: https://github.com/SoundSliced/settings_item/releases/tag/v1.0.0
