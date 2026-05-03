/// Public entrypoint for the `states_rebuilder_extended` subpackage.
///
/// A collection of ergonomic extensions and helpers built on top of
/// `states_rebuilder`'s `Injected` API.
///
/// Highlights:
/// * Safer `update<T?>` and `update<T>` methods with explicit generic usage.
/// * Boolean `toggle()` helpers for nullable and non-nullable `Injected<bool>`.
/// * Multi-injected builders to listen to several injected instances.
/// * Tag-based selective rebuilds (notify only widgets matching a tag).
/// * Hot-reload mixin to rebind stale references on Flutter Web.
/// * Safe refresh helpers to ignore disposed exceptions.
/// * `InjectExtension` and `MyNull` helpers for concise injected controllers.
library;

export 'package:states_rebuilder/states_rebuilder.dart';
export 'src/states_rebuilder_extended.dart';
