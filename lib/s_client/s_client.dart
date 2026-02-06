/// s_client package - Modern HTTP Client
///
/// A powerful HTTP client package supporting both http and dio backends
/// with advanced features like interceptors, caching, retry, and more.
library;

// Core
export 'src/client.dart';
export 'src/client_config.dart';

// Re-export FileAccessMode from dio for use with downloadToFile
export 'package:dio/dio.dart' show FileAccessMode;

// Models
export 'src/models/client_response.dart';
export 'src/models/client_exception.dart';

// Interceptors
export 'src/interceptors/client_interceptor.dart';
export 'src/interceptors/logging_interceptor.dart';
export 'src/interceptors/auth_interceptor.dart';
export 'src/interceptors/cache_interceptor.dart';

// Enums
export 'src/enums/client_type.dart';
