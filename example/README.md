# s_packages Example App

This is a comprehensive example app that showcases all the packages included in the `s_packages` collection.

## Features

- 📦 Browse all available packages organized by category
- 🔍 Search packages by name, description, or category
- 📱 Material Design 3 UI with light and dark theme support
- 🎯 Easy navigation to individual package examples

## Categories

The packages are organized into the following categories:

- **UI Components** - Visual widgets and components
- **Animations** - Animation utilities and effects
- **Lists** - List and collection widgets
- **Navigation** - Navigation and routing utilities
- **Networking** - HTTP and connectivity tools
- **State Management** - State management solutions
- **Utilities** - General-purpose utilities
- **Input** - Input handling and keyboard utilities
- **Layout** - Layout and positioning widgets
- **Platform** - Platform-specific integrations
- **Calendar** - Calendar and date widgets

## Running the App

```bash
cd example
flutter pub get
flutter run
```

## Structure

```
example/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/
│   │   └── package_info.dart        # Package information model
│   ├── screens/
│   │   ├── home_screen.dart         # Main browsing screen
│   │   └── package_example_screen.dart  # Individual package example
│   └── widgets/
│       └── package_card.dart        # Package card widget
└── pubspec.yaml                     # Dependencies
```

## Next Steps

To integrate actual examples from each package, you can:

1. Import the example main file from each package
2. Use Navigator to push to those examples
3. Or create a tab-based interface to show multiple examples

For example:
```dart
import 'package:bubble_label/example/main.dart' as bubble_label_example;

// Navigate to it
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => bubble_label_example.MyApp(),
  ),
);
```
