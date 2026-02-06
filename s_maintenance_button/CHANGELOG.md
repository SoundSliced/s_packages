# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-11

### Added
- Initial release of `s_maintenance_button`
- `SMaintenanceButton` widget with animated glow effect for maintenance mode indication
- `isOnMaintenance` property to toggle maintenance state with visual feedback
- `activeColor` property to customize the glow and button color when maintenance is active
- `nonActiveColor` property to customize the icon color when maintenance is inactive
- `onTap` callback for handling button interactions
- Automatic visibility control - only visible in debug and profile modes
- Animated pulsing glow effect when maintenance mode is active
- Interactive example app with playground to test all features
- Comprehensive test suite

### Features
- **Debug-only visibility**: Widget renders as `SizedBox.shrink()` in release mode
- **Animated glow effect**: Uses `Glow2` widget with smooth pulsing animation
- **Customizable colors**: Both active and inactive states can be customized
- **Tap handling**: Optional callback for toggle or custom actions
