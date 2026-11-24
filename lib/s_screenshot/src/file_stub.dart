/// Stand-in for `dart:io`'s [File] where there is no file system (the web).
///
/// [SScreenshot] only names `File` in signatures of native-only features
/// (saving to disk, a custom path provider); on the web those paths return a
/// file name or bytes instead, so nothing ever creates one of these. Importing
/// it instead of `dart:io` keeps `dart:io` out of web builds, which dart2wasm
/// and pub.dev's Wasm check require.
abstract class File {
  /// The path of the file.
  String get path;
}
