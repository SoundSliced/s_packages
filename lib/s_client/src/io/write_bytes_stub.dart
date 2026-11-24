/// Web: there is no file system to write a download to.
Future<String> writeBytesToFile(String path, List<int> bytes) async {
  throw UnsupportedError(
    'downloadToFile with http backend is not supported on web. Use ClientType.dio instead.',
  );
}
