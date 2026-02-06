# states_rebuilder_extended

[![pub package](https://img.shields.io/pub/v/states_rebuilder_extended.svg)](https://pub.dev/packages/states_rebuilder_extended)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> Current stable version: **1.0.3** (uses `states_rebuilder: ^6.4.0`)

A collection of ergonomic extensions and helpers built on top of the [`states_rebuilder`](https://pub.dev/packages/states_rebuilder) package, providing type-safe state management utilities and enhanced developer experience.

## 🚀 Features

- ✅ **Type-safe updates**: Safer `update<T?>` and `update<T>` methods with explicit generic enforcement
- ✅ **Boolean helpers**: Convenient `toggle()` for both nullable and non-nullable `Injected<bool>`
- ✅ **Multi-injected builders**: Listen to multiple injected instances simultaneously with reactive builders
- ✅ **Tag-based rebuilds**: Selective notification and rebuilding with tag matching
- ✅ **Safe refresh**: `safeRefresh()` to gracefully handle disposed injector exceptions
- ✅ **Hot reload mixin**: `RebuildOnHotReloadMixin` for reliable Flutter Web hot reload state rebinding
- ✅ **Injection shortcuts**: `InjectExtension` and `MyNull` for concise injector creation

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  states_rebuilder_extended: ^1.0.3
```

Then run:

```bash
flutter pub get
```

## 🎯 Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder_extended/states_rebuilder_extended.dart';

// Create an injected counter
final counter = 0.inject<int>();

// Type-safe update
void increment() {
  counter.update<int>((value) => value + 1);
}

// Reactive UI
Widget buildCounter() {
  return counter.builderData<int>(
    (count) => Text('Count: $count'),
  );
}
```

## 📚 Usage Examples

### 1. Type-Safe Updates

The `update` method enforces explicit generic types to prevent runtime errors:

```dart
// Non-nullable injected state
final counter = 0.inject<int>();
counter.update<int>((s) => s + 1);

// Nullable injected state
final nullableCounter = MyNull.inject<int?>();
nullableCounter.update<int?>((s) => (s ?? 0) + 1);
```

### 2. Boolean Toggle

Convenient toggle method for boolean states:

```dart
// Non-nullable boolean
final isDarkMode = false.inject<bool>();
isDarkMode.toggle(); // true
isDarkMode.toggle(); // false

// Nullable boolean (defaults to false if null)
final isEnabled = MyNull.inject<bool?>();
isEnabled.toggle(); // true
isEnabled.toggle(); // false
```

### 3. Reactive Builders

Multiple builder options for different use cases:

```dart
final counter = 0.inject<int>();

// Simple builder - just rebuild on changes
counter.builder(
  () => Text('Count: ${counter.state}'),
);

// Builder with state - access SnapState for loading/error handling
counter.builderState(
  (state) => state.isWaiting
      ? CircularProgressIndicator()
      : Text('Count: ${state.data}'),
);

// Data builder - automatic waiting/error/data handling
counter.builderData<int>(
  (count) => Text('Count: $count'),
  onWaiting: () => CircularProgressIndicator(),
  onError: (error) => Text('Error: $error'),
);
```

### 4. Multi-Injected Builders

Listen to multiple injected instances at once:

```dart
final firstName = 'John'.inject<String>();
final lastName = 'Doe'.inject<String>();

// Listen to both and rebuild when either changes
[firstName, lastName].builder(
  () => Text('${firstName.state} ${lastName.state}'),
);

// With data handling
[firstName, lastName].builderData(
  (data) => Text('${data[0]} ${data[1]}'),
);

// Indexed builder for lists
final counters = [0.inject(), 0.inject(), 0.inject()];
counters.builderDataIndexed(
  (index, count) => ListTile(
    title: Text('Counter $index: $count'),
    trailing: IconButton(
      icon: Icon(Icons.add),
      onPressed: () => counters.update<int>(
        (s) => s + 1,
        index: index,
      ),
    ),
  ),
);
```

### 5. Tag-Based Selective Rebuilds

Notify and rebuild only specific tagged widgets:

```dart
final counter = 0.inject<int>();

// Update with a specific tag
void incrementWithTag() {
  counter.update<int>(
    (s) => s + 1,
    tag: 'mainCounter',
  );
}

// Only rebuilds if notification matches tag
counter.builder(
  () => Text('Main: ${counter.state}'),
  tag: 'mainCounter', // Only rebuilds for 'mainCounter' updates
);

// This won't rebuild for 'mainCounter' updates
counter.builder(
  () => Text('Other: ${counter.state}'),
  tag: 'otherCounter',
);
```

### 6. Nullable Injection with MyNull

Create nullable injected instances easily:

```dart
// Create a nullable injected instance
final selectedUser = MyNull.inject<User?>();

// Auto-dispose version
final temporaryData = MyNull.injectDisposable<String?>();

// Use it
selectedUser.update<User?>((s) => User('John Doe'));
```

### 7. Safe Refresh

Refresh injected state without throwing on disposed instances:

```dart
final data = 0.inject<int>();

// Regular refresh might throw if disposed
// data.refresh(); // Could throw

// Safe refresh ignores disposed exceptions
data.safeRefresh(); // Safe in all scenarios
```

### 8. Hot Reload Support

For Flutter Web, ensure state survives hot reload:

```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});
  
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with RebuildOnHotReloadMixin {
  // Your injected state references will rebind on hot reload
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

## 🎨 Complete Example

Check out the [example](example/lib/main.dart) app for a complete working demonstration:

```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder_extended/states_rebuilder_extended.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'states_rebuilder_extended Example',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Examples')),
      body: const Column(
        children: [
          CounterWidget(),
          ToggleWidget(),
          MultiCounterWidget(),
        ],
      ),
    );
  }
}

