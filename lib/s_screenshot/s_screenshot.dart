/// s_screenshot package
///
/// This library exports all public APIs for the s_screenshot package.
library;

export 'src/save_screenshot.dart';
export 'src/s_screenshot.dart';
export 'src/file_stub.dart' if (dart.library.io) 'dart:io' show File;
