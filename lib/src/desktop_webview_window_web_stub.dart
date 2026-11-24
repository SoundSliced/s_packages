/// Web stand-in for `package:desktop_webview_window`: that package is
/// desktop-only and imports `dart:isolate`, which web builds (dart2js and
/// dart2wasm) cannot include, so `s_packages_extra1.dart` re-exports it only
/// where `dart:io` exists.
library;
