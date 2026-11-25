/// A production-ready reactive widget for signals_flutter with lifecycle callbacks,
/// debouncing, throttling, error handling, and more.
///
/// ## Features
/// - 🔄 Multiple constructor patterns (signal, signals, select, custom)
/// - 🎯 Lifecycle callbacks (onInit, onValueUpdated, onAfterBuild, onDispose)
/// - ⏱️ Debouncing and throttling
/// - 🎛️ Conditional updates (shouldRebuild, shouldNotify)
/// - 🐛 Error handling with custom builders
/// - ⌛ Loading state support
/// - 🔍 Debug tools (including SelectiveSignalsObserver)
/// - 🎭 StatelessWidget-friendly
///
/// ## Quick Start
/// ```dart
/// // Create signals (auto-registered)
/// final counter = SignalsWatch.signal(0);
/// final searchQuery = SignalsWatch.signal('');
///
/// // Basic usage
/// SignalsWatch<int>.fromSignal(
///   counter,
///   onValueUpdated: (value) {
///     print('Counter: $value');
///   },
///   builder: (value) => Text('$value'),
/// );
///
/// // With debouncing
/// SignalsWatch<String>.fromSignal(
///   searchQuery,
///   debounce: Duration(milliseconds: 300),
///   onValueUpdated: (value) => performSearch(value),
///   builder: (value) => SearchResults(value),
/// );
///
/// // Debug signals with selective observer
/// void main() {
///   SignalsWatch.initializeSignalsObserver();
///   runApp(MyApp());
/// }
/// ```
library;

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:signals/signals.dart' as s;

import 'package:signals/signals_flutter.dart';

// Internal parts for readability and maintainability.
part 'src/signals_watch_metadata.dart';
part 'src/signals_watch_registry.dart';
part 'src/signals_watch_observer.dart';
part 'src/signals_watch_async.dart';
part 'src/signals_watch.dart';
