## 1.1.1

* Updated `s_button` dependancy  

## 1.1.0

* **Bug Fix**: Fixed `ScrollTextFormFieldWhenKeyboardIsShown` widget causing runtime error "Unexpected null value" when scrolling (especially with mouse wheel on web)
  * Replaced incorrect `Scrollable` + `viewportBuilder` pattern with a simple `SingleChildScrollView` that properly manages its own scroll position

## 1.0.1

* pubspec.yaml updated

## 1.0.0

- **Keyboard Management**: `DismissKeyboard` widget to dismiss keyboards on tap, and `InputDoneView` with `KeyboardOverlay` for iOS-style done button overlay
- **Loading Indicators**: `SLoadingIndicator` wrapping `LoadingIndicator` with transform support and animation control
- **State Management**: `MountedState` base class for safe `setState` calls, preventing errors on unmounted widgets
- **Widget Extensions**: Extensions on all widgets for adding Material wrapping, tooltips, color filters, border radius, box decorations
- **UI Utilities**: `SDivider` for custom dividers, `STextButton` and `SIconButton` for flexible button implementations
- **Responsive Utilities**: `ForcePhoneSizeOnWeb` for forcing phone-sized frames on web, `ScrollTextFormFieldWhenKeyboardIsShown` for auto-scrolling
- **Animation Utilities**: `SBlur` and `SAnimatedBlur` for blur effects, `SButton` integration for tap interactions
- **Widget Measurement**: `MeasureChildSizeWidget` to measure child dimensions during layout
- **UI Components**: `ExpandCollapseButton` and `TextFormFieldClearButton` for common UI patterns
- **Snackbar Extensions**: `ShowSnackBar` extension on BuildContext for showing custom snackbars
- **Helper Functions**: `getWidgetPosition` and `getWidgetSize` utilities for determining widget dimensions
- **Full Documentation**: Comprehensive API documentation and multiple examples for all widgets
- **Performance**: Static widget caching and optimized rendering for better performance

## 0.0.1

* Initial release
