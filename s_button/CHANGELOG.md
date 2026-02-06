## 1.2.1

* `bubble_label` package dependency updated --> 
  - Fixed bubble positioning with ancestor transforms: Bubbles now correctly position themselves when the widget tree contains transforms such as Transform.scale, ForcePhoneSizeOnWeb (from flutter_web_frame), or FittedBox. Both the anchor position and visual size are now computed relative to the Overlay's coordinate system.

  -  Fixed bubble replacement during transforms: When showing a new bubble while one is already active, the Overlay's RenderBox reference is now correctly preserved (previously it was being cleared by the dismiss call before the new bubble was inserted).

  - Fixed crash when toggling transforms with active bubble: Added safety checks for RenderBox.attached to prevent "Assertion failed: attached is not true" errors when the widget tree is rebuilt (e.g., toggling Transform.scale mode) while a bubble is active.




## 1.2.0

* `bubble_label` package dependency updated --> ensure Overlay widget in complex widget trees is detected, by requiring context to be passed when calling BubbleLabel.show

## 1.1.0

* `s_ink_button` package dependency updated --> now `s_button` accepts hitTestBehavior to determines whether the button responds to touch events and how it interacts with other widgets in the hit test hierarchy.

## 1.0.3

* removed the class Box - used SizedBox widget instead

## 1.0.2

* Version 1.0.2

## 1.0.1

*GIF demo added to README 

## 1.0.0

### Initial Release

**Features:**
- Customizable button widget with flexible styling and interactions
- Splash effects with configurable color and opacity
- Bounce animation support with adjustable scale
- Bubble label tooltips for enhanced user feedback
- Multiple interaction modes:
  - Single tap with offset detection
  - Double tap support
  - Long press with start/end callbacks
- Shape customization:
  - Circle or rectangle button shapes
  - Custom border radius support
- Visual feedback:
  - Haptic feedback with multiple feedback types
  - Loading state management
  - Error handling with custom error builder
  - Button selected color overlay
- Advanced features:
  - Delayed widget initialization
  - Custom hit test behavior configuration
  - Tooltip support
  - Active/inactive state management
  - Rich animation controls
- Comprehensive dependency support:
  - Flutter animations via `flutter_animate`
  - Custom tween animations via `soundsliced_tween_animation_builder`
  - Bubble labels via `bubble_label`
  - Circular progress indicators via `ticker_free_circular_progress_indicator`
  - Advanced ink button effects via `s_ink_button`
  - Dart extensions via `soundsliced_dart_extensions`

### Documentation:
- Full API documentation with inline comments
- Example Flutter application with basic and advanced usage
- Comprehensive unit tests for all features
- README with usage examples and feature descriptions
