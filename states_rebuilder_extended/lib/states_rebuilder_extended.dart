// states_rebuilder_extended
//
// A collection of ergonomic extensions and helpers built on top of
// the `states_rebuilder` package's `Injected` API.
//
// Highlights:
// * Safer `update<T?>` and `update<T>` methods with explicit generic enforcement.
// * Boolean `toggle()` helpers for nullable and non-nullable `Injected<bool>`.
// * Multi-injected builders: listen to many injected instances simultaneously.
// * Tag-based selective rebuilds (notify only widgets matching a tag).
// * Hot-reload mixin to rebind stale references on Flutter Web.
// * Safe refresh to ignore disposed exceptions.
// * `InjectExtension` & `MyNull` helpers for concise creation of injected controllers.
//
// Import this file and enjoy the sugar:
// ```dart
// import 'package:states_rebuilder_extended/states_rebuilder_extended.dart';
// ```
// Barrel export for package API
export 'package:states_rebuilder/states_rebuilder.dart';
export 'src/states_rebuilder_extended.dart';
