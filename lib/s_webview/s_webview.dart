/// Public entrypoint for the `s_webview` subpackage.
///
/// Export this library to use the cross-platform [SWebView] widget and the
/// platform helpers used by the package.
library;

export 'src/s_webview.dart';
export 'src/_platforms.dart';

// pointer_interceptor is used internally by SWebView.tapTarget but should not
// be re-exported to consumers. Keeping it internal reduces API surface.
