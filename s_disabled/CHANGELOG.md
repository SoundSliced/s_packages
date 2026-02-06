
## 1.0.0

* **Initial Release**: Stable release of s_disabled package
* **SDisabled Widget**: A customizable Flutter widget for disabling child widgets with smooth animations
* **Features**:
  - Animated opacity changes when disabled (customizable, can be disabled)
  - Configurable opacity level when disabled (default 0.3)
  - Tap detection on disabled widgets with optional callback
  - Smooth transitions using AnimatedOpacity (300ms duration)
  - AbsorbPointer to prevent interaction with disabled children
  - Full state management support
* **Parameters**:
  - `child`: The widget to be disabled/enabled
  - `isDisabled`: Boolean flag to control disabled state
  - `disableOpacityChange`: Prevent visual opacity indication when disabled
  - `opacityWhenDisabled`: Custom opacity value for disabled state
  - `onTappedWhenDisabled`: Callback function for tap events on disabled widget
* **Documentation**: Complete README with basic and advanced examples
* **Testing**: Comprehensive widget tests covering all functionality
* **Example App**: Full Flutter example demonstrating usage patterns
