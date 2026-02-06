# s_dropdown Example


This is a simple Flutter application that demonstrates how to use the `SDropdown` widget from the `s_dropdown` package. The example shows:

- Basic usage and selection
- Custom styled dropdowns with `SDropdownDecoration`
- Excluding the selected item from the overlay
- Using `customItemsNamesDisplayed` for friendlier item text
- Item-specific styles
- Responsive sizes with `sizer` (the app uses `Sizer` for percentage-based widths/heights)
- Controller-based programmatic actions (open/close/highlight/select)
 - Controller-based programmatic actions (open/close/toggle/highlight/select/ highlightAtIndex/ highlightItem/ selectIndex/ selectItem)
 - Programmatic open requests focus automatically, enabling immediate keyboard navigation (arrow keys, Enter/Escape)

The app lives in `example/lib/main.dart` and is intended to mirror README examples.

To run this example locally:

```bash
cd example
flutter run
```

Controller example from the app:

```dart
final controller = SDropdownController();

// Use the controller to highlight/select
controller.open();
controller.highlightAtIndex(2);
controller.selectItem('Banana');

// With focus auto-request, you can use keyboard immediately:
// Arrow keys to move, Enter to select, Escape to close.
```
