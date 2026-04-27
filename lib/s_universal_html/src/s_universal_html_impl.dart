// Conditional export: web implementation for JS/WASM platforms,
// stub implementation for native (dart:io) platforms.
export 's_universal_html_impl_web.dart'
    if (dart.library.io) 's_universal_html_impl_others.dart';
