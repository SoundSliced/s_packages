## 1.3.0

* **Breaking Change**: Renamed `onOffstageStateChanged` to `onChanged` for brevity and consistency.
* **Breaking Change**: Renamed `forceReveal` to `showRevealButton` for clarity.
* **Enhancement**: Improved reveal button positioning logic:
  * Centered when using default loader.
  * Offset to top-right when using custom loader or custom hidden content to avoid obscuring content.
* **Enhancement**: Made custom `hiddenContent` tappable when `showRevealButton` is true, with proper splash effects and visibility icon overlay.
* **Fix**: Ensured splash effects are visible on custom hidden content by adjusting layer stacking.

## 1.2.1

* updated README

## 1.2.0

* **Enhancement**: Improved exit animation logic to ensure smooth transitions when hiding content
* **Enhancement**: Updated example app with a modern single-page design
* **Feature**: Added interactive toggles in example app for `showLoadingIndicator` and custom `loadingIndicator`
* **Fix**: Resolved `setState` issues in example app by using `addPostFrameCallback`
* **Documentation**: Updated README with comprehensive details on new features and example usage

## 1.1.0

* **Major Feature Release**: Added comprehensive animation and transition system
* Added multiple transition types: fade, scale, fadeAndScale, slide, rotation
* Added custom animation curves: `fadeInCurve`, `fadeOutCurve`, `scaleCurve`
* Added delay parameters: `delayBeforeShow`, `delayBeforeHide`
* Added `onAnimationComplete` callback for tracking animation completion
* Added `onOffstageStateChanged` callback to track visibility state changes 
* Added conditional loading indicator with `showLoadingAfter` parameter
* Added state management options: `maintainState`, `maintainAnimation`
* Added slide configuration: `slideDirection`, `slideOffset`
* Enhanced example app to showcase all new features
* Added comprehensive tests for all new features
* Updated documentation with detailed examples
* Updated README with better description of how the widget works as an alternative to Visibility
* Enhanced example to demonstrate the callback functionality
* Added comprehensive tests for callback behavior

## 1.0.1

* updated `README.md` file 


## 1.0.0

* Initial public release
* Added `SOffstage` widget for smooth loading/content transitions
* Added `HiddenContent` widget for content reveal/hide scenarios
* Supports fade transitions, custom loading indicators, and performance optimizations
* Example and test scaffolding

## 0.0.1

* Initial release
