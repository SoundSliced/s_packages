import 'dart:convert';

/// Utilities for normalizing HTML payloads returned by CORS proxies.
class SWebViewProxyHtmlUtils {
  static final RegExp _htmlSignal = RegExp(
    r'<\s*(!doctype|html|head|body|meta|title|script|style|div|span|p|a|img)\b',
    caseSensitive: false,
  );

  static final RegExp _headTag = RegExp(r'<head\b[^>]*>', caseSensitive: false);
  static final RegExp _baseTag = RegExp(r'<base\b', caseSensitive: false);
  // Matches a full <base ...> tag (including self-closing).
  static final RegExp _baseTagFull =
      RegExp(r'<base\b[^>]*>', caseSensitive: false);
  // Matches the href attribute value inside a tag fragment.
  static final RegExp _hrefAttrValue = RegExp(
    r"""\bhref\s*=\s*("[^"]*"|'[^']*')""",
    caseSensitive: false,
  );
  static final RegExp _moduleScriptTag = RegExp(
    r"""<script\b[^>]*\btype\s*=\s*["']module["'][^>]*>""",
    caseSensitive: false,
  );
  static final RegExp _importMapTag = RegExp(
    r"""<script\b[^>]*\btype\s*=\s*["']importmap["'][^>]*>([\s\S]*?)</script>""",
    caseSensitive: false,
  );

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

  /// Ensures a `<base href="...">` tag exists with an **absolute** URL.
  ///
  /// - If no `<base>` tag exists: injects one pointing to [baseUrl].
  /// - If a `<base>` tag exists but its `href` is relative (e.g. `href="/"`),
  ///   rewrites it to absolute by resolving against [baseUrl].
  /// - If a `<base>` tag already has an absolute `href`: leaves it unchanged.
  static String injectBaseTagIfMissing(String html, String baseUrl) {
    if (html.isEmpty) return html;

    final uri = Uri.tryParse(baseUrl);
    final parsed = uri ?? Uri.parse(baseUrl);
    final safeBaseUrl = parsed.hasFragment
        ? parsed.toString().split('#').first
        : parsed.toString();

    if (_baseTag.hasMatch(html)) {
      // A <base> tag already exists – ensure its href is absolute.
      return html.replaceFirstMapped(_baseTagFull, (tagMatch) {
        final wholeTag = tagMatch.group(0)!;
        final hrefMatch = _hrefAttrValue.firstMatch(wholeTag);
        if (hrefMatch == null) return wholeTag; // no href attr – leave as-is

        final hrefToken = hrefMatch.group(1)!;
        final quote = hrefToken[0];
        final href = hrefToken.substring(1, hrefToken.length - 1);

        // Already absolute – nothing to change.
        if (href.startsWith('http://') || href.startsWith('https://')) {
          return wholeTag;
        }

        // Resolve relative href to absolute.
        final absolute = parsed.resolve(href).toString();
        final safeAbsolute =
            absolute.contains('#') ? absolute.split('#').first : absolute;
        // Replace only the quoted value inside the existing tag.
        return wholeTag.replaceFirst(hrefToken, '$quote$safeAbsolute$quote');
      });
    }

    // No <base> tag at all – inject one after <head>.
    final baseTagStr = '<base href="$safeBaseUrl">';
    if (_headTag.hasMatch(html)) {
      return html.replaceFirstMapped(_headTag, (match) {
        return '${match.group(0)}$baseTagStr';
      });
    }

    return '$baseTagStr$html';
  }

  /// Returns `true` when the HTML payload appears to rely on module/import-map
  /// loading semantics where query-style proxy URLs can break relative imports.
  static bool requiresPathFriendlyProxy(String html) {
    if (html.isEmpty) return false;
    return _moduleScriptTag.hasMatch(html) || _importMapTag.hasMatch(html);
  }

  /// Returns `true` when the proxy base is query-parameter style
  /// (e.g. `...proxy?url=`) instead of path-prefix style.
  static bool isQueryStyleProxyBase(String proxyBase) {
    return proxyBase.contains('?');
  }

  /// Builds a proxied URL for a target absolute URL.
  ///
  /// Supported proxy patterns:
  /// - query style: `https://proxy.example/?url=`
  /// - path style: `https://proxy.example/`
  /// - template style: `https://proxy.example/{url}`
  static String buildProxiedUrl(String proxyBase, String targetAbsoluteUrl) {
    if (proxyBase.contains('{url}')) {
      return proxyBase.replaceAll(
          '{url}', Uri.encodeComponent(targetAbsoluteUrl));
    }
    if (isQueryStyleProxyBase(proxyBase)) {
      return '$proxyBase${Uri.encodeComponent(targetAbsoluteUrl)}';
    }
    return '$proxyBase$targetAbsoluteUrl';
  }

