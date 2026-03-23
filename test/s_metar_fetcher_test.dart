import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_client/s_client.dart';
import 'package:s_packages/s_metar/src/fetch_metar_taf.dart';

class _FakeMetarClient extends SClient {
  _FakeMetarClient({required this.responseBody}) : super();

  final String responseBody;
  final List<String> requestedUrls = [];

  @override
  Future<ClientResult> get({
    required String url,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Duration? timeout,
    ClientType? clientType,
    String? cancelKey,
    bool Function(int?)? validateStatus,
    OnSuccess? onSuccess,
    OnError? onError,
    OnHttpError? onHttpError,
    Map<int, OnStatus>? onStatus,
    Set<int>? successCodes,
    Set<int>? errorCodes,
  }) async {
    requestedUrls.add(url);

    return (
      ClientResponse(
        statusCode: 200,
        body: responseBody,
        bodyBytes: utf8.encode(responseBody),
        headers: const {},
        requestUrl: url,
        method: 'GET',
      ),
      null,
    );
  }
}

void main() {
  group('MetarTafFetcher.parseResponseBody', () {
    test('extracts raw METAR and TAF with custom field names and extractor',
        () {
      final body = jsonEncode({
        'payload': [
          {
            'metar_text': 'EGLL 222050Z 25009KT 9999 FEW025 08/03 Q1018 NOSIG',
            'taf_text': 'TAF EGLL 222045Z 2221/2324 24008KT 9999 FEW030',
          },
        ],
      });

      final result = MetarTafFetcher.parseResponseBody(
        body,
        fetchOptions: MetarTafFetchOptions(
          rawMetarFieldName: 'metar_text',
          rawTafFieldName: 'taf_text',
          itemsExtractor: (decoded) =>
              (decoded as Map<String, dynamic>)['payload'] as List<dynamic>,
        ),
      );

      expect(result.error, isNull);
      expect(
        result.rawMetar,
        'EGLL 222050Z 25009KT 9999 FEW025 08/03 Q1018 NOSIG',
      );
      expect(
        result.rawTaf,
        'TAF EGLL 222045Z 2221/2324 24008KT 9999 FEW030',
      );
      expect(result.rawJson, isA<Map<String, dynamic>>());
    });

    test('supports nested data lists with the default extractor', () {
      final body = jsonEncode({
        'data': [
          {
            'rawOb': 'EGLL 222050Z 25009KT 9999 FEW025 08/03 Q1018 NOSIG',
            'rawTaf': 'TAF EGLL 222045Z 2221/2324 24008KT 9999 FEW030',
          },
        ],
      });

      final result = MetarTafFetcher.parseResponseBody(body);

      expect(result.error, isNull);
      expect(
        result.rawMetar,
        'EGLL 222050Z 25009KT 9999 FEW025 08/03 Q1018 NOSIG',
      );
      expect(
        result.rawTaf,
        'TAF EGLL 222045Z 2221/2324 24008KT 9999 FEW030',
      );
      expect(result.rawJson, isA<Map<String, dynamic>>());
    });

    test('does not prepend proxy URLs when useProxyUrls is false', () async {
      final body = jsonEncode({
        'data': [
          {
            'rawOb': 'EGLL 222050Z 25009KT 9999 FEW025 08/03 Q1018 NOSIG',
            'rawTaf': 'TAF EGLL 222045Z 2221/2324 24008KT 9999 FEW030',
          },
        ],
      });
      final fakeClient = _FakeMetarClient(responseBody: body);
      final proxyUrls = ['https://proxy.example/?'];

      final result = await MetarTafFetcher.fetch(
        icao: 'EGLL',
        dateTime: DateTime.utc(2024, 1, 1, 12),
        client: fakeClient,
        customProxyUrls: proxyUrls,
        fetchOptions: const MetarTafFetchOptions(
          baseUrl: 'https://example.com/api/metar',
          useProxyUrls: false,
        ),
      );

      expect(result.error, isNull);
      expect(fakeClient.requestedUrls, hasLength(1));
      expect(
        fakeClient.requestedUrls.single,
        startsWith('https://example.com/api/metar?ids=EGLL'),
      );
      expect(fakeClient.requestedUrls.single, isNot(contains(proxyUrls.first)));
    });
  });
}
