// ignore: avoid_web_libraries_in_flutter

import 'package:s_packages/s_universal_html/src/html.dart' as html;

Future<String> saveScreenshot(List<int> bytes, String fileName) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  try {
    final anchor = html.AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    return fileName;
  } finally {
    html.Url.revokeObjectUrl(url);
  }
}
