# SignalsWatch

A unified, production-ready reactive framework for `signals_flutter` with auto-registering signal factories, lifecycle callbacks, debouncing, throttling, async helpers, and comprehensive debug tools.

[![pub package](https://img.shields.io/pub/v/signals_watch.svg)](https://pub.dev/packages/signals_watch)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

### ✅ Unified API
- **Single class**: All functionality in `SignalsWatch` - signals, reactive widgets, registry, observer
- **Static factories**: `SignalsWatch.signal<T>()`, `SignalsWatch.computed<T>()` with auto-registration
- **Async helpers**: `SignalsWatch.fromFuture<T>()`, `SignalsWatch.fromStream<T>()` for reactive async values
- **Registry management**: Track and dispose signals globally with `register()`, `disposeAll()`, `size`
- **Selective observer**: `initializeSignalsObserver()` for debug logging of labeled signals only

### 🎯 Reactive Widget
- **Multiple modes**: Single signal, multiple signals, custom read function, selector pattern
- **Lifecycle callbacks**: `onInit`, `onValueUpdated`, `onAfterBuild`, `onDispose` at both signal and widget levels
- **Callback override precedence**: Widget callbacks override signal callbacks
- **Optional previous value**: Callbacks can accept both current and previous values
- **Effect replacement**: `onValueUpdated` (with optional previous value) replaces the need for creating a manual `effect(() { ... })` in `signals_flutter` when you just want to react to changes of the watched signals.
- **StatelessWidget friendly**: No need to write StatefulWidget boilerplate

### ⏱️ Timing Control
- **Debouncing**: Wait for changes to settle (e.g., search input)
- **Throttling**: Limit update frequency (e.g., scroll events)

### 🛡️ Error Handling
- **`onError`**: Catch and handle read errors
- **`errorBuilder`**: Custom error UI (defaults to red text)
- **`loadingBuilder`**: Custom loading UI (defaults to CircularProgressIndicator)

### 🔍 Debug & Development
- **Selective observer**: Log only labeled signals with `initializeSignalsObserver()`
- **Auto-logging**: Built-in `debugPrint` for lifecycle events
- **Debug labels**: Name signals for easier tracking

### 🎨 Advanced Patterns
- **Selector pattern**: Only rebuild when selected part of value changes
- **Transform with `.transform()`**: Transform signal values with error handling
- **Batch updates**: Efficiently combine multiple signals
- **Builder caching**: Prevents redundant rebuilds
- **Modular architecture**: Clean separation of concerns with library parts

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  signals_watch: ^1.0.0
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:signals_watch/signals_watch.dart';

// Create auto-registered signals
final counter = SignalsWatch.signal(0);
final doubled = SignalsWatch.computed(() => counter.value * 2);

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Option 1: Fluent syntax
    return counter.observe(
      (value) => Text('$value'),
      onValueUpdated: (value) => debugPrint('Counter: $value'),
    );
    
    // Option 2: Traditional syntax
    return SignalsWatch<int>.fromSignal(
      counter,
      onValueUpdated: (value) => debugPrint('Counter: $value'),
      builder: (value) => Text('$value'),
    );
  }
}
```

## Examples

The `example/` directory contains a comprehensive set of examples demonstrating the features of `signals_watch`. These include:
- Basic counter example
- Debounced search
- Conditional updates
- Selector pattern
- Combining multiple signals
- Transforming signal values
- Async handling with `fromFuture` and `fromStream`
- Debugging with labeled signals

Refer to the `example/lib/main.dart` file for detailed implementations.

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions are welcome! Please open an issue or PR on [GitHub](https://github.com/soundsliced/signals_watch).

## Publishing

For first publish run:

```bash
dart pub get
dart pub publish --dry-run
dart pub publish
```

Update the version in `pubspec.yaml` and add a new section in `CHANGELOG.md` for subsequent releases.
