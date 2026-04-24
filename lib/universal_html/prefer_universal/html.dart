/// Compatibility shim for projects migrating from `package:universal_html/...`.
///
/// In this fork, `prefer_sdk` and `prefer_universal` both resolve to the
/// same wasm-safe implementation.
library;

export '../../s_universal_html/html.dart';
