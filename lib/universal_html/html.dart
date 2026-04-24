/// Compatibility shim for projects migrating from `package:universal_html/...`.
///
/// This library re-exports the in-repo fork under `s_universal_html` so
/// consumers can depend only on `s_packages` and avoid the upstream
/// `universal_html` package.
library;

export '../s_universal_html/html.dart';
