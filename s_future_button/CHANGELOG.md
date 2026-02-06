## 1.0.0

* **Initial stable release**: SFutureButton widget with full async operation support
* **Automatic state management**: Handles loading, success, error, and reset states
* **Future return value handling**:
  - Returns `true`: Shows success animation
  - Returns `false`: Shows error state with validation message
  - Returns `null`: Silent dismissal without animation
  - Throws exception: Shows error state with exception message
* **Customizable UI**:
  - Configurable button dimensions (height, width)
  - Custom background and icon colors
  - Border radius customization
  - Elevated or flat button styles
  - Optional error message display
* **Callbacks and hooks**:
  - `onPostSuccess`: Called after successful operation completion
  - `onPostError`: Called after error state display
* **Accessibility features**:
  - Focus node support
  - Focus change callbacks
  - Disabled state handling with SDisabled
* **Animation features**:
  - Smooth squeeze animation on tap
  - Loading circle indicator with configurable size
  - Success/error state animations with bounce effect
  - 1.5-second error display before auto-reset
* **State persistence**: Button state survives hot reload
* **Dependencies**: Uses RxDart for reactive state management and states_rebuilder for state management
