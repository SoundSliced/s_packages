import 'dart:convert';

import 'package:s_packages/s_client/s_client.dart';
import 'package:s_packages/s_metar/src/reports/reports.dart';

/// Extracts the iterable items that contain METAR/TAF payloads from decoded JSON.
typedef MetarTafJsonItemsExtractor = Iterable<dynamic> Function(
  dynamic decodedJson,
);

/// Configuration for a METAR/TAF fetch request.
///
/// Use this to point the fetcher at a different endpoint, change the expected
/// HTTP success code, or adapt parsing to a different JSON shape.
class MetarTafFetchOptions {
  /// The base URL used to build the request.
  ///
  /// If omitted, the Aviation Weather API default is used.
  final String? baseUrl;

  /// A custom builder for the request URI.
  ///
  /// When provided, this takes precedence over [baseUrl] and the default
  /// Aviation Weather URI construction.
  final Uri Function(String icao, DateTime dateTime)? requestUriBuilder;

  /// The HTTP status code that should be treated as success.
  ///
  /// If omitted, any 2xx response is accepted.
  final int? successStatusCode;

  /// The JSON field name containing the raw METAR string.
  final String rawMetarFieldName;

  /// The JSON field name containing the raw TAF string.
  final String rawTafFieldName;

  /// Extracts the JSON items that should be scanned for METAR/TAF payloads.
  ///
  /// The default assumes the decoded response is a JSON list.
  final MetarTafJsonItemsExtractor? itemsExtractor;

  /// Whether proxy URLs should be prepended before the direct request URL.
  ///
  /// When false, the fetcher skips both the built-in proxy URLs and any custom
  /// proxy URLs passed to [MetarTafFetcher.fetch].
  final bool useProxyUrls;

  const MetarTafFetchOptions({
    this.baseUrl,
    this.requestUriBuilder,
    this.successStatusCode,
    this.rawMetarFieldName = 'rawOb',
    this.rawTafFieldName = 'rawTaf',
    this.itemsExtractor,
    this.useProxyUrls = true,
  });
}

/// Result of a METAR/TAF fetch operation.
///
/// Contains the parsed [Metar] and [Taf] objects if available,
/// along with the raw JSON data from the API.
class MetarTafResult {
  /// The parsed METAR report, if available.
  final Metar? metar;

  /// The parsed TAF report, if available.
  final Taf? taf;

  /// The raw METAR string from the API.
  final String? rawMetar;

  /// The raw TAF string from the API.
  final String? rawTaf;

  /// The decoded JSON response data.
  final dynamic rawJson;

  /// Any error message if the fetch failed.
  final String? error;

  const MetarTafResult({
    this.metar,
    this.taf,
    this.rawMetar,
    this.rawTaf,
    this.rawJson,
    this.error,
  });

  /// Whether the fetch was successful (at least one of metar or taf is present).
  bool get isSuccess => metar != null || taf != null;

  @override
  String toString() =>
      'MetarTafResult(metar: ${rawMetar != null}, taf: ${rawTaf != null}, error: $error)';
}

/// Fetches METAR and TAF data from the Aviation Weather API.
///
/// Uses the aviationweather.gov public API to retrieve weather reports
/// for a given ICAO station code and date/time.
class MetarTafFetcher {
  static const _aviationBaseUrl = 'https://aviationweather.gov/api/data/metar';

  /// Default proxy URLs to try in order (for CORS bypass on web).
  /// Set to empty list to call the API directly (works on mobile/desktop).
  static List<String> proxyUrls = [
    // Add your Cloudflare Worker URL here
    'https://fetch-metar-taf.soundsliced-dev-s-metar.workers.dev/?',
    // extra cloudflare worker for redundancy
    'https://fetch-metar-taf-extra.soundsliced-dev-s-metar.workers.dev/?',
  ];

  /// ICAO station code regex: starts with an uppercase letter,
  /// followed by 3 uppercase alphanumeric characters.
  static final _icaoRegExp = RegExp(r'^[A-Z][A-Z0-9]{3}$');

  /// Validates whether the given string is a valid ICAO code.
  ///
  /// A valid ICAO code is exactly 4 characters: the first must be
  /// an uppercase letter, the remaining three must be uppercase
  /// letters or digits.
  static bool isValidIcao(String icao) => _icaoRegExp.hasMatch(icao);

