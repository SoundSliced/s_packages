# s_dropdown

Flexible, lightweight Flutter dropdown (SDropdown) offering precise overlay control, keyboard navigation, controller-based actions, per-item styles, and responsive sizing.


## Example app

See the `example/` directory which demonstrates basic usage of the package.

![SDropdown example GIF](https://raw.githubusercontent.com/SoundSliced/s_dropdown/main/example/assets/example.gif)
Shown above: the example app from `example/` with grouped sections, responsive controls, and controller-driven actions.

## Installation


For use, add the following to your package's `pubspec.yaml`:

```yaml
dependencies:
  s_dropdown: ^2.1.1
```


For local development, add the following to your package's `pubspec.yaml`:

```yaml
dependencies:
  s_dropdown:
    path: ../
```

For published package usage, simply depend on `s_dropdown` from pub.dev (if published).

## Usage

Import the package and use `SDropdown` inside a `MaterialApp`:

```dart
import 'package:flutter/material.dart';
import 'package:s_dropdown/s_dropdown.dart';

// Basic example
SDropdown(
  items: ['Apple', 'Banana', 'Cherry'],
  hintText: 'Select a fruit',
  width: 240,
  height: 52,
  onChanged: (value) {
    // handle selection
  },
  controller: SDropdownController(),
)
```

### Advanced usage examples

Decorated dropdown with overlay sizing and custom item names:

```dart
SDropdown(
  items: ['a', 'b', 'c'],
  selectedItem: 'a',
  selectedItemText: 'Apple',
  customItemsNamesDisplayed: ['Apple', 'Banana', 'Cherry'],
  overlayWidth: 350,
  overlayHeight: 180,
  decoration: SDropdownDecoration(
    closedFillColor: Colors.white,
    expandedBorder: Border.all(color: Colors.blueAccent, width: 1.5),
  ),
)
```

Validator and item-specific styles with responsive sizing:

```dart
Form(
  child: SDropdown(
    items: ['Apple', 'Banana', 'Cherry'],
    hintText: 'Pick a fruit',
    width: 70.w,
    height: 6.h,
    itemSpecificStyles: {'Cherry': TextStyle(color: Colors.purple)},
    validateOnChange: true,
    validator: (v) => v == null ? 'Please select' : null,
  ),
)
```

Programmatic usage with `SDropdownController`:

```dart
final controller = SDropdownController();

SDropdown(
  items: ['A', 'B', 'C'],
  controller: controller,
);

// Toggle programmatically
controller.open();
controller.highlightNext();
controller.selectHighlighted();

// Highlight/select by index or item value
controller.highlightAtIndex(1); // highlight the 2nd item
controller.highlightItem('B'); // highlight item 'B' by value
controller.selectIndex(2); // select the 3rd item programmatically
controller.selectItem('A'); // select item 'A' programmatically

// Navigate to next/previous item with automatic wrapping
controller.selectNext(); // select next item (wraps to first item if at end)
controller.selectPrevious(); // select previous item (wraps to last item if at start)

// Note: highlightAtIndex/selectIndex use indices from the original `items` list (0-based). If `excludeSelected` is true, the overlay may not show the item until re-opened and the highlight may be adjusted accordingly.

Note: When you call `controller.open()` (and other controller actions), the dropdown requests focus automatically (when `useKeyboardNavigation` is true), so you can immediately use arrow keys and Enter/Escape without clicking the widget first.

### Controller behavior with `excludeSelected`

When using `excludeSelected: true` the currently selected item is removed from the overlay list. `highlightAtIndex` and `highlightItem` try to map the given index/value to the currently visible overlay entries — if the item is excluded the highlight won't apply.

However, `selectIndex` and `selectItem` operate on the logical value and will select items regardless of their current visibility in the overlay. Example:

```dart
final controller = SDropdownController();

SDropdown(
  items: ['Apple','Banana','Cherry'],
  excludeSelected: true,
  selectedItem: 'Apple', // Apple will be excluded from overlay
  controller: controller,
);

controller.highlightAtIndex(0); // Will open the overlay but cannot highlight 'Apple' because it's excluded
controller.selectIndex(2); // Selects 'Cherry' regardless; onChanged will run and overlay will close
```
```

## Features

- Full control over dropdown/button width, height, and overlay dimensions
- Native overlay positioning using CompositedTransformTarget/Follower
- Minimal external dependencies: optional helper packages are used only in examples (e.g., `sizer`) for responsive sizing and layout.
- Advanced styling with `SDropdownDecoration`
- Keyboard & pointer interaction, highlight management, and overlay controls via `SDropdownController`
  - Programmatic open requests focus automatically to enable immediate keyboard navigation.
  - Navigation methods: `selectNext()` and `selectPrevious()` with wrapping support
  - Exposed `tapRegionGroupId` for custom TapRegion grouping to prevent unwanted overlay closure

### Advanced features

- `excludeSelected` - hide the currently selected item from the overlay list
- `customItemsNamesDisplayed` - show custom display strings for items while keeping their logical values
- `itemSpecificStyles` - apply special text style per item
- `selectedItemText` - override the header display text for a selected item (useful when `customItemsNamesDisplayed` is used)
- `overlayWidth` / `overlayHeight` - explicitly control overlay sizing independent of the button
- `validateOnChange` and `validator` - integrate with basic validation flows
- `SDropdownController` - programmatic expansion, collapse, toggling, highlight navigation, and item selection
  - `selectNext()` and `selectPrevious()` methods for sequential navigation with automatic wrapping
  - `tapRegionGroupId` property to enable custom control accessibility without dismissing the overlay
- `copyWith` - copy a widget with modified properties to reuse existing settings

## Example

See the `example/` folder for a runnable Flutter example. It demonstrates:

- Basic usage with selection
- Decoration + overlay sizing
- Excluding the selected item with custom display names
- Selected text override
- Validator + item-specific styles + responsive sizing
- Controller demo: open/close/toggle, highlight/select by index/value

## Running tests

Run the widget tests with:

```bash
flutter test
```

## License

This package is licensed under the MIT License. See `LICENSE` for details.

## Repository

https://github.com/SoundSliced/s_dropdown

