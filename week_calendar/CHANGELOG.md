# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [1.1.0] - 2026-02-05

* fixed `didUpdateWidget` method. When the selectedDate changed to a different month or year, the widget wasn't updating the _headerDate to match.


## [1.0.0] - 2026-01-03

### Added
- **Initial Release**: Complete weekly calendar widget package
- **Multiple Calendar Types**:
  - Standard: Circular day indicators (default)
  - Outlined: Bordered containers with customizable borders
  - Minimal: Simplified text-based display with underline selection
  - Elevated: Material Design elevated containers with shadows
- **Flexible Week Configuration**: Support for starting week on any day (Monday-Sunday)
- **Comprehensive Styling System**: `WeekCalendarStyle` class with extensive customization options
  - Custom colors (active, inactive, background)
  - Typography control (header, day names, day numbers)
  - Size customization (indicator sizes)
  - Border and shadow effects
  - Animation parameters
- **Rich Animation System**:
  - Configurable animation duration and curves
  - Enable/disable animations globally
  - Smooth transitions for date selection and navigation
- **Advanced Navigation Features**:
  - Month navigation with custom icons
  - Week-by-week navigation
  - Header date tapping with calendar popup
  - "Today" button for quick navigation
  - UTC and local date support
- **Comprehensive Callback System**:
  - Date selection callbacks
  - Month navigation callbacks
  - Week navigation callbacks
  - Header interaction callbacks
- **Accessibility Features**:
  - Future date disabling
  - Proper semantic structure
  - Touch-friendly interaction areas
- **Developer Experience**:
  - Comprehensive example app with all features
  - Extensive test suite covering all functionality
  - Detailed API documentation
  - Type-safe enum-based configuration
- **Cross-Platform Compatibility**: Works on iOS, Android, Web, and Desktop

### Technical Details
- Built with Flutter 3.0+ and Dart 3.0+
- Zero external UI dependencies (only utility packages)
- Optimized performance with efficient widget rebuilding
- Follows Flutter best practices and Material Design guidelines
- Comprehensive test coverage with 100+ test cases

### Dependencies
- `flutter`: Core Flutter framework
- `intl`: Date formatting utilities
- `dart_helper_utils`: Date manipulation helpers
- `s_ink_button`: Custom ink button implementation
- `icons_plus`: Icon collection
- `assorted_layout_widgets`: Layout utilities
- `s_disabled`: Disabled state management
- `soundsliced_dart_extensions`: Custom extensions
- `calendar_date_picker2`: Calendar popup functionality</content>
<parameter name="filePath">/Users/christophechanteur/Development/Flutter_projects/my_extensions/week_calendar/CHANGELOG.md