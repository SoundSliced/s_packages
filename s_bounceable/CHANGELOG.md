## 2.1.0
* SBounceable widget now uses Listener with pointer events (onPointerDown, onPointerUp, onPointerCancel) instead of gesture detector's tap events, to activate the scale animation: Pointer events are lower-level and always fire regardless of tap/click pressure


## 2.0.0

* No longer relies on flutter_bounceable package, as it is faulty when wanting to have scaleFactor of 1.0 --> it now uses a combination of GestureDetector and AnimatedScale internally
* isBounceEnabled param added to override whether to show or not the bounce effect

## 1.1.0

* didUpdateWidget added to Sbounceable to rebuild it when scaleFactor parameter is updated
* Example upgraded

## 1.0.0

* Initial stable release
* Added `SBounceable` widget with single and double tap support
* Integrated with `flutter_bounceable` for smooth scale animations
* Customizable scale factor for bounce effect
* Smart tap detection with configurable double-tap threshold (300ms)
* Comprehensive test coverage
* Complete example application

## 0.0.1

* Initial development release
