# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.5]

* updated dependencies

## [1.0.4]

* updated dependencies

## [1.0.3]

- TimeSpinner: Fixed dots positioning issue where dots would drift and replace valid numbers
- TimeSpinner: Fixed scroll inertia issue for smoother scrolling
- TimeSpinner: Added `isInfiniteScroll` parameter to enable/disable infinite looping
- TimeSpinner: Fixed `discardedHrValues` logic in 12-hour format to correctly discard hours based on AM/PM period

## [1.0.2]

- TimeInput: upgraded smart interpretation of partially typed times made by user


## [1.0.1] - 2025-01-05

- TimeInput: the widget now displays and handles local times (with optional small 'L' in the textfield)

## [1.0.0] - 2025-01-05

### Added
- **TimeSpinner Widget**: Full-featured wheel-based time picker
  - Support for 12-hour and 24-hour time formats
  - Infinite scroll wheels for smooth time selection
  - Customizable hour and minute values
  - Ability to discard specific hours/minutes (e.g., lunch breaks)
  - Dual-text styling (selected vs non-selected)
  - Customizable borders, border radius, and background colors
  - AM/PM button styling support
  - Keyboard editing via double-tap
  - Real-time time change callbacks
  - Optional selection dots

- **TimeInput Widget**: Text-based time input field with smart formatting
  - Smart cursor positioning that follows user taps
  - Dual text modes: formatted display (HH:MM z) when unfocused, digits-only when focused
  - Automatic formatting of input (e.g., "1030" → "10:30")
  - Keyboard navigation (Enter to submit, Escape to revert)
  - Real-time input validation
  - Extensive customization options (colors, fonts, padding, borders)
  - UTC and local time support
  - Optional/nullable time values
  - Optional clear button
  - Default time fallback for invalid input
  - Change and submit callbacks

- **TimeOfDayExtension**: Convenient extension method
  - `toDateTime()` - Convert TimeOfDay to DateTime with optional date parameter

- **AmPmButtonStyle**: Configuration class for AM/PM button styling
  - Customizable text style, colors, borders, and dimensions

### Documentation
- Comprehensive README with installation instructions
- Basic and advanced usage examples
- API reference with all properties documented
- Example Flutter application showcasing all features
- Complete widget documentation with code snippets

### Testing
- Basic functionality tests for both widgets
- Input validation tests
- Time conversion tests
- Custom value configuration tests

### Example App
- Fully functional demo application
- Multiple examples for TimeSpinner configurations
- Multiple examples for TimeInput variations
- Interactive toggles to demonstrate all features
- Features showcase section with visual cards
- Clean, modern Material Design UI

## Initial Release

This is the first stable release of the s_time package.
All core features are fully implemented, tested, and documented.