// Simple counter with type-safe update
class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});
  
  static final counter = 0.inject();

  @override
  Widget build(BuildContext context) {
    return counter.builderData<int>(
      (count) => Column(
        children: [
          Text('Counter: $count'),
          ElevatedButton(
            onPressed: () => counter.update<int>((s) => s + 1),
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}

// Boolean toggle example
class ToggleWidget extends StatelessWidget {
  const ToggleWidget({super.key});
  
  static final isEnabled = false.inject();

  @override
  Widget build(BuildContext context) {
    return isEnabled.builderData<bool>(
      (enabled) => Column(
        children: [
          Text('Enabled: $enabled'),
          ElevatedButton(
            onPressed: () => isEnabled.toggle(),
            child: const Text('Toggle'),
          ),
        ],
      ),
    );
  }
}

// Multi-injected builder example
class MultiCounterWidget extends StatelessWidget {
  const MultiCounterWidget({super.key});
  
  static final counters = [0.inject(), 0.inject(), 0.inject()];

  @override
  Widget build(BuildContext context) {
    return counters.builderDataIndexed(
      (index, count) => Row(
        children: [
          Text('Counter $index: $count'),
          ElevatedButton(
            onPressed: () => counters.update<int>(
              (s) => s + 1,
              index: index,
            ),
            child: const Text('+'),
          ),
        ],
      ),
    );
  }
}
```

## 📖 API Reference

### Extensions

#### `StateRebuilderExtension<T>` on `Injected<T?>`
- `update<R extends T?>(Function mutator, {bool shouldNotify, String? tag})`
- `builder(Function builder, {String? tag, ...})`
- `builderState(Function builder, {String? tag, ...})`
- `builderData<R>(Function builder, {String? tag, ...})`

#### `NonNullableStateRebuilderExtension<T>` on `Injected<T>`
- `update<R extends T>(Function mutator, {bool shouldNotify, String? tag})`

#### `BooleanStateRebuilderExtension` on `Injected<bool?>`
- `toggle({bool shouldNotify, String? tag})`

#### `NonNullableBooleanStateRebuilderExtension` on `Injected<bool>`
- `toggle({bool shouldNotify, String? tag})`

#### `SafeRefresh` on `Injected<dynamic>`
- `safeRefresh()`

#### `InjectExtension<T>` on `T`
- `inject<R>({bool autoDispose, ...})`
- `injectDisposable({...})`

#### `MultipleStateRebuilderExtension` on `List<Injected<dynamic>>`
- `update<R>(Function mutator, {int index, String? tag, ...})`
- `updateAll<R>(Function mutator, {String? tag, ...})`
- `notify({String? tag})`
- `builder(Function builder, {String? tag, ...})`
- `builderState(Function builder, {String? tag, ...})`
- `builderData(Function builder, {String? tag, ...})`
- `builderDataIndexed(Function builder, {String? tag, ...})`

### Classes

#### `MyNull`
Helper class for creating nullable injected instances:
- `static inject<T?>({bool autoDispose, ...})`
- `static injectDisposable<T?>({...})`

### Mixins

#### `RebuildOnHotReloadMixin`
Mixin for StatefulWidget states to support hot reload on Flutter Web.

## 🧪 Testing

The package includes unit tests covering core behaviors. Run them with:

```bash
flutter test
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [pub.dev](https://pub.dev/packages/states_rebuilder_extended)
- [GitHub Repository](https://github.com/SoundSliced/states_rebuilder_extended)
- [Issue Tracker](https://github.com/SoundSliced/states_rebuilder_extended/issues)
- [states_rebuilder](https://pub.dev/packages/states_rebuilder) – underlying state management package

## 💡 Credits

Built on top of the excellent [states_rebuilder](https://pub.dev/packages/states_rebuilder) package by [Mellati Fatah](https://github.com/GIfatahTH).

---

For change history see the [CHANGELOG](CHANGELOG.md).