  /// Rewrites external resource URLs (`src`, `href`, `poster`, `srcset`) and
  /// import-map values to use the selected proxy endpoint.
  static String rewriteHtmlResourceUrlsForProxy(
    String html, {
    required String originalUrl,
    required String proxyBase,
  }) {
    if (html.isEmpty) return html;
    final baseUri = Uri.tryParse(originalUrl);
    if (baseUri == null) return html;

    String proxify(String candidate) {
      final value = candidate.trim();
      if (value.isEmpty ||
          value.startsWith('#') ||
          value.startsWith('data:') ||
          value.startsWith('blob:') ||
          value.startsWith('javascript:') ||
          value.startsWith('mailto:') ||
          value.startsWith('tel:') ||
          value.startsWith('about:')) {
        return candidate;
      }

      final resolved = baseUri.resolve(value).toString();
      return buildProxiedUrl(proxyBase, resolved);
    }

    var updated = html.replaceAllMapped(
      RegExp(
        r"""\b(href|src|poster)\s*=\s*("[^"]*"|'[^']*'|[^\s>]+)""",
        caseSensitive: false,
      ),
      (match) {
        final attr = match.group(1)!;
        final token = match.group(2)!;
        String rawValue = token;
        String quote = '';

        if ((token.startsWith('"') && token.endsWith('"')) ||
            (token.startsWith("'") && token.endsWith("'"))) {
          quote = token[0];
          rawValue = token.substring(1, token.length - 1);
        }

        final rewritten = proxify(rawValue);
        final valueWithQuotes =
            quote.isEmpty ? rewritten : '$quote$rewritten$quote';
        return '$attr=$valueWithQuotes';
      },
    );

    updated = updated.replaceAllMapped(
      RegExp(
        r"""\bsrcset\s*=\s*("[^"]*"|'[^']*'|[^\s>]+)""",
        caseSensitive: false,
      ),
      (match) {
        final token = match.group(1)!;
        String rawValue = token;
        String quote = '';

        if ((token.startsWith('"') && token.endsWith('"')) ||
            (token.startsWith("'") && token.endsWith("'"))) {
          quote = token[0];
          rawValue = token.substring(1, token.length - 1);
        }

        final rewrittenEntries = rawValue.split(',').map((entry) {
          final trimmed = entry.trim();
          if (trimmed.isEmpty) return trimmed;

          final parts = trimmed.split(RegExp(r'\s+'));
          final urlPart = parts.first;
          final descriptor =
              parts.length > 1 ? ' ${parts.sublist(1).join(' ')}' : '';
          return '${proxify(urlPart)}$descriptor';
        }).join(', ');

        final valueWithQuotes =
            quote.isEmpty ? rewrittenEntries : '$quote$rewrittenEntries$quote';
        return 'srcset=$valueWithQuotes';
      },
    );

    updated = updated.replaceAllMapped(_importMapTag, (match) {
      final rawJson = (match.group(1) ?? '').trim();
      if (rawJson.isEmpty) return match.group(0)!;

      try {
        final dynamic decoded = json.decode(rawJson);
        if (decoded is! Map) return match.group(0)!;

        final imports = decoded['imports'];
        if (imports is Map) {
          imports.forEach((key, value) {
            if (value is String) {
              imports[key] = proxify(value);
            }
          });
        }

        final encoded = json.encode(decoded);
        return match.group(0)!.replaceFirst(rawJson, encoded);
      } catch (_) {
        return match.group(0)!;
      }
    });

    return updated;
  }

