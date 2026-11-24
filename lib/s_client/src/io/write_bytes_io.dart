import 'dart:io';

/// Writes [bytes] to [path] and returns the path.
Future<String> writeBytesToFile(String path, List<int> bytes) async {
  final file = File(path);
  await file.writeAsBytes(bytes);
  return file.path;
}
