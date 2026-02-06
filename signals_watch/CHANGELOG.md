## 1.0.0

### Stable Release
- First stable release of `signals_watch`.
- Includes all features from previous versions, such as:
  - Signal-level lifecycle callbacks (`onInit`, `onValueUpdated`, `onDispose`).
  - Fluent APIs for observing signals (`.observe()`, `.selectObserve()`).
  - Timing controls (`debounce`, `throttle`).
  - Error handling with `onError` and `errorBuilder`.
  - Async helpers (`fromFuture`, `fromStream`).
  - Debugging tools (`debugLabel`, `SelectiveSignalsObserver`).
- Comprehensive examples and test coverage.
- Documentation updated to reflect all features.

## [0.4.0] - 2025-11-18

### Added
- `.transform()` extension on `ReadonlySignal<T>` for transforming signal values with error handling
  - Perfect for transformations that might throw exceptions (validation, parsing, computed values)
  - Includes all SignalsWatch features: error handling, debouncing, lifecycle callbacks, etc.
  - Example: `mySignal.transform((v) => v * 2, builder: (result) => Text('$result'), errorBuilder: ...)`

### Changed
- Enhanced error handling documentation with clearer examples
- Added import comment for `kDebugMode` usage

## [0.3.1] - 2025-11-17

### Fixed/Docs
- Update README to document v0.3.0 signal-level lifecycle callbacks, widget override precedence, and reset API
- Example app: add trailing commas and minor formatting fixes to satisfy analyzer lints (no behavior changes)
- No functional code changes in library APIs

## [0.3.0] - 2025-11-17

### Added
- Signal-level lifecycle callbacks for all signal types (signal, computed, fromFuture, fromStream)
- Widget-level callbacks now override signal-level callbacks with proper precedence
- `.reset()` method on signals to restore initial value and trigger callbacks
- Async helpers now forward lifecycle callbacks consistently
- Internal metadata registry for initial values and callbacks

### Changed
- Documentation updated to reflect lifecycle callbacks, overrides, and reset API
- Example app updated to use the observer initializer and fluent APIs


## [0.2.1] - 2025-11-17

### Maintenance
- Republish after sensitive file cleanup and doc corrections. No code changes.
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-11-17

### Added
- **Fluent API extensions** for more ergonomic syntax:
  - `.observe()` extension on `ReadonlySignal<T>` - watch any signal (regular, computed, fromFuture, fromStream)
  - `.selectObserve()` extension on `ReadonlySignal<T>` - selector pattern with efficient updates
  - `.observe()` extension on `List<ReadonlySignal<dynamic>>` - combine multiple signals
- Comprehensive test coverage for all new extension methods (28 tests total)
- Example app updated to demonstrate fluent syntax

### Design Decisions
- Named `.observe()` to avoid conflict with `signals_flutter`'s existing `.watch()` extension
- Named `.selectObserve()` to avoid conflict with `signals`' existing `.select()` extension
- All original constructors remain available for backward compatibility
- Fluent API is purely additive syntax sugar

### Examples
```dart
// Single signal - fluent syntax
counter.observe((value) => Text('$value'))

// Selector pattern - only rebuilds when age changes
user.selectObserve(
  (u) => (u as User).age,
  (age) => Text('Age: $age'),
)

// Multiple signals - combines values
[firstName, lastName].observe(
  combine: (values) => '${values[0]} ${values[1]}',
  builder: (fullName) => Text(fullName),
)
```

## [0.1.0] - 2025-11-16

### Added
- Initial preview release with unified `SignalsWatch` class
- **Unified API**: All functionality consolidated into a single `SignalsWatch` class
- **Static factories**: `SignalsWatch.signal<T>()`, `SignalsWatch.computed<T>()` with auto-registration
- **Async helpers**: `SignalsWatch.fromFuture<T>()`, `SignalsWatch.fromStream<T>()` for reactive async values
- **Registry management**: `register()`, `unregister()`, `size`, `disposeAll()` for signal lifecycle
- **Selective observer**: `initializeSelectiveObserver()` for debug logging of labeled signals only
- 4 constructor patterns:
  - Default constructor with custom `read` function
  - `.fromSignal()` for single signals
  - `.fromSignals()` for batch updates from multiple signals
  - `.select()` for selector pattern
- Lifecycle callbacks:
  - `onInit` - Called once on initialization
  - `onValueUpdated` - Called when value changes
  - `onAfterBuild` - Called post-frame after every build
  - `onDispose` - Called when widget is disposed
- Flexible callback signatures supporting both `(T)` and `(T, T?)` patterns
- Conditional updates:
  - `shouldRebuild` - Control when widget rebuilds
  - `shouldNotify` - Control when callbacks fire
  - Custom `equals` - Custom equality checking
- Timing control:
  - `debounce` - Wait after last change before updating
  - `throttle` - Minimum time between updates
- Error handling:
  - `onError` - Error callback
  - `errorBuilder` - Custom error UI (defaults to red text)
  - `loadingBuilder` - Custom loading UI (defaults to CircularProgressIndicator)
- Debug tools:
  - `debugLabel` - Label for logging
  - `debugPrint` - Auto-log all lifecycle events
  - `SelectiveSignalsObserver` - Track only labeled signals globally
- Production-ready safety:
  - Timer cancellation on dispose
  - Mounted checks before callbacks
  - Assertions preventing misuse (debounce+throttle, empty signals list)
  - Try-catch in dispose to prevent exceptions
- Modular architecture:
  - Library parts for readability (registry, observer, async, core widget)
  - Single public API surface via `SignalsWatch` class
  - Private implementation details hidden
- Comprehensive documentation and examples
- StatelessWidget-friendly API

### Design Decisions
- **Unified class approach**: All features consolidated into `SignalsWatch` for simplicity
- **Static factories**: `signal()` and `computed()` replace standalone functions, auto-register for cleanup
- **Modular parts**: Code split into logical parts while maintaining single public API
- **Auto-registration**: All created signals tracked automatically with cleanup on dispose
- Used `Function.apply()` to support flexible callback signatures
- Timers check `mounted` state before executing callbacks
- Dispose method uses try-catch to prevent dispose exceptions
- Assertions added to prevent common mistakes at compile time

## [Unreleased]

### Planned
- Animation support with `AnimationController` integration
- More comprehensive test coverage
- Performance benchmarks
- Additional async utilities (retries, caching, etc.)
