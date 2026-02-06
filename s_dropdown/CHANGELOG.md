
```markdown

## 2.1.1

Bug fix release for keyboard navigation focus styling.

Changes:
- Fixed: Focus border now properly scales when `scale` parameter is applied to the dropdown widget.
- Fixed: Focus border shadow blur radius and spread radius now scale proportionally with the widget.
- Fixed: Focus border width now scales proportionally with the widget.

## 2.1.0

This release adds programmatic navigation methods and improves control accessibility in dropdown overlays.

Changes:
- New: `selectNext()` and `selectPrevious()` controller methods for programmatic navigation between items with wrapping support.
- New: `tapRegionGroupId` property exposed from `SDropdownController` to enable advanced TapRegion grouping for custom controls without dismissing the dropdown overlay.
- Fixed: Autoscroll to selected item now works correctly when opening the dropdown with `excludeSelected: false`.
- Improved: Keyboard navigation and item selection logic for better edge-case handling.

## 2.0.1

- upgraded dependencies 

## 2.0.0

This release introduces first-class keyboard navigation and polishes the example app.

Changes:
- New: keyboard navigation (Arrow Up/Down, Enter/Space, Escape) when `useKeyboardNavigation` is enabled.
- Programmatic open now auto-requests focus so keyboard navigation works immediately without tapping the widget first. Affected controller paths: `open`, `toggle`, `highlightNext/Previous`, `highlightAtIndex`, `highlightItem`, and `selectHighlighted`.
- Example page fully revamped: sections, responsive Wrap controls, icons, tooltips, helpful descriptions, and a clean selection summary.
- Documentation updates: clarified controller behavior and focus on programmatic open; README reflects the new example and features.

## 1.1.0

* New controller capabilities and enhancements
  - Added `SDropdownController` methods: `highlightAtIndex`, `highlightItem`, `selectIndex`, and `selectItem` to programmatically highlight and select items by index or value.
  - Tests added to validate these methods and controller-based navigation.
  - Example updated to demonstrate controller-based select/highlight by index and by value.
	- Added widget tests and advanced tests for key features (overlay, controller actions, excludeSelected, custom display names, validator integration, item-specific styles).
	- Updated `README.md` to include examples and advanced usage scenarios, with responsive sizing examples.
	- Added `LICENSE` file (MIT) and updated `pubspec.yaml` with license metadata.
	- Improved internal docs (`lib/src/SDropdown_Documentation.md`) and corrected wording on dependency usage.
	- Minor fixes to test timing and overlay animation handling to avoid flakiness.

## 1.0.2

* Maintenance and documentation release
	- Added comprehensive `example/` app demonstrating basic and advanced use cases.

## 1.0.1

* updated `README.md` file

## 1.0.0

* Initial stable release
	- Implemented `SDropdown` widget with overlay, highlight, keyboard navigation, and selection capabilities
	- Added `SDropdownDecoration` for comprehensive styling
	- Added `SDropdownController` for programmatic control (open/close/toggle/highlight)
	- Responsive and flexible overlay sizing with width/height and scale support
	- Included sample `example/` app demonstrating widget usage and controller actions
	- Unit/widget tests covering basic functionality and overlay behavior

## 0.0.1

* Initial release
