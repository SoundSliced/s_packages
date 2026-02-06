# states_rebuilder_extended Example

This example demonstrates key features of the `states_rebuilder_extended` package (version **1.0.2**, built on `states_rebuilder: ^6.4.0`).

## Running the Example

To run this example:

```bash
cd example
flutter pub get
flutter run
```

## What's Demonstrated

### 1. CounterWidget - Type-Safe Updates
Demonstrates:
- Creating an injected state with `.inject()`
- Type-safe updates with explicit generic `update<int>()`
- Reactive UI with `builderData<int>()`

```dart
static final counter = 0.inject();

counter.update<int>((s) => s + 1);

counter.builderData<int>(
  (count) => Text('Counter: $count'),
);
```

### 2. ToggleWidget - Boolean Toggle
Demonstrates:
- Boolean state management
- Convenient `toggle()` method
- Simple state mutations

```dart
static final isEnabled = false.inject();

isEnabled.toggle();

isEnabled.builderData<bool>(
  (enabled) => Text('Enabled: $enabled'),
);
```

### 3. MultiCounterWidget - Multi-Injected Builders
Demonstrates:
- Managing multiple related states
- `builderDataIndexed()` for list-based UI
- Updating specific items with `update<int>(index: index)`

```dart
static final counters = [0.inject(), 0.inject(), 0.inject()];

counters.update<int>((s) => s + 1, index: index);

counters.builderDataIndexed(
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
```

## Features Showcased

✅ Type-safe state updates with explicit generics  
✅ Reactive UI builders  
✅ Boolean toggle helpers  
✅ Multi-state management  
✅ Indexed builders for collections  
✅ Tag-based selective rebuild support (see package README)  
✅ Safe refresh & hot reload mixin (see package README)  

## Learn More

For full API details, tag-based rebuilds, safe refresh, nullable helpers and hot reload mixin usage, see the main [README](../README.md) and the [CHANGELOG](../CHANGELOG.md).
