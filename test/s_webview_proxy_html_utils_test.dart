import 'package:flutter_test/flutter_test.dart';
import 'package:s_packages/s_webview/src/_proxy_html_utils.dart';

void main() {
  group('SWebViewProxyHtmlUtils', () {
    test('unwraps allorigins-style JSON envelope and decodes escaped HTML', () {
      const payload =
          '{"contents":"&lt;html&gt;&lt;head&gt;&lt;title&gt;Proxy&lt;/title&gt;&lt;/head&gt;&lt;body&gt;ok&lt;/body&gt;&lt;/html&gt;","status":{"url":"https://example.com"}}';

      final normalized = SWebViewProxyHtmlUtils.normalizeProxyHtml(
        payload,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );

      expect(SWebViewProxyHtmlUtils.looksLikeHtml(normalized), isTrue);
      expect(normalized, contains('<html>'));
      expect(normalized, contains('<body>ok</body>'));
    });

    test('decodes doubly escaped entities when needed', () {
      const payload =
          '&amp;lt;html&amp;gt;&amp;lt;body&amp;gt;hello&amp;lt;/body&amp;gt;&amp;lt;/html&amp;gt;';

      final normalized = SWebViewProxyHtmlUtils.normalizeProxyHtml(payload);

      expect(normalized, contains('<html>'));
      expect(normalized, contains('<body>hello</body>'));
    });

    test('injects base into head if missing', () {
      const html = '<HTML><HEAD><title>T</title></HEAD><BODY>ok</BODY></HTML>';

      final result = SWebViewProxyHtmlUtils.injectBaseTagIfMissing(
        html,
        'https://example.com/path/page?x=1#frag',
      );

      expect(RegExp(r'<base\b', caseSensitive: false).hasMatch(result), isTrue);
      expect(
          result, contains('<base href="https://example.com/path/page?x=1">'));
    });

    test('does not inject duplicate base tag', () {
      const html =
          '<html><head><base href="https://example.com/"><title>T</title></head><body></body></html>';

      final result = SWebViewProxyHtmlUtils.injectBaseTagIfMissing(
        html,
        'https://another.example.com',
      );

      expect(RegExp(r'<base\b', caseSensitive: false).allMatches(result).length,
          equals(1));
      expect(result, contains('https://example.com/'));
    });
  });
}