  /// Injects a small compatibility patch for proxied documents rendered from
  /// `data:` origin, preventing hard failures on unsupported APIs.
  static String injectProxyCompatibilityScript(String html) {
    if (html.isEmpty) return html;

    const marker = 'data-swebview-proxy-compat';
    if (html.contains(marker)) return html;

    // The script patches six things that break when a page is served from a
    // data: URL (null origin):
    //
    // 1. Service-worker registration — SW scope must match origin; fails silently.
    // 2. IndexedDB — browsers block IDBFactory.open() from null origin and throw
    //    a synchronous SecurityError. We patch IDBFactory.prototype.open with a
    //    tiny in-memory shim that resolves successfully for common get/put paths.
    //    This helps feature-gated plugins that only need lightweight persistence.
    // 3. history.replaceState / pushState — cannot push external URLs from null
    //    origin; we wrap both and swallow the SecurityError.
    // 4. "Unlegal embed" overlay — some apps (e.g. Windy) check
    //    window.location.origin and show a blocking overlay when it is not their
    //    own domain. We inject CSS and also continuously force-hide the node
    //    because page JS can toggle inline styles after load.
    // 5. API proxy rewriting — when a page makes cross-origin API calls (e.g.,
    //    Axios to dir.aviapages.com), the null origin blocks them. We extract
    //    the proxy base from the injected <base> tag and rewrite fetch/XHR/Axios
    //    requests to *.aviapages.com URLs through that same proxy.
    // 6. Known benign noisy errors (Unlegal embed / IDBFactory / gl-particles)
    //    are swallowed to reduce console spam while keeping page execution alive.
    const script = '<script $marker="1">(function(){try{'
        'var _stats=(window.__swebviewCompatStats&&typeof window.__swebviewCompatStats==="object")'
        '?window.__swebviewCompatStats:{errors:0,swallowedErrors:0,unhandledRejections:0,pluginFailures:0,messages:[]};'
        'window.__swebviewCompatStats=_stats;'
        'var _pushMsg=function(m){try{m=String(m||"");_stats.messages.push(m);'
        'if(_stats.messages.length>25)_stats.messages.splice(0,_stats.messages.length-25);}catch(e){}};'
        // Extract proxy base from <base> tag for API rewriting
        'var _proxyBase="";'
        'try{var b=document.querySelector("base[href]");'
        'if(b&&b.href){'
        'var m=b.href.match(/^(https?:\\/\\/[^\\/]+(?:\\/[^\\/]+)*(?:\\?[^=]+=)?)/);'
        'if(m)_proxyBase=m[1];'
        '}}catch(e){}'
        // 1. Service workers
        'if(typeof navigator!=="undefined"&&"serviceWorker" in navigator){'
        'navigator.serviceWorker.register=function(){'
        'return Promise.reject(new Error("sw-disabled-proxy"));};}'
        // 2. IndexedDB
        'if(typeof IDBFactory!=="undefined"&&window.indexedDB){'
        'var _o=IDBFactory.prototype.open;'
        'var _dbMem={};'
        'var _mkReq=function(result,error){'
        'var r={readyState:"pending",result:undefined,error:error||null,'
        'onsuccess:null,onerror:null,onblocked:null,onupgradeneeded:null};'
        'setTimeout(function(){'
        'r.readyState="done";'
        'if(error){if(typeof r.onerror==="function")r.onerror({target:r,type:"error"});return;}'
        'r.result=result;'
        'if(typeof r.onsuccess==="function")r.onsuccess({target:r,type:"success"});'
        '},0);'
        'return r;};'
        'var _mkStore=function(name){'
        'if(!_dbMem[name])_dbMem[name]={};'
        'var s=_dbMem[name];'
        'return {'
        'get:function(k){return _mkReq(s[String(k)]);},'
        'put:function(v,k){if(typeof k==="undefined"&&v&&typeof v==="object"&&("id" in v))k=v.id;'
        's[String(k)]=v;return _mkReq(k);},'
        'add:function(v,k){if(typeof k==="undefined"&&v&&typeof v==="object"&&("id" in v))k=v.id;'
        'if(s.hasOwnProperty(String(k)))return _mkReq(undefined,new Error("ConstraintError"));'
        's[String(k)]=v;return _mkReq(k);},'
        'delete:function(k){delete s[String(k)];return _mkReq(undefined);},'
        'clear:function(){for(var p in s){if(Object.prototype.hasOwnProperty.call(s,p))delete s[p];}return _mkReq(undefined);}'
        '};};'
        'var _storeNames=[];'
        'var _ensureStore=function(n){'
        'n=String(n);'
        'if(_storeNames.indexOf(n)===-1)_storeNames.push(n);'
        'if(!_dbMem[n])_dbMem[n]={};'
        '};'
        'var _dropStore=function(n){'
        'n=String(n);'
        'delete _dbMem[n];'
        'var i=_storeNames.indexOf(n);'
        'if(i!==-1)_storeNames.splice(i,1);'
        '};'
        'var _mkStoreNamesObj=function(){return {'
        'contains:function(n){return _storeNames.indexOf(String(n))!==-1;},'
        'item:function(i){return _storeNames[i]||null;},'
        'get length(){return _storeNames.length;}'
        '};};'
        'var _mkDb=function(){return {'
        'close:function(){},'
        'get objectStoreNames(){return _mkStoreNamesObj();},'
        'createObjectStore:function(n){_ensureStore(n);return _mkStore(n);},'
        'deleteObjectStore:function(n){_dropStore(n);},'
        'transaction:function(names){'
        'var list=Array.isArray(names)?names:[names];'
        'for(var i=0;i<list.length;i++){_ensureStore(list[i]);}'
        'return {'
        'oncomplete:null,onerror:null,onabort:null,'
        'objectStore:function(n){_ensureStore(n);if(list.indexOf(n)===-1)list.push(n);return _mkStore(n);}'
        '};'
        '}'
        '};};'
        'IDBFactory.prototype.open=function(){'
        'try{return _o.apply(this,arguments);}catch(e){'
        'var req=_mkReq(_mkDb());'
        'setTimeout(function(){if(typeof req.onupgradeneeded==="function")req.onupgradeneeded({target:req,type:"upgradeneeded"});},0);'
        'return req;}};}'
        // 3. history
        'if(typeof history!=="undefined"){'
        'var _rs=history.replaceState;'
        'history.replaceState=function(s,t,u){try{_rs.call(history,s,t,u);}catch(e){}};'
        'var _ps=history.pushState;'
        'history.pushState=function(s,t,u){try{_ps.call(history,s,t,u);}catch(e){}};}'
        // 4. Keep windy "unlegal-embed" overlay hidden even if script toggles it
        'var _hideUE=function(){try{var n=document.getElementById("unlegal-embed");'
        'if(n){n.style.setProperty("display","none","important");'
        'n.setAttribute("aria-hidden","true");}}catch(e){}};'
        '_hideUE();setInterval(_hideUE,500);'
        // 3.5 API proxy rewriting for cross-origin API calls (Axios/fetch)
        'if(_proxyBase){'
        'var _rewriteApiUrl=function(u){try{u=String(u||"");'
        'if((u.indexOf("dir.aviapages.com")!==-1||u.indexOf("api.aviapages.com")!==-1)'
        '&&(u.indexOf("http://")===0||u.indexOf("https://")===0)){'
        'return _proxyBase+encodeURIComponent(u);'
        '}}catch(e){}_pushMsg("API rewrite failed: "+e);}return u;};'
        // Wrap fetch()
        'if(typeof window.fetch==="function"){'
        'var _origFetch=window.fetch;'
        'window.fetch=function(r){if(typeof r==="string")r=_rewriteApiUrl(r);'
        'return _origFetch.apply(this,arguments);};'
        '}'
        // Wrap XMLHttpRequest.open()
        'if(typeof XMLHttpRequest!=="undefined"){'
        'var _origOpen=XMLHttpRequest.prototype.open;'
        'XMLHttpRequest.prototype.open=function(method,url){'
        'if(typeof url==="string")url=_rewriteApiUrl(url);'
        'return _origOpen.apply(this,arguments);};'
        '}'
        // Wrap Axios if available
        'if(typeof window.axios!=="undefined"&&window.axios){'
        'var _origRequest=window.axios.request;'
        'if(typeof _origRequest==="function"){'
        'window.axios.request=function(cfg){if(cfg&&cfg.url)cfg.url=_rewriteApiUrl(cfg.url);'
        'return _origRequest.apply(this,arguments);};'
        '}'
        '}'
        '}'
        // 5. Reduce known noisy errors in proxied data-origin mode
        'var _swallow=function(msg){msg=String(msg||"");'
        'return msg.indexOf("Unlegal embed")!==-1||'
        'msg.indexOf("IDBFactory")!==-1||'
        'msg.indexOf("gl-particles")!==-1;};'
        'var _prevOnError=window.onerror;'
        'window.onerror=function(m,s,l,c,e){'
        '_stats.errors=(_stats.errors||0)+1;'
        '_pushMsg(m||(e&&e.message)||"");'
        'if(_swallow(m)||(e&&_swallow(e.message))){_stats.swallowedErrors=(_stats.swallowedErrors||0)+1;return true;}'
        'if(typeof _prevOnError==="function"){return _prevOnError.apply(this,arguments);}'
        'return false;};'
        'window.addEventListener("unhandledrejection",function(ev){'
        '_stats.unhandledRejections=(_stats.unhandledRejections||0)+1;'
        'var r=ev&&ev.reason;var m=(r&&r.message)||r;'
        '_pushMsg(m);'
        'if(_swallow(m)){ev.preventDefault();}});'
        'if(window.console&&typeof window.console.error==="function"){'
        'var _prevErr=window.console.error.bind(window.console);'
        'window.console.error=function(){'
        'try{var a=Array.prototype.slice.call(arguments).join(" ");'
        '_pushMsg(a);if(String(a).indexOf("plugin")!==-1){_stats.pluginFailures=(_stats.pluginFailures||0)+1;}}catch(e){}'
        'return _prevErr.apply(window.console,arguments);'
        '};}'
        '}catch(_){}})();</script>'
        // 4. Unlegal-embed overlay (CSS !important beats any inline style JS may set)
        '<style $marker="1">#unlegal-embed{display:none!important}</style>';

    if (_headTag.hasMatch(html)) {
      return html.replaceFirstMapped(_headTag, (m) => '${m.group(0)}$script');
    }

    return '$script$html';
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
