/// @nodoc
/// Compatibility shim for projects migrating from `package:universal_html/...`.
///
/// This entrypoint intentionally re-exports the forked implementation in
/// `s_universal_html` and does not rely on the upstream package.
library;

export 's_universal_html/html.dart';
