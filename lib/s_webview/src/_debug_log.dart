import 'package:flutter/foundation.dart';

/// Shared debug logger for SWebView internals.
///
/// Logs are emitted only when [enabled] is true and app is in debug mode.
class SWebViewDebug {
  static bool enabled = false;

  static void log(Object? message) {
    if (!kDebugMode || !enabled || message == null) {
      return;
    }

    final text = message.toString();
    if (text.isEmpty || text.trim() == 'null') {
      return;
    }

    debugPrint(text);
  }
}
