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

    test('detects Cloudflare challenge pages as proxy-incompatible', () {
      const html = '''
        <html><head><title>Just a moment...</title></head>
        <body>
          <script>
            window._cf_chl_opt = {};
            history.replaceState(null, null, '/some-path?__cf_chl_rt_tk=token');
          </script>
        </body></html>
      ''';

      expect(
        SWebViewProxyHtmlUtils.isLikelyProxyIncompatibleDocument(html),
        isTrue,
      );
    });

    test('does not mark regular HTML as proxy-incompatible', () {
      const html =
          '<html><head><title>Example</title></head><body>Hello</body></html>';

      expect(
        SWebViewProxyHtmlUtils.isLikelyProxyIncompatibleDocument(html),
        isFalse,
      );
    });

    test('detects module/importmap pages requiring path-friendly proxy', () {
      const html = '''
        <html><head>
          <script type="importmap">{"imports":{"@app":"./app.js"}}</script>
          <script type="module" src="./main.js"></script>
        </head><body></body></html>
      ''';

      expect(SWebViewProxyHtmlUtils.requiresPathFriendlyProxy(html), isTrue);
      expect(
        SWebViewProxyHtmlUtils.isQueryStyleProxyBase(
          'https://api.codetabs.com/v1/proxy?quest=',
        ),
        isTrue,
      );
      expect(
        SWebViewProxyHtmlUtils.isQueryStyleProxyBase(
          'https://cors.bridged.cc/',
        ),
        isFalse,
      );
    });

    test('builds proxied URL for query and path styles', () {
      const target = 'https://www.windy.com/v/app.js';

      final queryStyle = SWebViewProxyHtmlUtils.buildProxiedUrl(
        'https://api.codetabs.com/v1/proxy?quest=',
        target,
      );
      final pathStyle = SWebViewProxyHtmlUtils.buildProxiedUrl(
        'https://cors.bridged.cc/',
        target,
      );

      expect(queryStyle, contains(Uri.encodeComponent(target)));
      expect(pathStyle, equals('https://cors.bridged.cc/$target'));
    });

    test('rewrites resources and importmap through selected proxy', () {
      const html = '''
        <html>
          <head>
            <link rel="stylesheet" href="/styles.css">
            <script type="importmap">{"imports":{"@windyCore":"./v/index.js"}}</script>
            <script type="module" src="./main.js"></script>
          </head>
          <body>
            <img src="/logo.png" srcset="/logo.png 1x, /logo@2x.png 2x">
          </body>
        </html>
      ''';

      final rewritten = SWebViewProxyHtmlUtils.rewriteHtmlResourceUrlsForProxy(
        html,
        originalUrl: 'https://www.windy.com/',
        proxyBase: 'https://cors.bridged.cc/',
      );

      expect(rewritten,
          contains('https://cors.bridged.cc/https://www.windy.com/styles.css'));
      expect(rewritten,
          contains('https://cors.bridged.cc/https://www.windy.com/main.js'));
      expect(rewritten,
          contains('https://cors.bridged.cc/https://www.windy.com/logo.png'));
      expect(
          rewritten,
          contains(
              'https://cors.bridged.cc/https://www.windy.com/logo@2x.png'));
      expect(rewritten,
          contains('https://cors.bridged.cc/https://www.windy.com/v/index.js'));
    });

    test('rewrites relative <base href> to absolute (Windy case: href="/")',
        () {
      const html =
          '<html><head><base href="/"><title>Windy</title></head><body></body></html>';

      final result = SWebViewProxyHtmlUtils.injectBaseTagIfMissing(
        html,
        'https://www.windy.com',
      );

      expect(result, contains('<base href="https://www.windy.com/"'));
      // Must not contain the raw relative href="/".
      expect(result, isNot(contains('href="/"')));
      // Must not introduce a second base tag.
      expect(RegExp(r'<base\b', caseSensitive: false).allMatches(result).length,
          equals(1));
    });

    test('leaves already-absolute <base href> unchanged', () {
      const html =
          '<html><head><base href="https://example.com/"><title>T</title></head><body></body></html>';

      final result = SWebViewProxyHtmlUtils.injectBaseTagIfMissing(
        html,
        'https://another.com',
      );

      expect(result, contains('https://example.com/'));
      expect(
          result, isNot(contains('https://another.com'))); // original must win
    });

    test('injects <base href> when tag is missing', () {
      const html = '<html><head><title>T</title></head><body></body></html>';

      final result = SWebViewProxyHtmlUtils.injectBaseTagIfMissing(
        html,
        'https://www.example.com/path/page',
      );

      expect(
          result, contains('<base href="https://www.example.com/path/page">'));
    });

    test('injects compatibility script only once', () {
      const html = '<html><head><title>T</title></head><body>ok</body></html>';

      final once = SWebViewProxyHtmlUtils.injectProxyCompatibilityScript(html);
      final twice = SWebViewProxyHtmlUtils.injectProxyCompatibilityScript(once);

      final marker = RegExp('data-swebview-proxy-compat');
      // We inject a <script> tag and a <style> tag, each carrying the marker.
      expect(marker.allMatches(once).length, equals(2));
      // Calling a second time must be a no-op (idempotent).
      expect(marker.allMatches(twice).length, equals(2));
    });

    test('compatibility payload includes IDB shim and unlegal-embed guard', () {
      const html = '<html><head><title>T</title></head><body>ok</body></html>';

      final patched = SWebViewProxyHtmlUtils.injectProxyCompatibilityScript(
        html,
      );

      expect(patched, contains('IDBFactory.prototype.open'));
      expect(patched, contains('createObjectStore'));
      expect(patched, contains('transaction:function'));
      expect(patched, contains('__swebviewCompatStats'));
      expect(patched, contains('unlegal-embed'));
      expect(patched, contains('setInterval(_hideUE,500)'));
    });
  });
}
