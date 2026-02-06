# S_Connectivity Example

A comprehensive example app demonstrating all features of the s_connectivity package.

## Features Demonstrated

### 1. **Real-time Connectivity Status**
- Live connection monitoring with visual indicators
- Automatic status updates when connectivity changes
- Reactive UI using states_rebuilder_extended

### 2. **NoInternetWidget**
Interactive widget customization including:
- **Toggle visibility** - Show/hide based on connection
- **Animation control** - Enable/disable smooth transitions
- **Size adjustment** - Slider to change widget dimensions (20-80px)
- **Background colors** - Multiple color options
- **Icon colors** - Customizable icon appearance
- **Icon selection** - Choose from various WiFi-related icons

### 3. **NoInternetConnectionPopup**
- Animated overlay that appears when offline
- Toggle to enable/disable the popup
- Automatic dismissal when connection restored

### 4. **Event Logging**
- Real-time event log tracking connection changes
- Timestamps for each connectivity event
- Clear functionality to reset the log

### 5. **Callbacks**
- `onConnected` callback triggered when connection restored
- `onDisconnected` callback triggered when connection lost
- Event logging demonstration of callback usage

## Running the Example

```bash
cd example
flutter pub get
flutter run
```

## Testing Connectivity Changes

To test the app's behavior during connectivity changes:

1. **On Simulator/Emulator:**
   - Toggle airplane mode or disable WiFi
   - The app will immediately reflect the connectivity status

2. **On Physical Device:**
   - Turn on airplane mode
   - Disable WiFi/mobile data
   - Observe real-time updates

## Code Highlights

### Initialization
```dart
AppInternetConnectivity.initialiseInternetConnectivityListener(
  () => print('Connected'),
  () => print('Disconnected'),
);
```

### Reactive UI
```dart
OnBuilder(
  listenTo: AppInternetConnectivity.controller,
  builder: () {
    return Text(AppInternetConnectivity.isConnected ? 'Online' : 'Offline');
  },
)
```

### Custom Widget
```dart
NoInternetWidget(
  size: 40,
  backgroundColor: Colors.red,
  iconColor: Colors.white,
  icon: Icons.wifi_off_rounded,
  shouldShowWhenNoInternet: true,
  shouldAnimate: true,
)
```

### Popup Overlay
```dart
if (showPopup) NoInternetConnectionPopup()
```

## UI Organization

The example app combines all features in a single screen using:
- Collapsible card sections for each component
- Toggle switches for quick feature testing
- Interactive controls (sliders, color pickers, icon selectors)
- Real-time event logging for debugging

This compact design allows developers to quickly explore and test all package capabilities without navigating multiple screens.