  /// Fetches METAR and TAF data for the given [icao] station code
  /// at the specified [dateTime].
  ///
  /// The [icao] is automatically uppercased before validation.
  /// The [dateTime] must not be in the future (returns error if it is).
  /// Returns a [MetarTafResult] containing the parsed reports or an error.
  ///
  /// If [customProxyUrls] is provided, uses those proxies instead of the
  /// static [proxyUrls]. Tries each proxy in order until one succeeds.
  /// Automatically falls back to the next proxy if rate limits (429) are hit.
  ///
  /// Optionally accepts an [SClient] instance; if not provided,
  /// the singleton [SClient.instance] is used.
  static Future<MetarTafResult> fetch({
    required String icao,
    required DateTime dateTime,
    SClient? client,
    List<String>? customProxyUrls,
    MetarTafFetchOptions fetchOptions = const MetarTafFetchOptions(),
  }) async {
    final normalizedIcao = icao.toUpperCase();

    if (!isValidIcao(normalizedIcao)) {
      return MetarTafResult(
        error: 'Invalid ICAO code: "$icao". '
            'Must be 4 characters (e.g. EGLL, KJFK).',
      );
    }

    // Check if dateTime is in the future
    final now = DateTime.now().toUtc();
    if (dateTime.isAfter(now)) {
      return MetarTafResult(
        error: 'Cannot fetch weather data for future time. '
            'Requested: ${dateTime.toUtc()}, Current: $now',
      );
    }

    final formattedDate = _formatDate(dateTime);

    // Use custom proxies if provided, otherwise use static proxyUrls.
    final proxiesToUse = customProxyUrls ?? proxyUrls;

    // Build the complete target URL with query parameters unless a custom
    // request URI builder is provided.
    final targetUri = fetchOptions.requestUriBuilder?.call(
          normalizedIcao,
          dateTime,
        ) ??
        Uri.parse(fetchOptions.baseUrl ?? _aviationBaseUrl).replace(
          queryParameters: {
            'ids': normalizedIcao,
            'date': formattedDate,
            'format': 'json',
            'taf': 'true',
          },
        );
    final targetUrl = targetUri.toString();

    // Build list of URLs to try: proxies first, then direct
    final urlsToTry = [
      if (fetchOptions.useProxyUrls)
        ...proxiesToUse.map((proxy) => proxy + targetUrl),
      targetUrl, // Direct call as final fallback
    ];

    final errors = <String>[];

    // Try each URL until one succeeds
    for (var i = 0; i < urlsToTry.length; i++) {
      final url = urlsToTry[i];
      final isLastAttempt = i == urlsToTry.length - 1;

      final (response, error) = await (client ?? SClient.instance).get(
        url: url,
        clientType: ClientType.dio,
        headers: {
          'accept': '*/*',
        },
      );

      // Check for rate limit or service unavailable
      if (response?.statusCode == 429 || response?.statusCode == 503) {
        errors.add('URL $i rate limited (${response?.statusCode})');
        continue; // Try next proxy
      }

      // Check for the expected success code when a custom code is provided.
      if (response != null &&
          fetchOptions.successStatusCode != null &&
          response.statusCode != fetchOptions.successStatusCode) {
        errors.add(
          'URL $i unexpected status code (${response.statusCode}); '
          'expected ${fetchOptions.successStatusCode}',
        );
        if (!isLastAttempt) continue;
        return MetarTafResult(
          error: 'All attempts failed:\n${errors.join('\n')}',
        );
      }

      // Check for other errors
      if (error != null) {
        errors.add('URL $i error: ${error.message}');
        if (!isLastAttempt) continue; // Try next proxy
        return MetarTafResult(
          error: 'All attempts failed:\n${errors.join('\n')}',
        );
      }

      // Check for bad response
      if (response == null || !response.isSuccess) {
        errors
            .add('URL $i HTTP error: ${response?.statusCode ?? "no response"}');
        if (!isLastAttempt) continue; // Try next proxy
        return MetarTafResult(
          error: 'All attempts failed:\n${errors.join('\n')}',
        );
      }

      // Success! Parse and return
      return _parseResponse(response, fetchOptions: fetchOptions);
    }

    return MetarTafResult(
      error: 'All attempts failed:\n${errors.join('\n')}',
    );
  }

  /// Formats a [DateTime] to the API-expected format: `yyyyMMdd_HHmm`.
  static String _formatDate(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$y$m${d}_$h$min';
  }

  /// Parses the API JSON response body into a [MetarTafResult].
  static MetarTafResult parseResponseBody(
    String body, {
    MetarTafFetchOptions fetchOptions = const MetarTafFetchOptions(),
  }) {
    try {
      final decoded = jsonDecode(body);

      final items = _extractItems(decoded, fetchOptions.itemsExtractor);
      if (items.isEmpty) {
        return const MetarTafResult(
          error: 'No METAR/TAF data found for this station and time.',
        );
      }

      String? rawMetar;
      String? rawTaf;
      Metar? metar;
      Taf? taf;

      for (final entry in items) {
        if (entry is Map<String, dynamic>) {
          // Extract raw METAR string
          if (entry.containsKey(fetchOptions.rawMetarFieldName) &&
              entry[fetchOptions.rawMetarFieldName] != null) {
            rawMetar = entry[fetchOptions.rawMetarFieldName] as String;
            try {
              metar = Metar(rawMetar);
            } catch (_) {
              // Keep rawMetar even if parsing fails
            }
          }

          // Extract raw TAF string
          if (entry.containsKey(fetchOptions.rawTafFieldName) &&
              entry[fetchOptions.rawTafFieldName] != null) {
            rawTaf = entry[fetchOptions.rawTafFieldName] as String;
            try {
              taf = Taf(rawTaf);
            } catch (_) {
              // Keep rawTaf even if parsing fails
            }
          }
        }
      }

      return MetarTafResult(
        metar: metar,
        taf: taf,
        rawMetar: rawMetar,
        rawTaf: rawTaf,
        rawJson: decoded,
      );
    } catch (e) {
      return MetarTafResult(error: 'Failed to parse response: $e');
    }
  }

  /// Parses the API response and applies the configured parsing options.
  static MetarTafResult _parseResponse(
    ClientResponse response, {
    required MetarTafFetchOptions fetchOptions,
  }) {
    return parseResponseBody(
      response.body,
      fetchOptions: fetchOptions,
    );
  }

  static Iterable<dynamic> _extractItems(
    dynamic decoded,
    MetarTafJsonItemsExtractor? itemsExtractor,
  ) {
    if (itemsExtractor != null) {
      return itemsExtractor(decoded);
    }

    if (decoded is List<dynamic>) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final directList = decoded['data'];
      if (directList is List<dynamic>) {
        return directList;
      }

      final nestedList = decoded['results'];
      if (nestedList is List<dynamic>) {
        return nestedList;
      }
    }

    return const <dynamic>[];
  }
}
