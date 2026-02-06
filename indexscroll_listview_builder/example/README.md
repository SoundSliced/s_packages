# IndexScrollListViewBuilder Example

Interactive demonstration of the `indexscroll_listview_builder` package features.

## Features Demonstrated

This example app showcases all major capabilities of the package:

### 1. **Basic List** 📋
Simple scrollable list with 100 items demonstrating the base functionality.

### 2. **Auto-Scroll Demo** 🎯
Comprehensive demonstration of automatic scrolling with:
- **Slider Control**: Select target index (0-99) with real-time updates
- **Offset Control**: Adjust number of items visible before target (0-10)
- **Alignment Control**: Position target item in viewport (0.0 = top, 1.0 = bottom)
- **Smooth Animations**: Watch items scroll into view with configurable alignment

### 3. **External Controller** 🎮
Advanced programmatic control demonstrating:
- **First/Last Buttons**: Jump to list extremes with perfect positioning
- **Increment Buttons**: Navigate +10/-10 items with boundary protection
- **Direct Index Input**: Type any index to scroll directly
- **Bidirectional Scrolling**: Works perfectly both up and down the list

## Running the Example

```bash
cd example
flutter run
```

Select your target platform (iOS, Android, Web, Desktop).

## Key Learnings

### Bidirectional Scrolling ✅
Notice how scrolling works perfectly in both directions - try scrolling from index 90 down to index 10, then back up to 80.

### Off-Screen Items ⚡
Scroll to items that haven't been rendered yet (e.g., index 99 when starting at 0) - the package estimates their position and scrolls smoothly.

### Operation Cancellation 🔄
Rapidly drag the slider or press buttons multiple times - superseded scroll operations are automatically cancelled for smooth animations.

### Last Item Handling 🎬
Tap "Last" to see how the package ensures the final item is fully visible using `maxScrollExtent`.

## Code Structure

- `main.dart` - Complete example implementation
- `pubspec.yaml` - Package dependency configuration via path reference

## Version

This example is built for **indexscroll_listview_builder v2.0.0** and demonstrates all the improvements:
- Viewport-based scrolling
- Smart position estimation
- Operation versioning
- Perfect bidirectional scrolling

