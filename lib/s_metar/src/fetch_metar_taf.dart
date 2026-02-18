import 'dart:convert';

import 'package:s_packages/s_client/s_client.dart';
import 'package:s_packages/s_metar/src/reports/reports.dart';

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

  /// The raw JSON response data.
  final List<dynamic>? rawJson;

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

    // Use custom proxies if provided, otherwise use static proxyUrls
    final proxiesToUse = customProxyUrls ?? proxyUrls;

    // Build the complete target URL with query parameters
    final targetUrl = Uri.parse(_aviationBaseUrl).replace(queryParameters: {
      'ids': normalizedIcao,
      'date': formattedDate,
      'format': 'json',
      'taf': 'true',
    }).toString();

    // Build list of URLs to try: proxies first, then direct
    final urlsToTry = [
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
      return _parseResponse(response);
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

  /// Parses the API JSON response into a [MetarTafResult].
  static MetarTafResult _parseResponse(ClientResponse response) {
    try {
      final body = response.body;
      final decoded = jsonDecode(body);

      if (decoded is! List || decoded.isEmpty) {
        return const MetarTafResult(
          error: 'No METAR/TAF data found for this station and time.',
        );
      }

      String? rawMetar;
      String? rawTaf;
      Metar? metar;
      Taf? taf;

      for (final entry in decoded) {
        if (entry is Map<String, dynamic>) {
          // Extract raw METAR string
          if (entry.containsKey('rawOb') && entry['rawOb'] != null) {
            rawMetar = entry['rawOb'] as String;
            try {
              metar = Metar(rawMetar);
            } catch (_) {
              // Keep rawMetar even if parsing fails
            }
          }

          // Extract raw TAF string
          if (entry.containsKey('rawTaf') && entry['rawTaf'] != null) {
            rawTaf = entry['rawTaf'] as String;
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
}
