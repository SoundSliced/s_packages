import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Downloads [bytes] in the browser under [fileName] and returns the name.
Future<String> saveScreenshot(List<int> bytes, String fileName) async {
  final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  final blob = web.Blob([data.toJS].toJS);
  final url = web.URL.createObjectURL(blob);

  try {
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = fileName
      ..style.display = 'none';

    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    return fileName;
  } finally {
    web.URL.revokeObjectURL(url);
  }
}
