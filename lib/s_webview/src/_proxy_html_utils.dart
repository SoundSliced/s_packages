import 'dart:convert';

/// Utilities for normalizing HTML payloads returned by CORS proxies.
class SWebViewProxyHtmlUtils {
  static final RegExp _htmlSignal = RegExp(
    r'<\s*(!doctype|html|head|body|meta|title|script|style|div|span|p|a|img)\b',
    caseSensitive: false,
  );

  static final RegExp _headTag = RegExp(r'<head\b[^>]*>', caseSensitive: false);
  static final RegExp _baseTag = RegExp(r'<base\b', caseSensitive: false);

  static final List<RegExp> _proxyIncompatiblePageSignals = [
    RegExp(r'__cf_chl_rt_tk', caseSensitive: false),
    RegExp(r'_cf_chl_opt', caseSensitive: false),
    RegExp(r'cdn-cgi/challenge-platform', caseSensitive: false),
    RegExp(r'just a moment\.\.\.', caseSensitive: false),
    RegExp(r'history\.replaceState\(', caseSensitive: false),
  ];

  static final Map<String, String> _namedHtmlEntities = {
    'amp': '&',
    'lt': '<',
    'gt': '>',
    'quot': '"',
    'apos': "'",
    'nbsp': '\u00A0',
    '#39': "'",
  };

  /// Best-effort check indicating whether a string likely contains HTML markup.
  static bool looksLikeHtml(String value) {
    if (value.isEmpty) return false;
    return _htmlSignal.hasMatch(value);
  }

  /// Normalizes proxy response payloads into usable HTML:
  /// - unwraps known JSON envelopes (e.g. allorigins `{ contents: ... }`)
  /// - decodes HTML entities when payload appears escaped
  /// - removes wrapping quotes around full-document strings
  static String normalizeProxyHtml(
    String body, {
    Map<String, String>? headers,
  }) {
    if (body.trim().isEmpty) {
      return body;
    }

    var html = _extractHtmlFromPossibleJsonEnvelope(body, headers: headers);
    html = _stripWrappingQuotes(html.trim());

    if (_shouldDecodeEntities(html)) {
      // Decode up to twice for doubly escaped payloads such as &amp;lt;html...&amp;gt;
      var decoded = _decodeHtmlEntitiesOnce(html);
      if (_shouldDecodeEntities(decoded)) {
        decoded = _decodeHtmlEntitiesOnce(decoded);
      }
      if (looksLikeHtml(decoded)) {
        html = decoded;
      }
    }

    // Some proxies can return URL-encoded HTML payloads.
    if (!looksLikeHtml(html) && html.contains('%3C')) {
      try {
        final decodedUrlEncoded = Uri.decodeFull(html);
        if (looksLikeHtml(decodedUrlEncoded)) {
          html = decodedUrlEncoded;
        }
      } catch (_) {
        // Ignore malformed URI payloads.
      }
    }

    return html;
  }

  /// Injects a `<base href="...">` tag when none is present.
  static String injectBaseTagIfMissing(String html, String baseUrl) {
    if (html.isEmpty || _baseTag.hasMatch(html)) {
      return html;
    }

    final uri = Uri.tryParse(baseUrl);
    final parsed = uri ?? Uri.parse(baseUrl);
    final safeBaseUrl = parsed.hasFragment
        ? parsed.toString().split('#').first
        : parsed.toString();
    final baseTag = '<base href="$safeBaseUrl">';

    if (_headTag.hasMatch(html)) {
      return html.replaceFirstMapped(_headTag, (match) {
        return '${match.group(0)}$baseTag';
      });
    }

    return '$baseTag$html';
  }

  /// Detects HTML payloads that are known to break when rendered from a
  /// `data:` URL origin (for example Cloudflare challenge pages).
  ///
  /// Such pages generally require first-party origin semantics and should be
  /// opened directly in a browser tab/window instead of proxy-injected mode.
  static bool isLikelyProxyIncompatibleDocument(String html) {
    if (html.isEmpty) return false;
    return _proxyIncompatiblePageSignals
        .any((pattern) => pattern.hasMatch(html));
  }

  static String _extractHtmlFromPossibleJsonEnvelope(
    String rawBody, {
    Map<String, String>? headers,
  }) {
    final trimmed = rawBody.trim();
    final contentType = headers?['content-type']?.toLowerCase() ??
        headers?['Content-Type']?.toLowerCase() ??
        '';
    final isLikelyJson = contentType.contains('application/json') ||
        contentType.contains('text/json') ||
        trimmed.startsWith('{') ||
        trimmed.startsWith('[');

    if (!isLikelyJson) {
      return rawBody;
    }

    try {
      final decoded = json.decode(trimmed);
      final extracted = _extractHtmlCandidate(decoded);
      if (extracted != null && extracted.trim().isNotEmpty) {
        return extracted;
      }
    } catch (_) {
      // Not valid JSON envelope; keep original body.
    }

    return rawBody;
  }

  static String? _extractHtmlCandidate(dynamic payload) {
    if (payload is String) {
      return payload;
    }

    if (payload is Map) {
      const preferredKeys = [
        'contents',
        'content',
        'body',
        'html',
        'document',
        'response',
      ];

      for (final key in preferredKeys) {
        final value = payload[key];
        if (value is String && value.trim().isNotEmpty) {
          return value;
        }
      }

      final data = payload['data'];
      if (data is String && data.trim().isNotEmpty) {
        return data;
      }
      if (data is Map) {
        for (final key in preferredKeys) {
          final value = data[key];
          if (value is String && value.trim().isNotEmpty) {
            return value;
          }
        }
      }
    }

    return null;
  }

  static bool _shouldDecodeEntities(String value) {
    if (!value.contains('&')) return false;

    if (value.contains('&lt;html') ||
        value.contains('&lt;head') ||
        value.contains('&lt;body') ||
        value.contains('&#60;html') ||
        value.contains('&amp;lt;html')) {
      return true;
    }

    return !looksLikeHtml(value) &&
        (value.contains('&lt;') ||
            value.contains('&#60;') ||
            value.contains('&amp;lt;'));
  }

  static String _stripWrappingQuotes(String value) {
    if (value.length < 2) return value;
    final startsAndEndsWithDoubleQuote =
        value.startsWith('"') && value.endsWith('"');
    final startsAndEndsWithSingleQuote =
        value.startsWith("'") && value.endsWith("'");

    if (startsAndEndsWithDoubleQuote || startsAndEndsWithSingleQuote) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }

  static String _decodeHtmlEntitiesOnce(String input) {
    if (!input.contains('&')) {
      return input;
    }

    final numericDecoded = input.replaceAllMapped(
      RegExp(r'&#(x?[0-9A-Fa-f]+);'),
      (match) {
        final token = match.group(1);
        if (token == null) return match.group(0)!;

        int? codePoint;
        if (token.toLowerCase().startsWith('x')) {
          codePoint = int.tryParse(token.substring(1), radix: 16);
        } else {
          codePoint = int.tryParse(token, radix: 10);
        }
        if (codePoint == null) return match.group(0)!;
        return String.fromCharCode(codePoint);
      },
    );

    return numericDecoded.replaceAllMapped(
      RegExp(r'&([A-Za-z0-9#]+);'),
      (match) {
        final key = match.group(1);
        if (key == null) return match.group(0)!;
        return _namedHtmlEntities[key] ?? match.group(0)!;
      },
    );
  }
}
