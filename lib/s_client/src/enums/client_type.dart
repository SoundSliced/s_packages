/// Enum to specify which client backend to use.
enum ClientType {
  /// Use the `http` package (lightweight, simple)
  http,

  /// Use the `dio` package (feature-rich, interceptors, transformers)
  dio,
}
